# Reproducing this audit

All commands run from this directory
(`proofs/grunbaum-smoothing/no-Linfty-audits/fable-audit-fable/`).
Pinned tools: Macaulay2 1.20, Singular 4.4.1, Python ≥ 3.11
(python3.13 for the frozen replays), latexmk/TeX Live 2023.
Nothing here writes outside this directory (scripts read canonical data
via relative paths, read-only).

## 1. Independent exactness / controller verification (~5 s)

```sh
M2 --script independent_exactness.m2 --no-randomize
```

Expected final lines:

```text
relative_H1_dim=109  jacobian_image_dim=56  absolute_H1_dim=53  (independent)
independent_H2_dimension=27
frozen_two_jet_rows_are_homogeneous_cubics=true
theta_closed_through_e_f_g=true
independent_rank_ad_theta_H2_to_H3=12
independent_rank_ad_theta_relH1_to_H2=15
independent_composite_rank=0
INDEPENDENT_EXACTNESS_AT_H2_CERTIFIED
```

Inputs: only `../../audits/tate-stage/data/tate_candidate.tsv` and
`../../referee-packet/data/universal_2jet_QQ.txt`.  Uses no deformation
package (no VersalDeformations, no DGAlgebras).

## 1b. Third-angle T^2 check (~2 s)

```sh
M2 --script independent_T2_LS.m2 --no-randomize
```

Expected: `T2_LS_degree_zero_dimension=27` — the classical
Lichtenbaum–Schlessinger `T²(A)₀` from Macaulay2 core only (no packages,
no Tate data), corroborating the identification `H²(C)₀ = T²₀(A)` of
PROOF_DGLA Lemma 2.6(3).

## 2. Provenance of the Tate-stage data (~10 min)

```sh
M2 --script independent_provenance.m2 --no-randomize
```

Expected: `tsv_matches_DGAlgebras_model_R_and_Z=true`.  (This one does load
DGAlgebras, deliberately: it re-builds the pinned deterministic model and
compares it entrywise with the audited tsv.)

## 3. Independent Singular incidence sweep (~25–40 min, 4 workers)

```sh
python3 run_all_singular_incidence.py
```

Expected: `proved 280/280, failures: 0`; per-pair results are written to
`independent_incidence_singular.txt` (committed here from the audit run).
Exact re-multiplied lift certificates on a sample:

```sh
./sample_exact_lifts.sh
```

Each sampled pair prints `lift_exact chart=... : 1` or, when Singular's
unbounded `lift` exceeds its 300 s budget, `SKIPPED_TIMEOUT_300s`.  Audit
run (`sample_exact_lifts_results.txt`): exact lifts verified for charts
`(1,{1,2,3,4})`, `(3,{2,4,5,7})`, `(8,{4,5,6,7})`; three pairs skipped on
budget.  (The sweep itself covers all 280 pairs by degree-bounded
reduction, which is a sound positive membership certificate.)

## 4. Demonstrating Finding F1 (vacuity of the frozen spanning check)

From a **scratch copy** of the repository (never the frozen tree), insert
after line 185 of `referee-packet/code/verify_aq_bracket.m2`:

```
Kq = ker delta2quotient;
print take(degrees H2quotient, 3);
scan({0,4,5,6,7,8}, dg ->
  print(toString dg | " -> " | toString numColumns basis(dg,Kq)));
print numColumns basis(8,H2quotient);
exit 0;
```

and run `M2 --script code/verify_aq_bracket.m2 --no-randomize` from the
copy's `referee-packet/` (~80 s).  Observed in this audit:

```text
{{4},{4},{4}}
0 -> 0    4 -> 0    5 -> 0    6 -> 8    7 -> 18    8 -> 0
5378
```

Degree 8 is where weight-zero classes live; the frozen assert tested
degree 0, which is empty for any data.  `8 -> 0` is the meaningful check
and it passes (spanning true), matching `independent_H2_dimension=27`.

## 5. Full replay of the audit target

From a scratch copy of `proofs/grunbaum-smoothing/` (the target's local
step writes into its own directory, so never run it in the canonical tree
during an audit):

```sh
(cd <scratch>/proofs/grunbaum-smoothing/fable-dgla-only && ./verify.sh --all)
```

Observed 2026-08-27: `FABLE_DGLA_FULL_REPLAY_VERIFIED`, with
`VERIFIED: every exact computation, PROOF.pdf, and manifest entry passed.`,
`TATE_STAGE_AUDIT_REPLAY_CERTIFIED`, `proved 280/280 chart pairs`,
degree-8 pairs `[(2,7),(6,12),(8,16)]`, ranks 12/15, zero composites,
`FABLE_DGLA_LOCAL_VERIFIED`; the regenerated
`verification/fable_dgla_QQ.txt` and `verification/fable_twojet_QQ.txt`
are byte-identical to the committed ones.

## 6. External references

- Stacks Tag 00MK and Tag 0899: statements fetched from
  stacks.math.columbia.edu on 2026-08-27; both match the citations in
  PROOF_DGLA.tex verbatim (00MK also re-proved inline there in the case
  used; 0899 optional-footnote only).
