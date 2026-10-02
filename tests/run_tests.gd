extends SceneTree

const SUITES := [
	"res://tests/test_brtl.gd",
	"res://tests/test_compat.gd",
	"res://tests/test_find.gd",
	"res://tests/test_isthere.gd",
	"res://tests/test_unfreeze.gd",
	"res://tests/test_probe.gd",
	"res://tests/test_golden.gd",
]


func _initialize() -> void:
	var total_pass := 0
	var total_fail := 0
	for path in SUITES:
		var script: GDScript = load(path)
		if script == null:
			print("[FAIL] could not load " + path)
			total_fail += 1
			continue
		var suite: RefCounted = script.new()
		var t := GoTestContext.new()
		t.suite = suite.NAME
		suite.run(t)
		total_pass += t.passed
		total_fail += t.failed
		var status := "OK" if t.failed == 0 else "FAIL"
		print("[%s] %-10s %d passed, %d failed" % [status, t.suite, t.passed, t.failed])
		for f in t.failures:
			print("       - " + f)
	print("")
	print("TOTAL: %d passed, %d failed" % [total_pass, total_fail])
	quit(1 if total_fail > 0 else 0)
