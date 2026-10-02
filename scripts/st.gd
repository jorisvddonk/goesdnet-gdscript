class_name GoSt
extends NoctisCompat


func run(args: PackedStringArray) -> String:
	output = ""
	objectname = _zero(22)
	var argc := args.size() + 1
	var argv := PackedStringArray(["st"])
	for a in args:
		argv.append(a)

	if argc < 2:
		msg("________USAGE________")
		msg("ST OBJECTNAME")
		msg("ST OBJECTNAME:RANGE")
		msg("^^^^^^^^^^^^^^^^^^^^^")
		msg("PLEASE RUN AGAIN,")
		msg("SPECIFYING PARAMETERS")
		msg(DIVIDER)
		msg("(ST REVISION 6011/28)")
		return output
	else:
		msg("LOOKING FOR TARGET...")
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
		msg("_____________________")
		settarget()

	fh.close()
	return output


func settarget() -> void:
	var star_id: float
	var fp_star_check := 0
	var planet_nr: int

	if query == 2:
		planet_nr = (object_label[23] - 48) + 10 * (object_label[22] - 48)
		star_id = object_id - float(planet_nr)
	else:
		star_id = object_id

	if not isthere(star_id):
		msg(cstr(subjectname))
		msg("IS OUT OF RANGE")
		return
	else:
		fp_star_check = fpart(star_id, F_PART_STAR_LABEL.to_ascii_buffer())

	if query == 2:
		var off_system := false
		if laststar_x < nearstar_x - idscale or laststar_x > nearstar_x + idscale:
			off_system = true
		elif laststar_y < nearstar_y - idscale or laststar_y > nearstar_y + idscale:
			off_system = true
		elif laststar_z < nearstar_z - idscale or laststar_z > nearstar_z + idscale:
			off_system = true
		if off_system:
			_report_not_part_of_system()
			return
		ap_target_x = laststar_x
		ap_target_y = laststar_y
		ap_target_z = laststar_z
		extract_ap_target_infos()
		prepare_nearstar()
		fh.seek(4)
		while _read_star_record():
			var fp_object_check := fpart(object_id, object_label)
			if not _mem_eq(_last_id_bytes, _removed, 8) and fp_object_check == fp_star_check and object_id > star_id + 1 - idscale and object_id <= star_id + MAX_OBJECTS_PER_STAR + idscale:
				if _mem_eq(object_label, subjectname, _strlen(subjectname)):
					planet_nr = (object_label[23] - 48) + 10 * (object_label[22] - 48)
					var ch := create_comm()
					if ch != null:
						ch.store_16(planet_nr)
						ch.close()
						msg("LOC. TARGET DATA SENT")
						msg("BEGIN IN-SYSTEM DRIVE")
					else:
						msg("COMMUNICATION ERROR.")
					return
		_report_not_part_of_system()
	else:
		var ch := create_comm()
		if ch != null:
			ch.store_double(laststar_x)
			ch.store_double(laststar_y)
			ch.store_double(laststar_z)
			ch.close()
			msg("REM. TARGET DATA SENT")
			msg("STARTING VIMANA DRIVE")
		else:
			msg("COMMUNICATION ERROR.")


func _report_not_part_of_system() -> void:
	msg("PLANET NOT FOUND AS")
	msg("PART OF THIS SYSTEM.")
	msg("PLEASE USE \"" + "PAR" + "\" TO")
	msg("FIND PARSIS FOR THE")
	msg("CORRESPONDING STAR.")
