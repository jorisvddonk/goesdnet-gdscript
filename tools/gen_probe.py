#!/usr/bin/env python3
"""Build the C probe and record prepare_nearstar / isthere results as fixtures."""

import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REF = ROOT / "tools" / "reference"
SHIM = REF / "shim"
SRC = REF / "src"
OUT = ROOT / "tests" / "fixtures" / "probe"
PROBE = REF / "bin" / "probe"
CC = os.environ.get("CC", "clang")

NEARSTAR_CASES = [
    ("lava_lamp", 3690704, -4370114, -1304184),
    ("alexandros", 3352848, -4694601, -1274885),
    ("ferrium_n002", 3428560, -4060293, -686548),
    ("syamasundar", 3928560, -4310155, -1229625),
    ("blue_shadow", 4166416, -4003058, -1039179),
    ("alan_young", 3828560, -4547754, -1036719),
    ("lista_24", 3966416, -4766334, -893636),
    ("anthem", 4166416, -4803058, -1088856),
    ("xno4", 4166416, -4303058, -1074192),
    ("originish", 0, 0, 0),
    ("misc_a", 100000, 200000, 300000),
    ("misc_b", -500000, 250000, -750000),
]

ISTHERE_CASES = [
    ("lava_default", 0, 21034.919273902353),
    ("sc63_fieldamp", 1, 213.5312257256292),
    ("deus_ex_fieldamp", 1, 6476.846877693647),
    ("missing_fieldamp", 1, 3473.0),
    ("sc63_default", 0, 213.5312257256292),
    ("fenia", 0, 15995.519841678279),
]


def build_probe() -> None:
    PROBE.parent.mkdir(parents=True, exist_ok=True)
    cmd = [
        CC, "-std=gnu11", "-w", "-fno-builtin",
        "-Wno-error=return-mismatch", "-Wno-return-mismatch",
        "-I", str(SHIM), "-I", str(SRC),
        "-o", str(PROBE), str(REF / "probe.c"), "-lm",
    ]
    subprocess.run(cmd, check=True)


def run(args) -> str:
    proc = subprocess.run([str(PROBE), *[str(a) for a in args]],
                          stdout=subprocess.PIPE, check=True)
    return proc.stdout.decode("ascii")


def main() -> int:
    build_probe()
    OUT.mkdir(parents=True, exist_ok=True)
    near_files = []
    for name, x, y, z in NEARSTAR_CASES:
        text = run([x, y, z])
        (OUT / f"nearstar_{name}.txt").write_text(text)
        near_files.append({"name": name, "x": x, "y": y, "z": z,
                           "file": f"nearstar_{name}.txt"})

    is_files = []
    for name, amp, sid in ISTHERE_CASES:
        text = run(["--isthere", amp, repr(sid)])
        (OUT / f"isthere_{name}.txt").write_text(text)
        is_files.append({"name": name, "field_amplificator": amp, "id": sid,
                         "file": f"isthere_{name}.txt"})

    (OUT / "probe.json").write_text(
        json.dumps({"nearstar": near_files, "isthere": is_files}, indent=2) + "\n")
    print(f"wrote {len(near_files) + len(is_files)} probe fixtures to {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
