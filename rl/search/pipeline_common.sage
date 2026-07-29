"""Shared deterministic record and sampling helpers for the search stages."""

import hashlib
import random
from datetime import datetime
from pathlib import Path


def _pipeline_y(y):
    coefficients = list(y)
    if len(coefficients) != T1_DIM:
        raise ValueError(
            "expected %d T^1 coordinates, got %d"
            % (T1_DIM, len(coefficients))
        )
    return vector(K, coefficients)


def _pipeline_corrections(corrections, label):
    corrections = list(corrections)
    if len(corrections) != _N_GENERATORS:
        raise ValueError(
            "expected %d %s corrections, got %d"
            % (_N_GENERATORS, label, len(corrections))
        )
    coerced = tuple(R(correction) for correction in corrections)
    # Also rejects monomials outside the cached 1664-coordinate convention.
    _corrections_to_direction(coerced)
    return coerced


def _canonical_y(y):
    return ("y", tuple(int(coefficient) for coefficient in _pipeline_y(y)))


def _canonical_corrections(corrections, label):
    corrections = _pipeline_corrections(corrections, label)
    return (
        label,
        tuple(
            tuple(
                sorted(
                    (
                        tuple(int(exponent) for exponent in exponents),
                        int(K(coefficient)),
                    )
                    for exponents, coefficient in correction.dict().items()
                    if coefficient
                )
            )
            for correction in corrections
        ),
    )


def h_input_hash(y, seed):
    return _short_input_hash(
        (_canonical_y(y), ("seed", int(seed)))
    )


def q_input_hash(y, h, seed):
    return _short_input_hash(
        (
            _canonical_y(y),
            _canonical_corrections(h, "h"),
            ("seed", int(seed)),
        )
    )


def f_input_hash(y, h, q):
    return _short_input_hash(
        (
            _canonical_y(y),
            _canonical_corrections(h, "h"),
            _canonical_corrections(q, "q"),
        )
    )


def _short_input_hash(payload):
    serialized = repr(payload).encode("ascii")
    return hashlib.sha256(serialized).hexdigest()[:6]


def _sample_affine_parameters(dimension, seed):
    """Choose one reproducible sparse point in the full affine parameter space."""
    rng = random.Random(int(seed))
    dimension = int(dimension)
    if dimension == 0:
        return ()
    parameters = [K.zero()] * dimension
    index = rng.randrange(dimension)
    parameters[index] = K(rng.randrange(1, int(K.order())))
    return tuple(parameters)


def _save_stage_record(
    record,
    stage,
    input_hash,
    input_identifier=None,
    runs_directory="rl/runs",
    timestamp=None,
):
    """Save one dictionary, never overwriting an identical daily filename."""
    if stage not in ("h", "q", "f"):
        raise ValueError("unknown pipeline stage %r" % stage)
    directory = Path(runs_directory)
    directory.mkdir(parents=True, exist_ok=True)
    if timestamp is None:
        moment = datetime.now()
    elif isinstance(timestamp, datetime):
        moment = timestamp
    else:
        moment = datetime.strptime(str(timestamp), "%Y%m%dT%H%M%S")

    timestamp_text = moment.strftime("%Y%m%dT%H%M%S")
    date_text = moment.strftime("%Y%m%d")
    path = directory / (
        "%s-%s-%s.sobj" % (stage, date_text, input_hash)
    )
    if path.exists():
        print("record already exists; left untouched: %s" % path.resolve())
        return load(str(path))

    saved = dict(record)
    saved["stage"] = stage
    saved["input_hash"] = input_hash
    saved["input_identifier"] = input_hash
    if input_identifier is not None:
        saved["source_identifier"] = str(input_identifier)
    saved["timestamp"] = timestamp_text
    saved["output_file"] = str(path.resolve())
    save(saved, str(path))
    return saved
