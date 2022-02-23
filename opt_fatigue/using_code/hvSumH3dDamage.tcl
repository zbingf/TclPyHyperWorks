# optistruct 耐久计算后处理叠加专用
# source "C:/Users/zheng.bingfeng/Documents/HW_TCL/hyperworks_code/opt_fatigue/hvSumH3dDamage.tcl"


# hyperview 线性叠加后处理
proc sum_h3d_damage {model_path result_path new_h3d_path subcase_id} {

	# 前置
	catch { hwi CloseStack }
	set subcase_name [file rootname [lindex [file split $new_h3d_path] end]]

	# 清空
	hwc scale undeformed movewithtracking=false
	# 打开模型
	hwc open animation modelandresult $model_path $result_path

	# 线性叠加
	hwi OpenStack
		hwi GetSessionHandle session_handle

		session_handle GetProjectHandle project_handle
		project_handle GetPageHandle page_handle [project_handle GetActivePage]
		page_handle GetWindowHandle window_handle [page_handle GetActiveWindow]
		window_handle GetClientHandle client_handle
		client_handle GetModelHandle model_handle [client_handle GetActiveModel]
		model_handle GetResultCtrlHandle result_handle

		# 线性叠加
		result_handle AddSubcase $subcase_name $subcase_id
		result_handle GetSubcaseHandle subcase_handle $subcase_id
			subcase_handle SetDerivedType superposition
			# 导入的subcase
			set t_subcase_ids [result_handle GetSubcaseList "base"]
			foreach t_subcase_id $t_subcase_ids {
				catch {
					# 添加到 subcase 中
					subcase_handle AppendSubcase $t_subcase_id
				}
			}
	hwi CloseStack

	# 界面切换
	hwc result subcase $subcase_name
	# 显示全部comp
	hwc show component all
	# 显示损伤
	hwc result scalar load type=Damage system=global
	# 保存为h3d
	hwc save model h3d $new_h3d_path compressionloss=0.00001
}


proc get_file_name {file_path} {
	return [file rootname [lindex [file split $file_path] end]]
}

# 获取result_path
proc get_result_path {} {
	return [tk_getOpenFile -title "result h3d" -filetypes {"result .h3d"} -multi 1]
}

# 获取model_path
proc get_model_path {} {
	return [tk_getOpenFile -title "modal" -filetypes {"modal .*"}]
}

# 获取文件夹路径
proc get_dir {title} {
	return [tk_chooseDirectory -title $title]
}

# 根据result_path 且分为多个 子result_path
proc split_result_path {result_path surfix_num} {
	# 末端截取位置 num

	# set paths []
	# set surfixs []
	set path2surfixs []
	foreach result_path_one $result_path {
		# puts $result_path_one
		set list1 [split $result_path_one "_"]
		# puts $list1
		set path1 [join [lrange $list1 0 end-$surfix_num] "_"]
		# set surfix [lindex $list1 end]

		if {$path1 in $path2surfixs} {
			set cur_list [dict get $path2surfixs $path1]
			lappend cur_list $result_path_one
			dict set path2surfixs $path1 $cur_list
		} else {
			dict set path2surfixs $path1 $result_path_one
		}

	}
	# puts [dict keys $path2surfixs]
	return $path2surfixs
}


# 主程序
proc main {} {
	set file_dir [file dirname [info script]]
	set py_path   [format "%s/sub_get_h3d_files.py" $file_dir]

	set new_h3d_dir [get_dir "new h3d dir"]
	set model_path [get_model_path]
	# set new_h3d_dir "asdf"
	# set model_path "asdf"
	# set result_path [get_result_path]
	set result_path [exec python $py_path]
	set subcase_id 10000
	set surfix_num 2

	set path2surfixs [split_result_path $result_path $surfix_num]
	set path_list [dict keys $path2surfixs]
	puts "H3d File Num: [llength $path_list]"
	foreach path1 $path_list {
		set new_path1 [join "{$path1} h3d" "."]
		set new_path_name [lindex [file split $new_path1] end]
		# puts $new_path_name
		set new_h3d_path [file join $new_h3d_dir $new_path_name]
		set cur_result_path [dict get $path2surfixs $path1]
		set cur_result_path1 [join $cur_result_path ";"]
		
		puts "new_h3d_path: $new_h3d_path"
		puts "path_num: [llength $cur_result_path]"
		sum_h3d_damage $model_path $cur_result_path1 $new_h3d_path $subcase_id
	}
}

main


