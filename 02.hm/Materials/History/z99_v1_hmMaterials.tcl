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





# # 删除原有材料/属性
# hm_blockerrormessages 1
# *createmark materials 1 all
# catch {*deletemark materials 1}
# *createmark properties 1 all
# catch {*deletemark properties 1}
# hm_blockerrormessages 0

# # 当前文件路径
# set filepath [file dirname [info script]]

# # materials 材料卡片
# *collectorcreate materials "steel" "" 11
# *createmark materials 1  "steel"
# *dictionaryload materials 1 [format "%s/sets/optistruct" $filepath] "MAT1"
# *attributeupdatedouble materials 1 1 1 1 0 206000
# *attributeupdatedouble materials 1 3 1 1 0 0.3
# *attributeupdatedouble materials 1 4 1 1 0 7.85e-009

# # properties 属性卡片
# *collectorcreate properties "steel_solid" "steel" 11
# *createmark properties 1  "steel_solid"
# *dictionaryload properties 1 [format "%s/sets/optistruct" $filepath] "PSOLID"
# *attributeupdateint properties 1 3240 1 2 0 1
# *attributeupdateint properties 1 1000 1 2 0 1
# *attributeupdatestring properties 1 126 1 0 0 "FULL"
# *attributeupdatestring properties 1 127 1 0 0 "SMECH" 
# *attributeupdateint properties 1 7266 1 2 0 0


# properties
# *collectorcreate properties "steel_shell_1mm" "steel" 11
# *createmark properties 1  "steel_shell_1mm"
# *dictionaryload properties 1 [format "%s/sets/optistruct" $filepath] "PSHELL"
# *attributeupdatedouble properties 1 95 1 0 0 4.44




# *collectorcreate properties "steel_shell_3mm" "steel" 11
# *createmark properties 2  "steel_shell_3mm"
# *dictionaryload properties 2 "E:/Software/HyperWorks/templates/feoutput/optistruct/optistruct" "PSHELL"
# *attributeupdateint properties 4 3240 1 2 0 1
# *attributeupdatedouble properties 4 95 1 0 0 1
# *attributeupdateint properties 4 884 1 2 0 0
# *attributeupdatedouble properties 4 114 1 0 0 1
# *attributeupdateint properties 4 885 1 2 0 0
# *attributeupdatedouble properties 4 116 1 0 0 0.833333
# *attributeupdatedouble properties 4 96 1 2 0 0
# *attributeupdatedouble properties 4 119 1 0 0 0
# *attributeupdatedouble properties 4 120 1 0 0 0
# *attributeupdateint properties 4 897 1 2 0 1
# *attributeupdateentity properties 4 831 1 0 0 materials 0
# *attributeupdatedouble properties 4 2403 1 0 0 0
# *attributeupdateint properties 4 7253 1 2 0 0



