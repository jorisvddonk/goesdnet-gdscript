class_name NoctisCompat
extends RefCounted

const M_PI := 3.14159265358979323846
const M_PI_2 := 1.57079632679489661923
const M_PI_4 := 0.785398163397448309616
const deg := M_PI / 180.0

const star_classes := 12
const planet_types := 10
const avgmoons := 4
const maxbodies := 20 * avgmoons

const idscale := 0.00001

const planet_orb_scaling := 5.0
const avg_planet_sizing := 2.4
const moon_orb_scaling := 12.8
const avg_moon_sizing := 1.8

const DIVIDER := "&&&&&&&&&&&&&&&&&&&&&"
const MAX_OBJECTS_PER_STAR := 80
const F_PART_STAR_LABEL := "F-PARTTESTSTARLABEL Sxx"

const class_ray := [5000, 15000, 300, 20000, 15000, 1000, 3000, 2000, 4000, 1500, 30000, 250]
const class_rayvar := [2000, 10000, 200, 15000, 5000, 1000, 3000, 500, 5000, 10000, 1000, 10]
const class_act := [2, 4, 1, 6, 5, 10, 100, 1, 2, 1, 10, 1]
const class_planets := [12, 18, 8, 15, 20, 3, 0, 1, 7, 20, 2, 5]
const class_rgb := [
	63, 58, 40,
	30, 50, 63,
	63, 63, 63,
	63, 30, 20,
	63, 55, 32,
	32, 16, 10,
	32, 28, 24,
	10, 20, 63,
	63, 32, 16,
	48, 32, 63,
	40, 10, 10,
	0, 63, 63,
]
const planet_possiblemoons := [1, 1, 2, 3, 2, 2, 18, 2, 3, 20, 20]
const avg_planet_ray := [0.007, 0.003, 0.010, 0.011, 0.010, 0.008, 0.064, 0.009, 0.012, 0.125, 5.000]

var output: String = ""

var nsync := 1
var anti_rad := 1
var pl_search := 0
var field_amplificator := 0
var ilight := 63
var ilightv := 1
var charge := 3
var revcontrols := 0
var ap_targetting := 0
var ap_targetted := 0
var ip_targetting := 0
var ip_targetted := -1
var ip_reaching := 0
var ip_reached := 0
var ap_target_spin := 0
var ap_target_r := 0
var ap_target_g := 0
var ap_target_b := 0
var nearstar_spin := 0
var nearstar_r := 0
var nearstar_g := 0
var nearstar_b := 0
var gburst := 0
var menusalwayson := 1
var depolarize := 0

var sys := 4
var pwr := 15000
var dev_page := 0
var ap_target_class := 0
var f_ray_elapsed := 0
var nearstar_class := 0
var nearstar_nop := 0

var pos_x := 0.0
var pos_y := 0.0
var pos_z := -500.0
var user_alfa := 0.0
var user_beta := 0.0
var navigation_beta := 0.0
var ap_target_ray := 0.0
var nearstar_ray := 1000.0

var dzat_x := 3797120.0
var dzat_y := -4352112.0
var dzat_z := -925018.0
var ap_target_x := 0.0
var ap_target_y := 1e9
var ap_target_z := 0.0
var nearstar_x := 0.0
var nearstar_y := 1e9
var nearstar_z := 0.0
var helptime := 0.0
var ip_target_initial_d := 0.0
var requested_approach_coefficient := 1.0
var current_approach_coefficient := 1.0
var reaction_time := 0.01
var fcs_status_delay := 0
var psys := 4
var ap_target_initial_d := 0.0
var requested_vimana_coefficient := 1.0
var current_vimana_coefficient := 1.0
var vimana_reaction_time := 0.01
var lithium_collector := 0
var autoscreenoff := 0
var ap_reached := 0
var lifter := 0
var secs := 0.0

var object_id := 12345.0
var object_label: PackedByteArray
var s_object_id := 12345.0
var s_object_label: PackedByteArray
var mblock_id := 12345.0
var mblock_message: PackedByteArray
var subject_id := 12345.0
var objectname: PackedByteArray
var subjectname: PackedByteArray
var fcs_status: PackedByteArray

var laststar_x := 0.0
var laststar_y := 0.0
var laststar_z := 0.0
var laststar_id := 0.0
var _last_id_bytes: PackedByteArray = PackedByteArray()
var nearstar_identity := 0.0
var nearstar_nob := 0
var ap_target_id := 12345.0

var nearstar_p_type: PackedByteArray
var nearstar_p_moonid: PackedByteArray
var nearstar_p_owner: PackedInt32Array
var nearstar_p_ring: PackedFloat64Array
var nearstar_p_tilt: PackedFloat64Array
var nearstar_p_ray: PackedFloat64Array
var nearstar_p_orb_ray: PackedFloat64Array
var nearstar_p_orb_seed: PackedFloat64Array
var nearstar_p_orb_tilt: PackedFloat64Array
var nearstar_p_orb_orient: PackedFloat64Array
var nearstar_p_orb_ecc: PackedFloat64Array

var fh: FileAccess = null
var gh: FileAccess = null
var query := 0
var sts := 0
var analyzed_sectors_range := 0
var least := 0

var _removed := "Removed:".to_ascii_buffer()


func _init() -> void:
	object_label = _zero(25)
	s_object_label = _zero(25)
	subjectname = _zero(21)
	objectname = _zero(22)
	mblock_message = _zero(77)
	fcs_status = _zero(11)
	nearstar_p_type = _zero(maxbodies)
	nearstar_p_moonid = _zero(maxbodies)
	nearstar_p_owner = _zero_i32(maxbodies)
	nearstar_p_ring = _zero_f64(maxbodies)
	nearstar_p_tilt = _zero_f64(maxbodies)
	nearstar_p_ray = _zero_f64(maxbodies)
	nearstar_p_orb_ray = _zero_f64(maxbodies)
	nearstar_p_orb_seed = _zero_f64(maxbodies)
	nearstar_p_orb_tilt = _zero_f64(maxbodies)
	nearstar_p_orb_orient = _zero_f64(maxbodies)
	nearstar_p_orb_ecc = _zero_f64(maxbodies)


func _zero(n: int) -> PackedByteArray:
	var b := PackedByteArray()
	b.resize(n)
	return b


func _zero_i32(n: int) -> PackedInt32Array:
	var b := PackedInt32Array()
	b.resize(n)
	return b


func _zero_f64(n: int) -> PackedFloat64Array:
	var b := PackedFloat64Array()
	b.resize(n)
	return b


func msg(s) -> void:
	var t := str(s)
	if t.length() > 21:
		t = t.substr(0, 21)
	output += t
	var pad := 21 - t.length()
	if pad > 0:
		output += " ".repeat(pad)


func warn(_text, _line) -> void:
	pass


func cstr(b: PackedByteArray) -> String:
	var n := b.size()
	var i := 0
	while i < n and b[i] != 0:
		i += 1
	return b.slice(0, i).get_string_from_ascii()


func _strlen(b: PackedByteArray) -> int:
	var n := b.size()
	var i := 0
	while i < n and b[i] != 0:
		i += 1
	return i


func _byte(b: PackedByteArray, i: int) -> int:
	if i >= 0 and i < b.size():
		return b[i]
	return 0


func _mem_eq(a: PackedByteArray, b: PackedByteArray, n: int) -> bool:
	if a.size() < n or b.size() < n:
		return false
	for i in range(n):
		if a[i] != b[i]:
			return false
	return true


func _atoi_bytes(b: PackedByteArray, off: int) -> int:
	var i := off
	while i < b.size() and (b[i] == 32 or b[i] == 9 or b[i] == 10):
		i += 1
	var sign := 1
	if i < b.size() and (b[i] == 45 or b[i] == 43):
		if b[i] == 45:
			sign = -1
		i += 1
	var val := 0
	while i < b.size() and b[i] >= 48 and b[i] <= 57:
		val = val * 10 + (b[i] - 48)
		i += 1
	return sign * val


func _pad2(n: int) -> String:
	if n < 10:
		return "0" + str(n)
	return str(n)


func _f0(v: float) -> String:
	return str(int(round(v)))


func _name_buffer(s: String) -> PackedByteArray:
	var b := s.to_ascii_buffer()
	var out := _zero(22)
	var n: int = min(b.size(), 21)
	for i in range(n):
		out[i] = b[i]
	return out


func zrandom(r) -> float:
	return float(GoesnetBrtl.random(r) - GoesnetBrtl.random(r))


func open_starmap() -> FileAccess:
	return _open_data("STARMAP.BIN", FileAccess.READ)


func open_guide() -> FileAccess:
	return _open_data("GUIDE.BIN", FileAccess.READ)


func open_situation() -> FileAccess:
	return _open_data("CURRENT.BIN", FileAccess.READ)


func create_comm() -> FileAccess:
	return _open_data("COMM.BIN", FileAccess.WRITE)


func _open_data(name: String, mode: int) -> FileAccess:
	var d := OS.get_environment("NOCTIS_DATA_DIR")
	if d != "":
		var f := FileAccess.open(d + "/" + name, mode)
		if f != null:
			return f
	var f2 := FileAccess.open(name, mode)
	if f2 != null:
		return f2
	return FileAccess.open("../data/" + name, mode)


func find(starname: PackedByteArray) -> int:
	var ctc := _strlen(starname)
	if ctc > 20 or ctc <= 0:
		msg("INVALID OBJECT NAME.")
		return 0
	var n := 0
	var found := 0
	fh.seek(4)
	while true:
		var idb := fh.get_buffer(8)
		if idb.size() != 8:
			break
		var lb := fh.get_buffer(24)
		if lb.size() != 24:
			break
		s_object_id = idb.decode_double(0)
		s_object_label = lb.duplicate()
		s_object_label.resize(25)
		if not _mem_eq(idb, _removed, 8):
			if _mem_eq(lb, starname, ctc):
				n += 1
				object_label = s_object_label.duplicate()
				object_id = s_object_id
				subjectname = object_label.slice(0, 20)
				subjectname.resize(21)
				subject_id = object_id
				if object_label[21] == 83:
					found = 1
				if object_label[21] == 80:
					found = 2
				var p := 20
				while p >= 0:
					if s_object_label[p] != 32:
						if s_object_label[p] == _byte(starname, p):
							return found
						else:
							break
					p -= 1
	if n == 0:
		msg("OBJECT NOT FOUND.")
	if n > 1:
		msg("AMBIGUOUS SEARCH KEY:")
		msg("PLEASE EXPAND NAME...")
		msg(DIVIDER)
		msg("POSSIBLE RESULTS ARE:")
		msg(DIVIDER)
		fh.seek(4)
		while true:
			var idb2 := fh.get_buffer(8)
			if idb2.size() != 8:
				break
			var lb2 := fh.get_buffer(24)
			if lb2.size() != 24:
				break
			if not _mem_eq(idb2, _removed, 8) and _mem_eq(lb2, starname, ctc):
				var tmp := lb2.duplicate()
				tmp.resize(25)
				tmp[21] = 0
				msg(cstr(tmp))
		msg(DIVIDER)
		found = 0
	return found


func _read_star_record() -> bool:
	var idb := fh.get_buffer(8)
	if idb.size() != 8:
		return false
	var lb := fh.get_buffer(24)
	if lb.size() != 24:
		return false
	_last_id_bytes = idb.duplicate()
	object_id = idb.decode_double(0)
	object_label = lb.duplicate()
	object_label.resize(25)
	return true


func unfreeze() -> void:
	var f := open_situation()
	if f == null:
		return
	nsync = f.get_buffer(1).decode_s8(0)
	anti_rad = f.get_buffer(1).decode_s8(0)
	pl_search = f.get_buffer(1).decode_s8(0)
	field_amplificator = f.get_buffer(1).decode_s8(0)
	ilight = f.get_buffer(1).decode_s8(0)
	ilightv = f.get_buffer(1).decode_s8(0)
	charge = f.get_buffer(1).decode_s8(0)
	revcontrols = f.get_buffer(1).decode_s8(0)
	ap_targetting = f.get_buffer(1).decode_s8(0)
	ap_targetted = f.get_buffer(1).decode_s8(0)
	ip_targetting = f.get_buffer(1).decode_s8(0)
	ip_targetted = f.get_buffer(1).decode_s8(0)
	ip_reaching = f.get_buffer(1).decode_s8(0)
	ip_reached = f.get_buffer(1).decode_s8(0)
	ap_target_spin = f.get_buffer(1).decode_s8(0)
	ap_target_r = f.get_buffer(1).decode_s8(0)
	ap_target_g = f.get_buffer(1).decode_s8(0)
	ap_target_b = f.get_buffer(1).decode_s8(0)
	nearstar_spin = f.get_buffer(1).decode_s8(0)
	nearstar_r = f.get_buffer(1).decode_s8(0)
	nearstar_g = f.get_buffer(1).decode_s8(0)
	nearstar_b = f.get_buffer(1).decode_s8(0)
	gburst = f.get_buffer(1).decode_s8(0)
	menusalwayson = f.get_buffer(1).decode_s8(0)
	depolarize = f.get_buffer(1).decode_s8(0)
	sys = f.get_buffer(2).decode_u16(0)
	pwr = f.get_buffer(2).decode_u16(0)
	dev_page = f.get_buffer(2).decode_u16(0)
	ap_target_class = f.get_buffer(2).decode_u16(0)
	f_ray_elapsed = f.get_buffer(2).decode_u16(0)
	nearstar_class = f.get_buffer(2).decode_u16(0)
	nearstar_nop = f.get_buffer(2).decode_u16(0)
	pos_x = f.get_buffer(4).decode_float(0)
	pos_y = f.get_buffer(4).decode_float(0)
	pos_z = f.get_buffer(4).decode_float(0)
	user_alfa = f.get_buffer(4).decode_float(0)
	user_beta = f.get_buffer(4).decode_float(0)
	navigation_beta = f.get_buffer(4).decode_float(0)
	ap_target_ray = f.get_buffer(4).decode_float(0)
	nearstar_ray = f.get_buffer(4).decode_float(0)
	dzat_x = f.get_buffer(8).decode_double(0)
	dzat_y = f.get_buffer(8).decode_double(0)
	dzat_z = f.get_buffer(8).decode_double(0)
	ap_target_x = f.get_buffer(8).decode_double(0)
	ap_target_y = f.get_buffer(8).decode_double(0)
	ap_target_z = f.get_buffer(8).decode_double(0)
	nearstar_x = f.get_buffer(8).decode_double(0)
	nearstar_y = f.get_buffer(8).decode_double(0)
	nearstar_z = f.get_buffer(8).decode_double(0)
	helptime = f.get_buffer(8).decode_double(0)
	ip_target_initial_d = f.get_buffer(8).decode_double(0)
	requested_approach_coefficient = f.get_buffer(8).decode_double(0)
	current_approach_coefficient = f.get_buffer(8).decode_double(0)
	reaction_time = f.get_buffer(8).decode_double(0)
	fcs_status = f.get_buffer(11)
	fcs_status_delay = f.get_buffer(2).decode_u16(0)
	psys = f.get_buffer(2).decode_u16(0)
	ap_target_initial_d = f.get_buffer(8).decode_double(0)
	requested_vimana_coefficient = f.get_buffer(8).decode_double(0)
	current_vimana_coefficient = f.get_buffer(8).decode_double(0)
	vimana_reaction_time = f.get_buffer(8).decode_double(0)
	lithium_collector = f.get_buffer(1).decode_s8(0)
	autoscreenoff = f.get_buffer(1).decode_s8(0)
	ap_reached = f.get_buffer(1).decode_s8(0)
	lifter = f.get_buffer(2).decode_u16(0)
	secs = f.get_buffer(8).decode_double(0)
	f.close()


func isthere(star_id: float) -> int:
	var visible_sectors := 9
	var sect_x: int
	var sect_y: int
	var sect_z: int
	var k: int
	var advance := 100000
	var sidlow := star_id - idscale
	var sidhigh := star_id + idscale
	var eax: int
	var edx: int
	var ecx: int
	var result: int

	sect_x = GoesnetBrtl.to_i32(int((dzat_x - visible_sectors * 50000.0) / 100000.0)) * 100000
	sect_y = GoesnetBrtl.to_i32(int((dzat_y - visible_sectors * 50000.0) / 100000.0)) * 100000
	sect_z = GoesnetBrtl.to_i32(int((dzat_z - visible_sectors * 50000.0) / 100000.0)) * 100000

	if field_amplificator:
		visible_sectors = 14
	k = 100000 * visible_sectors

	var sx := visible_sectors
	while sx > 0:
		var sy := visible_sectors
		while sy > 0:
			var sz := visible_sectors
			while sz > 0:
				eax = GoesnetBrtl.to_i32(sect_x + sect_z)
				ecx = eax
				edx = eax
				edx = GoesnetBrtl.to_i32(edx & 0x0001FFFF)
				edx = GoesnetBrtl.to_i32(edx + sect_x)
				edx = GoesnetBrtl.to_i32(edx - 0xC350)
				laststar_x = float(edx)
				result = edx * eax
				eax = GoesnetBrtl.to_i32(result & 0xFFFFFFFF)
				edx = GoesnetBrtl.to_i32(result >> 32)
				edx = GoesnetBrtl.to_i32(edx + eax)
				ecx = GoesnetBrtl.to_i32(ecx + edx)
				edx = GoesnetBrtl.to_i32(edx & 0x0001FFFF)
				edx = GoesnetBrtl.to_i32(edx + sect_y)
				edx = GoesnetBrtl.to_i32(edx - 0xC350)
				laststar_y = float(edx)
				eax = ecx
				result = edx * eax
				eax = GoesnetBrtl.to_i32(result & 0xFFFFFFFF)
				edx = GoesnetBrtl.to_i32(result >> 32)
				edx = GoesnetBrtl.to_i32(edx + eax)
				edx = GoesnetBrtl.to_i32(edx & 0x0001FFFF)
				edx = GoesnetBrtl.to_i32(edx + sect_z)
				edx = GoesnetBrtl.to_i32(edx - 0xC350)
				laststar_z = float(edx)
				laststar_id = (laststar_x * idscale) * (laststar_y * idscale) * (laststar_z * idscale)
				if laststar_id > sidlow and laststar_id < sidhigh:
					return 1
				sect_z = GoesnetBrtl.to_i32(sect_z + advance)
				sz -= 1
			sect_z = GoesnetBrtl.to_i32(sect_z - k)
			sect_y = GoesnetBrtl.to_i32(sect_y + advance)
			sy -= 1
		sect_y = GoesnetBrtl.to_i32(sect_y - k)
		sect_x = GoesnetBrtl.to_i32(sect_x + advance)
		sx -= 1
	return 0


func extract_ap_target_infos() -> void:
	GoesnetBrtl.srand(ap_target_x / 100000.0 * ap_target_y / 100000.0 * ap_target_z / 100000.0)
	ap_target_class = GoesnetBrtl.random(star_classes)
	ap_target_ray = (float(class_ray[ap_target_class]) + float(GoesnetBrtl.random(class_rayvar[ap_target_class]))) * 0.001
	ap_target_r = class_rgb[3 * ap_target_class + 0]
	ap_target_g = class_rgb[3 * ap_target_class + 1]
	ap_target_b = class_rgb[3 * ap_target_class + 2]
	ap_target_spin = 0
	if ap_target_class == 11:
		ap_target_spin = GoesnetBrtl.random(30) + 1
	if ap_target_class == 7:
		ap_target_spin = GoesnetBrtl.random(12) + 1
	if ap_target_class == 2:
		ap_target_spin = GoesnetBrtl.random(4) + 1


func prepare_nearstar() -> void:
	var n: int
	var c: int
	var q: int
	var r: int
	var s: int
	var t: int
	var key_radius: float

	nearstar_class = ap_target_class
	nearstar_x = ap_target_x
	nearstar_y = ap_target_y
	nearstar_z = ap_target_z
	nearstar_ray = ap_target_ray
	nearstar_spin = ap_target_spin
	nearstar_r = ap_target_r
	nearstar_g = ap_target_g
	nearstar_b = ap_target_b

	nearstar_identity = nearstar_x / 100000.0 * nearstar_y / 100000.0 * nearstar_z / 100000.0

	var seed := int(nearstar_x) % 10000
	seed = (seed * int(nearstar_y)) % 10000
	seed = (seed * int(nearstar_z)) % 10000
	GoesnetBrtl.srand(seed)

	nearstar_nop = GoesnetBrtl.random(class_planets[nearstar_class] + 1)

	for i in range(nearstar_nop):
		nearstar_p_owner[i] = -1
		nearstar_p_orb_orient[i] = deg * float(GoesnetBrtl.random(360))
		nearstar_p_orb_seed[i] = 3.0 * (i * i + 1) * nearstar_ray + float(GoesnetBrtl.random(300.0 * nearstar_ray)) / 100.0
		nearstar_p_tilt[i] = zrandom(10.0 * nearstar_p_orb_seed[i]) / 500.0
		nearstar_p_orb_tilt[i] = zrandom(10.0 * nearstar_p_orb_seed[i]) / 5000.0
		nearstar_p_orb_ecc[i] = 1.0 - float(GoesnetBrtl.random(nearstar_p_orb_seed[i] + 10.0 * absf(nearstar_p_orb_tilt[i]))) / 2000.0
		nearstar_p_ray[i] = float(GoesnetBrtl.random(nearstar_p_orb_seed[i])) * 0.001 + 0.01
		nearstar_p_ring[i] = zrandom(nearstar_p_ray[i]) * (1.0 + float(GoesnetBrtl.random(1000)) / 100.0)
		if nearstar_class != 8:
			nearstar_p_type[i] = GoesnetBrtl.random(planet_types)
		else:
			if GoesnetBrtl.random(2):
				nearstar_p_type[i] = 10
				nearstar_p_orb_tilt[i] *= 100.0
			else:
				nearstar_p_type[i] = GoesnetBrtl.random(planet_types)
		if nearstar_class == 2 or nearstar_class == 7 or nearstar_class == 15:
			nearstar_p_orb_seed[i] *= 10.0

	if nearstar_class == 0:
		if GoesnetBrtl.random(4) == 2:
			nearstar_p_type[2] = 3
		if GoesnetBrtl.random(4) == 2:
			nearstar_p_type[3] = 3
		if GoesnetBrtl.random(4) == 2:
			nearstar_p_type[4] = 3

	for i in range(nearstar_nop):
		match nearstar_class:
			2:
				while nearstar_p_type[i] == 3:
					nearstar_p_type[i] = GoesnetBrtl.random(10)
			5:
				while nearstar_p_type[i] == 6 or nearstar_p_type[i] == 9:
					nearstar_p_type[i] = GoesnetBrtl.random(10)
			7:
				nearstar_p_type[i] = 9
			9:
				while nearstar_p_type[i] != 0 and nearstar_p_type[i] != 6 and nearstar_p_type[i] != 9:
					nearstar_p_type[i] = GoesnetBrtl.random(10)
			11:
				while nearstar_p_type[i] != 1 and nearstar_p_type[i] != 7:
					nearstar_p_type[i] = GoesnetBrtl.random(10)

	for i in range(nearstar_nop):
		match nearstar_p_type[i]:
			0:
				if GoesnetBrtl.random(8):
					nearstar_p_type[i] += 1
			3:
				if i < 2 or i > 6 or (nearstar_class != 0 and GoesnetBrtl.random(4)):
					if GoesnetBrtl.random(2):
						nearstar_p_type[i] += 1
					else:
						nearstar_p_type[i] -= 1
			7:
				if i < 7:
					if GoesnetBrtl.random(2):
						nearstar_p_type[i] -= 1
					else:
						nearstar_p_type[i] -= 2

	nearstar_nob = nearstar_nop

	if not (nearstar_class == 2 or nearstar_class == 7 or nearstar_class == 15):
		for i in range(nearstar_nop):
			s = nearstar_p_type[i]
			if i < 2:
				t = 0
				if s == 10:
					t = GoesnetBrtl.random(3)
			else:
				t = GoesnetBrtl.random(planet_possiblemoons[s] + 1)
			if nearstar_nob + t > maxbodies:
				t = maxbodies - nearstar_nob
			for c0 in range(t):
				q = nearstar_nob + c0
				nearstar_p_owner[q] = i
				nearstar_p_moonid[q] = c0
				nearstar_p_orb_orient[q] = deg * float(GoesnetBrtl.random(360))
				nearstar_p_orb_seed[q] = float(c0 * c0 + 4) * nearstar_p_ray[i] + float(zrandom(300.0 * nearstar_p_ray[i])) / 100.0
				nearstar_p_tilt[q] = zrandom(10.0 * nearstar_p_orb_seed[q]) / 50.0
				nearstar_p_orb_tilt[q] = zrandom(10.0 * nearstar_p_orb_seed[q]) / 500.0
				nearstar_p_orb_ecc[q] = 1.0 - float(GoesnetBrtl.random(nearstar_p_orb_seed[q] + 10.0 * absf(nearstar_p_orb_tilt[q]))) / 2000.0
				nearstar_p_ray[q] = float(GoesnetBrtl.random(nearstar_p_orb_seed[i])) * 0.05 + 0.1
				nearstar_p_ring[q] = 0.0
				nearstar_p_type[q] = GoesnetBrtl.random(planet_types)
				r = nearstar_p_type[q]
				if r == 9 and s != 10:
					r = 2
				if r == 6 and s < 9:
					r = 5
				if i > 7 and GoesnetBrtl.random(c0):
					r = 7
				if i > 9 and GoesnetBrtl.random(c0):
					r = 7
				if r == 2 or r == 3 or r == 4 or r == 8:
					if s != 6 and s < 9:
						r = 1
				if r == 3 and s < 9:
					if i > 7:
						r = 7
					if nearstar_class != 0 and GoesnetBrtl.random(4):
						r = 5
					if nearstar_class == 2 or nearstar_class == 7 or nearstar_class == 11:
						r = 8
				if r == 7 and i <= 5:
					r = 1
				if (nearstar_class == 2 or nearstar_class == 5 or nearstar_class == 7 or nearstar_class == 11) and GoesnetBrtl.random(i):
					r = 7
				nearstar_p_type[q] = r
			nearstar_nob += t

	key_radius = nearstar_ray * planet_orb_scaling
	if nearstar_class == 8:
		key_radius *= 2.0
	if nearstar_class == 2:
		key_radius *= 16.0
	if nearstar_class == 7:
		key_radius *= 18.0
	if nearstar_class == 11:
		key_radius *= 20.0
	for i in range(nearstar_nop):
		nearstar_p_ray[i] = avg_planet_ray[nearstar_p_type[i]] + avg_planet_ray[nearstar_p_type[i]] * zrandom(100) / 200.0
		nearstar_p_ray[i] *= avg_planet_sizing
		nearstar_p_orb_ray[i] = key_radius + key_radius * zrandom(100) / 500.0
		nearstar_p_orb_ray[i] += key_radius * avg_planet_ray[nearstar_p_type[i]]
		if i < 8:
			key_radius += nearstar_p_orb_ray[i]
		else:
			key_radius += 0.22 * nearstar_p_orb_ray[i]

	n = nearstar_nop
	while n < nearstar_nob:
		q = 0
		c = nearstar_p_owner[n]
		key_radius = nearstar_p_ray[c] * moon_orb_scaling
		while n < nearstar_nob and nearstar_p_owner[n] == c:
			nearstar_p_ray[n] = avg_planet_ray[nearstar_p_type[n]] + avg_planet_ray[nearstar_p_type[n]] * zrandom(100) / 200.0
			nearstar_p_ray[n] *= avg_moon_sizing
			nearstar_p_orb_ray[n] = key_radius + key_radius * zrandom(100) / 250.0
			nearstar_p_orb_ray[n] += key_radius * avg_planet_ray[nearstar_p_type[n]]
			if q < 2:
				key_radius += nearstar_p_orb_ray[n]
			if q >= 2 and q < 8:
				key_radius += 0.12 * nearstar_p_orb_ray[n]
			if q >= 8:
				key_radius += 0.025 * nearstar_p_orb_ray[n]
			q += 1
			n += 1

	for i in range(nearstar_nop):
		nearstar_p_ring[i] = 0.75 * nearstar_p_ray[i] * (2 + GoesnetBrtl.random(3))
		s = nearstar_p_type[i]
		if s != 6 and s != 9:
			if GoesnetBrtl.random(5):
				nearstar_p_ring[i] = 0.0
		else:
			if GoesnetBrtl.random(2):
				nearstar_p_ring[i] = 0.0


func fpart(id_in: float, label: PackedByteArray) -> int:
	var fp := 0
	var id := id_in
	var attempts := 0
	var multiplier := 1e9
	if label[21] == 80:
		id -= float((label[23] - 48) + 10 * (label[22] - 48))
	id = absf(id)
	while true:
		var lid: float = floor(id)
		fp = int(multiplier * (id - lid))
		multiplier *= 1000.0
		attempts += 1
		if not (fp < 1e6 and attempts < 44):
			break
	return fp
