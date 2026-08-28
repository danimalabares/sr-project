-- Provenance cross-check: the Tate-stage audit certifies module equalities
-- for the frozen tsv matrices (F,R,Z); the frozen bracket script computes
-- with the DGAlgebras model built by killCycles.  PROOF_DGLA identifies the
-- two ("the matrices are the frozen certified data", Lemma 2.2 /
-- Computation 2.3).  This script rebuilds the pinned deterministic
-- DGAlgebras model and compares its d(f_j) and d(g_a) entrywise with the
-- tsv.  All exact.
needsPackage "DGAlgebras";
assert((options DGAlgebras)#Version == "1.1.0");
setRandomSeed 0;
debug DGAlgebras;

S = QQ[x_1..x_8];
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
toS = value -> lift(value,S);

-- model relation matrix R (16 x 30)
relationMatrix = matrix apply(16,row -> apply(30,column ->
  toS contract(e#row,diff(E,f#column))));

-- model Z (150 x 136) in the audited basis: rows f_1..f_30 then e_i e_j lex
eePairs = flatten apply(toList(0..15), i -> apply(toList(i+1..15), j -> (i,j)));
assert(#eePairs == 120);
modelZ = matrix (
  (apply(30, r -> apply(136, c -> toS contract(f#r, diff(E,g#c)))))
  |
  (apply(eePairs, (i,j) -> apply(136, c ->
    toS contract((e#i)*(e#j), diff(E,g#c)))))
);

-- tsv parse
tsvLines = select(lines get "../../audits/tate-stage/data/tate_candidate.tsv",
  l -> #l > 0);
termLines = select(tsvLines, l -> #l >= 4 and substring(l,0,5) == "term\t");
xvars = gens S;
mats = new MutableHashTable;
mats#"F" = mutableMatrix(S,1,16);
mats#"R" = mutableMatrix(S,16,30);
mats#"Z" = mutableMatrix(S,150,136);
scan(termLines, l -> (
  p := separate("\t", l);
  r := value p#2; c := value p#3; coeff := value p#4;
  mono := product apply(8, i -> (xvars#i)^(value p#(5+i)));
  mm := mats#(p#1);
  mm_(r,c) = mm_(r,c) + coeff*mono;
));
assert(matrix mats#"F" == F0);
assert(matrix mats#"R" == relationMatrix);
assert(matrix mats#"Z" == modelZ);
print "tsv_matches_DGAlgebras_model_R_and_Z=true";
exit 0;
