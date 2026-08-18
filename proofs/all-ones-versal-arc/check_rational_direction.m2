-- Verify the transported rational tangent direction in Macaulay2's CT^1
-- coordinates.  This is an independent QQ computation of the quadratic
-- Kuranishi term and its linear syzygies.

needsPackage "VersalDeformations";

K = QQ;
S = K[x1,x2,x3,x4,x5,x6,x7,x8];
I = ideal(
  x6*x7*x8, x4*x6*x8, x3*x7*x8, x3*x5*x7,
  x3*x4*x8, x2*x7*x8, x2*x5*x7, x2*x5*x6,
  x2*x4*x7, x2*x4*x6, x1*x4*x6, x1*x4*x5,
  x1*x3*x8, x1*x3*x6, x1*x3*x5, x1*x2*x5);

F0 = gens I;
T1 = CT^1(0,F0);
T2 = CT^2(0,F0);
(F,R,G,C) = versalDeformation(
  F0,T1,T2,HighestOrder=>2,SmartLift=>false);
assert(numgens source T1 == 53);
assert(numgens source T2 == 27);

-- Move the quadratic row to a standard-graded parameter-only ring so that
-- the degree-one part of its syzygy module is unambiguous.
qOriginal = transpose G#0;
Toriginal = ring qOriginal;
U = QQ[u_1..u_53,MonomialOrder=>GRevLex];
phi = map(
  U,Toriginal,
  toList apply(0..52,index -> u_(index+1))
    | toList apply(0..7,index -> 0_U));
q = phi qOriginal;
allSyzygies = syz q;
linearPositions = positions(degrees source allSyzygies, degreeValue ->
  degreeValue === {1});
Ltranspose = allSyzygies_linearPositions;
assert(#linearPositions == 24);
assert(q*Ltranspose == 0);

rationalPoint = {
  1,3,1,2,6,1,1,1,1,1,21,28,1,5,10,55,66,15,1,18,2,35,42,1,4,10,1,
  25,12,30,5,33,44,1,6,3,14,7,1,9,1,6,12,20,1,4,22,1,15,1,1,8,11};
assert(#rationalPoint == 53);
evaluate = map(QQ,U,rationalPoint);
assert(evaluate q == 0);

D = matrix apply(27,row -> apply(53,column ->
  evaluate diff(u_(column+1),q_(0,row))));
evaluatedSyzygies = evaluate Ltranspose;
assert(transpose evaluatedSyzygies * D == 0);
assert(rank evaluatedSyzygies == 12);
assert(rank D == 15);
-- The inclusion im(D) subset ker(L(y)) and the complementary dimensions
-- 15+12=27 prove equality.

certificatePath =
  "proofs/all-ones-versal-arc/certificates/rational_direction_QQ.txt";
out = certificatePath;
out << "" << flush;
out << "field=QQ" << endl;
out << "T1_dimension=53" << endl;
out << "T2_dimension=27" << endl;
out << "linear_syzygies=24" << endl;
out << "q_at_transported_point_zero=true" << endl;
out << "rank_evaluated_syzygies=12" << endl;
out << "rank_Dq=15" << endl;
out << "evaluated_syzygies_times_Dq_zero=true" << endl;
out << "kernel_evaluated_syzygies_equals_image_Dq=true" << endl;
out << "transported_point=" | toString rationalPoint << endl << flush;

print("q(point)=0");
print("linear syzygies=24");
print("rank L(point)=12");
print("rank Dq(point)=15");
print("ker L(point)=im Dq(point)");
print("certificate=" | certificatePath);
exit 0;
