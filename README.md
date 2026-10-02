# goesnet-gdscript

A native **GDScript** port of the [αcτµαlly pδrταblε goεsneτ](../actually-portable-goesnet)
modules — the GOESNET tools that read the Noctis IV (Plus) `STARMAP.BIN` /
`GUIDE.BIN` databases and print the galactic guide, map, parsis analysis,
dependency listing and target-set commands.

The original modules are C programs built against Cosmopolitan libc
(`cat`, `where`, `par`, `dl`, `st`). This port keeps their behaviour
**byte-for-byte**: every module produces the exact same 21-column terminal
stream as the reference binaries.

## Usage

`scripts/` contains bare, self-contained GDScript library files. Drop them into
a Godot 4 project (or point your project's script search path at them) and use
the `class_name` entry points:

```gdscript
var cat := GoCat.new()
print(cat.run(PackedStringArray(["FELYSIA"])))

var par := GoPar.new()
print(par.run(PackedStringArray(["FENIA"])))

var dl := GoDl.new()
print(dl.run(PackedStringArray(["LAVA", "LAMP"])))
```

Each module exposes `run(args: PackedStringArray) -> String`, where `args` is
the argument list **without** the program name (`argv[1:]`). The returned string
is the complete output stream, including the Noctis column padding (there are no
newlines, exactly as in the C programs).

| C module | GDScript class | Helper |
|----------|----------------|--------|
| `cat.c`  | `GoCat`        | galactic guide records |
| `where.c`| `GoWhere`      | parent-star lookup |
| `par.c`  | `GoPar`        | parsis (coordinates) |
| `dl.c`   | `GoDl`         | dependency / moon listing |
| `st.c`   | `GoSt`         | writes `COMM.BIN` targets |
| `compat.h` / `fileops.h` / `brtl.h` | `NoctisCompat`, `GoesnetBrtl` | Noctis globals, file IO, RNG |

### Data files

Data access mirrors the C behaviour: `NOCTIS_DATA_DIR` is tried first, then the
current working directory, then `../data`. Set the environment variable before
calling a module:

```gdscript
OS.set_environment("NOCTIS_DATA_DIR", "/path/to/Noctis-IV-Plus/data")
```

## Tests

The port is verified against the original C modules, compiled natively through a
small libc shim (`tools/reference/`). Fixtures are a compact, deterministic
subset of the real Noctis data.

```bash
# run the full GDScript suite (170 checks)
tools/run_tests.sh

# or directly (GODOT=/path/to/Godot works too)
GODOT=/Applications/Godot.app/Contents/MacOS/Godot tools/run_tests.sh
```

On the first run Godot needs to scan the project (build the global class cache):

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --import
```

Suites:

| Suite      | What it checks |
|------------|----------------|
| `brtl`     | 16/32-bit RNG and truncation semantics vs. the C `brtl.h` |
| `compat`   | `msg` padding, C-string helpers, `atoi`, `fpart`, `zrandom` |
| `find`     | name search, ambiguity, `Removed:` records, planet id adjustment |
| `isthere`  | sector scan / coordinate derivation, including field amplification |
| `unfreeze` | `CURRENT.BIN` field order and integer/float widths |
| `probe`    | full `prepare_nearstar` planet/moon arrays across 12 systems |
| `golden`   | byte-for-byte stdout + `COMM.BIN` for every module/case |

### Regenerating fixtures / oracles

```bash
python3 tests/fixtures/generate_fixtures.py   # needs NOCTIS_SOURCE_DATA
bash tools/build_reference.sh                 # builds reference C binaries
python3 tools/gen_golden.py                   # records golden stdout/COMM.BIN
python3 tools/gen_probe.py                    # records prepare_nearstar/isthere
```

`tests/fixtures/generate_fixtures.py` reads the real data from
`NOCTIS_SOURCE_DATA` (default `~/projects/Noctis-IV-Plus/data`) and writes the
committed mini fixtures under `tests/fixtures/data/`.

### Note on the reference oracle

The reference `cat.c` performs an 84-byte `read` into `mblock_subject`, relying
on `mblock_message` being adjacent in memory. The vendored copy under
`tools/reference/src/` reads the 8-byte subject and 76-byte message explicitly
so the oracle is well-defined; the GDScript port follows the same intended
layout.
