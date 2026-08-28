# Hostile audit of `proofs/grunbaum-smoothing/fable-dgla-only/`

Independent audit, 2026-08-27.

## 0. Repository state and independence

```text
workspace = /Users/daniel/github/sr-project
branch    = restructure
HEAD      = 866e9f186a65485a3a71eb3554c33c840a757612
working tree at audit start: clean except untracked
    proofs/grunbaum-smoothing/dgla-only/  (not read)
    proofs/grunbaum-smoothing/fable-dgla-only/  (the audit target)
```

Material read: the target directory; the frozen referee packet;
`COMPLETION.md` and `completion/`; `audits/tate-stage/`; canonical source
data.  Not read: `dgla-only/`, anything under `no-Linfty-audits/` other than
this output directory, any other agent's output.  No repository instruction
files (`CLAUDE.md`, `AGENTS.md`) exist in this tree.  All compilation and
testing was done from scratch copies under the session scratchpad or inside
this directory; nothing outside this directory was created or modified; no
commit, reset, or push was performed.  After all replays,
`git status` shows the tracked tree unchanged and the target directory is
byte-identical to its pre-audit state.

## 1. The exact theorem proved

PROOF_DGLA.tex:100–111 (Theorem 1.1): there exist sixteen homogeneous cubics
`F_i ∈ Q[[s]][x_1..x_8]` with `F_i ≡ m_i (mod s)` — the `m_i` being the
sixteen ordered Stanley–Reisner monomials of the explicitly listed 20-facet
complex — whose reductions modulo `s³` are byte-exactly the frozen file
`referee-packet/data/universal_2jet_QQ.txt`, such that
`X = Proj(Q[[s]][x]/(F_i)) → Spec Q[[s]]` is flat and projective with special
fibre `X₀ = Proj(S/I)` and smooth geometric generic fibre; hence `X₀` is
smoothable in characteristic zero.

No stronger claim is made: I verified by reading (and grepping) both TeX
sources that smoothness of the total space, irreducibility or any
identification of the generic fibre, any `H³`/`T³` dimension, and
preservation of the starting family beyond order `s²` are all explicitly
disclaimed (PROOF_DGLA.tex:113–116, 254–267, 955–963) and never silently
used.  The deformation machinery is genuinely restricted to a strict dg Lie
algebra: the differential `[d,−]`, the binary graded commutator, the
ordinary Maurer–Cartan equation, and the strict Bianchi identity.  My own
grep found no L∞, transfer, minimal-model, or arity-≥3 construct in either
proof source, confirming `check_fable.py`'s scan.

The special fibre is genuinely the intended Stanley–Reisner scheme:
`verify_combinatorics.py` (inspected line by line, replayed) proves the
facet list is pure, its minimal nonfaces are exactly the sixteen cubics of
eq. (1.1), and every link has vanishing reduced rational homology below top
dimension, so `A` is Cohen–Macaulay by Reisner with `depth = dim = 4`.
(The identification of the facet list with the sphere of the 1967
Grünbaum–Sreedharan paper is imported and was not checkable offline; it is
immaterial, since the theorem quantifies over the listed complex.)

## 2. Findings

### F1 (the only substantive defect): the `H²`-spanning certificate cited by the proof is vacuous as written

**Claim affected.**  PROOF_DGLA.tex:718–721, Computation 5.3(1): the 27
transported classes "are `∂`-closed, independent modulo `im δ¹`, and no
weight-zero cocycle in `C²` remains outside their span plus `im δ¹`; hence
`[η₁],…,[η₂₇]` is a basis of the 27-dimensional `H²(g)`."  This is
load-bearing: the exactness proof (Prop. 5.5) computes
`dim ker(ad_θ : H² → H³) = 27 − 12` from it, and exactness at `H²` is the
hypothesis of the all-orders induction (Lemma 6.2).  Closedness and
independence are genuinely certified; **spanning is not**.

**The defect.**  The cited evidence is the frozen certificate line
`T2_remaining_degree_zero_cocycles=0`, produced by
`referee-packet/code/verify_aq_bracket.m2:183–185`:

```
H2quotient = coker(delta1 | T2cocycles);
delta2quotient = map(C3,H2quotient,delta2);
assert(numColumns basis(0,ker delta2quotient) == 0);
```

Here `C2 = A^(toList(30:{-4}))`, which in Macaulay2 has generators of
degree +4 (`degrees` returns `{{4}},…`), so a weight-zero cochain — values
in `A₄` — is an element of **module degree 8**, not 0.  The degree-0 graded
piece of `H2quotient` is empty, hence so is that of any submodule, and the
assert can never fail, for any data.  I confirmed this on the real objects
by instrumenting a scratch copy of the frozen script:

```
degrees H2quotient (first 3) = {{4},{4},{4}}
basis(0, ker delta2quotient) = 0     <- the frozen check (vacuous)
basis(4, ·) = 0,  basis(5, ·) = 0
basis(6, ·) = 8,  basis(7, ·) = 18   <- kernel nonzero elsewhere, so the
                                        degree-0 test is unfalsifiable
basis(8, ker delta2quotient) = 0     <- the meaningful degree: spanning TRUE
basis(8, H2quotient) = 5378          <- non-degeneracy of the degree-8 piece
```

(The script's other `basis(0, image ·)` assertions — independence 27, rank
12, rank 15, zero composites — are **not** affected: their sources are
`A^n` with generators in degree 0, for which Macaulay2's image grading
makes `basis(0,·)` exactly the `Q`-rank of the classes modulo the relation
submodule; I verified this semantics on controlled examples and, more
decisively, reproduced every one of those numbers independently, below.)

**Truth of the claim and repair.**  The spanning statement is TRUE.  It is
certified two independent ways in this audit:

1. `independent_exactness.m2` (this directory) computes, with correct
   homogeneous twists and no deformation package, from the dual-CAS-audited
   Tate-stage matrices: `dim (ker δ² / im δ¹)₀ = 27`, exhibiting 27 of my
   own representatives (`homology(delta2, delta1)`, `basis(0, ·)`, all maps
   `isHomogeneous`-checked).  Since 27 independent classes exist and the
   whole space has dimension 27, any 27 independent classes — in particular
   the frozen script's — span.
2. The instrumented replay above: `basis(8, ker delta2quotient) = 0`, the
   correctly-graded version of the frozen check itself.

Minimal repair to the target (not applied, per mandate): add to
`verify_fable_dgla.m2` (or a new script) an exact computation of
`dim H²₀ = 27` — e.g. the eight-line homology computation in
`independent_exactness.m2:105–144` — and cite it in Computation 5.3(1)
instead of (or beside) the frozen `T2_remaining_degree_zero_cocycles=0`
line; alternatively re-derive the frozen check in module degree 8.  With
either, every load-bearing computational claim in the target is certified
by a non-vacuous exact computation.

### F2 (observation, no defect): cross-process identification of `θ` and `a`

The bridge lemma (PROOF_DGLA.tex:743–768) requires the script cocycle `θ`
and the constructed linear coefficient `a` to have literally equal e-values.
`a`'s e-values are pinned to the frozen two-jet file by the byte-identity
check in `verify_fable_dgla.m2` (items 6–7); `θ`'s e-values are `T1*y`
computed in a different process, equal to the file's first-order row only
via determinism of `CT^1` (which every full replay of
`verify_formal_data.m2` in fact re-exercises against the manifest hash).
This chain holds, but to remove even the determinism assumption my
independent exactness computation **builds `θ` directly from the frozen
file's first-order row** and re-proves all three rank statements with it.
No repair needed.

### F3 (observation, no defect): `det U = 1` is stronger than needed

Only `Q₀U = R₀` with constant `U` is load-bearing for Prop. 4.2 (the
reduction `D ≡ d mod s` on the `f_j` and `D²(f_j) = (F^{[3]}Q^{[3]}U)_j`).
Invertibility of `U` is never used.  Certified anyway.

### F4 (observation, no defect): a latent parsing pitfall, absent from the canonical scripts

Macaulay2's `value` parses polynomial strings into whichever ring currently
binds `x_1..x_8`; parsing the two-jet file after constructing `A = S/I`
silently truncates any term lying in `I`.  I hit this writing my own
checker.  I verified the canonical scripts are safe:
`verify_incidence_chart.m2` never constructs a quotient ring, and no other
frozen script parses polynomial text.  Recorded only as a warning for
future tooling.

## 3. Independent verification performed (all scripts in this directory)

1. **`independent_exactness.m2`** (runs in ~4 s, no deformation packages).
   From the tsv matrices and the frozen two-jet file only:
   the tsv `F` row equals the ordered SR generators; `im R = ker F₀` as
   modules (completeness of the 30 syzygies, independent of
   `VersalDeformations`); `D₂Z = 0` with all `Z`-column weights (5×16,
   6×120); `dim ker(δ¹)₀ = 109 = dim Hom_S(I,A)₀`, Jacobian image 56,
   `H¹(g) = 53`; **`dim H²₀ = 27`** with an explicit basis; `θ` (e-values
   := the frozen first-order row) closed through `e, f, g` with every
   solve assert-certified; `rank(ad_θ : H² → C³/im δ²) = 12` on my basis;
   `rank(ad_θ : H¹(h) → H²) = 15` computed **directly on the full
   109-dimensional relative cocycle space** (so the relative-controller
   exactness needs no transfer lemma); composite rank 0.  With the
   automatic inclusion `im ⊆ ker` for Maurer–Cartan linear coefficients
   (DG_LIE_INDUCTION.tex:149–158, re-derived), this is a complete,
   independent proof of exactness at `H²(h)` — the analytic heart of the
   theorem.
2. **`independent_T2_LS.m2`** (~2 s): the classical
   Lichtenbaum–Schlessinger `T²(A)₀ = 27` computed with Macaulay2 core
   only (no packages, no Tate data) — a third independent angle on the
   27, corroborating the identification `H²(C)₀ = T²₀(A)` in
   Lemma 2.6(3).
3. **`independent_provenance.m2`** (~9 min): the audited tsv matrices
   `R`, `Z` equal, entry by entry, the differentials of the pinned
   deterministic DGAlgebras model used by the frozen bracket script — so
   the Tate-stage certificate and the bracket computation are about the
   same resolution, and Lemma 2.1's identification is sound.
4. **`run_all_singular_incidence.py` → `independent_incidence_singular.txt`**:
   all **280/280** incidence memberships re-proved in Singular — a
   different CAS and Gröbner engine, an independent dehomogenization and
   chart enumeration (all 4-subsets of {1..7} enumerated by my own code,
   so coverage does not depend on Macaulay2's `subsets` ordering), and an
   independent module encoding of `Q[z,a][s]/(s³)`.
5. **`sample_exact_lifts.sh`**: on a sample of chart pairs, Singular
   computes an explicit lift `L` with `M·L = (0,0,1)ᵀ` and the combination
   is **re-multiplied exactly** — a certificate stronger than any Gröbner
   reduction.  Verified for charts (1,{1,2,3,4}), (3,{2,4,5,7}),
   (8,{4,5,6,7}); three sampled pairs exceeded the 300 s lift budget and
   are covered by the bounded-reduce sweep
   (`sample_exact_lifts_results.txt`).
6. **Full replay** of the target's `verify.sh --all` from a scratch copy:
   all four canonical packages pass; `proved 280/280 chart pairs` with
   degree-8 pairs exactly `(2,7),(6,12),(8,16)`; ranks 12/15, zero
   composites, controller dimensions 109/56/53, `T¹=53`, `T²=27`,
   weight-homogeneity, two-jet SHA-256
   `40e64e...cd1795`; both PDFs compile with clean log scans; regenerated
   certificates byte-identical to the committed ones; frozen trees
   untouched (git-verified).
7. **External references**: Stacks Tags 00MK and 0899 fetched 2026-08-27
   and matched verbatim against the citations; the inline Artinian
   re-proof of 00MK checked by hand; Tag 0E7T confirmed unused (grep).

## 4. Hand verification of the deformation-theoretic core

Every non-computational step was re-derived on paper during this audit;
details and line references in CLAIM_LEDGER.md.  Highlights of what was
checked and found correct, sign by sign:

- `(d+α)² = ∂α + ½[α,α]` and the whole of Prop. 3.1 (realization): the
  perturbed subcomplex/LES induction, the weightwise finite free
  resolutions, `Tor₁ = 0`, the inline Nakayama proof of the Artinian local
  flatness criterion, and rank identification via right-exactness of `H₀`.
- Lemma 3.3 (filtered cycle lifting) and its use in Prop. 4.2: the
  homological-degree bookkeeping is exactly matched to the two certified
  Tate-stage module equalities (`q=3` ↔ `ker D₁ = im D₂`; `q=4` ↔
  `ker D₂ = im[D₃ Z]`, whose boundary space correctly lives in
  `P_{<4} = S[e,f,g]`); the extension is well-founded and `D² = ½[D,D]`
  kills the square globally.
- The strict Bianchi identity, the curvature-change formula, the initial
  `s⁴` case `r₄ = [a₁,a₃] + ½[a₂,a₂]`, Steps 1–5 of the induction
  (`∂r_N = 0`; `[a,r_N] = −∂r_{N+1}`; the correction `s^{N−1}v − s^N w`;
  `½[δ,δ] ∈ F^{2N−2} ⊆ F^{N+2}` needing exactly `N ≥ 4`; coefficientwise
  convergence and separatedness).  The two-jet is preserved because the
  first correction enters at `s³`; the target correctly refuses to claim
  `s³`-preservation (which would need `[r₄] = 0`, not provided by
  exactness) and nothing downstream needs it — the incidence scripts
  consume only `universal_2jet_QQ.txt` (verified by reading their input
  handling).
- Lemma 2.4/2.5 (relative vs absolute, derivation quasi-isomorphisms),
  Lemma 2.6 (`H¹(h) = Hom_S(I,A)₀` — its two characterizations agree
  numerically at 109 in two independent computations, a nontrivial
  consistency check of the syzygy-completeness input), Lemma 5.4 (bridge),
  Prop. 5.5 (transfer) — all correct; and my direct relative-space rank
  computation makes the transfer argument redundant anyway.
- Section 7: weight preservation ⇒ the `F_i` are honest polynomials in `x`
  (elements of `Q[[s]] ⊗ S₃`); the family is a finitely presented
  projective scheme over `Spec Q[[s]]` by construction — the proof
  correctly distinguishes this from `x`-adic completions and needs no
  algebraization theorem (Tag 0899 is an optional footnote only, and the
  theorem claims nothing over a finite-type base).
- Section 8: the Betti-semicontinuity lemma (the target's self-contained
  replacement for the previously cited opening step of Tag 0E7T) is
  correct: `R`-flat syzygies, fibrewise resolutions, universal
  coefficients over the DVR; then Auslander–Buchsbaum gives
  `pd ≤ 4 ⇒ depth ≥ 4 = dim`, CM, unmixedness, all components of
  dimension 3 over every extension of `K` (Tor and Hilbert functions
  commute with field extension — so the passage to the algebraic closure
  of `Q((s))` is legitimate).  The Jacobian dichotomy needs exactly this.
- The DVR valuation argument: the incidence scheme has a closed point over
  a finite extension `K'`; `R'` (integral closure) is a complete DVR
  finite over `R` (Serre); properness of `X` and `Gr(4,7)` extends point
  and plane integrally; a unit projective coordinate and a unit Plücker
  coordinate select one of the 280 pairs.  The chart-change repair is
  genuine: the 4-plane is re-chosen in the unit-coordinate chart, licensed
  by (i) each chart being cut out by the sixteen dehomogenized cubics
  (proved, Lemma 8.3) and (ii) intrinsicness of the Zariski tangent space,
  so `dim ker J_{v₀}(p) = dim T_p X_{K'} ≥ 4`.  Evaluating the lifted
  polynomial identity (8.3) at the integral point turns every truncated
  generator into `−s³·(integral)`, giving `s² = s³c` in `R'` and the
  valuation contradiction `2v'(s) ≥ 3v'(s)`.  Every step checks.

## 5. What the 280 certificates do and do not prove (mandatory target 8)

They prove exactly the 280 polynomial identities
`s² ∈ (q₁,…,q₈₀) + (s³) ⊂ Q[z,a][s]` for the two-jet incidence generators —
nothing more.  The encoding was inspected: 80 generators = 16 dehomogenized
two-jet cubics + 64 entries of `J⁽²⁾K_Π`; the 3×240 module over `Q[y,a]` is
the free rank-3 model of `Q[z,a][s]/(s³)`; the target `(0,0,1)ᵀ` is `s²`;
a zero remainder against a degree-limited Gröbner basis is a sound positive
membership certificate (every partial basis element is an exact input
combination), and the retained-lift spot check plus my exact re-multiplied
Singular lifts confirm it.  The driver provably covers all 280 pairs (list
equality check, line 130–131) and records the three degree-8 pairs.  The
geometric content — that these identities force smoothness of every flat
projective continuation of the two-jet — is supplied entirely by
Prop. 8.5 and its inputs, as audited above.  The certificates make no
reference to the unknown higher coefficients `H_i`, which is precisely why
two-jet preservation in the induction suffices; the proof states this
correctly (PROOF_DGLA.tex:1194–1199).

## 6. Verdict

**CONDITIONAL ON A PRECISE MISSING LEMMA OR COMPUTATION** — with the
condition discharged by this audit's own independent computations.

- **First exact logical failure** (and the only one): PROOF_DGLA.tex:718–721
  (Computation 5.3(1)) asserts that the 27 transported classes span the
  weight-zero `H²` on the strength of the frozen certificate line
  `T2_remaining_degree_zero_cocycles=0`
  (`referee-packet/code/verify_aq_bracket.m2:185`), and that assert is
  vacuous: it inspects the degree-0 graded piece of a module whose
  weight-zero classes live in degree 8, so it passes for any data
  (Finding F1, with the instrumented demonstration).
- **Effect on the theorem**: `dim H²` and hence
  `dim ker(ad_a : H² → H³) = 15` would be unsupported; exactness at `H²`
  (Prop. 5.5) and therefore the all-orders extension (Lemma 6.2,
  Cor. 6.5), the family (Section 7), and the theorem would all be
  conditional on it.  Nothing else in the chain fails.
- **Status of the missing computation**: performed independently here,
  twice (correctly-graded homology: `dim H²₀ = 27`; correctly-graded
  version of the frozen check itself: `basis(8, ker delta2quotient) = 0`),
  and it **passes**.  Every other computational input was replayed and,
  for the load-bearing ones, re-derived independently (exactness ranks
  12/15/0 on my own bases from independently-audited data; 109/56/53;
  280/280 incidence memberships in a second CAS; provenance of the Tate
  data).
- **Minimal repair**: add one exact `dim H²₀ = 27` computation (eight
  lines of package-free Macaulay2, as in `independent_exactness.m2`) to
  the target's verification layer and cite it at Computation 5.3(1).  No
  change to any mathematical argument is needed.

Subject to that one repair — whose content this audit has verified to be
true — the target genuinely proves the stated smoothing theorem using only
strict dg Lie algebra deformation theory: the Grünbaum–Sreedharan
Stanley–Reisner threefold is the special fibre of a flat projective family
over `Spec Q[[s]]` with smooth geometric generic fibre.
