
# 软件: 2021.1 hyperview
# source D:/github/TclPyHyperWorks/hv/hvView.tcl

# 视角矩阵
# X Y Z 坐标
# 1 0 0 0 
# 0 1 0 0 
# 0 0 1 0 
# 0 0 0 1


# 1.0 0.0 0.0 0.0 
# 0.0 1.0 0.0 0.0 
# 0.0 0.0 1.0 0.0 
# -32.354385 -227.086258 0.0 1.0

# 
# 视角矩阵 俯视图, X朝右, Y朝前
# 1.0 0.0 0.0 0.0 
# 0.0 1.0 0.0 0.0 
# 0.0 0.0 1.0 0.0 
# 0.0 0.0 0.0 1.0

# 视角矩阵 俯视图, 相机Y向移动, 
# 1.0 0.0 0.0 0.0 
# 0.0 1.0 0.0 0.0 
# 0.0 0.0 1.0 0.0 
# 0.0 100 0.0 1.0  # 在相机视角坐标系上移动


#  X   Y   Z  
# 0.0 0.0 1.0 0.0 
# 1.0 0.0 0.0 0.0 
# 0.0 1.0 0.0 0.0 
# 0.0 0.0 0.0 1.0

# # 相机视角Y向移动,上移动
# set_view_matrix view_1 "1 0 0 0 0 1 0 0 0 0 1 0 0 200 0 1"

# # 相机视角Y向移动,上移动
# set_view_matrix view_1  "0.707107 0.353553 -0.612372 0.0 -0.707107 0.353553 -0.612372 0.0 0.0 0.866025 0.5 0.0 100.0 0.0 0.0 1.0"

# # 相机视角X向移动, 右移动
# set_view_matrix view_1 "1 0 0 0 0 1 0 0 0 0 1 0 200 0 0 1"



variable file_dir [file dirname [info script]]
set py_path [format "%s/hvView.py" $file_dir]
set csv_path [format "%s/result.csv" $file_dir]

# ===================================================

# 矢量 - 点成乘
proc v_multi_c {loc c} {
    set x [lindex $loc 0]
    set y [lindex $loc 1]
    set z [lindex $loc 2]
    set x2 [expr $x*$c]
    set y2 [expr $y*$c]
    set z2 [expr $z*$c]
    return "$x2 $y2 $z2"
}


# ===================================================
# 设置视角矩阵
proc set_view_matrix {view_name view_matrix isFit view_type} {

	catch { hwi CloseStack }
	hwi OpenStack 
		hwi GetSessionHandle session_handle
		session_handle GetProjectHandle project_handle
		project_handle GetPageHandle page_handle [project_handle GetActivePage]
		page_handle GetWindowHandle window_handle [page_handle GetActiveWindow]
		window_handle GetClientHandle client_handle
		window_handle GetViewControlHandle viewctrl_handle
			
			catch { viewctrl_handle RemoveView $view_name }
			# 设置视角
			viewctrl_handle SetViewMatrix $view_matrix
			
			if {$isFit==1} {
				# 校正
				viewctrl_handle Fit
			}
			# 获取校正后的视角矩阵
			set new_view_matrix [viewctrl_handle GetViewMatrix]
			
			# 保存视角为 $view_name
			viewctrl_handle SaveView $view_name

			# 类型调整
			if { $view_type=="O" } {
				viewctrl_handle SetProjectionType Orthographic $view_name
			} elseif { $view_type=="L" } {
				viewctrl_handle SetProjectionType Lens $view_name
			}

	hwi CloseStack
	# hwc view restore $view_name
	return $new_view_matrix
}


# 获取视角矩阵
proc get_view_matrix {} {
	hwc view orientation iso

	catch { hwi CloseStack }
	hwi OpenStack
		hwi GetSessionHandle session_handle
		session_handle GetProjectHandle project_handle
		project_handle GetPageHandle page_handle [project_handle GetActivePage]
		page_handle GetWindowHandle window_handle [page_handle GetActiveWindow]
		window_handle GetClientHandle client_handle
		window_handle GetViewControlHandle viewctrl_handle
			
			catch { viewctrl_handle RemoveView "view_1" }
			set view_matrix [viewctrl_handle GetViewMatrix]
			# puts "View Matrix: $view_matrix"
	hwi CloseStack
	return $view_matrix
}


# 
proc set_view_ortho {view_name value} {
	catch { hwi CloseStack }
	hwi OpenStack
		hwi GetSessionHandle session_handle
		session_handle GetProjectHandle project_handle
		project_handle GetPageHandle page_handle [project_handle GetActivePage]
		page_handle GetWindowHandle window_handle [page_handle GetActiveWindow]
		window_handle GetViewControlHandle viewctrl_handle

			viewctrl_handle SetActiveView true $view_name
			viewctrl_handle SetOrtho "$value"
			viewctrl_handle SetActiveView false $view_name
	hwi CloseStack
}

# 
proc set_view_Translate {view_name value} {
	catch { hwi CloseStack }
	hwi OpenStack
		hwi GetSessionHandle session_handle
		session_handle GetProjectHandle project_handle
		project_handle GetPageHandle page_handle [project_handle GetActivePage]
		page_handle GetWindowHandle window_handle [page_handle GetActiveWindow]
		window_handle GetViewControlHandle viewctrl_handle

			viewctrl_handle SetActiveView true $view_name
			eval viewctrl_handle Translate $value
			viewctrl_handle SetActiveView false $view_name
	hwi CloseStack
}


# 镜头图放大缩小
proc set_view_focal_length {view_name value} {
	catch { hwi CloseStack }
	hwi OpenStack
		hwi GetSessionHandle session_handle
		session_handle GetProjectHandle project_handle
		project_handle GetPageHandle page_handle [project_handle GetActivePage]
		page_handle GetWindowHandle window_handle [page_handle GetActiveWindow]
		window_handle GetViewControlHandle viewctrl_handle

			# viewctrl_handle SetActiveView true $view_name
			# viewctrl_handle SetZOffset $value $view_name
			viewctrl_handle SetFocalLength $value $view_name
			# viewctrl_handle Zoom $value
	hwi CloseStack
	# hwc view restore $view_name

}


proc set_view_sensor_height {view_name value} {
	catch { hwi CloseStack }
	hwi OpenStack
		hwi GetSessionHandle session_handle
		session_handle GetProjectHandle project_handle
		project_handle GetPageHandle page_handle [project_handle GetActivePage]
		page_handle GetWindowHandle window_handle [page_handle GetActiveWindow]
		window_handle GetViewControlHandle viewctrl_handle

			viewctrl_handle SetSensorHeight $value $view_name
	hwi CloseStack
	# hwc view restore $view_name
}


proc set_look_at {view_name value} {
	catch { hwi CloseStack }
	hwi OpenStack
		hwi GetSessionHandle session_handle
		session_handle GetProjectHandle project_handle
		project_handle GetPageHandle page_handle [project_handle GetActivePage]
		page_handle GetWindowHandle window_handle [page_handle GetActiveWindow]
		window_handle GetViewControlHandle viewctrl_handle

			viewctrl_handle SetLookAt $value $view_name
	hwi CloseStack
	# hwc view restore $view_name
}


# 平移摄像头
proc move_view_xy {view_name view_matrix move_xy} {
	set new_view_matrix $view_matrix

	set x [lindex $move_xy 0]
	set y [lindex $move_xy 1]
	set new_x [expr [lindex $view_matrix end-3] + $x]
	set new_y [expr [lindex $view_matrix end-2] + $y]

	set new_view_matrix [lreplace $new_view_matrix end-3 end-2 $new_x $new_y]
	
	set_view_matrix $view_name $new_view_matrix 0
	return $new_view_matrix 
}


# 重新定义视角矩阵的 相机位置
proc reset_view_matrix_camera_loc {view_matrix camera_loc} {

	return new_view_matrix
}


# 视图矩阵拼接
proc join_view_matrix {view_matrix_12 camera_loc} {
	set view_matrix $view_matrix_12
	append view_matrix " $camera_loc "
	append view_matrix 1

	return $view_matrix
}


# 获取view相关数据
proc get_data_view {view_name} {
	catch { hwi CloseStack }
	hwi OpenStack
		hwi GetSessionHandle session_handle
		session_handle GetProjectHandle project_handle
		project_handle GetPageHandle page_handle [project_handle GetActivePage]
		page_handle GetWindowHandle window_handle [page_handle GetActiveWindow]
		window_handle GetViewControlHandle viewctrl_handle

			# puts "\nGetInputSensorHeight : [viewctrl_handle GetInputSensorHeight $view_name]"
			# puts "GetSensorHeight : [viewctrl_handle GetSensorHeight $view_name]"
			# puts "GetZOffset : [viewctrl_handle GetZOffset $view_name]"
			# puts "GetFocalLength : [viewctrl_handle GetFocalLength $view_name]"
			# puts "GetViewMatrix : [viewctrl_handle GetViewMatrix]"
			puts "$view_name GetViewMatrix 1-12 : [lrange [viewctrl_handle GetViewMatrix] 0 end-4]"
			puts "$view_name GetViewMatrix 13-16 : [lrange [viewctrl_handle GetViewMatrix] end-3 end]"
			puts "$view_name GetLookAt: [viewctrl_handle GetLookAt ]"
			puts "$view_name GetPrincipalPointOffset: [viewctrl_handle GetPrincipalPointOffset ]"
			puts "$view_name GetZOffset: [viewctrl_handle GetZOffset $view_name ]"
			puts "$view_name GetActiveView: [viewctrl_handle GetActiveView]"
			
			# puts "GetOrtho : [viewctrl_handle GetOrtho]"

	hwi CloseStack

}


proc value_ortho {camera_loc offsets} {
	set ortho []
	foreach v $camera_loc offset $offsets {
		lappend ortho [expr $v - $offset]
		lappend ortho [expr $v + $offset]
	}
	return $ortho	
}


proc get_camera_loc {view_matrix} {

	return [lrange $view_matrix end-3 end-1]
}

# set camera_loc "618.32 -494.738 925.906"

# 计算视角矩阵
set result_py [exec python $py_path csv_load $csv_path]
set view_matrix_16_0 [lindex $result_py 0]
set view_matrix_16_1 [lindex $result_py 1]
set center_point_loc [lindex $result_py 2]
# puts $view_matrix_16_0
# puts $view_matrix_16_1

# set view_matrix_12_0 [lindex $result_py 0]
# set view_matrix_12_1 [lindex $result_py 1]
# set camera_loc_0 [lindex $result_py 2]
# set camera_loc_1 [lindex $result_py 3]

# set view_matrix_0 [join_view_matrix $view_matrix_12_0 $camera_loc_0]
# set view_matrix_1 [join_view_matrix $view_matrix_12_1 $camera_loc_1]


# puts "view_matrix_0:  $view_matrix_0"

# set isFit 1
# set view_name view_1
# set view_matrix [set_view_matrix $view_name $view_matrix_0 $isFit]
# set_view_focal_length $view_name 30

# puts "camera_loc: $camera_loc"
puts "center_point_loc: $center_point_loc"


set offsets "400 400 400"



# set ortho [value_ortho $center_point_loc $offsets]
set view_matrix [set_view_matrix view_1 $view_matrix_16_0 1 O]
# set_view_ortho view_1 $ortho_0
# get_data_view view_1
# set_view_focal_length view_1 20
# set_view_sensor_height view_1 1


# set ortho_1 [value_ortho [get_camera_loc $view_matrix_16_1] $offsets]
set view_matrix [set_view_matrix view_2 $view_matrix_16_1 1 O]
# set_view_ortho view_2 $ortho_1
# set_look_at view_2 "0 0 0 1 1 1 0 0 1" 
set_view_Translate view_2 [v_multi_c $center_point_loc -1]
get_data_view view_2
# set_view_focal_length view_2 20
# set_view_sensor_height view_2 1





# set view_matrix [move_view_xy $view_name $view_matrix "200 200"]
# set view_matrix [move_view_xy $view_name $view_matrix "200 200"]
# set_view_focal_length $view_name 100

# get_data_view view_1
# puts $view_matrix

