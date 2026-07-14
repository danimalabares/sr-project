# 16_legal_torsion_repair_targets.sage
#
# Classify the stable t-torsion/saturation witnesses from scripts 14-15 by
# whether their t=0 monomial lies in the SR(M) ideal.  If the desired family
# has special fiber exactly SR(M), only witnesses already in I are legal as
# special-fiber repair terms.
#
# Run from:
#   code/more-lifting
#
# Suggested invocation:
#   HOME=/tmp sage 16_legal_torsion_repair_targets.sage

OUT_FILE = "cache/16_legal_torsion_repair_targets.log"

K = GF(32003)
S = PolynomialRing(K, ["x%d" % i for i in range(8)], order="degrevlex")
x = S.gens()

# SR(M), shifted from cotangent/part-1.sage variables x1,...,x8 to x0,...,x7.
sr_gens = [
    x[5] * x[6] * x[7],
    x[3] * x[5] * x[7],
    x[2] * x[6] * x[7],
    x[2] * x[4] * x[6],
    x[2] * x[3] * x[7],
    x[1] * x[6] * x[7],
    x[1] * x[4] * x[6],
    x[1] * x[4] * x[5],
    x[1] * x[3] * x[6],
    x[1] * x[3] * x[5],
    x[0] * x[3] * x[5],
    x[0] * x[3] * x[4],
    x[0] * x[2] * x[7],
    x[0] * x[2] * x[5],
    x[0] * x[2] * x[4],
    x[0] * x[1] * x[4],
]
I = S.ideal(sr_gens)
gb_I = I.groebner_basis()

layers = [
    ("layer1", [
        x[0] * x[2] * x[3] * x[7],
        x[0] * x[2] * x[3] * x[4],
        x[2]^2 * x[3]^3 * x[7]^2,
    ]),
    ("layer2", [
        x[2] * x[3]^2 * x[7],
        x[0] * x[1] * x[4]^2,
    ]),
    ("layer3", [
        x[1] * x[3] * x[4] * x[7],
        x[1] * x[3] * x[4]^2,
    ]),
    ("layer4", [
        x[1] * x[3]^2 * x[7]^2,
        x[1]^2 * x[4]^3,
    ]),
]

out = open(OUT_FILE, "w")


def pr(s=""):
    print(s)
    out.write(str(s) + "\n")
    out.flush()


def divides(a, b):
    ea = tuple(next(iter(a.dict().keys())))
    eb = tuple(next(iter(b.dict().keys())))
    return all(ea[i] <= eb[i] for i in range(8))


pr("Legal torsion repair targets")
pr("----------------------------")
pr("A monomial is legal as a special-fiber repair term only if it is in I.")
pr("")
pr("SR(M) generators:")
for g in sr_gens:
    pr("  %s" % g)
pr("")

legal = []
illegal = []
for layer_name, mons in layers:
    pr(layer_name)
    for m in mons:
        rem = S(m).reduce(gb_I)
        in_I = (rem == 0)
        divisors = [g for g in sr_gens if divides(g, m)]
        target = legal if in_I else illegal
        target.append((layer_name, m))
        pr("  %-24s in I = %-5s divisors = %s" % (m, in_I, divisors))
    pr("")

pr("Summary")
pr("-------")
pr("legal layers/monomials:")
for layer_name, m in legal:
    pr("  %s: %s" % (layer_name, m))
pr("")
pr("illegal layers/monomials:")
for layer_name, m in illegal:
    pr("  %s: %s" % (layer_name, m))
pr("")
pr("Interpretation")
pr("--------------")
pr("Adding layer1 and layer2 monomials can preserve the raw t=0 ideal I, but")
pr("scripts 14-15 show that doing so merely pushes torsion to layer3.  Since")
pr("layer3 and layer4 are not in I, a valid repair must prevent those witnesses")
pr("from appearing; it cannot add them as special-fiber generators.")

out.close()
