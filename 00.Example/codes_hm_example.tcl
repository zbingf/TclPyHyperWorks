
# =======================================
# 删除原有材料/属性
hm_blockerrormessages 1
*createmark materials 1 all
catch {*deletemark materials 1}
*createmark properties 1 all
catch {*deletemark properties 1}
hm_blockerrormessages 0


# =======================================
# 获取optistruct_path
proc get_optistruct_path {} {
	set altair_dir [hm_info -appinfo ALTAIR_HOME]
	set optistruct_path [format "%s/templates/feoutput/optistruct/optistruct" $altair_dir]
	return $optistruct_path
}

# --------------------------------------
# 屏幕视角
proc get_current_view_z { } {
	set view_matix [lindex [hm_getcurrentview] 0 ]
	set z_x [lindex $view_matix 2]
	set z_y [lindex $view_matix 6]
	set z_z [lindex $view_matix 10]
	return "$z_x $z_y $z_z"
}

proc get_current_view_x { } {
	set view_matix [lindex [hm_getcurrentview] 0 ]
	set z_x [lindex $view_matix 0]
	set z_y [lindex $view_matix 4]
	set z_z [lindex $view_matix 8]
	return "$z_x $z_y $z_z"
}

# --------------------------------------
# 打印数据
proc print_elem_node_to_fem {fem_path elem_ids} {
	# 导出指定单元数据到fem
	set altair_dir [hm_info -appinfo ALTAIR_HOME]
	set optistruct_path [format "%s/templates/feoutput/optistruct/optistruct" $altair_dir]
	# elems 1
	eval "*createmark elems 1 $elem_ids"
	# nodes 1
	hm_createmark nodes 1 "by elem" $elem_ids
	# 导出
	hm_answernext yes
	*feoutput_select "$optistruct_path" $fem_path 1 0 0
}

# 显示全部
proc show_all {} {
    *createmark comps 1 "all"
    *unmaskentitymark comps 1 "all" 1 0
    # *displaycollectorsallbymark 1 "all" 1 1
    *createmark elems 1 "all"
    *unmaskentitymark elements 1 0    
}

# =======================================
# 创建材料
proc create_materials_MAT1 {mat_name value_E value_NU value_RHO} {
	
	catch {
		hm_createmark materials 1 "by name only" "$mat_name"
		*deletemark materials 1
	}

	set optistruct_path  [get_optistruct_path]
	# set altair_dir [hm_info -appinfo ALTAIR_HOME]
	# set optistruct_path [format "%s/templates/feoutput/optistruct/optistruct" $altair_dir]

	*collectorcreate materials "$mat_name" "" 11
	hm_createmark materials 1 "by name only" "$mat_name"
	set mat_id [hm_getmark materials 1]
	
	*dictionaryload materials 1 $optistruct_path "MAT1"


	*attributeupdatedouble materials $mat_id 1 1 1 0 $value_E
	*attributeupdatedouble materials $mat_id 3 1 1 0 $value_NU
	*attributeupdatedouble materials $mat_id 4 1 1 0 $value_RHO
	
	return $mat_id
}

set mat_id1 [create_materials_MAT1 "steel_1" 206000 0.3 7.85e-009]
set mat_id2 [create_materials_MAT1 "steel_2" 206000 0.3 7.85e-009]


# =======================================
# 创建属性
proc create_properties_solid {prop_name mat_name} {
	
	catch {
		hm_createmark properties 1 "by name only" "$prop_name"
		*deletemark properties 1
	}

	set optistruct_path  [get_optistruct_path]
	# set altair_dir [hm_info -appinfo ALTAIR_HOME]
	# set optistruct_path [format "%s/templates/feoutput/optistruct/optistruct" $altair_dir]

	*collectorcreate properties "$prop_name" "$mat_name" 11
	hm_createmark properties 1  "$prop_name"
	set prop_id [hm_getmark properties 1]
	
	*dictionaryload properties 1 $optistruct_path "PSOLID"

	*attributeupdateint properties $prop_id 3240 1 2 0 1
	*attributeupdateint properties $prop_id 1000 1 2 0 1
	*attributeupdatestring properties $prop_id 126 1 0 0 "FULL"
	*attributeupdatestring properties $prop_id 127 1 0 0 "SMECH" 
	*attributeupdateint properties $prop_id 7266 1 2 0 0
	
	return $prop_id
}

set prop_id1 [create_properties_solid "steel_solid_1" "steel_1"]
set prop_id2 [create_properties_solid "steel_solid_2" "steel_2"]


# =======================================
# 根据nodeid 获取坐标
proc get_node_locs {node_id} {
	set x [hm_getvalue nodes id=$node_id dataname=x]
	set y [hm_getvalue nodes id=$node_id dataname=y]
	set z [hm_getvalue nodes id=$node_id dataname=z]
	return "$x $y $z"
}

proc get_node_locs {node_id prefix} {
	set x [hm_getvalue nodes id=$node_id dataname=x]
	set y [hm_getvalue nodes id=$node_id dataname=y]
	set z [hm_getvalue nodes id=$node_id dataname=z]
	if {$prefix == []} {
		return "$x $y $z"
	} else {
		return "$x$prefix$y$prefix$z"
	}
}

# =======================================
# 
proc csv_ASET_node_id_loc {csv_path} {
	# 获取所有 ASET 对应的 nodeID 及 坐标数据
	# 创建csv文件路径

	set f_obj [open $csv_path w]
	puts $f_obj "ASET_node_id,x,y,z"

	*createmark loads 1 all
	set loads_ids [hm_getmark loads 1]
	foreach load_id $loads_ids {
		# node id
		set node_id [hm_getvalue loads id=$load_id dataname=location]
		# 约束类型
		set type_name [hm_getvalue loads id=$load_id dataname=typename]

		# puts "NodeId: $node_id  type: $type_name"
		if {$type_name == "ASET"} {
			# puts "type is ASET"
			set locs [get_node_locs $node_id "," ]
			# puts "$node_id,$locs"
			puts $f_obj "$node_id,$locs"
		} 
	}
	close $f_obj
}

# =======================================
# 判定是否是RBE2
proc isBAR2 {elem_id} {
    set type_name [hm_getvalue elems id=$elem_id dataname=typename]
    if {$type_name == "{CBAR} {CBEAM} {CMBEAM}"} {
        return 1
    } else {
        return 0
    }
}

# 检索 RBE2
proc search_bar2 {elem_ids} {
    set bar2_ids []
    foreach elem_id $elem_ids {
        if {[isBAR2 $elem_id]} {
            lappend bar2_ids $elem_id
        }
    }
    return $bar2_ids
}

proc create_comps_name {name} {
    # 创建comps 前检查 是否存在
    *createmark comps 1 $name
    if {[hm_getmark comps 1]==[]} {
        *createentity comps name=$name
    }
    *createmark comps 1 $name
    return [hm_getmark comps 1]
}


proc is_entityname_exist {entity_type name} {
    *createmark $entity_type 1 $name
    if {[llength [hm_getmark $entity_type 1]]==0} {
        return 0
    } else {
        return 1
    }
}


# 根据孔周围点找对应连接单元
proc search_bar2_rbe2_from_circle_node {node_ids} {

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

    # 判定是否是RBE2
    proc sub_isBAR2 {elem_id} {
        set type_name [hm_getvalue elems id=$elem_id dataname=typename]
        if {$type_name in "{CBAR} {CBEAM} {CMBEAM}"} {
            return 1
        } else {
            return 0
        }
    }

    # 检索 RBE2
    proc sub_search_bar2 {elem_ids} {
        set bar2_ids []
        foreach elem_id $elem_ids {
            if {[sub_isBAR2 $elem_id]} {
                lappend bar2_ids $elem_id
            }
        }
        return $bar2_ids
    }

    *createmark elems 1 "by node" $node_ids
    set elem_ids [hm_getmark elems 1]
    set rbe2_ids [sub_search_rbe2 $elem_ids]
    eval *createmark elems 1 $rbe2_ids
    *appendmark elems 1 "by adjacent"
    set bar2_ids [sub_search_bar2 [hm_getmark elems 1]]

    eval *createmark elems 1 $bar2_ids
    *appendmark elems 1 "by adjacent"
    return [hm_getmark elems 1]
}


# --------------------------------

# --------------------------------
# 根据line_id 获取闭环数据 point\line
proc get_circle_data_by_line {line_id} {

	namespace eval ::TempData {
	    variable line_ids []
	    variable point_ids []
	}

	proc line_to_points {line_id} {
		
		if {$line_id in $::TempData::line_ids} {return}
		lappend ::TempData::line_ids "$line_id"

		*createmark points 1 "by lines" $line_id
		set point_ids [hm_getmark points 1]
		if {[llength $point_ids]<2} {
			lappend ::TempData::point_ids $point_ids
			return
		}
		# puts "cal_line : $line_id"
		foreach point_id $point_ids {
			if {$point_id in $::TempData::point_ids} {
				continue
			} else {
				lappend ::TempData::point_ids $point_id
			}

			*createmark lines 1 "by points" $point_id
			set line_2_ids [hm_getmark lines 1]
			# puts "cal_line_2_ids : $line_2_ids"
			foreach line_temp_id $line_2_ids {
				line_to_points $line_temp_id
			}
		}
	}

	set ::TempData::line_ids []
	set ::TempData::point_ids []
	line_to_points $line_id
	# puts "line_ids : $::TempData::line_ids"
	# puts "point_ids : $::TempData::point_ids"
	set line_ids $::TempData::line_ids
	set point_ids $::TempData::point_ids
	set ::TempData::line_ids []
	set ::TempData::point_ids []
	return "{$line_ids} {$point_ids}"
}

# 根据line_id 获取闭环数据 point\line in lines
proc get_circle_data_by_line_in_lines {line_id base_ids} {
	# line_id 需在 base_ids 里

	namespace eval ::TempData {
	    variable line_ids []
	    variable point_ids []
	    variable base_ids []
	}

	proc line_to_points {line_id} {
		
		if {$line_id in $::TempData::line_ids} {return}
		if {$line_id in $::TempData::base_ids} {} else {return}
		lappend ::TempData::line_ids "$line_id"

		*createmark points 1 "by lines" $line_id
		set point_ids [hm_getmark points 1]
		if {[llength $point_ids]<2} {
			lappend ::TempData::point_ids $point_ids
			return
		}
		# puts "cal_line : $line_id"
		foreach point_id $point_ids {
			if {$point_id in $::TempData::point_ids} {
				continue
			} else {
				lappend ::TempData::point_ids $point_id
			}

			*createmark lines 1 "by points" $point_id
			set line_2_ids [hm_getmark lines 1]
			# puts "cal_line_2_ids : $line_2_ids"
			foreach line_temp_id $line_2_ids {
				line_to_points $line_temp_id
			}
		}
	}

	set ::TempData::line_ids []
	set ::TempData::point_ids []
	set ::TempData::base_ids $base_ids
	line_to_points $line_id
	# puts "line_ids : $::TempData::line_ids"
	# puts "point_ids : $::TempData::point_ids"
	set line_ids $::TempData::line_ids
	set point_ids $::TempData::point_ids
	set ::TempData::line_ids []
	set ::TempData::point_ids []
	set ::TempData::base_ids []
	return "{$line_ids} {$point_ids}"
}


# 根据 line 获取 相应面的 闭环line\point id
proc get_surf_data_by_line {line_id} {

	*createmark surfs 1 "by lines" $line_id
	set surf_id [hm_getmark surfs 1]
	*createmark lines 1 "by surface" $surf_id
	set line_surf_ids [hm_getmark lines 1]
	puts "line_surf_ids : $line_surf_ids"
	set line_cur_ids []

	set circle_data [get_circle_data_by_line_in_lines [lindex $line_surf_ids 0] $line_surf_ids]
	set circle_data_list "{$circle_data}"
	set line_cur_ids [concat $line_cur_ids [lindex $circle_data 0]]

	foreach line_surf_id [lrange $line_surf_ids 1 end] {
		if {$line_surf_id in $line_cur_ids} {continue} else {
			set circle_data [get_circle_data_by_line_in_lines $line_surf_id $line_surf_ids]
			lappend circle_data_list $circle_data
			set line_cur_ids [concat $line_cur_ids [lindex $circle_data 0]]			
			puts "cur_line_cur_ids : $line_cur_ids"
		}
	}
	return $circle_data_list
}

