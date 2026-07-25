"""Independent loader for the frozen cubic family over GF(32003)."""

from pathlib import Path

K = GF(32003)
R = PolynomialRing(
    K,
    ["t"] + ["x%d" % i for i in range(1, 9)],
    order="degrevlex",
)
t, x1, x2, x3, x4, x5, x6, x7, x8 = R.gens()

DATA_FILE = (
    Path.cwd()
    / "serendipity"
    / "data"
    / "flat_cubic_candidate_GF32003.sobj"
)
frozen = load(str(DATA_FILE))

assert frozen["characteristic"] == K.characteristic()
F = tuple(R(generator) for generator in frozen["generators"])
assert len(F) == 16


def _x_degree(exponents):
    # The first exponent is the exponent of t.
    return sum(int(exponent) for exponent in exponents[1:])


for index, generator in enumerate(F):
    assert generator != 0
    assert all(_x_degree(exponents) == 3 for exponents in generator.dict())

J = R.ideal(F)

# Define the SR special fibre directly from the frozen generators.
F_at_t_zero = tuple(R(generator.subs({t: 0})) for generator in F)
I_SR = R.ideal(F_at_t_zero)

# Guard against accidentally replacing the intended SR ideal in the data.
_expected_SR_generators = (
    x6*x7*x8, x4*x6*x8, x3*x7*x8, x3*x5*x7,
    x3*x4*x8, x2*x7*x8, x2*x5*x7, x2*x5*x6,
    x2*x4*x7, x2*x4*x6, x1*x4*x6, x1*x4*x5,
    x1*x3*x8, x1*x3*x6, x1*x3*x5, x1*x2*x5,
)
assert I_SR == R.ideal(_expected_SR_generators)
