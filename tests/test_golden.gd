extends RefCounted
const NAME := "golden"


func _copy(src: String, dst: String) -> void:
	var b := FileAccess.get_file_as_bytes(src)
	var f := FileAccess.open(dst, FileAccess.WRITE)
	f.store_buffer(b)
	f.close()


func _make(module: String) -> RefCounted:
	match module:
		"cat":
			return GoCat.new()
		"where":
			return GoWhere.new()
		"par":
			return GoPar.new()
		"dl":
			return GoDl.new()
		"st":
			return GoSt.new()
	return null


func _first_diff(a: String, b: String) -> int:
	var n: int = mini(a.length(), b.length())
	var i := 0
	while i < n:
		if a.unicode_at(i) != b.unicode_at(i):
			return i
		i += 1
	if a.length() != b.length():
		return n
	return -1


func run(t: GoTestContext) -> void:
	var base := OS.get_temp_dir().path_join("goesnet_gd_golden")
	DirAccess.make_dir_recursive_absolute(base)
	_copy("res://tests/fixtures/data/STARMAP.BIN", base.path_join("STARMAP.BIN"))
	_copy("res://tests/fixtures/data/GUIDE.BIN", base.path_join("GUIDE.BIN"))
	OS.set_environment("NOCTIS_DATA_DIR", base)

	var cases = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/cases.json"))
	if cases == null:
		t.check(false, "could not parse cases.json")
		return

	for case in cases:
		DirAccess.remove_absolute(base.path_join("COMM.BIN"))
		var args := PackedStringArray()
		for a in case["args"]:
			args.append(a)
		var inst := _make(case["module"])
		if inst == null:
			t.check(false, "unknown module " + str(case["module"]))
			continue
		var out: String = inst.run(args)
		var golden := FileAccess.get_file_as_string("res://tests/fixtures/golden/" + case["golden"])
		if out == golden:
			t.passed += 1
		else:
			t.failed += 1
			var d := _first_diff(golden, out)
			t.failures.append(case["name"] + " stdout mismatch at " + str(d) +
				" (golden len " + str(golden.length()) + ", got " + str(out.length()) + ")")
			t.failures.append("  golden: " + golden.substr(maxi(d - 5, 0), 30))
			t.failures.append("  got:    " + out.substr(maxi(d - 5, 0), 30))

		if case.has("comm") and case.has("comm_hex"):
			var got := FileAccess.get_file_as_bytes(base.path_join("COMM.BIN"))
			var want_hex: String = case["comm_hex"]
			var want := want_hex.hex_decode()
			if got == want:
				t.passed += 1
			else:
				t.failed += 1
				t.failures.append(case["name"] + " COMM.BIN mismatch (want " +
					str(want.size()) + " bytes, got " + str(got.size()) + ")")
