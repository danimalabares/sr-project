"""Independent exact flatness certificate for the frozen family."""

import time

load("serendipity/family.sage")

assert len(F) == 16
assert all(
    sum(int(exponent) for exponent in exponents[1:]) == 3
    for generator in F
    for exponents in generator.dict()
)

expected_special_fibre = R.ideal(_expected_SR_generators)
special_fibre_equal = I_SR == expected_special_fibre
assert special_fibre_equal

colon_started = time.perf_counter()
colon_by_t = J.quotient(R.ideal(t))
colon_equal = colon_by_t == J
first_colon_seconds = time.perf_counter() - colon_started
assert colon_equal

# Repeat from J rather than reusing colon_by_t.
second_colon_started = time.perf_counter()
second_colon_by_t = J.quotient(R.ideal(t))
second_colon_equal = second_colon_by_t == J
second_colon_seconds = time.perf_counter() - second_colon_started
assert second_colon_equal
assert second_colon_by_t == colon_by_t

print("Serendipity family verified")
print("field: GF(32003)")
print("number of generators: 16")
print("special fibre equals original SR ideal: True")
print("J:t = J: True")
print("flat near t=0: True")
print("first colon runtime: %.6f seconds" % first_colon_seconds)
print("second colon runtime: %.6f seconds" % second_colon_seconds)
