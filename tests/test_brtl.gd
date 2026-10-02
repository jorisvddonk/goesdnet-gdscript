extends RefCounted
const NAME := "brtl"


func run(t: GoTestContext) -> void:
	GoesnetBrtl.srand(1)
	var seq := [346, 130, 10982, 1090, 11656, 7117, 17595, 6415]
	for i in range(seq.size()):
		t.eq(GoesnetBrtl.rand(), seq[i], "rand(seed=1) #%d" % i)

	GoesnetBrtl.srand(1234)
	var rseq := [1356, 29133, 21998, 27018, 30398, 13799]
	for i in range(rseq.size()):
		t.eq(GoesnetBrtl.rand(), rseq[i], "rand(seed=1234) #%d" % i)

	GoesnetBrtl.srand(1234)
	var r10 := [0, 8, 6, 8, 9, 4, 8, 5, 8, 6]
	for i in range(r10.size()):
		t.eq(GoesnetBrtl.random(10), r10[i], "random(10) #%d" % i)

	GoesnetBrtl.srand(1234)
	var r360 := [14, 320, 241, 296, 333, 151]
	for i in range(r360.size()):
		t.eq(GoesnetBrtl.random(360), r360[i], "random(360) #%d" % i)

	GoesnetBrtl.srand(0)
	var r0 := [0, 1, 0, 33, 3, 35]
	for i in range(r0.size()):
		t.eq(GoesnetBrtl.random(100), r0[i], "random(100) seed0 #%d" % i)

	t.eq(GoesnetBrtl.to_i16(65535), -1, "to_i16 65535")
	t.eq(GoesnetBrtl.to_i16(40000), -25536, "to_i16 40000")
	t.eq(GoesnetBrtl.to_u16(-1), 65535, "to_u16 -1")
	t.eq(GoesnetBrtl.to_i32(4294967295), -1, "to_i32 0xFFFFFFFF")
	t.eq(GoesnetBrtl.to_i32(2147483648), -2147483648, "to_i32 0x80000000")

	var buf := "abcXYZ".to_ascii_buffer()
	GoesnetBrtl.strupr_buf(buf)
	t.eq(buf.get_string_from_ascii(), "ABCXYZ", "strupr_buf")
