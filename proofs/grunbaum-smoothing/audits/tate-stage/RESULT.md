# Tate-stage audit result

## Verdict: certified

For the exact frozen data in `data/tate_candidate.tsv`, over `QQ`, this audit
certifies

\[
D_1D_2=0,\qquad D_2D_3=0,\qquad D_2Z=0,
\]

and the two unbounded graded-module equalities

\[
\ker D_1=\operatorname{im}D_2,
\qquad
\ker D_2=\operatorname{im}[D_3\;Z].
\]

Thus the 136 proposed homological-degree-3 Tate generators are complete at
the audited stage: together with decomposable degree-3 elements, their
differentials generate every degree-2 cycle.  This closes the low-stage
exactness gap identified in the source audit.  The precise construction and
its consequence for the Tate-extension argument are in
`MATHEMATICAL_CERTIFICATE.md`.

## Evidence

The canonical sparse file has SHA-256

```text
9e0691837d69ba2027cca1fef52e0598dcd83f0bc65e2c88379061bce9caa396
```

It contains matrices `F:1x16`, `R:16x30`, and `Z:150x136`, in explicit
ordered bases, with 16, 60, and 439 nonzero monomial terms respectively.
The first 16 columns of `Z` have source internal degree 5 and the remaining
120 have degree 6.

Macaulay2 1.20 used full homogeneous `syz` computations and exact two-sided
lifts.  It obtained 30 generators for `ker(D1)` and 136 for `ker(D2)` and
retained matrices satisfying

```text
D2*Q1 = K1       K1*P1 = D2
B*Q2  = K2       K2*P2 = B,   B=[D3 Z].
```

Singular 4.4.1 independently rebuilt the maps, recomputed both full syzygy
modules, and lifted them through `D2` and `B`.  Its Gröbner-dependent,
nonminimal generating sets have 31 and 141 columns.  That count difference
does not change the modules and confirms that the two systems did not merely
serialize the same chosen syzygy bases.

Both systems use exact rational polynomial arithmetic and public core
operations.  Neither certification script loads `DGAlgebras` or calls
`killCycles`.  Each full computation is paired with a reloadable exact lift
certificate; replay also compares the freshly generated certificate bytes
with the frozen copy before checking the retained identities.

## Provenance of `Z`

The one-time provenance extractor repeated the pinned referee packet's
ordered ideal and its `freeDGAlgebra`/`setDiff`/two-stage `killCycles`
construction solely to observe `F`, `R`, and the candidate `Z`.  It then
recomposed every differential in the declared bases before serializing it.
The raw extraction and canonical audit input were byte-for-byte identical,
and a second extraction produced the same SHA-256 shown above.

The observed source facts are recorded in `data/provenance.json`, including:

- source construction `code/verify_aq_bracket.m2` SHA-256
  `7b49da5c17ccbff951b94384b547adcd6c73f8b151a95d8a78c3afa5d6b39f18`;
- referee release archive SHA-256
  `8244ef6272f895d787c9b21fe9f757e8a1ad67db9dde96ad7be774289193c57b`;
- pinned `DGAlgebras` 1.1.0 source SHA-256
  `72adff5eb889703562b7cedfce10c93490fda171f5f9dd90a998eb69b7d433b0`.

This provenance step is intentionally separate from the certification.  The
standalone replay consumes only frozen files inside this directory.

## Runtime recovery

The earlier exit-137 episode was an infrastructure failure and was not used
as mathematical evidence.  On resumption, shell `true`, `/usr/bin/true`,
Python, Macaulay2, and Singular all executed normally.  `/bin/true` is absent
on this macOS 12.7.6 host and returns 127; that path distinction is unrelated
to the previous SIGKILL behavior.

The exact executable versions and hashes are in
`verification/environment.txt`.  Singular is always run with `--no-rc` and
`--random=0`; its raw `--version` output contains a changing random seed, so
the environment checker pins the stable version tuple, build banner, and
executable hash instead of that nondeterministic field.

## Isolated replay

The final packet was replayed from a fresh temporary copy under a macOS
filesystem sandbox.  The sandbox explicitly denied reads from the working
audit directory, `grunbaum-smoothing-referee`, and `sr-project`; all three
denial probes failed as required before `./verify.sh` started.  The full
fresh-copy replay, including both syzygy computations, both retained-
certificate checks, and the manifest check, passed.  Its deterministic
verdict is recorded in `verification/fresh_copy_replay.txt`.

## Scope limits

This result is only the requested low Tate-stage certification.  It does not
compute total intrinsic `T^3`, rerun or certify the packet's commutator rank,
prove `ker(ad_y)=im(Dq_y)`, address terminology or hull comparison, rerun the
miniversal/incidence calculations, or independently prove the smoothing
theorem.  No failure witness exists because both exact module equalities
passed; on a failed Macaulay2 containment, the implementation instead writes
`verification/FAILED_CLASS.m2` with an explicit cycle and nonzero normal
remainder.
