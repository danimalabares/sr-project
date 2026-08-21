-- Certify the actual flat graded deformation from which the fixed-jet
-- Maurer--Cartan induction starts.
--
-- The frozen referee packet separately verifies q(y)=0, kappa_3(y)=0, and
-- exports the sixteen equations modulo s^3.  Here we retain the order-three
-- family and relation lifts, specialize them along t=s*y, and check the
-- deformation equation directly over QQ[s]/(s^4).

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

T1 = CT^1(0,F0);
T2 = CT^2(0,F0);
assert(numRows T1 == 16 and numColumns T1 == 53);
assert(numRows T2 == 30 and numColumns T2 == 27);

(F,R,G,C) = versalDeformation(
  F0,T1,T2,HighestOrder=>3,SmartLift=>false,DefParam=>t);
assert(#F == 4 and #R == 4 and #G == 2 and #C == 2);

y = {
  1,3,1,2,6,1,1,1,1,1,21,28,1,5,10,55,66,15,1,18,2,35,42,1,4,10,1,
  25,12,30,5,33,44,1,6,3,14,7,1,9,1,6,12,20,1,4,22,1,15,1,1,8,11};
assert(#y == 53);

parameterRing = ring F#0;
Q = K[s,z_1..z_8,Degrees=>({0}|toList(8:1))]/ideal(s^4);
qVariables = gens Q;
specialize = map(Q,parameterRing,
  apply(y,coefficient -> coefficient*qVariables#0)
    | drop(qVariables,1));

family3 = specialize(sum F);
relations3 = specialize(sum R);
base3 = specialize(sum G);

-- This is the exact lifted-presentation equation over QQ[s]/(s^4).
assert(base3 == 0);
assert(family3*relations3 == 0);

-- R_0 is the complete first-syzygy matrix used to initialize the package,
-- not a sampled collection of relations.
specialSyzygies = gens ker F0;
assert(numColumns specialSyzygies == 30);
assert(F0*specialSyzygies == 0);
assert(R#0 == substitute(specialSyzygies,parameterRing));

-- Check directly that reducing the certified order-three family modulo s^3
-- gives the same coefficients exported by the frozen two-jet computation.
evaluateAll = map(S,parameterRing,y | gens S);
firstOrder = evaluateAll F#1;
secondOrder = evaluateAll F#2;
Q2 = K[r,w_1..w_8,Degrees=>({0}|toList(8:1))]/ideal(r^3);
q2Variables = gens Q2;
reduceToTwoJet = map(Q2,Q,
  {q2Variables#0} | drop(q2Variables,1));
family2 = reduceToTwoJet family3;
embedSpecialFiber = map(Q2,S,drop(q2Variables,1));
expected2 = embedSpecialFiber F0 +
  q2Variables#0 * embedSpecialFiber firstOrder +
  q2Variables#0^2 * embedSpecialFiber secondOrder;
assert(family2 == expected2);

-- Regenerate the frozen text format and compare every byte with the actual
-- incidence input, rather than merely comparing two expressions derived in
-- this run.
generatedTwoJetPath = "verification/starting_twojet_QQ.txt";
generatedTwoJet = generatedTwoJetPath;
generatedTwoJet << "" << flush;
scan(16,index ->
  generatedTwoJet << toString index << "|"
    << toString firstOrder_(0,index) << "|"
    << toString secondOrder_(0,index) << endl << flush);
frozenTwoJetPath = "../referee-packet/data/universal_2jet_QQ.txt";
assert(get generatedTwoJetPath == get frozenTwoJetPath);

certificatePath = "verification/starting_jet_QQ.txt";
out = certificatePath;
out << "" << flush;
out << "field=QQ" << endl;
out << "macaulay2_required=1.20" << endl;
out << "VersalDeformations_version=3.0" << endl;
out << "base=QQ[s]/(s^4)" << endl;
out << "family_generators=16" << endl;
out << "complete_special_first_syzygies=30" << endl;
out << "quadratic_and_cubic_base_terms_at_y_zero=true" << endl;
out << "specialized_family_times_relations_zero=true" << endl;
out << "reduction_mod_s3_is_exported_two_jet=true" << endl;
out << "two_jet_sha256=40e64e61674b6a4e61f1ea6822dc79327bf4ba397285f84ed8738c4c18cd1795" << endl;
out << flush;

print("starting three-jet deformation equation verified over QQ[s]/(s^4)");
print("certificate=" | certificatePath);
exit 0;
