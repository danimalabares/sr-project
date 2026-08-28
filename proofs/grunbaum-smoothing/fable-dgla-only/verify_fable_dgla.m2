-- Independent exact checks for the strict dg Lie proof in
-- fable-dgla-only/PROOF_DGLA.tex.  All arithmetic is exact over QQ.
--
-- This script re-derives, in one run:
--   (1) the relative/absolute controller dimensions 109 / 56 / 53;
--   (2) the order-three versal package data specialized along t = s*y;
--   (3) the deformation equation F^[3] * Q^[3] = 0 over QQ[s]/(s^4);
--   (4) completeness of the thirty special first syzygies;
--   (5) NEW: internal-weight homogeneity of every family correction
--       (x-degree 3) and every relation correction (x-degree 1), which is
--       the weight-zero property of the truncated Maurer--Cartan element;
--   (6) the identity  first-order coefficient = T1 * y, tying the linear
--       coefficient of the constructed differential to the class y;
--   (7) byte identity of the regenerated two-jet with the frozen
--       incidence input.

needsPackage "VersalDeformations";
assert((options VersalDeformations)#Version == "3.0");
setRandomSeed 0;

K = QQ;
S = K[x_1..x_8];
I = ideal(
  x_6*x_7*x_8, x_4*x_6*x_8, x_3*x_7*x_8, x_3*x_5*x_7,
  x_3*x_4*x_8, x_2*x_7*x_8, x_2*x_5*x_7, x_2*x_5*x_6,
  x_2*x_4*x_7, x_2*x_4*x_6, x_1*x_4*x_6, x_1*x_4*x_5,
  x_1*x_3*x_8, x_1*x_3*x_6, x_1*x_3*x_5, x_1*x_2*x_5);
F0 = gens I;
A = S/I;

-- (1) controller dimensions.  H^1 of the relative controller Der_S(P,P)_0
-- is Hom_S(I,A)_0; the absolute H^1 is its quotient by the coordinate
-- (Jacobian) boundaries.
relativeBasis = ambient basis(0,Hom(I,A));
jacobianMap = transpose substitute(jacobian F0,A);
T1 = CT^1(0,F0);
T2 = CT^2(0,F0);
relativeDimension = numColumns relativeBasis;
jacobianImageDimension = numColumns basis(0,image jacobianMap);
absoluteDimension = numColumns T1;
assert(numRows T1 == 16 and numColumns T1 == 53);
assert(numRows T2 == 30 and numColumns T2 == 27);
assert(relativeDimension == 109);
assert(jacobianImageDimension == 56);
assert(absoluteDimension == 53);
assert(relativeDimension - jacobianImageDimension == absoluteDimension);

-- (2) the order-three package data at the fixed rational direction.
y = {
  1,3,1,2,6,1,1,1,1,1,21,28,1,5,10,55,66,15,1,18,2,35,42,1,4,10,1,
  25,12,30,5,33,44,1,6,3,14,7,1,9,1,6,12,20,1,4,22,1,15,1,1,8,11};
assert(#y == 53);
(F,R,G,C) = versalDeformation(
  F0,T1,T2,HighestOrder=>3,SmartLift=>false,DefParam=>t);
assert(#F == 4 and #R == 4 and #G == 2 and #C == 2);

parameterRing = ring F#0;
Q = K[s,z_1..z_8,Degrees=>({0}|toList(8:1))]/ideal(s^4);
qVariables = gens Q;
specialize = map(Q,parameterRing,
  apply(y,coefficient -> coefficient*qVariables#0)
    | drop(qVariables,1));

family3 = specialize(sum F);        -- F^[3], 1 x 16 over QQ[s]/(s^4)
relations3 = specialize(sum R);     -- Q^[3], 16 x 30
base3 = specialize(sum G);

-- (3) the exact lifted deformation equation and base equations at y.
assert(base3 == 0);
assert(family3*relations3 == 0);

-- (4) Q_0 is the complete thirty-column first-syzygy matrix of F_0.
specialSyzygies = gens ker F0;
assert(numColumns specialSyzygies == 30);
assert(F0*specialSyzygies == 0);
assert(R#0 == substitute(specialSyzygies,parameterRing));

-- (5) NEW: internal-weight homogeneity.  The variable s has degree 0 and
-- each z_i degree 1, so these assertions state that every specialized
-- family entry is homogeneous of x-degree 3 and every specialized relation
-- entry is homogeneous of x-degree 1.  This is exactly the statement that
-- the truncated Maurer--Cartan element has internal weight zero: it sends
-- the weight-3 generators e_i into weight-3 cubics and the weight-4
-- generators f_j into weight-1 multiples of the e_i.
assert(all(flatten entries family3,
  p -> p != 0 and isHomogeneous p and degree p === {3}));
assert(all(flatten entries relations3,
  p -> p == 0 or (isHomogeneous p and degree p === {1})));

-- (6) the linear coefficient of the constructed differential has e-values
-- T1*y, hence absolute cohomology class y.
evaluateAll = map(S,parameterRing,y | gens S);
firstOrder = evaluateAll F#1;
secondOrder = evaluateAll F#2;
yColumn = transpose matrix(S,{y});
assert(firstOrder == transpose(T1*yColumn));

-- (7) regenerate the frozen two-jet text and compare every byte.
generatedTwoJetPath = "verification/fable_twojet_QQ.txt";
generatedTwoJet = generatedTwoJetPath;
generatedTwoJet << "" << flush;
scan(16,index ->
  generatedTwoJet << toString index << "|"
    << toString firstOrder_(0,index) << "|"
    << toString secondOrder_(0,index) << endl << flush);
frozenTwoJetPath = "../referee-packet/data/universal_2jet_QQ.txt";
assert(get generatedTwoJetPath == get frozenTwoJetPath);

certificatePath = "verification/fable_dgla_QQ.txt";
out = certificatePath;
out << "" << flush;
out << "field=QQ" << endl;
out << "VersalDeformations_version=3.0" << endl;
out << "relative_H1_dimension=109" << endl;
out << "coordinate_boundary_image_dimension=56" << endl;
out << "absolute_H1_dimension=53" << endl;
out << "relative_minus_coordinate_equals_absolute=true" << endl;
out << "T2_degree_zero_dimension=27" << endl;
out << "base_equations_vanish_at_y_through_order_three=true" << endl;
out << "specialized_family_times_relations_zero=true" << endl;
out << "complete_special_first_syzygies=30" << endl;
out << "family_corrections_homogeneous_x_degree_3=true" << endl;
out << "relation_corrections_homogeneous_x_degree_1=true" << endl;
out << "starting_mc_linear_e_values_equal_T1_y=true" << endl;
out << "two_jet_matches_frozen_input=true" << endl;
out << flush;

print("relative H1 dimension=" | toString relativeDimension);
print("coordinate-boundary image dimension=" | toString jacobianImageDimension);
print("absolute H1 dimension=" | toString absoluteDimension);
print("family and relation corrections weight-homogeneous=true");
print("starting MC linear e-values equal T1*y=true");
print("two jet matches frozen input=true");
print("certificate=" | certificatePath);
exit 0;
