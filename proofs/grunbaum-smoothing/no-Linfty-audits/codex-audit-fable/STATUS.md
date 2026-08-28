# Audit status

Date: 2026-08-27

## Verdict

**VALID AFTER MINOR EXPOSITIONAL CORRECTIONS**

The hostile mathematical audit, source inspection, full fresh computational
replay, forced TeX rebuild, and independent exact controller reconstruction
are complete.

The target genuinely proves the following strict-dg-Lie result: there are 16
homogeneous cubics in `Q[[s]][x_1,...,x_8]`, with the frozen printed two-jet,
whose Proj is flat and projective over `Spec Q[[s]]`, specializes to the
Grünbaum--Sreedharan Stanley--Reisner scheme, and has smooth geometric generic
fibre.  No `L_infinity` operation is needed or used.

The first exact omission is `fable-dgla-only/PROOF_DGLA.tex:444-499`: the
printed over-`Q[[s]]` paragraph does not prove the proposition's positive
acyclicity clause.  A compatible weightwise boundary-lifting paragraph repairs
it.  The main theorem uses the fully proved finite-quotient acyclicity, so this
omission does not affect the constructed family.

Other minor corrections are:

1. cite the finite-type/catenary dimension formula at
   `PROOF_DGLA.tex:1128-1130`;
2. delete or qualify the unsupported “every flat projective family” sentence
   at `PROOF_DGLA.tex:1205-1207`;
3. distinguish the actual finite-presentation family over `Q[[s]]` from a
   spread-out family over a finite-type `Q`-base;
4. force TeX rebuilding in `verify.sh:33-38`.

## Reproduction summary

Fresh exact replay results:

```text
relative H1 = 109
coordinate-boundary rank = 56
absolute H1 = 53
H2 = 27
secondary rank = 12
primary rank = 15
primary/secondary composite = 0
all incidence pairs = 280/280
both full Tate-stage module equalities = certified
R4 starting presentation = certified
forced TeX builds = passed
```

The independent Sage script, which loads neither deformation package, found
`rank(delta0,delta1,delta2)=(56,1555,5378)` and reproduced relative `H1=109`,
absolute `H1=53`, and `H2=27`.

## Repository state

Initial state:

```text
branch=restructure
HEAD=866e9f186a65485a3a71eb3554c33c840a757612
?? proofs/grunbaum-smoothing/dgla-only/
?? proofs/grunbaum-smoothing/fable-dgla-only/
```

The two initial untracked trees were preserved.  No target or canonical file
was modified.  No reset, commit, or push was performed.  Persistent output is
confined to `proofs/grunbaum-smoothing/no-Linfty-audits/codex-audit-fable/`.
At completion, `git diff --name-only` and `git diff --cached --name-only` were
empty; `git status --short` showed the two initial untracked trees plus the
untracked `proofs/grunbaum-smoothing/no-Linfty-audits/` output tree.

## Deliverables

- `AUDIT_REPORT.md` -- complete mathematical and computational audit;
- `CLAIM_LEDGER.md` -- 80 classified substantive claims with exact sources;
- `REPRODUCE.md` -- fresh-copy commands, expected output, and caveats;
- `STATUS.md` -- this disposition;
- `check_controller_complex.py` -- independent exact low-controller check.
