#!/usr/bin/env bash
# Compile the original Cosmopolitan-based GOESNET modules natively using a tiny
# libc shim. The resulting binaries act as the reference oracle for the GDScript
# port (see tools/gen_golden.py).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REF="$ROOT/tools/reference"
OUT="${1:-$REF/bin}"
CC="${CC:-clang}"

mkdir -p "$OUT"

for m in cat where par dl st; do
	"$CC" -std=gnu11 -w -fno-builtin \
		-Wno-error=return-mismatch -Wno-return-mismatch \
		-I "$REF/shim" -I "$REF/src" \
		-o "$OUT/$m" "$REF/src/$m.c" -lm
	echo "built $OUT/$m"
done
