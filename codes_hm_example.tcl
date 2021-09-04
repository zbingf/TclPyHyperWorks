
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


