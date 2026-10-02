class_name GoesnetBrtl
extends RefCounted

static var _seed: int = 1

static func to_u16(value) -> int:
	return int(value) & 0xFFFF

static func to_i16(value) -> int:
	var v: int = int(value) & 0xFFFF
	if v >= 0x8000:
		v -= 0x10000
	return v

static func to_i32(value) -> int:
	var v: int = int(value) & 0xFFFFFFFF
	if v >= 0x80000000:
		v -= 0x100000000
	return v

static func srand(seed) -> void:
	_seed = to_u16(seed)

static func rand() -> int:
	_seed = to_i32(_seed * 0x015A4E35 + 1)
	return (_seed >> 16) & 0x7FFF

static func random(num) -> int:
	var r := rand()
	return to_i16((r * to_i16(num)) / 32768)

static func strupr_buf(buf: PackedByteArray) -> void:
	for i in range(buf.size()):
		var c := buf[i]
		if c >= 97 and c <= 122:
			buf[i] = c - 32
