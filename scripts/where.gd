class_name GoWhere
extends NoctisCompat


func find(starname: PackedByteArray) -> int:
	var q := super.find(starname)
	if q == 2:
		var no := (object_label[23] - 48) + 10 * (object_label[22] - 48)
		subject_id -= float(no)
	return q


func run(args: PackedStringArray) -> String:
	output = ""
	var argc := args.size() + 1
	var argv := PackedStringArray(["where"])
	for a in args:
		argv.append(a)

	if argc < 2:
		msg("________USAGE________")
		msg("WHERE PLANETNAME")
		msg("^^^^^^^^^^^^^^^^^^^^^")
		msg("PLEASE RUN AGAIN,")
		msg("SPECIFYING PARAMETERS")
		return output
	else:
		msg("  GOES GALACTIC MAP  ")
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

	objectname = _name_buffer(parbuffer)
	query = find(objectname)
	if query:
		if query == 1:
			msg("THIS OBJECT IS A STAR")
			msg("AND ITS POSITION CAN")
			msg("BE DETERMINED USING")
			msg("THE 'PAR' MODULE.")
		else:
			fh.seek(4)
			var gotit := false
			while true:
				var idb := fh.get_buffer(8)
				if idb.size() != 8:
					break
				var lb := fh.get_buffer(24)
				if lb.size() != 24:
					break
				s_object_id = idb.decode_double(0)
				s_object_label = lb.duplicate()
				s_object_label.resize(25)
				if not _mem_eq(idb, _removed, 8):
					if s_object_id >= subject_id - idscale and s_object_id <= subject_id + idscale:
						s_object_label[20] = 0
						msg(cstr(subjectname))
						msg("IS PART OF THE")
						msg(cstr(s_object_label))
						msg("SYSTEM.")
						gotit = true
						break
			if not gotit:
				msg("UNABLE  TO  DETERMINE")
				msg("THIS PLANET'S  PARENT")
				msg("STAR;  PROBABLY, THAT")
				msg("STAR ISN'T CATALOGUED")

	fh.close()
	return output
