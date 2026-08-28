# Final status (fable-dgla-only)

Date: 2026-08-27

## Verdict

**Proved with a strict dg Lie algebra only, subject to the explicitly
identified exact computer-algebra inputs.**  There is no mathematical
obstruction to a dg-Lie-only proof: L∞-machinery was a convenience of the
frozen write-up, not a necessity, and [AUDIT.md](AUDIT.md) establishes this
by exhibiting a strict replacement for every formerly transferred step
(none of the higher operations ever carried independent computational
content).

The exact theorem proved (PROOF_DGLA.tex, Theorem 1.1):

> There are sixteen homogeneous cubics `F_i ∈ Q[[s]][x_1..x_8]` with
> `F_i ≡ m_i (mod s)`, whose reductions mod `s^3` are exactly the frozen
> printed two-jet, such that `X = Proj(Q[[s]][x]/(F_i)) → Spec Q[[s]]` is
> flat and projective with special fibre the Grünbaum–Sreedharan
> Stanley–Reisner threefold and smooth geometric generic fibre.  In
> particular that threefold is smoothable in characteristic zero.

Not claimed (and not needed): smoothness of the total space, irreducibility
or any further identification of the generic fibre, any dimension for `H^3`
or intrinsic `T^3`, preservation of the starting family beyond order `s^2`.

The machinery used, in full: a Tate resolution `P → A` (existence re-proved
inline); the strict dg Lie algebra `Der_S(P,P)_0` with `∂ = [d,−]` and the
graded commutator; the ordinary Maurer–Cartan equation
`∂α + ½[α,α] = 0`; elementary obstruction theory in the complete filtered
dg Lie algebra `s·Der_S(P,P)_0[[s]]` with the strict Bianchi identity
`∂F(α) + [α,F(α)] = 0`; exact rational computer algebra; and the classical
theorems listed in PROOF_DGLA §1.3 with hypotheses checked (each either
re-proved inline or verified verbatim against its source).

The controller question posed by the task is resolved by determination,
not assumption: the fixed-coordinate controller is the **relative** algebra
`Der_S(P,P)_0` (its `H^1` is `Hom_S(I,A)_0`, of dimension 109, not the
53-dimensional package tangent space); the absolute algebra `Der_Q(P,P)_0`
carries the computed 53-dimensional `H^1`; the two literally coincide in
cohomological degrees ≥ 1, and the exactness statement is transferred to
the relative controller by an explicit chain-level argument.

## Deliverables

- [PROOF_DGLA.tex](PROOF_DGLA.tex) / PROOF_DGLA.pdf — complete standalone
  strict proof.
- [DG_LIE_INDUCTION.tex](DG_LIE_INDUCTION.tex) / DG_LIE_INDUCTION.pdf —
  the abstract fixed-two-jet all-orders lemma, self-contained, with all
  signs, the explicit initial `s^4` case, the convergence argument, and
  sharpness remarks (including the automatic inclusion `im ⊆ ker` for MC
  linear coefficients).
- [AUDIT.md](AUDIT.md) — replacement map for every former L∞-dependent
  step; necessity analysis; hostile review of the five critical bridges.
- [REPRODUCE.md](REPRODUCE.md) — exact commands and portability notes.
- [verify.sh](verify.sh) — non-mutating wrapper (`--local` / `--all`).
- [verify_fable_dgla.m2](verify_fable_dgla.m2) — new exact checks,
  including two new weight-homogeneity assertions.
- [check_fable.py](check_fable.py) — source-contract and certificate
  checker.
- verification/fable_dgla_QQ.txt, verification/fable_twojet_QQ.txt —
  deterministic certificates.

## What is new relative to the earlier attempts in this repository

Produced independently of, and without modifying, `../dgla-only/`.  Beyond
an independent re-derivation and re-verification of that attempt's claims,
this write-up:

1. **verifies weight-homogeneity of the truncated MC element** (every
   family correction cubic in `x`, every relation correction linear in
   `x`) by a new exact check — previously asserted but never separately
   certified;
2. **replaces the appeal to the opening step of Stacks Tag 0E7T** for
   Cohen–Macaulayness/equidimensionality of the generic fibre by a
   self-contained Betti-number-semicontinuity argument
   (PROOF_DGLA §8.1): Tag 0E7T's full statement carries a Fitting-ideal
   hypothesis that the incidence certificates never literally instantiate,
   so relying on its "opening reductions" was citation-fragile;
3. **removes the deformation-functor formalism entirely** — no converse
   MC correspondence, no Hinich citation, and the two classical criteria
   actually used (local flatness criterion, in its Artinian case; Tate
   existence) are re-proved inline;
4. gives a cleaner chain-level bridge between the constructed linear
   coefficient `a` and the script's cocycle `θ`: both have literally the
   same values `T1·y` on the `e_i`, so `a − θ` maps to the zero cochain in
   `Der(P,A)_0` and is exact by the derivation quasi-isomorphism;
5. fixes the chart-change gap in the DVR argument explicitly: the
   four-plane is re-chosen in the chart where the extended point has a
   unit coordinate, justified by intrinsicness of the Zariski tangent
   space and by the proof that each Proj chart is cut out by the sixteen
   dehomogenized cubics.

## Repository state

```text
workspace=/Users/daniel/github/sr-project
branch=restructure
HEAD=866e9f186a65485a3a71eb3554c33c840a757612
baseline=9c0fc0e8da6699bd7fe30d9940b4637222686472  (ancestor; tree diff to HEAD empty)
working tree at start: clean except untracked proofs/grunbaum-smoothing/dgla-only/
```

The requested path `~/github/danimalabares/sr-project` does not exist in
this environment; the repository lives at `~/github/sr-project`.  Nothing
in `referee-packet/`, `audits/`, `completion/`, `snapshots/`, or
`dgla-only/` was modified; no commit, push, or reset was performed.  All
output is confined to `proofs/grunbaum-smoothing/fable-dgla-only/`.

## Reproduction results (2026-08-27, this machine)

All replays ran from fresh temporary copies with the pinned executables
(Macaulay2 1.20, VersalDeformations 3.0, DGAlgebras 1.1.0, Singular 4.4.1,
Python 3.13.7, latexmk 4.79 / TeX Live 2023).

### Frozen referee packet: passed

Final line:
`VERIFIED: every exact computation, PROOF.pdf, and manifest entry passed.`
Key replayed values:

```text
T1 degree-zero dimension=53
T2 degree-zero dimension=27
rank Dq_y=15
rank commutator columns modulo delta2=12
primary plus Dq rank=0
ad_y composed primary-bracket rank=0
Jacobi composite rank=0
primary self bracket at y zero=true
proved 280/280 chart pairs
```

### Low Tate-stage audit: passed

Final line: `TATE_STAGE_AUDIT_REPLAY_CERTIFIED` (Macaulay2 and Singular
full syzygy computations, both module equalities).

### Starting R4 deformation: passed

```text
starting_deformation_flatness_inputs_verified=true
starting_two_jet_matches_frozen_input=true
universal_two_jet_sha256=40e64e61674b6a4e61f1ea6822dc79327bf4ba397285f84ed8738c4c18cd1795
```

### New local checks: passed

```text
relative_H1_dimension=109
coordinate_boundary_image_dimension=56
absolute_H1_dimension=53
family and relation corrections weight-homogeneous=true
starting MC linear e-values equal T1*y=true
two jet matches frozen input=true
FABLE_DGLA_LOCAL_VERIFIED
```

Both TeX documents compile under `latexmk -norc -pdf -halt-on-error` with
no undefined control sequences or references.

External references checked against their sources on 2026-08-27: Stacks
Tags 00MK and 0899 (statements verified verbatim; 00MK also re-proved
inline in the case used, 0899 optional); Tag 0E7T checked and deliberately
not used.

## Remaining dependencies

No unresolved mathematical lemma remains.  The proof depends on:

1. the exact Macaulay2/Singular computations of the frozen referee packet,
   the Tate-stage audit, the completion certificate, and the new
   `verify_fable_dgla.m2` — all replayed successfully;
2. classical commutative algebra and algebraic geometry as itemized in
   PROOF_DGLA §1.3 and §9 (each either re-proved inline or a standard
   textbook fact cited at section level, with the two Stacks tags verified
   verbatim).

## The first stronger statement that is NOT proved

Preservation of the full starting element modulo `s^4`.  The strict
induction's first correction `s^3·v` may change the `s^3` coefficient;
retaining it would require the leading obstruction class
`[r_4] = [[a_1,a_3] + ½[a_2,a_2]]` to vanish in `H^2`, which exactness
does not give.  This is immaterial: the 280 smoothness certificates
consume only the two-jet, which is preserved.
