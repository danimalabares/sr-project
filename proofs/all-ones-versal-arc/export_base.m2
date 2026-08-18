-- Export the homogeneous versal-base equations through degree five.
--
-- Run from the repository root with Macaulay2 1.20:
--   M2 --script proofs/all-ones-versal-arc/export_base.m2
--
-- The computation is exact over GF(32003).  On the reference machine it
-- takes several minutes.  The generated 108-line export is intentionally
-- ignored by git; verify_arc.sage records its SHA-256 in every certificate.

needsPackage "VersalDeformations";

K = ZZ/32003;
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

outputPath =
  "proofs/all-ones-versal-arc/generated/versal_base_GF32003.txt";
out = outputPath;
out << "" << flush;
scan(#G, i -> scan(#flatten entries G#i, j ->
  out << toString i << "|" << toString j << "|"
      << toString((flatten entries G#i)#j) << endl << flush));

print("field=GF(32003)");
print("T1_parameters=" | toString numgens source T1);
print("T2_equations=" | toString numgens source T2);
print("exported_degrees=(2,3,4,5)");
print("output=" | outputPath);
exit 0;
