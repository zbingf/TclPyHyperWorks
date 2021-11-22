# source D:/github/TclPyHyperWorks/hm/TieCreate/hmTieCreate.tcl


# 参数
set surf_1_name "comp5_A"
set surf_2_name "comp5_B"
set dis_limit  4
set deg_limit  10


# 获取optistruct_path
proc get_optistruct_path {} {
	set altair_dir [hm_info -appinfo ALTAIR_HOME]
	set optistruct_path [format "%s/templates/feoutput/optistruct/optistruct" $altair_dir]
	return $optistruct_path
}


# 路径定义
set filepath  [file dirname [info script]]
set temp_path [format "%s/__temp.csv" $filepath]
set fem_path  [format "%s/__temp.fem" $filepath]
set tcl_path  [format "%s/__temp.tcl" $filepath]
set tcl_path2  [format "%s/__temp2.tcl" $filepath]
set tcl_path3  [format "%s/__temp3.tcl" $filepath]
set tcl_path4  [format "%s/__temp4.tcl" $filepath]
set py_path   [format "%s/hmTieCreate.py" $filepath]


# 导出数据-fem (仅导出显示的数据)
hm_answernext yes
*feoutputwithdata [get_optistruct_path] $fem_path 0 0 0 1 2

# 写入文档数据
set f_obj [open $temp_path w]
*createmarkpanel elems 1
set elem_ids_b [hm_getmark elems 1]
puts $f_obj $elem_ids_b
*maskentitymark elems 1 0

*createmarkpanel elems 2
set elem_ids_t [hm_getmark elems 2]
puts $f_obj $elem_ids_t

close $f_obj

# *createmark elems 1 $elem_ids_b
# *unmaskentitymark elems 1 0

# ------------------------------------------
# 调用 python数据
set result_py [exec python $py_path $dis_limit $deg_limit]
if {$result_py} {
	puts "python run success!!"
} else {
	return;
}

# ------------------------------------------
# A surf创建
source $tcl_path
*contactsurfcreatewithshells "$surf_1_name" 11 1 0
*createmark contactsurfs 2 "$surf_1_name"
*dictionaryload contactsurfs 2 [get_optistruct_path] "ELIST"
*startnotehistorystate {Attached attributes to contactsurf "$surf_1_name"}
*attributeupdateint contactsurfs 1 3240 1 2 0 1
*endnotehistorystate {Attached attributes to contactsurf "$surf_1_name"}

# 方向修正
catch {
	source $tcl_path3
	*reversecontactsurfnormals "$surf_1_name" 1 1
}

# ------------------------------------------
# B surf创建
source $tcl_path2
*contactsurfcreatewithshells "$surf_2_name" 11 1 0
*createmark contactsurfs 2 "$surf_2_name"
*dictionaryload contactsurfs 2 [get_optistruct_path] "ELIST"
*startnotehistorystate {Attached attributes to contactsurf "$surf_2_name"}
*attributeupdateint contactsurfs 1 3240 1 2 0 1
*endnotehistorystate {Attached attributes to contactsurf "$surf_2_name"}

# 方向修正
catch {
	source $tcl_path4
	*reversecontactsurfnormals "$surf_2_name" 1 1
}


file delete $temp_path
file delete $fem_path
file delete $tcl_path
file delete $tcl_path2
file delete $tcl_path3
file delete $tcl_path4

