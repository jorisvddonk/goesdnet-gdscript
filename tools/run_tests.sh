#!/usr/bin/env bash
# Run the GDScript test suite headlessly.
#   GODOT=/path/to/Godot tools/run_tests.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT:-/Applications/Godot.app/Contents/MacOS/Godot}"

if [ ! -f "$ROOT/.godot/global_script_class_cache.cfg" ]; then
	"$GODOT" --headless --path "$ROOT" --import >/dev/null 2>&1 || true
fi

"$GODOT" --headless --path "$ROOT" -s res://tests/run_tests.gd
