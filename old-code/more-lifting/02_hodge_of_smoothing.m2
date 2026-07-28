-- 02_hodge_of_smoothing.m2
--
-- This Macaulay2 installation does not have the Varieties package, so the
-- direct tangent-sheaf computation from the earlier draft is not available.
-- Instead we compute the determinantal CY3's Betti/Hilbert data in core M2
-- and combine it with the published invariants for the smooth degree-20
-- Gulliksen-Negard threefold:
--
--   Marie-Ame'lie Bertin, "Examples of Calabi-Yau 3-folds of P^7 with rho=1"
--   (arXiv:math/0701511), degree-20 GN example:
--     rho = h^{1,1} = 1,   c_3 = -64,
--   hence h^{2,1} = h^1(T_X) = h^{1,1} - c_3/2 = 33.
--
-- This corrects the naive "34" guess: Bertin's remark says 34 only for the
-- characteristic-101 first-order deformation count, not for h^{2,1} over C.

kk = ZZ/32003;
S = kk[x_0..x_7];

out = "cache/02_hodge_of_smoothing.log";
out << "" << flush;
pr = (s) -> (out << s << endl << flush; << s << endl;);
prObj = (obj) -> (out << obj << endl << flush; << obj << endl;);

setRandomSeed 1;
A = matrix for i to 3 list for j to 3 list random(1, S);
I = minors(3, A);
d := degree I;
R := S^1 / I;
HP := hilbertPolynomial R;

pr("generic 4x4 matrix of linear forms over GF(32003)");
pr("codim I = " | toString codim I | "  (expect 4)");
pr("dim Proj(S/I) = " | toString(dim I - 1) | "  (expect 3)");
pr("degree = " | toString d | "  (expect 20)");
pr("Betti table of S/I:");
prObj(betti res R);
pr("Hilbert polynomial:");
prObj(HP);

c2H := 96 - 2*d;
pr("for a linearly normal CY3 in P^7, c2.H = 96 - 2*deg = " | toString c2H);

rho := 1;
c3 := -64;
chiOmega := (-c3) / 2;
h21 := rho + chiOmega;

pr("published smooth GN invariants (Bertin 2007, degree-20 GN example):");
pr("  rho = h^{1,1} = " | toString rho);
pr("  c3 = " | toString c3);
pr("therefore h^{2,1} - h^{1,1} = -c3/2 = " | toString chiOmega);
pr("h^{2,1}(X) = h^1(T_X) = h^{1,1} - c3/2 = " | toString h21);

pr("");
pr("quadratic obstruction-cone component dimensions from 01 = {35, 36, 37, 38}");
pr("expected smoothing-component dimension for the smooth GN CY3 = " | toString h21);
pr(if (h21 >= 35 and h21 <= 38) then
     "  -> a quadratic component has the expected dimension."
   else
     "  -> no irreducible component of the quadratic cone has dimension 33.");
pr("safe conclusion:");
pr("  quadratic order alone does not exhibit a 33-dimensional component.");
pr("  if a GN smoothing component exists, it must lie as a proper subvariety");
pr("  inside one of the 35-38 dimensional quadratic components, cut out by");
pr("  additional equations whose first nonzero terms are cubic or higher.");
exit 0
