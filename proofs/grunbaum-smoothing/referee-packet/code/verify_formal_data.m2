-- Exact characteristic-zero data for the formal-arc argument.
--
-- Input: the sixteen displayed cubic monomials and the displayed 53-vector y.
-- Algorithm: VersalDeformations 3.0 computes the degree <= 3 part of a
-- homogeneous miniversal deformation with SmartLift disabled.  We evaluate
-- the quadratic and cubic base equations at y, differentiate the quadratic
-- equations, and export the corresponding family equations through s^2.

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
assert(#F == 4);
assert(#G == 2);
assert(all(G,M -> numRows M == 27 and numColumns M == 1));

rationalPoint = {
  1,3,1,2,6,1,1,1,1,1,21,28,1,5,10,55,66,15,1,18,2,35,42,1,4,10,1,
  25,12,30,5,33,44,1,6,3,14,7,1,9,1,6,12,20,1,4,22,1,15,1,1,8,11};
assert(#rationalPoint == 53);

parameterRing = ring F#0;
evaluateAll = map(S,parameterRing,rationalPoint | gens S);
firstOrder = evaluateAll F#1;
secondOrder = evaluateAll F#2;
assert(numRows firstOrder == 1 and numColumns firstOrder == 16);
assert(numRows secondOrder == 1 and numColumns secondOrder == 16);

evaluateBase = map(K,parameterRing,rationalPoint | toList(8:0_K));
assert(evaluateBase G#0 == 0);
assert(evaluateBase G#1 == 0);

qOriginal = transpose G#0;
U = K[u_1..u_53,MonomialOrder=>GRevLex];
parametersOnly = map(U,parameterRing,
  toList apply(0..52,index -> u_(index+1))
    | toList apply(0..7,index -> 0_U));
q = parametersOnly qOriginal;
assert(numColumns mingens ideal q == 27);
evaluateY = map(K,U,rationalPoint);
DqY = matrix apply(27,row -> apply(53,column ->
  evaluateY diff(u_(column+1),q_(0,row))));
assert(rank DqY == 15);

twoJetPath = "data/universal_2jet_QQ.txt";
twoJet = twoJetPath;
twoJet << "" << flush;
scan(16,index ->
  twoJet << toString index << "|" << toString firstOrder_(0,index) << "|"
    << toString secondOrder_(0,index) << endl << flush);

certificatePath = "verification/formal_data_QQ.txt";
out = certificatePath;
out << "" << flush;
out << "field=QQ" << endl;
out << "macaulay2_required=1.20" << endl;
out << "VersalDeformations_version=3.0" << endl;
out << "T1_degree_zero_dimension=53" << endl;
out << "T2_degree_zero_dimension=27" << endl;
out << "minimal_quadratic_base_equations=27" << endl;
out << "direction=" << toString rationalPoint << endl;
out << "quadratic_kuranishi_at_y_zero=true" << endl;
out << "cubic_kuranishi_at_y_zero=true" << endl;
out << "rank_Dq_y=15" << endl;
out << "base_arc_two_jet=s*y" << endl;
out << "two_jet_rows=16" << endl << flush;

print("T1 degree-zero dimension=53");
print("T2 degree-zero dimension=27");
print("q(y)=0 and kappa_3(y)=0");
print("rank Dq_y=15");
print("two-jet=" | twoJetPath);
print("certificate=" | certificatePath);
exit 0;
