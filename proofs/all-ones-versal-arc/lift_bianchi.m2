-- Lift all 24 linear syzygies of the quadratic Kuranishi term through every
-- available homogeneous base term.  With g_d of degree d, this constructs
-- homogeneous matrices S_k of degree k satisfying
--
--        sum_(d+k=N) g_d S_k = 0,       N=3,4,5,6.
--
-- The degree-five export therefore determines and checks S_1,...,S_4.
-- This is exact finite-order evidence for the formal Bianchi matrix; it is
-- not, by itself, an all-orders construction.

K = ZZ/32003;
B = K[t_1..t_53,MonomialOrder=>GRevLex];

inputPath = getenv "VD_BASE_EXPORT";
if inputPath === null then inputPath =
  "proofs/all-ones-versal-arc/generated/versal_base_GF32003.txt";
certificatePath = getenv "BIANCHI_CERTIFICATE";
if certificatePath === null then certificatePath =
  "proofs/all-ones-versal-arc/certificates/bianchi_through_degree6_GF32003.txt";

rawLines = select(lines get inputPath, line -> #line > 0);
polynomials = apply(rawLines, line ->
  value((separate("\\|",line))#2));
assert(#polynomials == 108);
g = apply(0..3, index ->
  matrix {take(drop(polynomials,27*index),27)});
assert(all(0..3,index ->
  numRows g#index == 1 and numColumns g#index == 27));

allQuadraticSyzygies = syz g#0;
linearPositions = positions(degrees source allQuadraticSyzygies,
  degreeValue -> degreeValue === {3});
S1 = allQuadraticSyzygies_linearPositions;
assert(#linearPositions == 24);
assert(g#0*S1 == 0);

entryDegrees = M -> unique apply(
  select(flatten entries M, entry -> entry != 0),
  entry -> first degree entry);
nonzeroEntryCount = M -> #select(flatten entries M, entry -> entry != 0);
assert(entryDegrees S1 == {1});

syzygyPieces = {S1};
scan(toList(2..4), k -> (
  residual := sum apply(toList(1..k-1), i ->
    g#(k-i)*syzygyPieces#(i-1));
  Sk := (-residual)//g#0;
  assert(g#0*Sk + residual == 0);
  assert(entryDegrees Sk == {k});
  syzygyPieces = append(syzygyPieces,Sk);
  ));

scan(toList(3..6), totalDegree -> (
  identityPart := sum apply(toList(1..totalDegree-2), k ->
    g#(totalDegree-k-2)*syzygyPieces#(k-1));
  assert(identityPart == 0);
  ));

rankCheck = (label,point) -> (
  evaluate := map(K,B,point);
  assert(evaluate g#0 == 0);
  evaluatedSyzygies := evaluate S1;
  D := matrix apply(27,row -> apply(53,column ->
    evaluate diff(t_(column+1),(g#0)_(0,row))));
  assert(transpose evaluatedSyzygies * D == 0);
  assert(rank evaluatedSyzygies == 12);
  assert(rank D == 15);
  );

rankCheck("all_ones",toList apply(0..52,index -> 1_K));
transportedGenericPoint = {
  1,3,1,2,6,1,1,1,1,1,21,28,1,5,10,55,66,15,1,18,2,35,42,1,4,10,1,
  25,12,30,5,33,44,1,6,3,14,7,1,9,1,6,12,20,1,4,22,1,15,1,1,8,11};
rankCheck("transported_generic",transportedGenericPoint);

out = certificatePath;
out << "" << flush;
out << "field=GF(32003)" << endl;
out << "input=generated/versal_base_GF32003.txt" << endl;
out << ("input_sha256="
    | "40d1d011748a0b3528464067b6c320dacef073d56304363c005230eb2ec41cc5");
out << endl;
out << "exported_base_degrees=(2,3,4,5)" << endl;
out << ("quadratic_syzygy_generators="
    | toString(numgens source allQuadraticSyzygies)) << endl;
out << "linear_syzygies=24" << endl;
scan(toList(1..4), k -> (
  out << ("S" | toString k | "_coefficient_degree="
      | toString(first(entryDegrees(syzygyPieces#(k-1))))) << endl;
  out << ("S" | toString k | "_nonzero_entries="
      | toString(nonzeroEntryCount(syzygyPieces#(k-1)))) << endl;
  ));
scan(toList(3..6), totalDegree ->
  out << ("identity_total_degree_" | toString totalDegree | "_zero=true")
      << endl);
out << "all_ones_q_zero=true" << endl;
out << "all_ones_rank_L=12" << endl;
out << "all_ones_rank_Dq=15" << endl;
out << "transported_generic_q_zero=true" << endl;
out << "transported_generic_rank_L=12" << endl;
out << "transported_generic_rank_Dq=15" << endl;
out << "kernel_L_equals_image_Dq_at_both_points=true" << endl << flush;

print("linear syzygies=24");
scan(toList(1..4), k -> print(
  "S" | toString k | " degree=" | toString(entryDegrees(syzygyPieces#(k-1)))
  | " nonzero_entries=" | toString(nonzeroEntryCount(syzygyPieces#(k-1)))));
print("Bianchi identities in total degrees 3..6 verified");
print("rank checks at all-ones and transported generic point verified");
print("certificate=" | certificatePath);
exit 0;
