extends RefCounted
const NAME := "isthere"


func _check_star(t: GoTestContext, star_id: float, x: float, y: float, z: float, label: String) -> void:
	var c := NoctisCompat.new()
	t.eq(c.isthere(star_id), 1, "isthere " + label)
	t.check(absf(c.laststar_x - x) < 0.5, label + " laststar_x")
	t.check(absf(c.laststar_y - y) < 0.5, label + " laststar_y")
	t.check(absf(c.laststar_z - z) < 0.5, label + " laststar_z")


func run(t: GoTestContext) -> void:
	_check_star(t, 21034.919273902353, 3690704.0, -4370114.0, -1304184.0, "LAVA LAMP")
	_check_star(t, 20067.05142379023, 3352848.0, -4694601.0, -1274885.0, "ALEXANDROS")
	_check_star(t, 17331.848125710116, 4166416.0, -4003058.0, -1039179.0, "BLUE SHADOW")
	_check_star(t, 20820.87434451645, 3928560.0, -4310155.0, -1229625.0, "SYAMASUNDAR")

	var c := NoctisCompat.new()
	t.eq(c.isthere(15995.519841678279), 0, "FENIA out of range")
	c = NoctisCompat.new()
	t.eq(c.isthere(1.0), 0, "arbitrary id out of range")
