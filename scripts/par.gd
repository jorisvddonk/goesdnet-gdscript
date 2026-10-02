class_name GoPar
extends NoctisCompat


func run(args: PackedStringArray) -> String:
	output = ""
	objectname = _zero(22)
	var argc := args.size() + 1
	var argv := PackedStringArray(["par"])
	for a in args:
		argv.append(a)

	if argc < 2:
		msg("________USAGE________")
		msg("PAR OBJECTNAME")
		msg("PAR OBJECTNAME:RANGE")
		msg("^^^^^^^^^^^^^^^^^^^^^")
		msg("PLEASE RUN AGAIN,")
		msg("SPECIFYING PARAMETERS")
		msg(DIVIDER)
		msg("(PAR REVISION 6011/2)")
		return output
	else:
		msg("GOES STARMAP ANALYSIS")
		msg(DIVIDER)

	fh = open_starmap()
	if fh == null:
		msg("STARMAP NOT AVAILABLE")
		return output

	var i := 2
	var parbuffer := argv[1]
	while i < argc:
		parbuffer += " " + argv[i]
		i += 1
	parbuffer = parbuffer.replace("_", " ")
	var pb := parbuffer.to_ascii_buffer()

	i = 0
	while i < 21 and _byte(pb, i) != 58 and _byte(pb, i) != 0:
		objectname[i] = _byte(pb, i)
		i += 1

	if _byte(pb, i) != 58:
		analyzed_sectors_range = 100
	else:
		sts = _atoi_bytes(pb, i + 1)
		if sts <= 2 or sts > 10000:
			analyzed_sectors_range = 100
		else:
			analyzed_sectors_range = sts

	unfreeze()
	if sts > 100:
		warn("SCANNING THE GALAXY: ESC TO STOP", -1)

	GoesnetBrtl.strupr_buf(objectname)
	objectname[i] = 0
	query = find(objectname)
	if query:
		if query == 1:
			msg("SUBJECT: STAR;")
		if query == 2:
			msg("SUBJECT: PLANET;")
		msg("NAME: " + cstr(subjectname))
		calc_parsis_for()

	fh.close()
	return output


func calc_parsis_for() -> void:
	var star_id: float
	if object_label[21] == 83:
		star_id = object_id
		if isthere(star_id):
			msg("X=" + _f0(laststar_x))
			msg("Y=" + _f0(-laststar_y))
			msg("Z=" + _f0(laststar_z))
		else:
			msg(cstr(object_label))
			msg("IS OUT OF RANGE")
	else:
		var planet_nr := (object_label[23] - 48) + 10 * (object_label[22] - 48)
		star_id = object_id - planet_nr
		if isthere(star_id):
			msg("X=" + _f0(laststar_x))
			msg("Y=" + _f0(-laststar_y))
			msg("Z=" + _f0(laststar_z))
		else:
			msg(cstr(object_label))
			msg("IS OUT OF RANGE")
