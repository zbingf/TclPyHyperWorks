# 单位力创建
# 六分力
# zbingf
# version 3.3
# 20230921

# csv 模板
# a,200.000,-410.000,250.000
# b,200.000,410.000,250.000
# c,5.000,-275.000,250.000
# d,5.000,275.000,250.000


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
	close $f_obj


	eval *createmark nodes 2 $node_ids
	
	hm_entityrecorder elems on
		*rigidlinkinodecalandcreate 2 0 0 123456
	hm_entityrecorder elems off

	set rb2_id [hm_entityrecorder elems ids]


	puts "========End hmLoadForce1N========="
	return $rb2_id
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



set str_csv "是否清除temp node"
set choice [tk_messageBox -type yesnocancel -default yes -message $str_csv -icon question ]
if {$choice == yes} {
	*nodecleartempmark 
}


set str_csv "需csv文件:\nname1,x1,y1,z1\nname2,x2,y2,z2\n是否开始加载单位力"
set choice [tk_messageBox -type yesnocancel -default yes -message $str_csv -icon question ]
if {$choice == yes} {
	set rb2_id [hmLoadForce1N]
}




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



# --------------------------------
# rb2自动连接

# 判定是否是RBE2
proc sub_isRBE2 {elem_id} {
    set type_name [hm_getvalue elems id=$elem_id dataname=typename]
    if {$type_name == "RBE2"} {
        return 1
    } else {
        return 0
    }
}

# 检索 RBE2
proc sub_search_rbe2 {elem_ids} {
    set rbe2_ids []
    foreach elem_id $elem_ids {
        if {[sub_isRBE2 $elem_id]} {
            lappend rbe2_ids $elem_id
        }
    }
    return $rbe2_ids
}



# 获取rigid主节点
proc get_rigid_indep_id {rigid_id} {

    set list_id [hm_getvalue elems id=$rigid_id dataname=nodes]

    set indep_node_id [lindex $list_id 0]

    return $indep_node_id
}


proc get_rigid_dep_id {rigid_id} {

    set list_id [hm_getvalue elems id=$rigid_id dataname=nodes]

    set dep_node_ids [lrange $list_id 1 end]

    return $dep_node_ids
}


# 获取node 对应坐标
proc get_node_locs {node_id} {
    set x [hm_getvalue nodes id=$node_id dataname=x]
    set y [hm_getvalue nodes id=$node_id dataname=y]
    set z [hm_getvalue nodes id=$node_id dataname=z]
    return "$x $y $z"
}





set str_csv "是否进行rigid 与 rigid 的 耦合"
set choice [tk_messageBox -type yesnocancel -default yes -message $str_csv -icon question ]
if {$choice == yes} {

	set dep_node_ids [get_rigid_dep_id $rb2_id]

	eval *createmark node 1 $dep_node_ids
	# set r 5

	set r [hm_getfloat "nearby search radius:" "Please specify a radius" 5.0]


	hm_getnearbyentities inputentitytype=nodes inputentitymark=1 outputentitytypes={elems} outputentitymark=2 radius=$r nearby_search_method=sphere
	set elem_ids [hm_getmark elems 2]
	# puts "elem_ids: $elem_ids"
	set elem_rigid_ids [sub_search_rbe2 $elem_ids]
	puts "elem_rigid_ids: $elem_rigid_ids"


	# for elem_rigid_id in get_rigid_indep_id:

	# foreach elem_id $elem_rigid_ids {
	# 	# if {$rb2_id == $elem_id} { continue }
	# 	puts $elem_id

	# }

	*clearmark elems 1
	eval *createmark elems 1 $elem_rigid_ids
	catch {
		*equivalence elems 1 $r 1 0 0	
	}
	puts "耦合rigid"


	# *clearmark elems 1
	# *createmark elems 1 $rb2_id
	# catch { *deletemark elems 1	}
	# puts "删除rigid $rb2_id"


	# 清除temp node
	*nodecleartempmark 
	puts "清除temp node"


	*EntityPreviewEmpty loadcols 1
	# set loadcols_id [hm_getmark loadcols 1]
	if {[ llength [hm_getmark loadcols 1] ] > 0} {
		tk_messageBox -message "纯在空loadcols\n耦合可能不完全!!!" -icon warning
	} else {
		*clearmark elems 1
		*createmark elems 1 $rb2_id
		catch { *deletemark elems 1	}
		puts "删除rigid $rb2_id"
	}

}









