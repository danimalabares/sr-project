-- Export Macaulay2's CT^1 basis over QQ for comparison with the historical
-- deterministic coordinates.  Run from the repository root:
--
--   M2 --script proofs/all-ones-versal-arc/export_t1_QQ.m2

needsPackage "VersalDeformations";

K = QQ;
S = K[x1,x2,x3,x4,x5,x6,x7,x8];
I = ideal(
  x6*x7*x8, x4*x6*x8, x3*x7*x8, x3*x5*x7,
  x3*x4*x8, x2*x7*x8, x2*x5*x7, x2*x5*x6,
  x2*x4*x7, x2*x4*x6, x1*x4*x6, x1*x4*x5,
  x1*x3*x8, x1*x3*x6, x1*x3*x5, x1*x2*x5);

T1 = CT^1(0,gens I);
assert(numRows T1 == 16 and numColumns T1 == 53);

outputPath = "proofs/all-ones-versal-arc/generated/m2_t1_QQ.txt";
out = outputPath;
out << "" << flush;
scan(toList(0..52), column -> scan(toList(0..15), row ->
  out << toString column << "|" << toString row << "|"
      << toString T1_(row,column) << endl << flush));

print("field=QQ");
print("matrix=16x53");
print("output=" | outputPath);
exit 0;
