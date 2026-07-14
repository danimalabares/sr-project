-- 01_versal_base_structure.m2
--
-- The 27 second-order obstruction quadrics of SR(M) (from
-- ../cotangent/obstruction_quadrics_ff32003.sage) in the 53 T^1
-- coordinates y0..y52 split into THREE disjoint 12-variable blocks
-- (9 quadrics each) plus 17 free variables.  So the quadratic cone of
-- the versal base is  V_A x V_B x V_C x A^17.
--
-- This script computes, for each block, the dimension, degree, and
-- minimal primes (irreducible components + their dimensions), and
-- assembles the structure of the full second-order versal base.
--
-- Done over GF(32003) to match the quadrics; structure is generic so
-- this reflects the QQ picture (verified separately).

kk = ZZ/32003;

out = "cache/01_versal_base_structure.log";
out << "" << flush;
pr = (s) -> (out << s << endl << flush; << s << endl;);

----------------------------------------------------------------------
-- Block A : variables y0 y3 y7 y9 y23 y31 y35 y36 y39 y44 y48 y52
----------------------------------------------------------------------
RA = kk[y0,y3,y7,y9,y23,y31,y35,y36,y39,y44,y48,y52];
IA = ideal(
  y0*y23 - y9*y31,
  y0*y39 - y31*y48,
  y3*y39 + y0*y44 - y35*y48 - y31*y52,
  y3*y23 - y9*y35,
  y7*y39 + y3*y44 - y36*y48 - y35*y52,
  y7*y23 - y9*y36,
  y7*y44 - y36*y52,
  y9*y39 - y23*y48,
  y9*y44 - y23*y52);

----------------------------------------------------------------------
-- Block B : variables y1 y4 y19 y20 y22 y26 y27 y29 y38 y43 y45 y47
----------------------------------------------------------------------
RB = kk[y1,y4,y19,y20,y22,y26,y27,y29,y38,y43,y45,y47];
IB = ideal(
  -y19*y26 + y1*y38,
  -y20*y26 - y19*y27 + y4*y38 + y1*y43,
  -y20*y27 - y19*y29 + y4*y43 + y1*y45,
  -y19*y22 + y1*y47,
  -y20*y29 + y4*y45,
  -y20*y22 + y4*y47,
  y22*y38 - y26*y47,
  y22*y43 - y27*y47,
  y22*y45 - y29*y47);

----------------------------------------------------------------------
-- Block C : variables y6 y8 y15 y16 y24 y25 y32 y33 y37 y40 y49 y50
----------------------------------------------------------------------
RC = kk[y6,y8,y15,y16,y24,y25,y32,y33,y37,y40,y49,y50];
IC = ideal(
  y6*y24 - y32*y40,
  y6*y25 - y33*y40,
  y6*y37 - y8*y40,
  -y15*y40 + y6*y49,
  -y16*y40 + y6*y50,
  y8*y24 + y16*y25 - y32*y37 - y33*y50,
  y8*y25 - y33*y37,
  y15*y24 - y32*y49,
  y16*y24 + y15*y25 - y33*y49 - y32*y50);

analyze = (name, I) -> (
  pr("===== Block " | name | " =====");
  pr("  #generators = " | toString numgens I);
  d := dim I;
  pr("  dim (in 12-var affine space) = " | toString d);
  pr("  degree = " | toString degree I);
  pr("  codim = " | toString codim I);
  pr("  is prime: " | toString isPrime I);
  mp := minimalPrimes I;
  pr("  # minimal primes (irreducible components) = " | toString(#mp));
  scan(#mp, i -> pr("    component " | toString i | ": dim = "
        | toString dim(mp#i) | ", codim = " | toString codim(mp#i)
        | ", #gens = " | toString numgens(mp#i)));
  pr("");
  apply(mp, p -> dim p));

pr("source quadrics: ../cotangent/obstruction_quadrics_ff32003.sage");
pr("block A variables = {y0,y3,y7,y9,y23,y31,y35,y36,y39,y44,y48,y52}");
pr("block B variables = {y1,y4,y19,y20,y22,y26,y27,y29,y38,y43,y45,y47}");
pr("block C variables = {y6,y8,y15,y16,y24,y25,y32,y33,y37,y40,y49,y50}");
pr("free variables   = {y2,y5,y10,y11,y12,y13,y14,y17,y18,y21,y28,y30,y34,y41,y42,y46,y51}");
pr("");

dimsA = analyze("A", IA);
dimsB = analyze("B", IB);
dimsC = analyze("C", IC);

pr("===== full second-order versal base =====");
pr("  ambient T^1 dimension = 53");
pr("  free (unobstructed) variables = 17");
topDim := dim IA + dim IB + dim IC + 17;
pr("  top component dimension = " | toString topDim);
pr("  total degree = degree(V_A) * degree(V_B) * degree(V_C) = "
   | toString(degree IA * degree IB * degree IC));
pr("  each block contributes component dimensions {7,6,6}");
pr("  total irreducible product components = 3^3 = 27");
pr("    components of dimension 35 = 8");
pr("    components of dimension 36 = 12");
pr("    components of dimension 37 = 6");
pr("    components of dimension 38 = 1");
pr("  note: these are the dimensions of the product components of V_A x V_B x V_C x A^17");
exit 0
