# Basic scripts

1. `random_h_search.sage` takes
for input an order-1 direction $y$,
computes the space of compatible
order-2 lifts $h$ and chooses one randomly.
The output is either the valid pair $(y,h)$
ready to feed to `random_q_search.sage`;
or the result that the test failed.

2. `random_q_search.sage` takes for input an
   order-2-liftable choice $(y,h)$, computes
the space of compatible order-3 lifts $q$
and chooses one randomly. The output is
either the valid triple $(y,h,q)$ ready to
feed to `evaluate_candidate.sage`; or the
result that test failed.

3. `evaluate_candidate.sage`
takes for input an order-3-liftable
choice $(y,h,q)$ and runs the flatness
test. The output is the result of the test.

4. The three scripts above share a bunch
of code, which is stored in 
`pipeline_common.sage` for simplicity.

The outputs are stored in files like this:
```
rl/runs/h-20260729-a83f21.sobj
rl/runs/q-20260729-a83f21.sobj
rl/runs/f-20260729-a83f21.sobj
```
where `h`, `q` or `f` means this was produced 
by either of the functions 1, 2 or 3
in the list above. The number `20260729`
is the date, and `a83f21` is a short
identifier of the input data. The
file is a `.sobj` file
to be read in Sage/Python
and contains dictionary with the output
data collected.

NOTE: 29/07/2026. I accidentally noticed
that the "random" choices made in the above
functions are actually just fixing all
coordinates to be zero and assigning a
random nonzero value to a random entry of
the vector. So it's not completely random
but might be computationally reasonable for
the first runs.


## Exercise

To run the test on a specific 2-order
direction $(y,h)$, do...
 
you can check
the `.sobj` file produced in the
directory `rl/runs`.

# Iteration - here comes the statistics
