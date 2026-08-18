# Order-2 obstruction story

> **Archived account.** The empty-complex convention used by this historical
> calculation omitted 15 cotangent-cohomology classes. The exact value is
> \(\dim T^2_0=27\), not 12, and the smoothing problem has since been solved.
> See [`../../../README.md`](../../../README.md) and
> [`../../../proofs/`](../../../proofs/).

We write the Stanley--Reisner ideal as

\(I_{M}=(f_{1},\ldots,f_{16})\subset S\).

A first-order deformation replaces

$$
f_{i}
\quad\text{by}\quad
f_{i}+\varepsilon g_{i},
\qquad \varepsilon^2=0.
$$

The $g_{i}$ must satisfy the first-order
syzygy conditions. After quotienting
coordinate changes, this gives

$$
\dim T^1=53.
$$

To lift to order 2, we try

$$
f_{i}+\varepsilon g_{i}+\varepsilon^2 h_{i},
\qquad \varepsilon^3=0.
$$

The order-$\varepsilon^2$ syzygy failure is
the obstruction. The current script quotients
by the allowed $h_{i}$-corrections and gives
27 candidate quadratic equations on $T^1$.

This was historically misidentified with a 12-dimensional obstruction
target.  The corrected exact computation instead gives
\(\dim T^2_0=27\), as recorded in the proof linked above.
