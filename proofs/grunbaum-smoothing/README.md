# Grünbaum smoothing proof materials

> **Status as of 2026-08-21:** the smoothing theorem is proved by the frozen
> candidate calculations, the independent low Tate-stage certificate, and
> [`COMPLETION.md`](COMPLETION.md) together.  The frozen `referee-packet/`
> alone is still not a complete proof and has deliberately not been edited.

The frozen packet's expression “André–Quillen bracket” is unsupported as
standard terminology.  The completion instead defines the operation used:
the cohomology bracket induced by the graded commutator in the tangent DG Lie
algebra of a full Tate resolution.

The foundations audit's remaining comparison gap is closed without any
completed-hull equation comparison.  The exact order-three package output is
first proved flat over \(\mathbb Q[s]/(s^4)\); a relative Maurer--Cartan
induction uses it as a starting lift without changing its reduction modulo
\(s^3\); and a graded Nakayama argument recovers the literal embedded cubics.

## Contents

- `referee-packet/` is the standalone frozen candidate proof, copied
  byte-for-byte with its internal manifest intact.
- `audits/tate-stage/` is the complete certified low Tate-stage audit. Its
  manifest covers 33 files.
- `audits/terminology-and-foundations.md` is the unchanged terminology and
  foundations audit that motivated the later Tate-stage audit.
- `COMPLETION.md` supplies the missing graded classical fixed-jet bridge and
  completes the smoothing proof.
- `completion/` contains the extra exact starting-deformation certificate.
- `PROVENANCE.md` records source locations, hashes, copy and verification
  details, and archive regeneration instructions.

## How to read the evidence

The terminology audit records the status at the time of that audit. Its first
foundational gap—the completeness of the displayed low Tate stages—was closed
subsequently for the exact frozen candidate by the certified Tate-stage audit.
The comparison gap recorded in that historical audit is closed by
`COMPLETION.md`; the audit text remains unchanged as an audit trail.

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

The additional starting-deformation check runs with:

```sh
(cd completion && ./verify.sh)
```
