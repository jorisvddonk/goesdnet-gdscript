extends RefCounted
const NAME := "find"

const STAR_LAVA := 21034.919273902353
const PLANET_CRYSTAL := 21035.919273902353


func _copy(src: String, dst: String) -> void:
	var b := FileAccess.get_file_as_bytes(src)
	var f := FileAccess.open(dst, FileAccess.WRITE)
	f.store_buffer(b)
	f.close()


func _setup() -> void:
	var base := OS.get_temp_dir().path_join("goesnet_gd_find")
	DirAccess.make_dir_recursive_absolute(base)
	_copy("res://tests/fixtures/data/STARMAP.BIN", base.path_join("STARMAP.BIN"))
	_copy("res://tests/fixtures/data/GUIDE.BIN", base.path_join("GUIDE.BIN"))
	OS.set_environment("NOCTIS_DATA_DIR", base)


func run(t: GoTestContext) -> void:
	_setup()
	var c := NoctisCompat.new()
	c.fh = c.open_starmap()
	t.check(c.fh != null, "opened starmap")
	if c.fh == null:
		return

	var q := c.find(c._name_buffer("LAVA LAMP"))
	t.eq(q, 1, "find LAVA LAMP -> star")
	t.eq(c.cstr(c.subjectname), "LAVA LAMP           ", "subjectname padded to 20")
	t.check(absf(c.subject_id - STAR_LAVA) < 1e-6, "subject_id is star id")

	c.output = ""
	q = c.find(c._name_buffer("CRYSTAL BLUE"))
	t.eq(q, 2, "find CRYSTAL BLUE -> planet")
	t.check(absf(c.subject_id - PLANET_CRYSTAL) < 1e-6, "subject_id is planet id")

	c.output = ""
	q = c.find(c._name_buffer("NOVACULA"))
	t.eq(q, 1, "find NOVACULA -> star")

	c.output = ""
	q = c.find(c._name_buffer("NOVA"))
	t.eq(q, 0, "find NOVA -> ambiguous (0)")
	t.check(c.output.find("AMBIGUOUS SEARCH KEY:") >= 0, "ambiguous message printed")

	c.output = ""
	q = c.find(c._name_buffer("GHOST OBJECT"))
	t.eq(q, 1, "find GHOST OBJECT skips Removed record")

	c.output = ""
	q = c.find(c._name_buffer("NONEXISTENT"))
	t.eq(q, 0, "find NONEXISTENT -> 0")
	t.check(c.output.find("OBJECT NOT FOUND.") >= 0, "not found message printed")

	c.output = ""
	q = c.find(c._name_buffer("THIS NAME IS FAR TOO LONG"))
	t.eq(q, 0, "find overlong -> 0")
	t.check(c.output.find("INVALID OBJECT NAME.") >= 0, "invalid name message printed")

	var w := GoWhere.new()
	w.fh = w.open_starmap()
	q = w.find(w._name_buffer("CRYSTAL BLUE"))
	t.eq(q, 2, "where find CRYSTAL BLUE -> planet")
	t.check(absf(w.subject_id - STAR_LAVA) < 1e-6, "where adjusts planet id to star id")

	c.fh.close()
	w.fh.close()
