-- Export the homogeneous versal-base equations through degree five over QQ.
--
-- Run from the repository root with Macaulay2 1.20:
--   M2 --script proofs/all-ones-versal-arc/export_base_QQ.m2
--
-- This deliberately uses SmartLift=>false, matching export_base.m2.  The
-- degree-five term is nonzero, and VersalDeformations reports that
-- HighestOrder has been reached: this is a finite truncation, not a complete
-- polynomial Kuranishi map.

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
assert(numgens source T1 == 53);
assert(numgens source T2 == 27);

(F,R,G,C) = versalDeformation(
  F0,T1,T2,
  HighestOrder=>5,
  SmartLift=>false);

assert(#G == 4);
assert(all(G, M -> numRows M == 27 and numColumns M == 1));
assert(G#-1 != 0);

outputPath =
  "proofs/all-ones-versal-arc/generated/versal_base_QQ_deg2_5.txt";
out = outputPath;
out << "" << flush;
scan(#G, i -> scan(#flatten entries G#i, j ->
  out << toString i << "|" << toString j << "|"
      << toString((flatten entries G#i)#j) << endl << flush));

print("field=QQ");
print("T1_parameters=" | toString numgens source T1);
print("T2_equations=" | toString numgens source T2);
print("exported_degrees=(2,3,4,5)");
print("degree_five_nonzero=true");
print("complete_polynomial_base=false");
print("output=" | outputPath);
exit 0;
