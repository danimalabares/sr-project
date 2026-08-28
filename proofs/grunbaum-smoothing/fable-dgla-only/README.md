# fable-dgla-only

A complete, standalone proof of the Grünbaum–Sreedharan Stanley–Reisner
smoothing theorem in which every deformation-theoretic step is formulated
and proved with a **strict dg Lie algebra** — no L∞-algebras, homotopy
transfer, minimal models, or operations of arity ≥ 3.

Produced 2026-08-27, independently of and without modifying the earlier
`../dgla-only/` attempt or any frozen material.

- [STATUS.md](STATUS.md) — final verdict, reproduction record, remaining
  dependencies.
- [PROOF_DGLA.tex](PROOF_DGLA.tex) — the complete proof.
- [DG_LIE_INDUCTION.tex](DG_LIE_INDUCTION.tex) — the abstract all-orders
  lemma.
- [AUDIT.md](AUDIT.md) — the L∞ → strict dg Lie replacement map, necessity
  analysis, and hostile review.
- [REPRODUCE.md](REPRODUCE.md) — verification commands.
- `./verify.sh --local` / `./verify.sh --all` — non-mutating checks.
