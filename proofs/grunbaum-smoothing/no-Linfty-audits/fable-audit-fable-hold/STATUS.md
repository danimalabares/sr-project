# Audit status — fable-audit-fable

Date: 2026-08-27.
Target: `proofs/grunbaum-smoothing/fable-dgla-only/` at HEAD
`866e9f186a65485a3a71eb3554c33c840a757612` (branch `restructure`).

## Verdict

**CONDITIONAL ON A PRECISE MISSING LEMMA OR COMPUTATION.**

The missing item is a single exact computation: that the 27 transported
degree-two classes **span** the weight-zero `H²` (equivalently,
`dim H²₀ = 27`).  The target certifies independence and rank 12/15/0
soundly, but for spanning it cites the frozen certificate line
`T2_remaining_degree_zero_cocycles=0`, whose generating assert
(`referee-packet/code/verify_aq_bracket.m2:185`,
`numColumns basis(0, ker delta2quotient) == 0`) is **vacuous**: with the
script's module twists, weight-zero classes live in module degree 8, the
degree-0 piece it inspects is empty for any data, and the same kernel is
nonzero in degrees 6 and 7 — so the check cannot fail and certifies
nothing.  Spanning is load-bearing: it gives
`dim ker(ad_a : H² → H³) = 27 − 12 = 15`, the exactness at `H²`
(PROOF_DGLA Prop. 5.5) on which the all-orders Maurer–Cartan induction
(Lemma 6.2) and hence the entire theorem rest.

**The condition is discharged**: this audit performed the missing
computation independently, twice, and it passes —

- `independent_exactness.m2`: `dim H²₀ = 27` computed package-free with
  correct homogeneous twists from the dual-CAS-audited Tate matrices;
- an instrumented scratch replay of the frozen script:
  `basis(8, ker delta2quotient) = 0`, the correctly-graded form of the
  intended check.

So the theorem is true and the proof is complete once the target's
verification layer gains one non-vacuous `dim H²₀ = 27` check (minimal
repair specified in AUDIT_REPORT.md §6; not applied, per audit mandate).
Every other essential claim was verified: full replay of all four
canonical packages; line-by-line inspection of every load-bearing script;
hand re-derivation of the strict Bianchi induction, the MC-realization and
flatness proofs, the controller comparison (109/56/53), the bridge and
transfer lemmas, the Betti-semicontinuity/equidimensionality argument, the
chart-change and DVR valuation argument; and new independent computations —
exactness ranks 12/15/0 re-derived from independently audited data on the
full 109-dimensional relative cocycle space, provenance of the Tate data,
and all 280 incidence memberships re-proved in Singular
(`independent_incidence_singular.txt`, 280/280).

## What this audit did NOT find

No error in any mathematical argument of PROOF_DGLA.tex or
DG_LIE_INDUCTION.tex; no circular computation; no use of the 136 cycles as
`H³` classes; no hidden L∞/transfer machinery; no overclaim in
Theorem 1.1; no gap in the weight-homogeneity, equidimensionality, or
chart-change repairs (all three verified as genuine).

## Deliverables

- [AUDIT_REPORT.md](AUDIT_REPORT.md) — findings (F1–F4), verification
  narrative, verdict and minimal repair.
- [CLAIM_LEDGER.md](CLAIM_LEDGER.md) — claim-by-claim status with exact
  file/line references.
- [REPRODUCE.md](REPRODUCE.md) — exact commands for every check.
- `independent_exactness.m2`, `independent_T2_LS.m2`,
  `independent_provenance.m2`, `gen_singular_incidence.py`,
  `run_all_singular_incidence.py`, `sample_exact_lifts.sh`,
  `independent_incidence_singular.txt`.

## Repository hygiene

No canonical or target file modified (git-verified; target directory
byte-identical to its pre-audit state).  All testing from scratch copies
or inside this directory.  No commit, reset, or push.
