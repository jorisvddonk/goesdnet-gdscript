class_name GoDl
extends NoctisCompat


func run(args: PackedStringArray) -> String:
	output = ""
	objectname = _zero(22)
	var argc := args.size() + 1
	var argv := PackedStringArray(["dl"])
	for a in args:
		argv.append(a)

	unfreeze()
	if argc < 2 and ap_targetted != 1:
		msg("________USAGE________")
		msg("DL OBJECTNAME")
		msg("DL OBJECTNAME:RANGE")
		msg("^^^^^^^^^^^^^^^^^^^^^")
		msg("PLEASE RUN AGAIN,")
		msg("SPECIFYING PARAMETERS")
		msg(DIVIDER)
		msg("(DL REVISION 6011/29)")
		return output
	else:
		msg("DEPENDENCIES LISTING:")
		msg(DIVIDER)

	gh = open_guide()
	fh = open_starmap()
	if fh == null:
		msg("STARMAP NOT AVAILABLE")
		return output

	if argc < 2:
		ap_target_id = ap_target_x / 100000.0 * ap_target_y / 100000.0 * ap_target_z / 100000.0
		fh.seek(4)
		var matched := false
		while _read_star_record():
			if object_id > ap_target_id - idscale and object_id < ap_target_id + idscale:
				object_label[20] = 0
				objectname = _name_buffer(cstr(object_label))
				analyzed_sectors_range = 100
				matched = true
				break
		if not matched:
			msg("CURRENT REMOTE TARGET")
			msg("CANNOT BE FOUND.")
			return output
	else:
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
		listplanets()

	if gh != null:
		gh.close()
	fh.close()
	return output


func notesabout(id: float) -> int:
	if gh == null:
		return 0
	var ncount := 0
	gh.seek(4)
	while true:
		var idb := gh.get_buffer(8)
		if idb.size() != 8:
			break
		var mb := gh.get_buffer(76)
		if mb.size() != 76:
			break
		mblock_id = idb.decode_double(0)
		if not _mem_eq(idb, _removed, 8):
			if mblock_id >= id - idscale and mblock_id <= id + idscale:
				ncount += 1
	return ncount


func _sort_records(posit: PackedInt64Array, progr: PackedByteArray, count: int) -> void:
	var b1 := true
	while b1:
		b1 = false
		for b2 in range(count - 1):
			if progr[b2] > progr[b2 + 1]:
				var b4 := posit[b2]
				posit[b2] = posit[b2 + 1]
				posit[b2 + 1] = b4
				var b3 := progr[b2]
				progr[b2] = progr[b2 + 1]
				progr[b2 + 1] = b3
				b1 = true


func listplanets() -> void:
	var n: int
	var n2: int
	var ncount: int
	var planet_nr: int
	var pcount: int
	var planet_id: int
	var mcount: int
	var star_id: float
	var fp_star_check: int
	var fp_object_check: int

	least = 0

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

	warn("ORGANIZING TREE...", 1)

	ap_target_x = laststar_x
	ap_target_y = laststar_y
	ap_target_z = laststar_z
	extract_ap_target_infos()
	prepare_nearstar()

	msg("*" + cstr(subjectname))

	var labposit := PackedInt64Array()
	labposit.resize(80)
	var labprogr := PackedByteArray()
	labprogr.resize(80)
	var labposit2 := PackedInt64Array()
	labposit2.resize(80)
	var labprogr2 := PackedByteArray()
	labprogr2.resize(80)

	if query == 1:
		ncount = notesabout(star_id)
		if ncount > 0:
			msg("]   (" + str(ncount) + " NOTES)")
		pcount = 0
		fh.seek(4)
		while _read_star_record():
			fp_object_check = fpart(object_id, object_label)
			if not _mem_eq(_last_id_bytes, _removed, 8) and fp_object_check == fp_star_check and object_id > star_id + 1 - idscale and object_id <= star_id + MAX_OBJECTS_PER_STAR + idscale:
				planet_nr = (object_label[23] - 48) + 10 * (object_label[22] - 48)
				if nearstar_p_owner[planet_nr - 1] == -1:
					labposit[pcount] = fh.get_position() - 32
					labprogr[pcount] = planet_nr
					least = 1
					pcount += 1
		_sort_records(labposit, labprogr, pcount)
		n = 0
		while pcount > 0:
			fh.seek(labposit[n])
			_read_star_record()
			planet_nr = (object_label[23] - 48) + 10 * (object_label[22] - 48)
			pcount -= 1
			if pcount != 0:
				msg("$" + _pad2(planet_nr) + "&" + cstr(object_label))
				ncount = notesabout(object_id)
				if ncount > 0:
					msg("]   (" + str(ncount) + " NOTES)")
			else:
				msg("[" + _pad2(planet_nr) + "&" + cstr(object_label))
				ncount = notesabout(object_id)
				if ncount > 0:
					msg("    (" + str(ncount) + " NOTES)")
			planet_id = (object_label[23] - 48) + 10 * (object_label[22] - 48)
			mcount = 0
			fh.seek(4)
			while _read_star_record():
				fp_object_check = fpart(object_id, object_label)
				if not _mem_eq(_last_id_bytes, _removed, 8) and fp_object_check == fp_star_check and object_id > star_id + 1 - idscale and object_id <= star_id + MAX_OBJECTS_PER_STAR + idscale:
					planet_nr = (object_label[23] - 48) + 10 * (object_label[22] - 48)
					if nearstar_p_owner[planet_nr - 1] == planet_id - 1:
						labposit2[mcount] = fh.get_position() - 32
						labprogr2[mcount] = nearstar_p_moonid[planet_nr - 1]
						mcount += 1
			_sort_records(labposit2, labprogr2, mcount)
			n2 = 0
			while mcount > 0:
				fh.seek(labposit2[n2])
				_read_star_record()
				planet_nr = (object_label[23] - 48) + 10 * (object_label[22] - 48)
				mcount -= 1
				if pcount != 0:
					if mcount != 0:
						msg("] $" + _pad2(nearstar_p_moonid[planet_nr - 1] + 1) + "&" + cstr(object_label))
						ncount = notesabout(object_id)
						if ncount > 0:
							msg("] ]   (" + str(ncount) + " NOTES)")
					else:
						msg("] [" + _pad2(nearstar_p_moonid[planet_nr - 1] + 1) + "&" + cstr(object_label))
						ncount = notesabout(object_id)
						if ncount > 0:
							msg("]     (" + str(ncount) + " NOTES)")
				else:
					if mcount != 0:
						msg("  $" + _pad2(nearstar_p_moonid[planet_nr - 1] + 1) + "&" + cstr(object_label))
						ncount = notesabout(object_id)
						if ncount > 0:
							msg("  ]   (" + str(ncount) + " NOTES)")
					else:
						msg("  [" + _pad2(nearstar_p_moonid[planet_nr - 1] + 1) + "&" + cstr(object_label))
						ncount = notesabout(object_id)
						if ncount > 0:
							msg("      (" + str(ncount) + " NOTES)")
				n2 += 1
			n += 1
		if least:
			msg(DIVIDER)
			msg("PLANETS LISTING END.")
		else:
			msg("NO KNOWN PLANETS.")

	if query == 2:
		ncount = notesabout(object_id)
		if ncount > 0:
			msg("]   (" + str(ncount) + " NOTES)")
		planet_id = (object_label[23] - 48) + 10 * (object_label[22] - 48)
		mcount = 0
		fh.seek(4)
		while _read_star_record():
			fp_object_check = fpart(object_id, object_label)
			if not _mem_eq(_last_id_bytes, _removed, 8) and fp_object_check == fp_star_check and object_id > star_id + 1 - idscale and object_id <= star_id + MAX_OBJECTS_PER_STAR + idscale:
				planet_nr = (object_label[23] - 48) + 10 * (object_label[22] - 48)
				if nearstar_p_owner[planet_nr - 1] == planet_id - 1:
					labposit2[mcount] = fh.get_position() - 32
					labprogr2[mcount] = nearstar_p_moonid[planet_nr - 1]
					least = 1
					mcount += 1
		_sort_records(labposit2, labprogr2, mcount)
		n2 = 0
		while mcount > 0:
			fh.seek(labposit2[n2])
			_read_star_record()
			planet_nr = (object_label[23] - 48) + 10 * (object_label[22] - 48)
			mcount -= 1
			if mcount != 0:
				msg("$" + _pad2(nearstar_p_moonid[planet_nr - 1] + 1) + "&" + cstr(object_label))
				ncount = notesabout(object_id)
				if ncount > 0:
					msg("]   (" + str(ncount) + " NOTES)")
			else:
				msg("[" + _pad2(nearstar_p_moonid[planet_nr - 1] + 1) + "&" + cstr(object_label))
				ncount = notesabout(object_id)
				if ncount > 0:
					msg("    (" + str(ncount) + " NOTES)")
			n2 += 1
		if least:
			msg(DIVIDER)
			msg("MOONS LISTING END.")
		else:
			msg("NO KNOWN MOONS.")
