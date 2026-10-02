#!/usr/bin/env python3
"""Generate small, deterministic STARMAP.BIN / GUIDE.BIN fixtures from real Noctis data.

Usage:
    NOCTIS_SOURCE_DATA=/path/to/Noctis-IV-Plus/data python3 generate_fixtures.py

The produced fixtures are committed so the test-suite is self-contained.
"""

import os
import struct
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT = HERE / "data"

IDSCALE = 0.00001
IDSCALE_TOL = IDSCALE

SYSTEM_STARS = [b"LAVA LAMP", b"ALEXANDROS", b"BLUE SHADOW", b"FENIA"]
EXTRA_PLANETS = [b"SURICRASIA"]


def source_data_dir() -> Path:
    env = os.environ.get("NOCTIS_SOURCE_DATA")
    if env:
        return Path(env)
    return Path.home() / "projects" / "Noctis-IV-Plus" / "data"


def load_starmap(path: Path):
    raw = path.read_bytes()
    header = raw[:4]
    recs = []
    off = 4
    while off + 32 <= len(raw):
        sid = struct.unpack_from("<d", raw, off)[0]
        label = raw[off + 8:off + 32]
        recs.append((sid, label))
        off += 32
    return header, recs


def load_guide(path: Path):
    raw = path.read_bytes()
    header = raw[:4]
    recs = []
    off = 4
    while off + 84 <= len(raw):
        subj = struct.unpack_from("<d", raw, off)[0]
        msg = raw[off + 8:off + 84]
        recs.append((subj, msg))
        off += 84
    return header, recs


def fpart(idv: float, label: bytes) -> int:
    if label[21:22] == b"P":
        no = (label[23] - 48) + 10 * (label[22] - 48)
        idv -= no
    idv = abs(idv)
    mult = 1e9
    attempts = 0
    while True:
        lid = float(int(idv))
        fp = mult * (idv - lid)
        mult *= 1000
        attempts += 1
        if not (fp < 1e6 and attempts < 44):
            break
    return int(fp)


def name_of(label: bytes) -> bytes:
    return label[:20].rstrip(b" ")


def build_starmap(source: Path) -> bytes:
    header, recs = load_starmap(source / "STARMAP.BIN")
    by_name = {}
    for sid, label in recs:
        by_name.setdefault((name_of(label), label[21:22]), []).append((sid, label))

    wanted = []
    seen = set()

    def add(rec):
        if rec[0] in seen:
            return
        seen.add(rec[0])
        wanted.append(rec)

    for star_name in SYSTEM_STARS:
        matches = by_name.get((star_name, b"S"))
        if not matches:
            raise SystemExit(f"star not found: {star_name!r}")
        sid, label = matches[0]
        add((sid, label))
        fp = fpart(sid, label)
        for other_id, other_label in recs:
            if sid + 1 - IDSCALE_TOL < other_id <= sid + 80 + IDSCALE_TOL:
                if fpart(other_id, other_label) == fp:
                    add((other_id, other_label))

    for planet_name in EXTRA_PLANETS:
        matches = by_name.get((planet_name, b"P"))
        if not matches:
            raise SystemExit(f"planet not found: {planet_name!r}")
        pid, plabel = matches[0]
        no = (plabel[23] - 48) + 10 * (plabel[22] - 48)
        star_id = pid - no
        parent = None
        for other_id, other_label in recs:
            if abs(other_id - star_id) <= IDSCALE_TOL:
                parent = (other_id, other_label)
                break
        if parent is None:
            raise SystemExit(f"parent star not found for: {planet_name!r}")
        add(parent)
        add((pid, plabel))

    for sid, label in wanted:
        if name_of(label) == b"FENIA":
            fp = fpart(sid, label)
            for other_id, other_label in recs:
                if sid + 1 - IDSCALE_TOL < other_id <= sid + 80 + IDSCALE_TOL:
                    if fpart(other_id, other_label) == fp:
                        add((other_id, other_label))
            break

    def synth_label(name: bytes, type_char: bytes, planet_nr: int) -> bytes:
        tail = type_char + f"{planet_nr:02d}".encode("ascii")
        return name.ljust(21) + tail

    synthetic = [
        (424242.000001, synth_label(b"NOVACULA", b"S", 0)),
        (424242.000002, synth_label(b"NOVARA", b"S", 0)),
        (424242.000003, synth_label(b"BLUE SHADOW II", b"S", 0)),
        (999999.000009, synth_label(b"GHOST OBJECT", b"S", 0)),
    ]
    removed_id = b"Removed:"
    synthetic.append((removed_id, synth_label(b"GHOST OBJECT", b"S", 0)))

    out = bytearray(header)
    emitted = set()
    for sid, label in synthetic:
        if sid in emitted:
            continue
        emitted.add(sid)
        out += struct.pack("<d", sid) if isinstance(sid, float) else sid
        out += label.ljust(24)[:24]
    for sid, label in wanted:
        out += struct.pack("<d", sid)
        out += label
    return bytes(out)


def guide_msg(text: str) -> bytes:
    raw = text.encode("ascii", "replace")
    return raw[:76].ljust(76, b"\x00")


def build_guide(source: Path, starmap_index) -> bytes:
    header, recs = load_guide(source / "GUIDE.BIN")

    def find_subject(name: bytes):
        for sid, label in starmap_index:
            if name_of(label) == name:
                return sid, label
        raise SystemExit(f"subject not found: {name!r}")

    out = bytearray(header)

    lava_id, lava_label = find_subject(b"LAVA LAMP")
    crystal_id, _ = find_subject(b"CRYSTAL BLUE")
    suri_id, suri_label = find_subject(b"SURICRASIA")

    entries = []
    entries.append((lava_id, guide_msg("LAVA LAMP: A TROUBLED SYSTEM WITH A LONG AND STORIED HISTORY.")))
    entries.append((lava_id, guide_msg("ITS PLANETS ARE RICH IN MINERALS BUT POOR IN HOSPITALITY.")))
    entries.append((lava_id, guide_msg("TRAVELLERS ARE ADVISED TO KEEP THEIR DISTANCE.")))
    entries.append((crystal_id, guide_msg("CRYSTAL BLUE IS THE FIRST PLANET OF THE LAVA LAMP SYSTEM.")))
    entries.append((crystal_id, guide_msg("IT IS COVERED ENTIRELY BY A SINGLE VAST OCEAN OF GLASS.")))
    entries.append((suri_id, guide_msg("SURICRASIA: ONE OF THE MOST BEAUTIFUL PLANETS IN THE WHOLE GALAXY.")))
    entries.append((suri_id, guide_msg("ITS SKY AT SUNRISE IS SIMPLY INSPIRING.")))

    for subj, msg in entries:
        out += struct.pack("<d", subj)
        out += msg
    return bytes(out)


def main() -> int:
    src = source_data_dir()
    if not (src / "STARMAP.BIN").exists():
        print(f"source STARMAP.BIN not found in {src}", file=sys.stderr)
        return 1
    OUT.mkdir(parents=True, exist_ok=True)
    sm = build_starmap(src)
    (OUT / "STARMAP.BIN").write_bytes(sm)

    _, recs = load_starmap(src / "STARMAP.BIN")
    index = []
    for sid, label in recs:
        index.append((sid, label))
    gd = build_guide(src, index)
    (OUT / "GUIDE.BIN").write_bytes(gd)

    print(f"wrote {OUT/'STARMAP.BIN'} ({len(sm)} bytes)")
    print(f"wrote {OUT/'GUIDE.BIN'} ({len(gd)} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
