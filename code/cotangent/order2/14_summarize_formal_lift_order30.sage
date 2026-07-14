# 11_summarize_formal_lift.sage
#
# Summarize the formal lift found by
# 10_iterate_lifts_from_order5.sage.

INPUT_FILE = "cache/formal_lift_to_order30.sobj"

d = load(INPUT_FILE)

print("Formal lift summary")
print("===================")
print()
print("file =", INPUT_FILE)
print("prime =", d["prime"])
print("status =", d["status"])
print("start_order =", d["start_order"])
print("max_order_target =", d["max_order_target"])
print("max_order_reached =", d["max_order_reached"])
print("n_params =", d["n_params"])
print("n_corr =", d["n_corr"])
print("n_unknowns =", d["n_unknowns"])
print()

print("Ranks by order")
print("--------------")
for k in sorted(d["rank_A_by_order"]):
    print(
        "order", k,
        "rank_A =", d["rank_A_by_order"][k],
        "rank_augmented =", d["rank_augmented_by_order"][k],
        "residual_zero =", d["residual_zero_by_order"][k],
    )

print()

def nnz(v):
    return sum(1 for c in v if c != 0)

print("Generator corrections")
print("---------------------")
for k in sorted(d["gen_vectors"]):
    v = d["gen_vectors"][k]
    print("G_%d length = %d nnz = %d" % (k, len(v), nnz(v)))

print()

print("Syzygy corrections")
print("------------------")
for k in sorted(d["syz_vectors"]):
    v = d["syz_vectors"][k]
    print("A_%d length = %d nnz = %d" % (k, len(v), nnz(v)))
