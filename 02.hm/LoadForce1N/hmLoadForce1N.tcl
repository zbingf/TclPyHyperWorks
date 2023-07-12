# 单位力创建
# 六分力
# zbingf
# version 1.1


set filepath [file dirname [info script]]

	
proc hardpoint_load {num loc} {

	# hardpoint
	set list1 [split $loc ","] 
	set new_loc [lrange $list1 1 end]
	set point_name [lindex $list1 0]

	hm_entityrecorder nodes on
		eval "*createnode $new_loc 0 0 0"
	hm_entityrecorder nodes off
	set node_id [hm_entityrecorder nodes ids]
	*createmark nodes 1 $node_id
	
	set new_name [format "%s_%s" $point_name $num]

	set ori 0
	foreach name "Fx Fy Fz Tx Ty Tz" {
		set name [format "%s_%s" $new_name $name]

		*collectorcreate loadcols "$name" "" 11
		*loadstepscreate "$name" 1
		*createmark loadcols 1 "$name"
		*createmark loadsteps 1 "$name"
			*attributeupdateentity loadsteps [hm_getmark loadsteps 1] 4147 1 1 0 loadcols [hm_getmark loadcols 1]

		if {$ori == 0} {
			*loadcreateonentity_curve nodes 1 1 1 1 0 0 0 0 1 0 0 0 0 0	
		} elseif {$ori == 1} {
			*loadcreateonentity_curve nodes 1 1 1 0 1 0 0 0 1 0 0 0 0 0
		} elseif {$ori == 2} {
			*loadcreateonentity_curve nodes 1 1 1 0 0 1 0 0 1 0 0 0 0 0
		} elseif {$ori == 3} {
			*loadcreateonentity_curve nodes 1 2 1 1 0 0 0 0 1 0 0 0 0 0		
		} elseif {$ori == 4} {
			*loadcreateonentity_curve nodes 1 2 1 0 1 0 0 0 1 0 0 0 0 0		
		} elseif {$ori == 5} {
			*loadcreateonentity_curve nodes 1 2 1 0 0 1 0 0 1 0 0 0 0 0	
		}
		set ori [expr $ori + 1 ]
	}
	return $node_id
}
	

proc hmLoadForce1N {} {
	# set csv_path "LoadForce1N/hardpoint.csv"
	# set csv_path [format "%s/%s" $filepath "hardpoint.csv"]
	puts "========Start hmLoadForce1N========="
	set csv_path [tk_getOpenFile -title "select csv file" -filetypes {{{csv file} {.csv}}}]
	if {[string length $csv_path] < 3 } {
		puts "========End hmLoadForce1N========="
		return 
	}
	puts "csv_path: $csv_path"

	set f_obj [open $csv_path r]
	set node_ids []
	set num 0
	while {[eof $f_obj]==0} {
		set line [gets $f_obj]
		if {[string length $line] < 3 } {
			continue
		}
		set num [expr $num + 1]
		lappend node_ids [hardpoint_load $num $line]
	}
		
	eval *createmark nodes 2 $node_ids
	*rigidlinkinodecalandcreate 2 0 0 123456
	close $f_obj

	puts "========End hmLoadForce1N========="
}

hmLoadForce1N