"""Test representative nonzero fibres, using a proven rescaling if present."""

import time

_SERENDIPITY_RESCALING_LIBRARY = True
load("serendipity/check_fibre_rescaling.sage")
_SERENDIPITY_SMOOTHNESS_LIBRARY = True
load("serendipity/test_smoothness.sage")

sample_values = [K(value) for value in (1, 2, 3, 5, 7)]
all_nonzero_isomorphic = (
    rescaling_result["integer_solution_exists"]
    and rescaling_result["identities_verified"]
)
values_to_test = sample_values[:1] if all_nonzero_isomorphic else sample_values

started = time.perf_counter()
fibre_results = []
smooth_value = None
for value in values_to_test:
    result = test_fibre_smoothness(value)
    fibre_results.append(result)
    print_smoothness_result(result)
    if result["smooth"] is True:
        smooth_value = value
        break

if smooth_value is not None:
    conclusion = "A smooth fibre was found; the generic fibre is smooth."
elif all_nonzero_isomorphic:
    conclusion = (
        "The tested t=1 fibre is singular, and the verified integer "
        "rescaling shows that every nonzero fibre, including the "
        "geometric generic fibre, is singular."
    )
else:
    conclusion = "No smooth fibre found among the sampled values."

summary = {
    "requested_values": tuple(sample_values),
    "tested_values": tuple(result["t_value"] for result in fibre_results),
    "skipped_values": tuple(sample_values[len(fibre_results):]),
    "all_nonzero_fibres_diagonally_isomorphic": all_nonzero_isomorphic,
    "rescaling": rescaling_result,
    "fibre_results": tuple(fibre_results),
    "smooth_fibre_found": smooth_value is not None,
    "smooth_t_value": smooth_value,
    "conclusion": conclusion,
    "runtime": time.perf_counter() - started,
}

save(summary, "serendipity/data/nonzero_fibre_smoothness_results.sobj")
with open(
    "serendipity/data/nonzero_fibre_smoothness_results.txt", "w"
) as output:
    output.write("Nonzero fibre smoothness samples over GF(32003)\n")
    output.write("requested values: %s\n" % (tuple(sample_values),))
    output.write("tested values: %s\n" % (summary["tested_values"],))
    output.write("skipped values: %s\n" % (summary["skipped_values"],))
    output.write(
        "all nonzero fibres diagonally isomorphic: %s\n"
        % all_nonzero_isomorphic
    )
    output.write("variable weights: %s\n" % (rescaling_result["x_weights"],))
    output.write(
        "generator weights: %s\n"
        % (rescaling_result["generator_weights"],)
    )
    for result in fibre_results:
        output.write(
            "t=%s: smooth=%s, runtime=%.6f seconds\n"
            % (result["t_value"], result["smooth"], result["runtime"])
        )
    output.write("%s\n" % conclusion)
    output.write("total runtime: %.6f seconds\n" % summary["runtime"])

if all_nonzero_isomorphic:
    print(
        "The verified rescaling makes all nonzero fibres isomorphic; "
        "the full Jacobian calculation was therefore run only at t=1."
    )
print(conclusion)
print("values actually tested: %s" % (summary["tested_values"],))
print("total runtime: %.6f seconds" % summary["runtime"])
