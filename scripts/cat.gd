class_name GoCat
extends NoctisCompat


func run(args: PackedStringArray) -> String:
	output = ""
	objectname = _zero(22)
	var argc := args.size() + 1
	var argv := PackedStringArray(["cat"])
	for a in args:
		argv.append(a)

	if argc < 2:
		msg("________USAGE________")
		msg("CAT OBJECTNAME")
		msg("CAT OBJECTNAME:X..Y")
		msg("^^^^^^^^^^^^^^^^^^^^^")
		msg("PLEASE RUN AGAIN,")
		msg("SPECIFYING PARAMETERS")
		return output
	else:
		msg(" GOES GALACTIC GUIDE ")
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

	if i == 21:
		msg("INVALID SUBJECT NAME.")
		fh.close()

	var rec_start := 1
	var rec_end := 32767
	if _byte(pb, i) == 58:
		var istart := i + 1
		i += 1
		while _byte(pb, i) != 46 and _byte(pb, i) != 0:
			i += 1
		rec_start = _atoi_bytes(pb, istart)
		if _byte(pb, i + 1) == 46:
			rec_end = _atoi_bytes(pb, i + 2)
		else:
			rec_end = 32767

	objectname[i] = 0
	query = find(objectname)
	if query:
		if query == 1:
			msg("SUBJECT: STAR;")
		if query == 2:
			msg("SUBJECT: PLANET;")
		msg(cstr(subjectname))
		msg(DIVIDER)
		gh = open_guide()
		if gh == null:
			msg("DATABASE ERROR.")
			msg("(ERROR CODE 1003)")
		else:
			var rec := 0
			var col := 0
			query = 0
			gh.seek(4)
			while true:
				var sb := gh.get_buffer(8)
				if sb.size() != 8:
					break
				var mb := gh.get_buffer(76)
				if mb.size() != 76:
					break
				var mblock_subject := sb.decode_double(0)
				if mblock_subject > subject_id - idscale and mblock_subject < subject_id + idscale:
					rec += 1
					if rec >= rec_start and rec <= rec_end:
						if col != 0:
							while col < 21:
								output += " "
								col += 1
							col = 0
						msg("(" + str(rec) + ")")
						query = 1
						var gi := 0
						while gi < 76 and _byte(mb, gi) != 0:
							if gi == 0 or _byte(mb, gi) == 32:
								var j := gi + 1
								var pre := col + 1
								while j < 76 and _byte(mb, j) != 32 and _byte(mb, j) != 0:
									if pre >= 21:
										while col < 21:
											output += " "
											col += 1
										col = 0
										if gi != 0:
											gi += 1
										break
									pre += 1
									j += 1
							if col == 0 and _byte(mb, gi) == 32:
								gi += 1
								continue
							output += String.chr(_byte(mb, gi))
							col += 1
							if col > 20:
								col = 0
							gi += 1
			if query == 0:
				msg("THERE WERE NO RECORDS")
				msg("IN THE GUIDE RELATING")
				msg("SPECIFIED SUBJECT.")
			else:
				msg("")
			gh.close()

	fh.close()
	return output
