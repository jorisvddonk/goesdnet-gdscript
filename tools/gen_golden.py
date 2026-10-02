#!/usr/bin/env python3
"""Run the reference C modules over the fixture data and record golden outputs.

Writes:
  tests/fixtures/cases.json     - the list of cases
  tests/fixtures/golden/*.txt   - stdout captured from the C modules
  tests/fixtures/golden/*.comm  - COMM.BIN produced by `st`
"""

import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FIX = ROOT / "tests" / "fixtures"
DATA = FIX / "data"
GOLD = FIX / "golden"
BIN = ROOT / "tools" / "reference" / "bin"

CASES = [
    ("cat", "cat_noargs", []),
    ("cat", "cat_fenia", ["FENIA"]),
    ("cat", "cat_lava_lamp", ["LAVA_LAMP"]),
    ("cat", "cat_lava_lamp_multi_arg", ["LAVA", "LAMP"]),
    ("cat", "cat_lava_lamp_records_1_2", ["LAVA_LAMP:1..2"]),
    ("cat", "cat_lava_lamp_record_2", ["LAVA_LAMP:2"]),
    ("cat", "cat_ambiguous_nova", ["NOVA"]),
    ("cat", "cat_novacula", ["NOVACULA"]),
    ("cat", "cat_crystal_blue", ["CRYSTAL_BLUE"]),
    ("cat", "cat_not_found", ["GHOST_OBJECT"]),
    ("cat", "cat_invalid_name", ["THIS_NAME_IS_FAR_TOO_LONG"]),

    ("where", "where_noargs", []),
    ("where", "where_lava_lamp", ["LAVA", "LAMP"]),
    ("where", "where_lava_lamp_underscore", ["LAVA_LAMP"]),
    ("where", "where_crystal_blue", ["CRYSTAL", "BLUE"]),
    ("where", "where_crystal_blue_underscore", ["CRYSTAL_BLUE"]),
    ("where", "where_suricrasia", ["SURICRASIA"]),
    ("where", "where_novacula", ["NOVACULA"]),
    ("where", "where_not_found", ["GHOST_OBJECT"]),

    ("par", "par_noargs", []),
    ("par", "par_fenia", ["FENIA"]),
    ("par", "par_lava_lamp", ["LAVA_LAMP"]),
    ("par", "par_crystal_blue", ["CRYSTAL_BLUE"]),
    ("par", "par_suricrasia", ["SURICRASIA"]),
    ("par", "par_novacula", ["NOVACULA"]),

    ("dl", "dl_noargs", []),
    ("dl", "dl_fenia", ["FENIA"]),
    ("dl", "dl_lava_lamp", ["LAVA_LAMP"]),
    ("dl", "dl_crystal_blue", ["CRYSTAL_BLUE"]),
    ("dl", "dl_novacula", ["NOVACULA"]),

    ("st", "st_noargs", []),
    ("st", "st_fenia", ["FENIA"]),
    ("st", "st_lava_lamp", ["LAVA_LAMP"]),
    ("st", "st_crystal_blue", ["CRYSTAL_BLUE"]),
    ("st", "st_novacula", ["NOVACULA"]),
]


def main() -> int:
    for m in ("cat", "where", "par", "dl", "st"):
        if not (BIN / m).exists():
            print(f"missing reference binary: {BIN/m} (run tools/build_reference.sh)", file=sys.stderr)
            return 1

    GOLD.mkdir(parents=True, exist_ok=True)
    cases_out = []

    for module, name, args in CASES:
        with tempfile.TemporaryDirectory() as tmp:
            data = Path(tmp)
            shutil.copy(DATA / "STARMAP.BIN", data / "STARMAP.BIN")
            shutil.copy(DATA / "GUIDE.BIN", data / "GUIDE.BIN")
            env = dict(os.environ)
            env["NOCTIS_DATA_DIR"] = str(data)
            proc = subprocess.run(
                [str(BIN / module), *args],
                cwd=str(data),
                env=env,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            golden_name = f"{name}.txt"
            (GOLD / golden_name).write_bytes(proc.stdout)
            entry = {
                "module": module,
                "name": name,
                "args": args,
                "golden": golden_name,
            }
            comm = data / "COMM.BIN"
            if comm.exists():
                comm_name = f"{name}.comm"
                shutil.copy(comm, GOLD / comm_name)
                entry["comm"] = comm_name
                entry["comm_hex"] = comm.read_bytes().hex()
            cases_out.append(entry)
            print(f"{name}: {len(proc.stdout)} bytes stdout")

    (FIX / "cases.json").write_text(json.dumps(cases_out, indent=2) + "\n")
    print(f"wrote {FIX/'cases.json'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
