"""Planned joint random search over second- and third-order parameters.

The later pipeline will:

1. fix a first-order direction y;
2. sample 109 second-order parameters and construct h;
3. test whether that chosen h reaches third order;
4. sample 109 third-order parameters and construct q;
5. evaluate the resulting cubic family for flatness.

This file deliberately contains no partial search implementation.
"""

print(
    "random_hq_search is not implemented yet; "
    "run random_q_search first."
)
