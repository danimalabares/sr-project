# M_FACETS.py
""" Facet list for Grünbaum's triangulated
3-sphere M.

Source: Grünbaum--Shephard original facet
list, as currently used in the SR(M)
computations.

Convention:
- vertices are labelled 1,...,8
- facets are tetrahedra, listed as 4-element
  lists """

FACETS = [ [1,2,3,4], [1,2,3,7], [1,2,6,7],
[1,3,4,7], [1,5,6,7], [2,3,4,5], [2,3,6,7],
[3,4,6,7], [3,4,5,6], [4,5,6,7], [2,3,5,8],
[2,3,6,8], [3,5,6,8], [1,2,6,8], [1,5,6,8],
[1,2,4,8], [2,4,5,8], [1,4,7,8], [1,5,7,8],
[4,5,7,8] ]


def normalized_facets():
    """
    Return facets as sorted tuples.
    This avoids accidental mutation of FACETS.
    """
    return [tuple(sorted(F)) for F in FACETS]


def vertices():
    """
    Return the sorted vertex set.
    """
    return sorted({v for F in FACETS for v in F})


if __name__ == "__main__":
    print("Number of vertices:", len(vertices()))
    print("Vertices:", vertices())
    print("Number of facets:", len(FACETS))
    print("Facets:")
    for F in normalized_facets():
        print(" ", F)
