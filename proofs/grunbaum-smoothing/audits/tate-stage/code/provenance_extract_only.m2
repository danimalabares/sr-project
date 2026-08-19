-- One-time provenance extractor.  This is NOT part of the mathematical
-- certification.  It observes the exact in-memory f- and g-differentials
-- selected by the frozen referee packet's pinned construction.

needsPackage "DGAlgebras";
assert((options DGAlgebras)#Version == "1.1.0");
setRandomSeed 0;
debug DGAlgebras;

K = QQ;
S = K[x_1..x_8,MonomialOrder=>GRevLex];
I = ideal(
  x_6*x_7*x_8, x_4*x_6*x_8, x_3*x_7*x_8, x_3*x_5*x_7,
  x_3*x_4*x_8, x_2*x_7*x_8, x_2*x_5*x_7, x_2*x_5*x_6,
  x_2*x_4*x_7, x_2*x_4*x_6, x_1*x_4*x_6, x_1*x_4*x_5,
  x_1*x_3*x_8, x_1*x_3*x_6, x_1*x_3*x_5, x_1*x_2*x_5);
F0 = gens I;

generatorDegrees = apply(flatten entries F0, entry -> {1} | degree entry);
E = freeDGAlgebra(S,generatorDegrees);
E = setDiff(E,I_*,InitializeComplex=>false);
E = killCycles(E,StartDegree=>1);
E = killCycles(E,StartDegree=>2);

dgGenerators = gens E.natural;
e = take(dgGenerators,16);
f = take(drop(dgGenerators,16),30);
g = drop(dgGenerators,46);
assert(#e == 16 and #f == 30 and #g == 136);
assert(all(e,z -> degree z === {1,3}));
assert(all(f,z -> degree z === {2,4}));
assert(#select(g,z -> degree z === {3,5}) == 16);
assert(#select(g,z -> degree z === {3,6}) == 120);

toS = value -> lift(value,S);
pairBasis = flatten apply(toList(0..14),i ->
  apply(toList((i+1)..15),j -> e#i*e#j));
assert(#pairBasis == 120);
basis2Canonical = f | pairBasis;

RinE = (coefficients(
  matrix {apply(f,z -> diff(E,z))},
  Monomials=>matrix {e}))#1;
R = matrix apply(16,row -> apply(30,column ->
  toS RinE_(row,column)));

ZinE = (coefficients(
  matrix {apply(g,z -> diff(E,z))},
  Monomials=>matrix {basis2Canonical}))#1;
Z = matrix apply(150,row -> apply(136,column ->
  toS ZinE_(row,column)));

-- Recompose in the explicit bases; this proves the serialization did not
-- change a sign or omit a term.
assert(entries(matrix {e} * substitute(R,E.natural))
  == entries matrix {apply(f,z -> diff(E,z))});
assert(entries(matrix {basis2Canonical} * substitute(Z,E.natural))
  == entries matrix {apply(g,z -> diff(E,z))});

out = openOut "/private/tmp/tate_candidate_raw.tsv";
out << "format\ttate-stage-sparse-v1" << endl;
out << "ring\tQQ[x_1,x_2,x_3,x_4,x_5,x_6,x_7,x_8]\tGRevLex" << endl;
out << "basis_E1\te_1,...,e_16" << endl;
out << "basis_E2\tf_1,...,f_30; e_i*e_j lexicographic i<j" << endl;
out << "matrix\tF\t1\t16" << endl;
out << "matrix\tR\t16\t30" << endl;
out << "matrix\tZ\t150\t136" << endl;

writeSparse = (label,M) -> (
  scan(0..(numRows M-1),row ->
    scan(0..(numColumns M-1),column ->
      scan(terms M_(row,column),term -> (
        out << "term\t" << label
          << "\t" << toString row
          << "\t" << toString column
          << "\t" << toString leadCoefficient term;
        scan(first exponents term,exponent ->
          out << "\t" << toString exponent);
        out << endl;
      )))));

writeSparse("F",F0);
writeSparse("R",R);
writeSparse("Z",Z);
scan(0..135,index ->
  out << "gdegree\t" << toString index
      << "\t" << toString last degree g#index << endl);
out << "end\ttate-stage-sparse-v1" << endl;
close out;

print("R_shape=" | toString numRows R | "x" | toString numColumns R);
print("Z_shape=" | toString numRows Z | "x" | toString numColumns Z);
print("candidate=/private/tmp/tate_candidate_raw.tsv");
exit 0;
