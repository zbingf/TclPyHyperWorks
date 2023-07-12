# -------------------------------------
# hmMaterials.tcl
# hypermeh 13.0
# 设置材料属性
# 设置前会!删除!原有材料/属性
# 调用文件夹目录下的子文件夹sets中的 optistruct
# -------------------------------------


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


set mat_id1 [create_materials_MAT1 "steel_1" 206000 0.3 7.85e-009]
set prop_id1 [create_properties_solid "steel_solid_1" "steel_1"]


