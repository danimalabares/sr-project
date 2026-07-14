# 04_candidate_branch_flatness_diagnostics.sage
#
# Summarize the constructive status of the known QQ cubic family from
# code/cotangent/order2, using the cached flatness-inspection data.
#
# Run from:
#   code/more-lifting
#
# Suggested invocation:
#   HOME=/tmp sage 04_candidate_branch_flatness_diagnostics.sage

INSPECTION_FILE = "../cotangent/order2/cache/cubic_family_QQ_flatness_failure_inspection.sobj"
PICKLE_FILE = "../cotangent/part-1.pkl"
OUT_FILE = "cache/04_candidate_branch_flatness_diagnostics.log"

out = open(OUT_FILE, "w")


def pr(s=""):
    print(s)
    out.write(str(s) + "\n")
    out.flush()


def shift_old_sr_name_to_x0(s):
    # part-1.pkl uses x1,...,x8 while the QQ[t,x0,...,x7] flatness scripts
    # use x0,...,x7. Shift indices by -1 for comparison.
    for i in range(8, 0, -1):
        s = s.replace("x%d" % i, "X%d" % (i - 1))
    return s.replace("X", "x")


pr("Loading " + INSPECTION_FILE)
inspection = load(INSPECTION_FILE)

pr("Loading " + PICKLE_FILE)
import pickle
with open(PICKLE_FILE, "rb") as f:
    data = pickle.load(f)

sr_generators = [shift_old_sr_name_to_x0(str(g)) for g in data["I"].gens()]
K0_gb = [str(g) for g in inspection["K0_groebner_basis"]]

extra_K0_gb = [g for g in K0_gb if g not in sr_generators]
missing_sr_gb = [g for g in sr_generators if g not in K0_gb]

pr("")
pr("Constructive Branch Diagnostic")
pr("==============================")
pr("")
pr("Known facts from code/cotangent/order2:")
pr("  - a formal branch exists to order 30 over GF(32003);")
pr("  - a sparse QQ cubic ansatz G1,G2,G3 was recovered and verified modulo I;")
pr("  - but the naive generated ideal J=(F_1(t),...,F_16(t)) is not flat over QQ[t].")

pr("")
pr("Flatness status of the QQ cubic family")
pr("--------------------------------------")
pr("J:(t) == J : %s" % inspection["colon_eq_J"])
pr("number of explicit t-torsion witnesses : %d" % len(inspection["colon_torsion_witnesses"]))
pr("t-saturation steps needed : %s" % inspection["sat_steps"])
pr("final K = J:t^infty is t-saturated : %s" % inspection["K_t_saturated"])

pr("")
pr("First colon-torsion witnesses")
pr("-----------------------------")
for i, w in enumerate(inspection["colon_torsion_witnesses"]):
    pr("witness %d:" % i)
    pr("  remainder = %s" % w["remainder"])
    pr("  t * remainder mod J = %s" % w["t_times_remainder_mod_J"])
    pr("  remainder(t=0) mod I = %s" % w["specialization_t0_mod_I"])

pr("")
pr("Special fiber after saturation")
pr("------------------------------")
pr("K_0 == I : %s" % inspection["K0_eq_I"])
pr("I subset K_0 : %s" % inspection["I_contained_in_K0"])
pr("K_0 subset I : %s" % inspection["K0_contained_in_I"])
pr("number of K_0 generators kept in cache : %d" % inspection["n_K0_gens_unique"])

pr("")
pr("Hilbert data")
pr("------------")
I_inv = inspection["I_invariants"]
K0_inv = inspection["K0_invariants"]
pr("I  Hilbert polynomial  = %s" % I_inv["hilbert_polynomial"]["value"])
pr("I  degree              = %s" % I_inv["degree_from_hilbert_polynomial"]["value"])
pr("K0 Hilbert polynomial  = %s" % K0_inv["hilbert_polynomial"]["value"])
pr("K0 degree              = %s" % K0_inv["degree_from_hilbert_polynomial"]["value"])

pr("")
pr("Groebner-basis comparison")
pr("-------------------------")
pr("shifted SR generators appearing in K0 Groebner basis : %d / %d" % (
    len(sr_generators) - len(missing_sr_gb), len(sr_generators)
))
pr("extra K0 Groebner-basis generators beyond SR : %d" % len(extra_K0_gb))
for g in extra_K0_gb:
    pr("  %s" % g)

pr("")
pr("Interpretation")
pr("--------------")
pr("The saturated special fiber is not an unrelated scheme: it contains the")
pr("full shifted SR ideal, but also four extra equations.")
pr("Equivalently, K_0 = I + (extra equations), so the degree drops from 20 to 16.")
pr("Thus the formal branch is real, but the current cubic generator ansatz does")
pr("not yet produce a flat family with special fiber exactly SR(M).")

pr("")
pr("Constructive repair target")
pr("--------------------------")
pr("Any successful repair of this branch must do both:")
pr("  1. remove the t-torsion in J;")
pr("  2. avoid creating the four extra special-fiber equations above after saturation.")
pr("This points toward solving for the family ideal itself, or enlarging the")
pr("generator/syzygy ansatz beyond the current sparse cubic truncation.")

out.close()
