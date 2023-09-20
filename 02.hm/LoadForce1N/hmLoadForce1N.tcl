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

	# 毕竟步骤, 提前清空
	*clearmark loadcols 1
	*clearmark loadsteps 1

	# 点创建
	hm_entityrecorder nodes on
		eval "*createnode $new_loc 0 0 0"
	hm_entityrecorder nodes off
	set node_id [hm_entityrecorder nodes ids]
	*createmark nodes 1 $node_id
	
	# 点命名
	set new_name [format "%s_%s" $point_name $num]

	set ori 0
	foreach name "Fx Fy Fz Tx Ty Tz" {
		set name [format "%s_%s" $new_name $name]

		*clearmark loadcols 1
		*clearmark loadsteps 1

		*collectorcreate loadcols "col_$name" "" 11
		*loadstepscreate "step_$name" 1

		*createmark loadcols 1 "col_$name"
		*createmark loadsteps 1 "step_$name"
		set loadcol_id [hm_getmark loadcols 1]
		set loadstep_id [hm_getmark loadsteps 1]

			# 2021.1
			*attributeupdateint loadsteps $loadstep_id 4143 1 1 0 1
			*attributeupdateint loadsteps $loadstep_id 4709 1 1 0 1
			*setvalue loadsteps id=$loadstep_id STATUS=2 4059=1 4060=STATICS
			*attributeupdateentity loadsteps $loadstep_id 4147 1 1 0 loadcols $loadcol_id
			*attributeupdateint loadsteps $loadstep_id 3800 1 1 0 0
			*attributeupdateint loadsteps $loadstep_id 707 1 1 0 0
			*attributeupdateint loadsteps $loadstep_id 2396 1 1 0 0
			*attributeupdateint loadsteps $loadstep_id 8134 1 1 0 0
			*attributeupdateint loadsteps $loadstep_id 2160 1 1 0 0
			*attributeupdateint loadsteps $loadstep_id 10212 1 1 0 0

			# *attributeupdateentity loadsteps [hm_getmark loadsteps 1] 4147 1 1 0 loadcols [hm_getmark loadcols 1]

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
			break;
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



set str_csv "是否删除原有load 及 comp"
set choice [tk_messageBox -type yesnocancel -default yes -message $str_csv -icon question ]
if {$choice == yes} {

	catch {
		*createmark loadsteps 1 "all"
		*deletemark loadsteps 1
	}
	
	catch {
		*createmark loadcols 1 "all"
		*deletemark loadcols 1	
	}
}



set str_csv "是否清楚temp node"
set choice [tk_messageBox -type yesnocancel -default yes -message $str_csv -icon question ]
if {$choice == yes} {
	*nodecleartempmark 
}


set str_csv "需csv文件:\nname1,x1,y1,z1\nname2,x2,y2,z2\n是否开始加载单位力"
set choice [tk_messageBox -type yesnocancel -default yes -message $str_csv -icon question ]
if {$choice == yes} { hmLoadForce1N }




set str_csv "是否进行惯性释放设置"
set choice [tk_messageBox -type yesnocancel -default yes -message $str_csv -icon question ]
if {$choice == yes} {

	catch {
		*cardcreate "PARAM"
		*cardcreate "OUTPUT"
	}

	*createmark cards 1 "PARAM"
	set card_param_id [hm_getmark cards 1]

	*createmark cards 1 "OUTPUT"
	set card_output_id [hm_getmark cards 1]

	*setvalue cards id=1 STATUS=2 412=1
	*setvalue cards id=$card_param_id STATUS=2 413="-2"

	*setvalue cards id=$card_output_id STATUS=2 3850=2

	*setvalue cards id=$card_output_id STATUS=2 ROW=0 3851= {H3D}
	*setvalue cards id=$card_output_id STATUS=2 ROW=0 3852= {ALL}
	*setvalue cards id=$card_output_id STATUS=2 ROW=0 3854= {        }

	*setvalue cards id=$card_output_id STATUS=2 ROW=1 3851= {OP2}
	*setvalue cards id=$card_output_id STATUS=2 ROW=1 3852= {ALL}
	*setvalue cards id=$card_output_id STATUS=2 ROW=1 3854= {        }

	
}
