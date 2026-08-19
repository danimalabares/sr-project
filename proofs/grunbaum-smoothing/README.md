# Grünbaum smoothing proof materials

> **Status as of 2026-08-19:** `referee-packet/` is a frozen candidate proof,
> not a certified final proof. The low Tate-stage claim is now certified for
> that exact frozen candidate by `audits/tate-stage/`. This certification does
> **not** certify total \(T^3\), the commutator-rank claim, or the smoothing
> theorem.

The expression “André–Quillen bracket” is unsupported/nonstandard
terminology. The chain-level operation must be defined precisely and its
terminology chosen with expert review; the frozen files retain the original
wording only as evidence.

The principal remaining foundational gap is the comparison between the finite
Macaulay2 versal two-jet, the controlling Maurer–Cartan deformation problem,
and the classical graded embedded deformation while preserving the required
two-jet.

## Contents

- `referee-packet/` is the standalone frozen candidate proof, copied
  byte-for-byte with its internal manifest intact.
- `audits/tate-stage/` is the complete certified low Tate-stage audit. Its
  manifest covers 33 files.
- `audits/terminology-and-foundations.md` is the unchanged terminology and
  foundations audit that motivated the later Tate-stage audit.
- `PROVENANCE.md` records source locations, hashes, copy and verification
  details, and archive regeneration instructions.

## How to read the evidence

The terminology audit records the status at the time of that audit. Its first
foundational gap—the completeness of the displayed low Tate stages—was closed
subsequently for the exact frozen candidate by the certified Tate-stage audit.
The comparison gap stated above remains open.

Scientific files in the frozen packet and both audits have not been edited to
reconcile their wording with this later status. Treat this README and
`PROVENANCE.md` as status and provenance overlays, not as replacements for the
underlying evidence.

Manifest verification alone is sufficient to confirm the preserved bytes:

```sh
(cd referee-packet && shasum -a 256 -c MANIFEST.sha256)
(cd audits/tate-stage && shasum -a 256 -c MANIFEST.sha256)
```

The complete replay commands documented inside the packets run substantially
more expensive computer-algebra computations and are not needed merely to
verify this consolidation.
