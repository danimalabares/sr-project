# Reproducing the Tate-stage audit

Run from this directory:

```sh
./verify.sh
```

The replay is deliberately strict.  It requires the exact pinned Python,
Macaulay2, and Singular executable bytes in `verification/environment.txt`.
It then:

1. validates the canonical sparse format and its SHA-256;
2. regenerates Macaulay2 and Singular syntax from that one file;
3. reconstructs `D1`, `D2`, `D3`, and `Z` with grading checks;
4. recomputes both full syzygy modules and all required lifts in Macaulay2;
5. byte-compares and multiplies the retained Macaulay2 certificate;
6. independently repeats the full computation in Singular;
7. byte-compares and reloads the retained Singular certificate;
8. accepts only exact clean success logs, then checks `MANIFEST.sha256`.

The expected final line is

```text
TATE_STAGE_AUDIT_REPLAY_CERTIFIED
```

Macaulay2 is invoked with deterministic/noninteractive options before the
script filename and with `--stop`, so an assertion failure is fatal.  Singular
is invoked with `--no-rc --random=0`; because Singular may return status zero
after an interpreter error, `code/check_results.py` requires the complete
semantic logs to equal the expected success output, not merely to contain a
success word.

The one-time script `code/provenance_extract_only.m2` is not part of
`verify.sh`.  It documents how the frozen candidate was observed from the
pinned source construction, and it is the only file that uses `DGAlgebras`
or `killCycles`.  Replaying the certification does not read the referee packet
or either neighboring project.

Every packet file except `MANIFEST.sha256` itself is covered by the manifest.
A manifest mismatch after the computations means a supposedly deterministic
input, program, certificate, or report differs from the audited packet and
the result must not be accepted.

For the stronger fresh-copy isolation test, run:

```sh
./fresh_replay.sh
```

That driver copies the finalized packet to a new `/private/tmp` directory and
runs the complete replay under `code/fresh_replay.sb`.  It first proves that
representative files in the original audit, referee packet, and `sr-project`
are readable outside the sandbox; inside, all three reads must fail before
the audit can start.  The sandbox denies network access and permits writes
only within the fresh temporary run root.  It retains the temporary copy and
log and prints their paths for inspection.
