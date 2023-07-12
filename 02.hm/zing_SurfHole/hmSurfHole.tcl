



proc get_surf_circle_lines {surf_id min_radius max_radius} {
	*createmark lines 1 "by surface" $surf_id
	# puts [hm_getmark lines 1]
	hm_markbyfeature 1 1 "feature_mode 1 min_radius $min_radius max_radius $max_radius"
	# puts 
	return [hm_getmark lines 1]
}


proc get_line_best_circle_center {line_id} {
	*createmark lines 1 $line_id
	set result [hm_getbestcirclecenter lines 1]
	set loc [lrange $result 0 2]
	set R [lindex $result 3]
	return "{$loc} {$R}"
}


proc get_line_circle_id {line_id} {
	
	*createmark lines 1 $line_id
	set result [hm_getbestcirclecenter lines 1]
	set x [expr round([lindex $result 0])]
	set y [expr round([lindex $result 1])]
	set z [expr round([lindex $result 2])]
	set R [expr round([lindex $result 3])]
	set circle_id "$x\_$y\_$z\_$R"
	return $circle_id
}


*createmarkpanel surfs 1 
set line_ids [get_surf_circle_lines [hm_getmark surfs 1] 1 4]
puts $line_ids
foreach line_id $line_ids {
	set circle_id [get_line_circle_id $line_id]
	puts $circle_id
}

