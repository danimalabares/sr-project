# Objective

In this directory I want to:

1. Compute the dimension of T^1, the space of
   first-order deformations of SR(M).

2. Compute the dimension of T^2, the
   obstruction space of SR(M).

See
https://chatgpt.com/share/69ce768a-9a88-83e9-8443-7abd02ad584c.

# Past work on Artin's Criterion

Based on what I did in ../syzygy-M,
here's how to re-compute the deformation polynomials of SR(M):

1. Run `sage part-1.sage`. This introduces
   the SR ring of M from the simplicial data
recorded directly in the script (and independently checked by `M_FACETS.py`) and
follows Michele's method via Artin's
criterion to compute the general deformation
polynomials. This computation takes some time
so the script creates a Pickle file where the
data is stored.

2. Run `sage M-syz.sage`. This file reads off
   the Pickle data and prints the deformation
polynomials.

# Preliminaries

1. `M_FACETS.py` contains the minimal
    data of the facets of M as in the
original paper by Grünbaum-Shreedharan.

2. `verify_M.py` is a "verification script"
    that makes sure that the facets data
used in the Artin's criterion scripts is
correct. (AI idea to write this.)

# Computation of T1

1. `compute_T1_AC.py` uses
    Theorem low_dim3 from jan2.tex to 
compute the dimension of T1 using the 
combinatorial data. The result is 53. 

2. (12/June/26.) Chat GPT claims
the scripts `count_*` are not Chat GPT
garbage, and that they prove that
Artin's Criterion method also gives
53 free parameters after considering
the syzygy contraints (which is why
there are two files - we need to take 
quotient). More precisely:

Christophersen computation: dim T^1 = 53
Artin method computation before quotient: 109
Trivial coordinate-change directions: 56
Artin method computation after quotient: 53

# Computation of T2

To find that the dimension of T2 is 12
and that there exists a linear lift,
we used these scripts:
```
random_second_order_lift_test.sage
random_second_order_lift_test_v2.sage
```
and then IA came up with the idea
of "obstruction quadrics", and
produced the exploratory script
```
compute_obstruction_quadrics.sage
```

# Summary so far

- T1 = 53 confirmed. 
- T2 space = 12 computed.
- Generic random first-order directions
obstruct at order 2. 
- A raw obstruction computation gives 27 
candidate quadrics. 
- Need projection to the canonical 
12-dimensional T2 before claiming final 
equations.

# June 16-17, 2026

Objectives:

1. Continue looking for the second-order
   lifts.
2. Wire in Lean to proof-check dim T^1 = 53.
3. Prepare a tex document explaining the
   theory to not get lost in what's going on.

Output:

1. Found an explicit order-2 lift.
2. ChatGPT says we proved in lean that
   dim T^1 = 53, as expected.

Next steps:

1. ChatGPT suggests trying to find an order-3
   lift and only after that try to guess
   an actual family.
2. Understand how does lean work,
   or actually understand the formula myself
   and make sure it's correct.

# June 18, 2026

Today we tested more lifts up to degree 30.
Somehow there were no new restrictions
after order 3, so we had a great order-3
candidate. We were working with a finite
field, so we tested with another finite
field to check if everything was a
coincidence, and, promisingly, it also 
worked. So we passed to Q.
And then we noticed that unfortunately
the family obtained this way is not flat.

Also, at some point of the Lean verification
I encountered coding difficulties that
require a bit of human thinking to resolve.

Positive:
  - order-30 finite-field lift terminates 
    cubically
  - QQ cubic formal lift verified modulo I
  - second-prime support replay works
  - independent QQ verifier added

Negative:
  - naive ideal J=(F_{j}(t)) is not flat
  - t-saturation changes special fiber
  - Lean verification attempt hit 
    coding/formalization wall
