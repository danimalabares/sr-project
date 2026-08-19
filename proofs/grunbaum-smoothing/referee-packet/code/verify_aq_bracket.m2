-- Compute the intrinsic tangent-Lie bracket
--
--       [y,-] : T^2_0(A) --> T^3_0(A)
--
-- for the explicit rational direction y.  This uses a semi-free
-- commutative DG algebra resolution of A, not Yoneda multiplication.

needsPackage "DGAlgebras";
needsPackage "VersalDeformations";
assert((options DGAlgebras)#Version == "1.1.0");
assert((options VersalDeformations)#Version == "3.0");
setRandomSeed 0;
debug DGAlgebras;

K = QQ;
S = K[x_1..x_8];
I = ideal(
  x_6*x_7*x_8, x_4*x_6*x_8, x_3*x_7*x_8, x_3*x_5*x_7,
  x_3*x_4*x_8, x_2*x_7*x_8, x_2*x_5*x_7, x_2*x_5*x_6,
  x_2*x_4*x_7, x_2*x_4*x_6, x_1*x_4*x_6, x_1*x_4*x_5,
  x_1*x_3*x_8, x_1*x_3*x_6, x_1*x_3*x_5, x_1*x_2*x_5);
A = S/I;
F0 = gens I;

-- Avoid DGAlgebras' eager construction of the entire 16-generator Koszul
-- complex.  Only homological degrees 1, 2, and 3 are needed here.
generatorDegrees = apply(flatten entries F0, entry -> {1} | degree entry);
E = freeDGAlgebra(S,generatorDegrees);
E = setDiff(E,I_*,InitializeComplex=>false);
E = killCycles(E,StartDegree=>1);
E = killCycles(E,StartDegree=>2);

dgGenerators = gens E.natural;
e = take(dgGenerators,16);
f = take(drop(dgGenerators,16),30);
g = drop(dgGenerators,46);
assert(#e == 16 and #f == 30 and #g == 136);
assert(all(f,z -> degree z === {2,4}));
assert(#select(g,z -> degree z === {3,5}) == 16);
assert(#select(g,z -> degree z === {3,6}) == 120);

-- A homogeneous derivation of homological degree p.  Values on the free DG
-- generators determine it; coefficients in S are fixed.  This is the same
-- signed Leibniz implementation used by DGAlgebras for its differential,
-- with the sign multiplied by p.
applyDerivationToMonomial = (values,p,m) -> (
  monomialPart := first flatten entries first coefficients m;
  coefficientPart := substitute(
    first flatten entries last coefficients m, ring m);
  monomialSupport := support monomialPart;
  monomialExponents := select(first exponents monomialPart, exponent ->
    exponent > 0);
  supportPowers := apply(#monomialSupport,index ->
    (monomialSupport#index)^(monomialExponents#index));
  sum apply(#monomialSupport,index -> (
    generatorIndex := first positions(dgGenerators,variable ->
      variable === monomialSupport#index);
    signExponent := p * sum apply(index,previous ->
      (first degree monomialSupport#previous)
        * monomialExponents#previous);
    coefficientPart * (-1)^signExponent
      * product take(supportPowers,index)
      * values#generatorIndex
      * monomialExponents#index
      * (monomialSupport#index)^(monomialExponents#index-1)
      * product drop(supportPowers,index+1)
    )));

applyDerivation = (values,p,polynomial) -> sum apply(
  terms polynomial, term -> applyDerivationToMonomial(values,p,term));

zeroInE = 0_(E.natural);
toE = value -> substitute(value,E.natural);
toS = value -> lift(value,S);

-- The fixed tangent direction in Macaulay2's CT^1 coordinates.
rationalPoint = {
  1,3,1,2,6,1,1,1,1,1,21,28,1,5,10,55,66,15,1,18,2,35,42,1,4,10,1,
  25,12,30,5,33,44,1,6,3,14,7,1,9,1,6,12,20,1,4,22,1,15,1,1,8,11};
T1 = CT^1(0,F0);
T2 = CT^2(0,F0);
assert(numRows T1 == 16 and numColumns T1 == 53);
assert(numRows T2 == 30 and numColumns T2 == 27);
y = transpose matrix(S,{rationalPoint});
thetaEvaluesS = T1*y;

-- Lift y from Der(E,A) to a closed degree-one derivation of E through the
-- degree-two generators.  For d(f_j)=sum_i r_ij e_i, closure is
-- d(theta(f_j))+theta(d(f_j))=0.
relationMatrix = matrix apply(16,row -> apply(30,column ->
  toS contract(e#row,diff(E,f#column))));
packageRelationMatrix = gens ker F0;
relationMap = map(target packageRelationMatrix,source packageRelationMatrix,
  relationMatrix);
relationChange = relationMap//packageRelationMatrix;
assert(packageRelationMatrix*relationChange == relationMap);
assert(rank relationChange == 30);
assert(isUnit det relationChange);
assert(det relationChange == 1_K);
assert(all(flatten entries relationChange,
  entry -> entry == 0 or degree entry === {0}));
-- CT^2 uses packageRelationMatrix, whereas f uses relationMatrix.  The
-- versal equations are paired with NT2, the canonical reduction of CT^2
-- modulo relation changes (RACTION), so reproduce that reduction exactly.
ambientA = coker F0;
relationAction = map(ambientA^30,S^16,
  Hom(packageRelationMatrix,ambientA));
NT2 = matrix(map(ambientA^30,source T2,T2)%relationAction);
-- If relationMatrix=packageRelationMatrix*U, a cochain's values transform by
-- h_f=transpose(U)*h_package.
T2onF = transpose relationChange*NT2;
thetaDf = transpose relationMatrix * thetaEvaluesS;
thetaFCoefficients = (-transpose thetaDf)//F0;
assert(F0*thetaFCoefficients == -transpose thetaDf);
thetaFvalues = apply(30,column -> sum apply(16,row ->
  toE(thetaFCoefficients_(row,column))*e#row));
thetaValuesThroughF = ((apply(16,row -> toE thetaEvaluesS_(row,0)))
  | thetaFvalues | (toList(136:zeroInE)));

-- Lift theta over the degree-three generators.  This is needed because the
-- bracket on a degree-three generator contains eta(theta(g)).
thetaDgValues = apply(g,z -> applyDerivation(thetaValuesThroughF,1,diff(E,z)));
thetaDgMatrix = matrix apply(16,row -> apply(136,column ->
  toS contract(e#row,thetaDgValues#column)));
basis2 = flatten entries getBasis(2,E);
D2 = polyDifferential(2,E);
assert(numRows D2 == 16 and numColumns D2 == #basis2);
thetaDgMap = map(target D2,S^(apply(g,z -> {-last degree z})),thetaDgMatrix);
thetaGCoefficients = (-thetaDgMap)//D2;
assert(D2*thetaGCoefficients == -thetaDgMap);
thetaGvalues = apply(136,column -> sum apply(#basis2,row ->
  toE(thetaGCoefficients_(row,column))*basis2#row));

-- The linear part d(g) -> f is the differential C^2 -> C^3 in
-- Der(E,A).  It is also used below to quotient degree-three coboundaries.
delta2Matrix = matrix apply(136,row -> apply(30,column ->
  toS contract(f#column,diff(E,g#row))));
assert(sub(delta2Matrix*T2onF,A) == 0);
thetaGLinearF = matrix apply(30,row -> apply(136,column ->
  toS contract(f#row,thetaGvalues#column)));

-- For every CT^2 basis cocycle eta, lift eta through g and compute
-- [theta,eta](g)=theta(eta(g))-eta(theta(g)).
bracketColumns = apply(27,etaIndex -> (
  etaFvaluesS := T2onF_{etaIndex};
  etaDgValuesS := delta2Matrix * etaFvaluesS;
  etaGCoefficients := (transpose etaDgValuesS)//F0;
  assert(F0*etaGCoefficients == transpose etaDgValuesS);
  thetaEtaG := transpose thetaEvaluesS * etaGCoefficients;
  etaThetaG := transpose etaFvaluesS * thetaGLinearF;
  transpose(thetaEtaG-etaThetaG)
  ));
bracketMatrix = matrix apply(136,row -> apply(27,column ->
  (bracketColumns#column)_(row,0)));
assert(numRows bracketMatrix == 136 and numColumns bracketMatrix == 27);

-- Compute independence modulo all degree-three coboundaries.  The cocycle
-- assertion here is not an assumption about this truncated model.  Complete
-- E to an acyclic Tate resolution E_infinity.  A degree-p derivation already
-- closed through generator degree 3 extends without changing its old values:
-- for each new degree-n generator z, closure asks for d(theta(z)) equal to a
-- signed theta(dz).  The right side is a cycle in degree n-p-1.  For p=1,2
-- and n>=4 this degree is positive, hence it is a boundary in E_infinity.
-- (The degree-zero initial cases were solved explicitly above.)  Thus theta
-- and every eta extend to globally closed derivations.  Their commutators
-- are globally closed, and the 136 entries computed above are genuine C^3
-- cocycles.  Consequently H^3 injects into C^3/im(delta2), so independence
-- in the following cokernel is exactly independence in T^3.
gInternalDegrees = apply(g,z -> last degree z);
C3 = A^(apply(gInternalDegrees,d -> {-d}));
C2 = A^(toList(30:{-4}));
delta2 = map(C3,C2,sub(delta2Matrix,A));
delta1 = map(C2,A^(toList(16:{-3})),sub(transpose relationMatrix,A));
T2cocycles = map(C2,A^27,sub(T2onF,A));
assert(delta2*delta1 == 0);
assert(delta2*T2cocycles == 0);
-- The 27 displayed columns are independent modulo boundaries in degree zero.
T2classesDirect = map(coker delta1,A^27,sub(T2onF,A));
assert(numColumns basis(0,image T2classesDirect) == 27);
-- After quotienting by both boundaries and these 27 classes, no further
-- degree-zero cocycle remains.  This proves spanning without making a false
-- assertion about other internal degrees of the graded modules.
H2quotient = coker(delta1 | T2cocycles);
delta2quotient = map(C3,H2quotient,delta2);
assert(numColumns basis(0,ker delta2quotient) == 0);
bracketTarget = coker delta2;
bracketMap = map(bracketTarget,A^27,sub(bracketMatrix,A));
bracketRank = numColumns basis(0,image bracketMap);
assert(bracketRank == 12);

-- Coordinate sanity check against the quadratic Kuranishi map.  The
-- intrinsic Jacobi identity predicts ad_y o Dq_y=0.  Together with the two
-- ranks this proves ker(ad_y)=image(Dq_y), without identifying either map
-- merely from dimensions.
(versalF,versalR,versalG,versalC) = versalDeformation(
  F0,T1,T2,HighestOrder=>2,SmartLift=>false,DefParam=>t);
qOriginal = transpose versalG#0;
parameterRing = ring qOriginal;
U = K[u_1..u_53,MonomialOrder=>GRevLex];
parametersOnly = map(U,parameterRing,
  toList apply(0..52,index -> u_(index+1))
    | toList apply(0..7,index -> 0_U));
q = parametersOnly qOriginal;
evaluateAtY = map(K,U,rationalPoint);
assert(evaluateAtY q == 0);
DqY = matrix apply(27,row -> apply(53,column ->
  evaluateAtY diff(u_(column+1),q_(0,row))));
assert(rank DqY == 15);
DqYoverA = map(A^27,A^53,sub(DqY,A));
jacobiComposite = bracketMap*DqYoverA;
jacobiRank = numColumns basis(0,image jacobiComposite);
print("Jacobi composite rank=" | toString jacobiRank);
assert(jacobiRank == 0);
assert(27-bracketRank == rank DqY);

-- Compare Dq_y with the primary commutator [theta_y,theta_v] in T^2.
-- Construct every relation lift directly, so this check is independent of
-- VersalDeformations' choice of R_1.
primaryColumns = apply(53,index -> (
  psiE := T1_{index};
  psiDf := transpose relationMatrix*psiE;
  psiF := (-transpose psiDf)//F0;
  assert(F0*psiF == -transpose psiDf);
  transpose(
    transpose(thetaEvaluesS)*psiF
      + transpose(psiE)*thetaFCoefficients)
  ));
primaryMatrix = matrix apply(30,row -> apply(53,column ->
  (primaryColumns#column)_(row,0)));
C2classes = coker delta1;
primaryMap = map(C2classes,A^53,sub(primaryMatrix,A));
kuranishiMap = map(C2classes,A^53,sub(T2onF*DqY,A));
T2classMap = map(C2classes,A^27,sub(T2onF,A));
assert(numColumns basis(0,image T2classMap) == 27);
primaryCoordinates = primaryMap//T2classMap;
assert(T2classMap*primaryCoordinates == primaryMap);
print("primary minus Dq rank=" |
  toString numColumns basis(0,image(primaryMap-kuranishiMap)));
print("primary plus Dq rank=" |
  toString numColumns basis(0,image(primaryMap+kuranishiMap)));
assert(primaryMap+kuranishiMap == 0);
print("ad_y composed primary-bracket rank=" |
  toString numColumns basis(0,image(bracketMap*primaryCoordinates)));
assert(bracketMap*primaryCoordinates == 0);
print("primary self bracket at y zero=" |
  toString(primaryMap*map(A^53,A^1,sub(y,A)) == 0));
assert(primaryMap*map(A^53,A^1,sub(y,A)) == 0);

certificatePath = "verification/aq_bracket_QQ.txt";
out = certificatePath;
out << "" << flush;
out << "field=QQ" << endl;
out << "DGAlgebras_version=1.1.0" << endl;
out << "VersalDeformations_version=3.0" << endl;
out << "model=semi-free_commutative_DG_algebra_resolution" << endl;
out << "degree1_generators=16" << endl;
out << "degree2_generators=30" << endl;
out << "degree3_internal5_generators=16" << endl;
out << "degree3_internal6_generators=120" << endl;
out << "T2_degree_zero_dimension=27" << endl;
out << "relation_change_determinant=1" << endl;
out << "T2_columns_closed=true" << endl;
out << "T2_independent_classes_mod_boundaries=27" << endl;
out << "T2_remaining_degree_zero_cocycles=0" << endl;
out << "direction=explicit_rational_53_vector" << endl;
out << "rank_commutator_columns_mod_delta2=12" << endl;
out << "rank_Dq_y=15" << endl;
out << "commutator_composed_Dq_y_zero=true" << endl;
out << "primary_bracket_plus_Dq_y_zero=true" << endl;
out << "primary_self_bracket_at_y_zero=true" << endl;
out << flush;

print("rank commutator columns modulo delta2=" | toString bracketRank);
print("rank Dq_y=" | toString rank DqY);
print("certificate=" | certificatePath);
exit 0;
