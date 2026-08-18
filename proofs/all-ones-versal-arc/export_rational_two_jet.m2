-- Export the canonical order-two pullback of Macaulay2's versal family along
-- the transported rational tangent direction.  The output has one line per
-- Stanley--Reisner generator:
--
--     zero_based_row | first_order_cubic | second_order_cubic

needsPackage "VersalDeformations";

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
(F,R,G,C) = versalDeformation(
  F0,T1,T2,HighestOrder=>2,SmartLift=>false);
assert(#F == 3);
assert(#G == 1);

rationalPoint = {
  1,3,1,2,6,1,1,1,1,1,21,28,1,5,10,55,66,15,1,18,2,35,42,1,4,10,1,
  25,12,30,5,33,44,1,6,3,14,7,1,9,1,6,12,20,1,4,22,1,15,1,1,8,11};
parameterRing = ring F#0;
specialize = map(S,parameterRing,rationalPoint | gens S);
g = specialize F#1;
h = specialize F#2;
assert(numRows g == 1 and numColumns g == 16);
assert(numRows h == 1 and numColumns h == 16);

qAtPoint = map(K,parameterRing,rationalPoint | toList(8:0_K));
assert(qAtPoint G#0 == 0);

outputPath =
  "proofs/all-ones-versal-arc/generated/m2_rational_two_jet_QQ.txt";
out = outputPath;
out << "" << flush;
scan(16,index ->
  out << toString index << "|" << toString g_(0,index) << "|"
      << toString h_(0,index) << endl << flush);

print("field=QQ");
print("q_at_rational_point_zero=true");
print("output=" | outputPath);
exit 0;
