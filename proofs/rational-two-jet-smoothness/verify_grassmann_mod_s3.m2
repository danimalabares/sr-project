-- Exact truncated singular-incidence membership on one affine x-chart and
-- one standard Gr(4,7) chart.  A zero remainder proves that s^2 lies in the
-- incidence ideal modulo s^3.  Run verify_grassmann_all.py to cover all
-- 8*35 pairs over QQ and retry the few degree-six inconclusives at degree 8.
--
-- VERIFY_LIFT=1 asks Macaulay2 to retain its change matrix and verifies an
-- explicit identity in the original 240 module columns.  It is much slower;
-- a zero remainder without this option is already an exact membership proof,
-- since every partial Groebner-basis element is an exact input combination.

xChartText = getenv "X_CHART";
if xChartText === null or #xChartText == 0 then xChartText = "1";
xChart = value xChartText;
pivotChartText = getenv "GRASSMANN_CHART";
if pivotChartText === null or #pivotChartText == 0 then pivotChartText = "1";
pivotChart = value pivotChartText;
assert(1 <= xChart and xChart <= 8);
assert(1 <= pivotChart and pivotChart <= 35);
scoutGF = getenv "SCOUT_GF" === "1";
baseField = if scoutGF then ZZ/32003 else QQ;
verifyLift = getenv "VERIFY_LIFT" === "1";

S = baseField[x_1..x_8];
I = ideal(
  x_6*x_7*x_8, x_4*x_6*x_8, x_3*x_7*x_8, x_3*x_5*x_7,
  x_3*x_4*x_8, x_2*x_7*x_8, x_2*x_5*x_7, x_2*x_5*x_6,
  x_2*x_4*x_7, x_2*x_4*x_6, x_1*x_4*x_6, x_1*x_4*x_5,
  x_1*x_3*x_8, x_1*x_3*x_6, x_1*x_3*x_5, x_1*x_2*x_5);
F0 = gens I;
inputPath = "proofs/rational-two-jet-smoothness/universal_2jet_QQ.txt";
rawLines = select(lines get inputPath,line -> #line > 0);
assert(#rawLines == 16);
piecesByLine = apply(rawLines,line -> separate("\\|",line));
assert(apply(piecesByLine,pieces -> value pieces#0) == toList(0..15));
g = matrix {apply(piecesByLine,pieces -> value pieces#1)};
h = matrix {apply(piecesByLine,pieces -> value pieces#2)};
assert(numRows g == 1 and numColumns g == 16);
assert(numRows h == 1 and numColumns h == 16);

T0 = baseField[s,z1,z2,z3,z4,z5,z6,z7,
  k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,
  MonomialOrder=>GRevLex];
T = T0 / ideal(s^3);
use T;
zvars = (gens T)_{1..7};
kvars = (gens T)_{8..19};
imageVars = {};
zindex = 0;
scan(toList(1..8),i -> (
  if i == xChart then imageVars = append(imageVars,1_T)
  else (
    imageVars = append(imageVars,zvars#zindex);
    zindex = zindex + 1;
    );
  ));
phi = map(T,S,imageVars);
Ft = phi F0 + s*phi g + s^2*phi h;

allPivotRows = subsets(toList(0..6),4);
pivotRows = allPivotRows#(pivotChart-1);
freeRows = select(toList(0..6),i -> not member(i,pivotRows));
kernelMatrix = matrix apply(toList(0..6),i ->
  apply(toList(0..3),j -> (
    if i == pivotRows#j then 1_T
    else if member(i,pivotRows) then 0_T
    else kvars#(4*position(freeRows,q -> q == i)+j)
    )));
fullJacobian = jacobian ideal Ft;
xJacobian = submatrix(fullJacobian,{1..7},toList(0..15));
kernelEquations = transpose(xJacobian) * kernelMatrix;
qs = flatten entries Ft | flatten entries kernelEquations;

B = baseField[y1,y2,y3,y4,y5,y6,y7,
  a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,
  MonomialOrder=>GRevLex];
rho = map(B,T,{0_B} | gens B);
coefficientMatrix = matrix apply(3,a -> apply(qs,q -> (
  if a == 0 then rho q
  else if a == 1 then rho diff(s,q)
  else (1/2) * rho diff(s,diff(s,q))
  )));
n = numColumns coefficientMatrix;
zeroRow = matrix {toList(n:0_B)};
C0 = submatrix(coefficientMatrix,{0},toList(0..n-1));
C1 = submatrix(coefficientMatrix,{1},toList(0..n-1));
moduleGenerators = coefficientMatrix |
  (zeroRow || C0 || C1) |
  (zeroRow || zeroRow || C0);
membershipTarget = matrix {{0_B},{0_B},{1_B}};

print("x_chart=" | toString xChart);
print("pivot_chart=" | toString pivotChart);
print("pivots=" | toString pivotRows);
print("coefficient_field=" | toString baseField);
print("incidence_generators=" | toString(#qs));
print("module_columns=" | toString numColumns moduleGenerators);
degreeBoundText = getenv "DEGREE_LIMIT";
if degreeBoundText === null or #degreeBoundText == 0 then degreeBoundText = "6";
scan({value degreeBoundText},degreeBound -> (
  moduleBasis := gb(moduleGenerators,DegreeLimit=>{degreeBound},
    ChangeMatrix=>verifyLift);
  targetRemainder := membershipTarget % moduleBasis;
  print("degree_limit=" | toString degreeBound |
    " remainder_zero=" | toString(targetRemainder == 0));
  if targetRemainder == 0 then (
    if verifyLift then (
      originalCoefficients := membershipTarget // moduleBasis;
      assert(moduleGenerators * originalCoefficients == membershipTarget);
      print("lift_verified=true");
      print("lift_nonzero_coefficients=" | toString(#(select(
        flatten entries originalCoefficients,p -> p != 0))));
      );
    print("membership_proved=true");
    exit 0;
    );
  ));
print("membership_proved=false");
exit 2;
