"""Freeze the selected GF(32003) cubic lift without resolving it later."""

from pathlib import Path

_SR_ENVIRONMENT_SKIP_SMOKE = True
load("code/rl/sr_environment.sage")

OUTPUT_DIR = Path.cwd() / "code" / "rl" / "cache"
SOBJ_FILE = OUTPUT_DIR / "flat_cubic_candidate_GF32003.sobj"
TEXT_FILE = OUTPUT_DIR / "flat_cubic_candidate_GF32003.txt"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

y = vector(K, T1_DIM)
y[0] = 1403
y[2] = 30586
y[3] = 25586
y[19] = 4225
y[33] = 3849
y[34] = 8966
y[41] = 27546

# This is the sole lifting call.  Everything saved below is the particular
# representative returned by this call.
result = lift_to_third_order(y)
if not result["exists"]:
    raise RuntimeError(
        "selected direction did not lift: %s" % result["obstruction"]
    )

candidate = {
    "characteristic": int(K.characteristic()),
    "field": K,
    "T1_DIM": T1_DIM,
    "RAW_DIM": RAW_DIM,
    "y": vector(K, list(y)),
    "first_order_corrections": tuple(result["first_order_corrections"]),
    "second_order_corrections": tuple(result["second_order_corrections"]),
    "third_order_corrections": tuple(result["third_order_corrections"]),
    "generators": tuple(result["generators"]),
    "coordinate_metadata": {
        "raw_index_formula": "generator_index * 104 + monomial_index",
        "generator_exponents": tuple(_generator_exponents),
        "correction_exponents": tuple(_correction_exponents),
        "variable_names": tuple(str(variable) for variable in _x),
        "t_variable": str(t),
        "generator_count": _N_GENERATORS,
        "correction_monomial_count": _N_CORRECTION_MONOMIALS,
    },
}
save(candidate, str(SOBJ_FILE))

with open(TEXT_FILE, "w") as output:
    output.write("Flat cubic candidate over GF(32003)\n")
    output.write("====================================\n\n")
    output.write("Nonzero T^1 coordinates:\n")
    for index, coefficient in enumerate(y):
        if coefficient:
            output.write("y[%d] = %s\n" % (index, coefficient))
    output.write("\nExact cubic generators:\n")
    for index, generator in enumerate(candidate["generators"]):
        output.write("F[%d] = %s\n" % (index, generator))

print("Saved", SOBJ_FILE)
print("Saved", TEXT_FILE)
