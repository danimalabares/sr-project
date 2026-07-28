-- Step 3.  Necessary condition for a flat degeneration GN ~> SR(M):
-- equal Hilbert series (and, expected here, equal graded Betti table).
-- Compares I_SR with three determinantal ideals:
--   * the given circulant matrix,
--   * a generic matrix of linear forms in x1..x8 (the actual smooth CY3),
-- writing results incrementally to a lg file.

out = "cache/03_invariants.lg";
out << "" << flush;  -- truncate
lg = (s) -> (out << s << endl << flush; print s);

S = QQ[x1,x2,x3,x4,x5,x6,x7,x8];

ISR = ideal(
  x6*x7*x8, x4*x6*x8, x3*x7*x8, x3*x5*x7,
  x3*x4*x8, x2*x7*x8, x2*x5*x7, x2*x5*x6,
  x2*x4*x7, x2*x4*x6, x1*x4*x6, x1*x4*x5,
  x1*x3*x8, x1*x3*x6, x1*x3*x5, x1*x2*x5);

lg "===== I_SR =====";
lg("numgens = " | toString numgens ISR
    | "  codim = " | toString codim ISR
    | "  degree = " | toString degree ISR);
hsSR = hilbertSeries(ISR, Reduce=>true);
lg("Hilbert series: " | toString hsSR);
bSR = betti res ISR;
lg("Betti table:"); lg toString bSR;

-- given circulant matrix
A = matrix{{x1,x2,x3,x4},{x5,x6,x7,x8},{x2,x3,x4,x5},{x6,x7,x8,x1}};
IGN = minors(3, A);
lg "";
lg "===== I_GN (given circulant matrix) =====";
lg("numgens = " | toString numgens IGN
    | "  codim = " | toString codim IGN
    | "  degree = " | toString degree IGN);
hsGN = hilbertSeries(IGN, Reduce=>true);
lg("Hilbert series: " | toString hsGN);
bGN = betti res IGN;
lg("Betti table:"); lg toString bGN;
lg("same Hilbert series as I_SR: " | toString(hsSR == hsGN));
lg("same Betti table as I_SR:    " | toString(bSR == bGN));

-- generic matrix of linear forms (the actual smooth GN CY3)
setRandomSeed 42;
Ag = matrix for i to 3 list for j to 3 list random(1, S);
IGg = minors(3, Ag);
lg "";
lg "===== I_GN (generic linear matrix) =====";
lg("numgens = " | toString numgens IGg
    | "  codim = " | toString codim IGg
    | "  degree = " | toString degree IGg);
hsGg = hilbertSeries(IGg, Reduce=>true);
lg("Hilbert series: " | toString hsGg);
bGg = betti res IGg;
lg("Betti table:"); lg toString bGg;
lg("same Hilbert series as I_SR: " | toString(hsSR == hsGg));
lg("same Betti table as I_SR:    " | toString(bSR == bGg));

lg "";
lg "DONE";
exit 0
