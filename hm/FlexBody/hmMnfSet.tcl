# -------------------------------------
# hm_mnfset.tcl
# 柔性体文件生成设置
# 设置时会！删除！原有的 卡片\载荷\工况
# 自由模态阶数默认：10阶
# 
# -------------------------------------


# =======================================
# 获取optistruct_path
proc get_optistruct_path {} {
	set altair_dir [hm_info -appinfo ALTAIR_HOME]
	set optistruct_path [format "%s/templates/feoutput/optistruct/optistruct" $altair_dir]
	return $optistruct_path
}



# 删除原有卡片\载荷\工况
hm_blockerrormessages 1
*createmark card 1 all
catch {*deletemark card 1}
*createmark loadcols 1 all
catch {*deletemark loadcols 1}
*createmark loadstep 1 all
catch {*deletemark loadstep 1}
hm_blockerrormessages 0

# 当前文件路径 的 父目录-父目录
set filepath [file dirname [info script]]
set filepath [file dirname $filepath]
set filepath [file dirname $filepath]
puts $filepath

# CMSMETH_1
*collectorcreate loadcols "CMSMETH_1" "" 11
*createmark loadcols 1  "CMSMETH_1"
# 调用 ./HyperWorks/templates/feoutput/optistruct/optistruct
*dictionaryload loadcols 1 [get_optistruct_path] "CMSMETH"
*attributeupdateint loadcols 1 3240 1 2 0 1
*attributeupdateint loadcols 1 7685 1 2 0 1
*attributeupdatestring loadcols 1 4822 1 2 0 "CB"
*attributeupdatedouble loadcols 1 4823 1 0 0 0
*attributeupdateint loadcols 1 4824 1 0 0 0
*attributeupdateint loadcols 1 8088 1 2 0 0
*attributeupdateentity loadcols 1 4825 1 0 0 nodes 0
*attributeupdatestring loadcols 1 1033 1 0 0 "LAN"
*attributeupdateint loadcols 1 1035 1 2 0 0
*attributeupdateint loadcols 1 1038 1 2 0 0
*attributeupdateint loadcols 1 8159 1 2 0 0
# 模态阶数设置
*attributeupdateint loadcols 1 4824 1 1 0 10

# ASET
*collectorcreate loadcols "ASET_1" "" 11

# DTI_UNITS
*cardcreate "DTI_UNITS"
*createmark cards 1 "DTI_UNITS"
set idnum [hm_getmark cards 1 ]
*attributeupdatestring cards $idnum 4832 1 2 0 "MGG"
*attributeupdatestring cards $idnum 4833 1 2 0 "N"
*attributeupdatestring cards $idnum 4834 1 2 0 "MM"
*attributeupdatestring cards $idnum 4835 1 2 0 "S"

# GLOBAL_OUTPUT_REQUEST
*cardcreate "GLOBAL_OUTPUT_REQUEST"
*createmark cards 1 "GLOBAL_OUTPUT_REQUEST"
set idnum [hm_getmark cards 1 ]
*attributeupdateint cards $idnum 3809 1 2 0 1
*attributeupdateint cards $idnum 1911 1 0 0 1
*createstringarray 1  "        "
*attributeupdatestringarray cards $idnum 4319 1 2 0 1 1
*createstringarray 1  "        "
*attributeupdatestringarray cards $idnum 4030 1 2 0 1 1
*createstringarray 1  "ALL"
*attributeupdatestringarray cards $idnum 3810 1 2 0 1 1

# OUTPUT
*cardcreate "OUTPUT"
*createmark cards 1 "OUTPUT"
set idnum [hm_getmark cards 1 ]
*attributeupdateint cards $idnum 3850 1 0 0 1
*attributeupdatestring cards $idnum 130 1 0 0 "0"
*createstringarray 1  "ADAMSMNF"
*attributeupdatestringarray cards $idnum 3851 1 2 0 1 1
*createstringarray 1  "        "
*attributeupdatestringarray cards $idnum 3854 1 2 0 1 1

# GLOBAL_CASE_CONTROL
*cardcreate "GLOBAL_CASE_CONTROL"
*createmark loadcols 1  "CMSMETH_1"
*createmark cards 1 "GLOBAL_CASE_CONTROL"
set idnum [hm_getmark cards 1 ]
*attributeupdateint cards $idnum 4204 1 2 0 1
*attributeupdateentity cards $idnum 4205 1 2 0 loadcols 1




