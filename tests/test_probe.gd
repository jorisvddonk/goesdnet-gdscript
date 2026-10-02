extends RefCounted
const NAME := "probe"


func _nearstar_string(c: NoctisCompat) -> String:
	var parts := PackedStringArray()
	parts.append("class=" + str(c.ap_target_class))
	parts.append("spin=" + str(c.ap_target_spin))
	parts.append("r=" + str(c.ap_target_r))
	parts.append("g=" + str(c.ap_target_g))
	parts.append("b=" + str(c.ap_target_b))
	parts.append("nop=" + str(c.nearstar_nop))
	parts.append("nob=" + str(c.nearstar_nob))
	for i in range(c.nearstar_nob):
		parts.append("t" + str(i) + "=" + str(c.nearstar_p_type[i]))
	for i in range(c.nearstar_nob):
		parts.append("o" + str(i) + "=" + str(c.nearstar_p_owner[i]))
	for i in range(c.nearstar_nob):
		parts.append("m" + str(i) + "=" + str(c.nearstar_p_moonid[i]))
	return "\n".join(parts) + "\n"


func _isthere_string(c: NoctisCompat, id: float) -> String:
	var r := c.isthere(id)
	return "res=" + str(r) + " x=" + str(int(round(c.laststar_x))) + \
		" y=" + str(int(round(c.laststar_y))) + " z=" + str(int(round(c.laststar_z))) + "\n"


func run(t: GoTestContext) -> void:
	var data = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/probe/probe.json"))
	if data == null:
		t.check(false, "could not parse probe.json")
		return

	for c in data["nearstar"]:
		var inst := NoctisCompat.new()
		inst.ap_target_x = float(c["x"])
		inst.ap_target_y = float(c["y"])
		inst.ap_target_z = float(c["z"])
		inst.extract_ap_target_infos()
		inst.prepare_nearstar()
		var got := _nearstar_string(inst)
		var want := FileAccess.get_file_as_string("res://tests/fixtures/probe/" + c["file"])
		if got == want:
			t.passed += 1
		else:
			t.failed += 1
			t.failures.append("nearstar " + c["name"] + " mismatch")

	for c in data["isthere"]:
		var inst := NoctisCompat.new()
		inst.field_amplificator = int(c["field_amplificator"])
		var got := _isthere_string(inst, float(c["id"]))
		var want := FileAccess.get_file_as_string("res://tests/fixtures/probe/" + c["file"])
		if got == want:
			t.passed += 1
		else:
			t.failed += 1
			t.failures.append("isthere " + c["name"] + " mismatch (got " + got.strip_edges() + ", want " + want.strip_edges() + ")")
