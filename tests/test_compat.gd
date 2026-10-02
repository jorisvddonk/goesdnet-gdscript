extends RefCounted
const NAME := "compat"


func run(t: GoTestContext) -> void:
	var c := NoctisCompat.new()

	c.output = ""
	c.msg("ABC")
	t.eq(c.output, "ABC" + " ".repeat(18), "msg pads to 21")
	t.eq(c.output.length(), 21, "msg length 21")

	c.output = ""
	c.msg("")
	t.eq(c.output, " ".repeat(21), "msg empty -> 21 spaces")

	c.output = ""
	c.msg("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
	t.eq(c.output, "ABCDEFGHIJKLMNOPQRSTU", "msg truncates to 21")

	t.eq(c.cstr(PackedByteArray([65, 66, 0, 67])), "AB", "cstr stops at NUL")
	t.eq(c.cstr(PackedByteArray([65, 66])), "AB", "cstr without NUL")

	t.eq(c._atoi_bytes("  12".to_ascii_buffer(), 0), 12, "atoi spaces")
	t.eq(c._atoi_bytes("-5x".to_ascii_buffer(), 0), -5, "atoi negative")
	t.eq(c._atoi_bytes("007".to_ascii_buffer(), 0), 7, "atoi leading zeros")
	t.eq(c._atoi_bytes("abc42".to_ascii_buffer(), 3), 42, "atoi offset")

	t.eq(c._pad2(3), "03", "pad2 single digit")
	t.eq(c._pad2(12), "12", "pad2 double digit")

	t.eq(c._f0(3690704.0), "3690704", "f0 positive")
	t.eq(c._f0(-1304184.0), "-1304184", "f0 negative")

	t.eq(c._strlen("HELLO".to_ascii_buffer()), 5, "_strlen")
	t.eq(c.cstr(c._name_buffer("AB")), "AB", "name buffer roundtrip")
	t.eq(c._name_buffer("AB").size(), 22, "name buffer size")

	t.check(c._mem_eq("ABCD".to_ascii_buffer(), "ABXX".to_ascii_buffer(), 2), "mem_eq prefix")
	t.check(not c._mem_eq("ABCD".to_ascii_buffer(), "ABXX".to_ascii_buffer(), 4), "mem_eq mismatch")

	GoesnetBrtl.srand(5)
	var z := c.zrandom(100)
	t.eq(z, -92.0, "zrandom value")

	var star_label := PackedByteArray()
	star_label.resize(25)
	star_label[21] = 83
	t.eq(c.fpart(21034.919273902353, star_label), 919273902, "fpart star")

	var planet_label := PackedByteArray()
	planet_label.resize(25)
	planet_label[21] = 80
	planet_label[22] = 48
	planet_label[23] = 49
	t.eq(c.fpart(21035.919273902353, planet_label), 919273902, "fpart planet")
