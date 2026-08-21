# Fixed-jet completion certificate

This directory contains the additional exact calculation used by
[`../COMPLETION.md`](../COMPLETION.md).

Run the complete check from this directory:

```sh
./verify.sh
```

The script specializes the order-three family and relation matrices at the
displayed rational direction, verifies their product over
`QQ[s]/(s^4)`, checks that the special relation matrix is the complete first
syzygy matrix, regenerates all sixteen printed rows, and compares them
byte-for-byte (and by SHA-256) with the frozen incidence input.  The wrapper
also reuses the frozen packet's exact executable and package-source checks.
Its deterministic semantic output is
[`verification/starting_jet_QQ.txt`](verification/starting_jet_QQ.txt).
