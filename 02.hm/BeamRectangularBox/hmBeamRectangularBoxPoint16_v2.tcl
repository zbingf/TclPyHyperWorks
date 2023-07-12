# 矩形刚 - 新算法
# 直接获取完整几何特征

*createmarkpanel solids 1 
set solid_ids [hm_getmark solids 1]

set solid_point16_ids []
foreach solid_id $solid_ids {
	*createmark surfaces 1 "by solids" $solid_id
	set surf_ids [hm_getmark surfaces 1]
	*createmark points 1 "by solids" $solid_id
	set solid_point_ids [hm_getmark points 1]
	if {[llength $solid_point_ids]!=16} {continue;}
	set surf_8point_ids []
	foreach surf_id $surf_ids {
		*createmark points 1 "by surface" $surf_id
		set point_ids [hm_getmark points 1]
		if {[llength $point_ids] == 8} {
			lappend surf_8point_ids $surf_id
		}
	}
	if {[llength $surf_8point_ids] != 2} { continue }
	dict set solid_to_surf_ids_dic $solid_id $surf_8point_ids
	lappend solid_point16_ids $solid_id
	# dict set surf_to_lines_ids_dic $solid_id $surf_8point_ids
	# puts "solid point 16 : $solid_id"
}




# 符合16点要求的solid
foreach solid_id $solid_point16_ids {
	# puts $solid_id
	set surf_ids [dict get $solid_to_surf_ids_dic $solid_id]
	set surf_id_1 [lindex $surf_ids 0]
	*createmark lines 1 "by surface" $surf_id_1
	set line_ids [hm_getmark lines 1]
	puts "line_ids : $line_ids"
	
	set line_id_1 [lindex $line_ids 0]
	*createmark points 1 "by lines" $line_id_1
	set line_point_ids [hm_getmark points 1]
	*createmark lines 1 "by points" [lindex $line_point_ids 0]
	puts [hm_getmark lines 1]

	# *createmark lines 1 [lindex $line_ids 0]
	# puts [hm_getmark lines 1]
	# *appendmark lines 1 "by adjacent"
	# set line_1_ids [hm_getmark lines 1]
	# puts "line_1_ids : $line_1_ids"

}
# puts $solid_to_surf_ids_dic
# 


