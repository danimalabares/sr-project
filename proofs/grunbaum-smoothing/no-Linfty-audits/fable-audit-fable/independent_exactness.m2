-- Independent hostile-audit verification of the exactness step of
-- proofs/grunbaum-smoothing/fable-dgla-only/PROOF_DGLA.tex (Prop. 5.4)
-- and of the controller dimensions (Comp. 2.6), USING NO DEFORMATION
-- PACKAGES.  Inputs:
--   * the dual-CAS-audited Tate-stage data  ../../audits/tate-stage/data/tate_candidate.tsv
--     (matrices F 1x16, R 16x30, Z 150x136);
--   * the frozen two-jet file  ../../referee-packet/data/universal_2jet_QQ.txt
--     (whose first-order row is, by the byte-certified check in
--     fable-dgla-only/verify_fable_dgla.m2, the vector of e-values of the
--     linear coefficient `a` of the constructed Maurer-Cartan element).
-- Everything else is Macaulay2 core exact linear algebra over QQ.
--
-- What is verified, independently of VersalDeformations/DGAlgebras:
--   (0) the tsv F row equals the ordered Stanley-Reisner generators;
--   (1) R is a complete first-syzygy matrix of F0 (module equality);
--   (2) D2*Z == 0 and column weights of Z are (5 x16, 6 x120);
--   (3) dim Hom_S(I,A)_0 = ker(delta1)_0 = 109; Jacobian image = 56;
--       absolute H^1 = 53;
--   (4) dim H^2_0 = ker(delta2)_0/im(delta1)_0 = 27, with an explicit
--       basis of 27 cocycle representatives (my own, not the package's);
--   (5) theta := (a-values) extends to a closed derivation through e,f,g
--       (all solves certified by asserts), and likewise every eta and a
--       full 109-column relative Z^1 spanning set psi;
--   (6) rank of ad_theta : H^2 -> C^3/im(delta2) on my basis = 12
--       (hence dim ker(ad_theta : H^2 -> H^3) = 15);
--   (7) rank of ad_theta : H^1(relative) -> H^2 = 15, computed on the
--       full 109-dimensional relative cocycle space (this checks the
--       relative-controller statement directly, with no transfer lemma);
--   (8) the composite of the two maps is zero on the computed spans.
-- Together with the automatic inclusion im <= ker for the Maurer-Cartan
-- linear coefficient (PROOF_DGLA / DG_LIE_INDUCTION), (6)+(7)+(8) give
-- exactness at H^2 of the relative controller.

S = QQ[x_1..x_8];
I = ideal(
  x_6*x_7*x_8, x_4*x_6*x_8, x_3*x_7*x_8, x_3*x_5*x_7,
  x_3*x_4*x_8, x_2*x_7*x_8, x_2*x_5*x_7, x_2*x_5*x_6,
  x_2*x_4*x_7, x_2*x_4*x_6, x_1*x_4*x_6, x_1*x_4*x_5,
  x_1*x_3*x_8, x_1*x_3*x_6, x_1*x_3*x_5, x_1*x_2*x_5);
F0 = gens I;
A = S/I;

-- ---------------------------------------------------------------- tsv parse
tsvPath = "../../audits/tate-stage/data/tate_candidate.tsv";
tsvLines = select(lines get tsvPath, l -> #l > 0);
termLines = select(tsvLines, l -> #l >= 4 and substring(l,0,5) == "term\t");
xvars = gens S;
shapes = new HashTable from {"F" => (1,16), "R" => (16,30), "Z" => (150,136)};
mats = new MutableHashTable;
scan(keys shapes, k -> (
  (r,c) := shapes#k;
  mats#k = mutableMatrix(S,r,c);
));
scan(termLines, l -> (
  p := separate("\t", l);
  name := p#1;
  r := value p#2; c := value p#3; coeff := value p#4;
  exps := apply(8, i -> value p#(5+i));
  mono := product apply(8, i -> (xvars#i)^(exps#i));
  m := mats#name;
  m_(r,c) = m_(r,c) + coeff*mono;
));
Fts = matrix mats#"F";
Rts = matrix mats#"R";
Zts = matrix mats#"Z";
assert(Fts == F0);                                    -- (0)
print "tsv_F_equals_ordered_SR_generators=true";

-- ------------------------------------------------- (1) completeness of R
syzF0 = gens ker F0;
assert(numColumns syzF0 == 30);
assert(F0*Rts == 0);
RtsMap = map(target syzF0, S^(toList(30:{4})), Rts);
assert((RtsMap % image syzF0) == 0);                  -- im R <= ker F0 (again)
assert((syzF0 % image RtsMap) == 0);                  -- ker F0 <= im R
print "R_generates_full_first_syzygy_module=true";

-- ------------------------------------------------- (2) D2, D2*Z == 0
eePairs = flatten apply(toList(1..8), i -> apply(toList(i+1..8), j -> (i,j)));
assert(#eePairs == 28);
-- the audited basis uses e_i e_j for 1<=i<j<=16 restricted to 16 e's:
-- 120 pairs from 16 generators
eePairs = flatten apply(toList(0..15), i -> apply(toList(i+1..15), j -> (i,j)));
assert(#eePairs == 120);
m = flatten entries F0;
eeCols = matrix apply(16, r -> apply(eePairs, (i,j) -> (
  if r == j then m#i else if r == i then -(m#j) else 0_S)));
D2 = Rts | eeCols;                                    -- 16 x 150
assert(F0*D2 == 0);
assert(D2*Zts == 0);
-- weights of Z columns
Zf = submatrix(Zts, toList(0..29), toList(0..135));
Zee = submatrix(Zts, toList(30..149), toList(0..135));
scan(136, c -> (
  dfs := select(apply(30, r -> Zf_(r,c)), e -> e != 0);
  des := select(apply(120, r -> Zee_(r,c)), e -> e != 0);
  wf := unique apply(dfs, e -> 4 + first degree e);
  we := unique apply(des, e -> 6 + first degree e);
  w := unique(wf | we);
  assert(#w == 1);
  assert((c < 16 and w == {5}) or (c >= 16 and w == {6}));
));
print "D2Z_zero_and_Z_column_weights_certified=true";

-- --------------------------------------- cochain complex over A (weight 0)
gDegs = apply(16, i -> {5}) | apply(120, i -> {6});
C1 = A^(toList(16:{3}));   -- generators in degree -3: weight-0 cochains sit in module degree 0
C2 = A^(toList(30:{4}));
C3 = A^gDegs;
delta1 = map(C2, C1, sub(transpose Rts, A));
delta2 = map(C3, C2, sub(transpose Zf, A));
assert isHomogeneous delta1;
assert isHomogeneous delta2;
assert(delta2*delta1 == 0);
-- self-test of grading conventions
assert(numColumns basis(0,C2) == 30*hilbertFunction(4,A));
assert(numColumns basis(0,C1) == 16*hilbertFunction(3,A));

-- --------------------------------------- (3) controller dimensions
K1 = ker delta1;
relReps = (generators K1)*(matrix basis(0,K1));       -- ambient C1 coords
relH1 = numColumns relReps;
assert(relH1 == 109);
jacMap = map(C1, A^(toList(8:{1})), sub(transpose jacobian F0, A));
assert isHomogeneous jacMap;
assert(delta1*jacMap == 0);
jacImageDim = numColumns basis(0, image jacMap);
assert(jacImageDim == 56);
H1abs = homology(delta1, jacMap);
absH1 = numColumns basis(0, H1abs);
assert(absH1 == 53);
print("relative_H1_dim=109  jacobian_image_dim=56  absolute_H1_dim=53  (independent)");

-- --------------------------------------- (4) H^2_0 = 27 with my own basis
H2 = homology(delta2, delta1);
b2 = basis(0, H2);
etaReps = (generators H2)*(matrix b2);                -- ambient C2 coords
nEta = numColumns etaReps;
assert(nEta == 27);
-- their classes are independent mod im(delta1) and span all weight-0 cocycles:
C2mod = coker delta1;
etaClassMap = map(C2mod, A^nEta, etaReps);
assert(numColumns basis(0, image etaClassMap) == 27);
print "independent_H2_dimension=27";

-- --------------------------------------- (5) theta from the frozen two-jet
use S;  -- ensure value() parses the jet file into S, not A
jetLines = select(lines get "../../referee-packet/data/universal_2jet_QQ.txt",
  l -> #l > 0);
assert(#jetLines == 16);
jetPieces = apply(jetLines, l -> separate("\\|", l));
assert(apply(jetPieces, p -> value p#0) == toList(0..15));
thetaE = transpose matrix {apply(jetPieces, p -> value p#1)};  -- 16x1 over S
assert(ring thetaE === S);
secondRow = apply(jetPieces, p -> value p#2);
scan(flatten entries thetaE, e -> assert(isHomogeneous e and degree e === {3}));
scan(secondRow, e -> assert(e == 0 or (isHomogeneous e and degree e === {3})));
print "frozen_two_jet_rows_are_homogeneous_cubics=true";

-- closure through f: solve F0 * thetaF = -(R^T * thetaE)
thetaDf = transpose Rts * thetaE;                     -- 30 x 1
thetaF = (matrix entries (-transpose thetaDf))//F0;                    -- 16 x 30
assert(F0*thetaF == matrix entries (-transpose thetaDf));
-- closure through g: theta(dg) as e-vector, then solve through D2
thetaDgF = matrix apply(16, r -> apply(136, c ->
  sum apply(30, j -> Zf_(j,c)*thetaF_(r,j))));
thetaDgEE = matrix apply(16, r -> apply(136, c ->
  sum apply(120, p -> (
    (i,j) := eePairs#p;
    coefficientEE := Zee_(p,c);
    if coefficientEE == 0 then 0_S else
      coefficientEE*(if r == j then thetaE_(i,0)
        else if r == i then -thetaE_(j,0) else 0_S)))));
thetaDg = thetaDgF + thetaDgEE;                       -- 16 x 136 over S
thetaG = (matrix entries (-thetaDg))//(matrix entries D2);                              -- 150 x 136
assert((matrix entries D2)*thetaG == matrix entries (-thetaDg));
thetaGLinearF = submatrix(thetaG, toList(0..29), toList(0..135)); -- 30 x 136
print "theta_closed_through_e_f_g=true";

-- --------------------------------------- eta lifts through g
etaFS = lift(etaReps, S);                             -- 30 x 27 over S
-- closure on g: solve F0 * c = eta(dg) columnwise
secondaryColumns = apply(nEta, t -> (
  etaF := etaFS_{t};
  etaDg := matrix entries transpose(transpose Zf * etaF); -- 1 x 136 over S
  etaG := etaDg // F0;
  assert(F0*etaG == etaDg);
  -- [theta,eta](g) = theta(eta(g)) - eta(theta(g))
  thetaEtaG := (transpose thetaE) * etaG;             -- 1 x 136
  etaThetaG := (transpose etaF) * thetaGLinearF;      -- 1 x 136
  thetaEtaG - etaThetaG
));
secondaryMatrix = matrix apply(136, r -> apply(nEta, t ->
  (secondaryColumns#t)_(0,r)));
C3mod = coker delta2;
secondaryClassMap = map(C3mod, A^nEta, sub(secondaryMatrix, A));
secondaryRank = numColumns basis(0, image secondaryClassMap);
print("independent_rank_ad_theta_H2_to_H3=" | toString secondaryRank);
assert(secondaryRank == 12);                          -- (6)

-- --------------------------------------- (7) primary map on all 109 classes
psiES = matrix entries lift(relReps, S);              -- 16 x 109 over S, untwisted
primaryColumns = apply(relH1, t -> (
  psiE := psiES_{t};
  pDf := transpose Rts * psiE;                        -- 30 x 1
  pF := (matrix entries (-transpose pDf))//F0;
  assert(F0*pF == matrix entries (-transpose pDf));
  (matrix entries transpose thetaE)*pF + (transpose psiE)*thetaF -- 1 x 30
));
primaryMatrix = matrix apply(30, r -> apply(relH1, t ->
  (primaryColumns#t)_(0,r)));
primaryClassMap = map(C2mod, A^relH1, sub(primaryMatrix, A));
primaryRank = numColumns basis(0, image primaryClassMap);
print("independent_rank_ad_theta_relH1_to_H2=" | toString primaryRank);
assert(primaryRank == 15);                            -- (7)

-- --------------------------------------- (8) zero composite
coords = primaryClassMap // etaClassMap;
assert(etaClassMap*coords == primaryClassMap);
compositeMap = secondaryClassMap * coords;
compositeRank = numColumns basis(0, image compositeMap);
print("independent_composite_rank=" | toString compositeRank);
assert(compositeRank == 0);                           -- (8)

assert(27 - secondaryRank == primaryRank);
print "INDEPENDENT_EXACTNESS_AT_H2_CERTIFIED";
print "  dim ker(ad_theta: H^2 -> H^3) = 27 - 12 = 15";
print "  dim im (ad_theta: H^1_rel -> H^2) = 15, composite = 0";
exit 0;
