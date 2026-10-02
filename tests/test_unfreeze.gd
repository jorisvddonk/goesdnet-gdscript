extends RefCounted
const NAME := "unfreeze"


func run(t: GoTestContext) -> void:
	var base := OS.get_temp_dir().path_join("goesnet_gd_unfreeze")
	DirAccess.make_dir_recursive_absolute(base)
	var path := base.path_join("CURRENT.BIN")
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_8(7)            # nsync
	f.store_8(3)            # anti_rad
	f.store_8(1)            # pl_search
	f.store_8(0)            # field_amplificator
	f.store_8(63)           # ilight
	f.store_8(5)            # ilightv
	f.store_8(9)            # charge
	f.store_8(0)            # revcontrols
	f.store_8(0)            # ap_targetting
	f.store_8(1)            # ap_targetted
	f.store_8(0)            # ip_targetting
	f.store_8(-1)           # ip_targetted
	f.store_8(0)            # ip_reaching
	f.store_8(0)            # ip_reached
	f.store_8(4)            # ap_target_spin
	f.store_8(10)           # ap_target_r
	f.store_8(20)           # ap_target_g
	f.store_8(30)           # ap_target_b
	f.store_8(0)            # nearstar_spin
	f.store_8(1)            # nearstar_r
	f.store_8(2)            # nearstar_g
	f.store_8(3)            # nearstar_b
	f.store_8(0)            # gburst
	f.store_8(1)            # menusalwayson
	f.store_8(0)            # depolarize
	f.store_16(4)           # sys
	f.store_16(15000)       # pwr
	f.store_16(2)           # dev_page
	f.store_16(3)           # ap_target_class
	f.store_16(0)           # f_ray_elapsed
	f.store_16(5)           # nearstar_class
	f.store_16(6)           # nearstar_nop
	f.store_float(1.5)      # pos_x
	f.store_float(-2.5)     # pos_y
	f.store_float(-500.0)   # pos_z
	f.store_float(0.1)      # user_alfa
	f.store_float(0.2)      # user_beta
	f.store_float(0.3)      # navigation_beta
	f.store_float(15.0)     # ap_target_ray
	f.store_float(1000.0)   # nearstar_ray
	f.store_double(3797120.0)   # dzat_x
	f.store_double(-4352112.0)  # dzat_y
	f.store_double(-925018.0)   # dzat_z
	f.store_double(1.0)     # ap_target_x
	f.store_double(2.0)     # ap_target_y
	f.store_double(3.0)     # ap_target_z
	f.store_double(4.0)     # nearstar_x
	f.store_double(5.0)     # nearstar_y
	f.store_double(6.0)     # nearstar_z
	f.store_double(1.0)     # helptime
	f.store_double(2.0)     # ip_target_initial_d
	f.store_double(1.0)     # requested_approach_coefficient
	f.store_double(1.0)     # current_approach_coefficient
	f.store_double(0.01)    # reaction_time
	var status := "ACTIVE".to_ascii_buffer()
	status.resize(11)
	f.store_buffer(status)  # fcs_status
	f.store_16(7)           # fcs_status_delay
	f.store_16(4)           # psys
	f.store_double(8.0)     # ap_target_initial_d
	f.store_double(1.0)     # requested_vimana_coefficient
	f.store_double(1.0)     # current_vimana_coefficient
	f.store_double(0.02)    # vimana_reaction_time
	f.store_8(1)            # lithium_collector
	f.store_8(0)            # autoscreenoff
	f.store_8(0)            # ap_reached
	f.store_16(2)           # lifter
	f.store_double(3.5)     # secs
	f.close()

	OS.set_environment("NOCTIS_DATA_DIR", base)
	var c := NoctisCompat.new()
	c.unfreeze()

	t.eq(c.nsync, 7, "nsync")
	t.eq(c.anti_rad, 3, "anti_rad")
	t.eq(c.ilight, 63, "ilight")
	t.eq(c.ap_targetted, 1, "ap_targetted")
	t.eq(c.ip_targetted, -1, "ip_targetted signed")
	t.eq(c.sys, 4, "sys")
	t.eq(c.pwr, 15000, "pwr")
	t.eq(c.ap_target_class, 3, "ap_target_class")
	t.eq(c.nearstar_class, 5, "nearstar_class")
	t.eq(c.nearstar_nop, 6, "nearstar_nop")
	t.check(absf(c.pos_x - 1.5) < 1e-6, "pos_x float")
	t.check(absf(c.pos_y - -2.5) < 1e-6, "pos_y float")
	t.check(absf(c.ap_target_ray - 15.0) < 1e-6, "ap_target_ray float")
	t.check(absf(c.dzat_x - 3797120.0) < 1e-6, "dzat_x double")
	t.check(absf(c.nearstar_z - 6.0) < 1e-6, "nearstar_z double")
	t.eq(c.cstr(c.fcs_status), "ACTIVE", "fcs_status bytes")
	t.eq(c.fcs_status_delay, 7, "fcs_status_delay")
	t.check(absf(c.secs - 3.5) < 1e-9, "secs")
