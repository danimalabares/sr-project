"""Independent loader for frozen historical y8,y20 branch families."""

from pathlib import Path


def _find_project_root():
    """Locate this subproject when invoked from the repository root or directly."""
    candidates = []
    try:
        candidates.append(Path(__file__).resolve().parent)
    except NameError:
        pass
    cwd = Path.cwd().resolve()
    candidates.extend([cwd] + list(cwd.parents))
    for candidate in candidates:
        if (
            candidate.name == "y8-y20-branch"
            and (candidate / "data").is_dir()
        ):
            return candidate
        nested = candidate / "serendipity" / "y8-y20-branch"
        if (nested / "data").is_dir():
            return nested
    raise RuntimeError("could not locate serendipity/y8-y20-branch")


PROJECT_ROOT = _find_project_root()


def load_family(y8_coefficient, y20_coefficient):
    """Load one frozen family without invoking any lifting machinery."""
    characteristic = 32003
    K_local = GF(characteristic)
    R_local = PolynomialRing(
        K_local,
        ["t"] + ["x%d" % i for i in range(8)],
        order="degrevlex",
    )
    t_local = R_local.gen(0)
    variables = R_local.gens()[1:]
    stem = "family_y8_%d_y20_%d_GF32003.sobj" % (
        int(y8_coefficient), int(y20_coefficient)
    )
    frozen = load(str(PROJECT_ROOT / "data" / stem))
    assert frozen["characteristic"] == characteristic
    generators_local = tuple(
        R_local(generator) for generator in frozen["generators"]
    )
    assert len(generators_local) == 16

    def x_degree(exponents):
        return sum(ZZ(exponent) for exponent in exponents[1:])

    assert all(
        all(x_degree(exponents) == 3 for exponents in generator.dict())
        for generator in generators_local
    )
    ideal_local = R_local.ideal(generators_local)
    generator_exponents = frozen["coordinate_metadata"][
        "generator_exponents"
    ]
    original_generators = tuple(
        prod(
            variable**int(exponent)
            for variable, exponent in zip(variables, exponents)
        )
        for exponents in generator_exponents
    )
    original_sr_ideal = R_local.ideal(original_generators)
    return {
        "K": K_local,
        "R": R_local,
        "t": t_local,
        "variables": variables,
        "y": vector(K_local, list(frozen["y"])),
        "generators": generators_local,
        "ideal": ideal_local,
        "original_sr_ideal": original_sr_ideal,
        "frozen": frozen,
        "pair": (int(y8_coefficient), int(y20_coefficient)),
    }
