# source D:/github/TclPyHyperWorks/opt_fatigue/fatigue_search_node_ids.tcl
# 视角view记录操作
# hyperview 2021.1
# Version 0.2   2023/12/04
# 	增加遍历视角

namespace eval ::hvViewRecord {
    variable view_name 
    variable view_name2tcl
    variable view_list
    variable view_name_select

    variable recess
    variable file_dir [file dirname [info script]]
}


# UI界面
proc ::hvViewRecord::GUI { args } {
    variable recess

    set minx [winfo pixel . 200p]
    set miny [winfo pixel . 150p]
    
    # 主窗口
    ::hwt::CreateWindow hvViewRecordWin \
        -windowtitle "hvViewRecord" \
        -resizeable 1 1 \
        -propagate 1 \
        -minsize $minx $miny \
        -cancelButton "Cancel" \
        -cancelFunc ::hvViewRecord::Quit \
        noGeometrySaving
        # -addButton OK ::hvViewRecord::OkExit no_icon \

    ::hwt::KeepOnTop .hvViewRecordWin

    set recess [::hwt::WindowRecess hvViewRecordWin]

    grid columnconfigure $recess 2 -weight 1
    grid rowconfigure    $recess 10 -weight 1

    # ===================
    ::hwt::LabeledLine $recess.end_line1 "视角记录" -font {MS 10}
    grid $recess.end_line1 -row 1 -column 0 -pady 6 -sticky ew -columnspan 2

    # ===================
	label $recess.entryLabel1 -text "View名称" -font {MS 10}
    grid $recess.entryLabel1 -row 2 -column 0 -padx 2 -pady 2 -sticky nw
    entry $recess.entry1 -width 16 -textvariable ::hvViewRecord::view_name  -font {MS 10}
    grid $recess.entry1 -row 2 -column 1 -padx 2 -pady 2 -sticky nw

    # ===================
    button $recess.button_01 \
        -text "记录视角" \
        -command ::hvViewRecord::record_current_view \
        -width 16 -font {MS 10}
    grid $recess.button_01 -row 3 -column 0 -padx 2 -pady 2 -sticky nw

    # ===================
    ::hwt::LabeledLine $recess.end_line2 "视角管理" -font {MS 10}
    grid $recess.end_line2 -row 4 -column 0 -pady 6 -sticky ew -columnspan 2


    # ===================
    # button $recess.button_02 \
    #     -text "记录清空" \
    #     -command ::hvViewRecord::clear_view \
    #     -width 16
    # grid $recess.button_02 -row 4 -column 0 -padx 2 -pady 2 -sticky nw
    
    listbox $recess.listbox_01  \
    	-listvariable ::hvViewRecord::view_list \
    	-selectmode single \
    	-height 15\
    	-font {MS 10}
    grid $recess.listbox_01 -row 5 -column 0 -padx 2 -pady 2 -sticky nw
    # 选项监测
    bind $recess.listbox_01 "<<ListboxSelect>>" ::hvViewRecord::bind_listbox_select_01

    # ===================
    frame $recess.frame_01 
    grid $recess.frame_01 -row 5 -column 1  -sticky N

    button $recess.frame_01.button_02 \
        -text "删除对应view" \
        -command ::hvViewRecord::remove_view \
        -width 16 -font {MS 10}
    # grid $recess.frame_01.button_03 -row 6 -column 0 -padx 2 -pady 2 -sticky n
    grid $recess.frame_01.button_02

    # ===================
	button $recess.frame_01.button_03 \
        -text "保存视角" \
        -command ::hvViewRecord::save_view_file \
        -width 16 -font {MS 10}
    # grid $recess.button_02 -row 7 -column 0 -padx 2 -pady 2 -sticky nw
    grid $recess.frame_01.button_03


    # ===================
	button $recess.frame_01.button_04 \
        -text "加载视角" \
        -command ::hvViewRecord::load_view_file \
        -width 16 -font {MS 10}
    # grid $recess.button_04 -row 8 -column 0 -padx 2 -pady 2 -sticky nw
    grid $recess.frame_01.button_04


	button $recess.frame_01.button_05 \
        -text "遍历视角-保存图片" \
        -command ::hvViewRecord::view_all \
        -width 16 -font {MS 10}
    # grid $recess.button_04 -row 8 -column 0 -padx 2 -pady 2 -sticky nw
    grid $recess.frame_01.button_05

    # ===================
    ::hwt::RemoveDefaultButtonBinding $recess
    ::hwt::PostWindow hvViewRecordWin -onDeleteWindow ::hvViewRecord::Quit

    # ===================
    ::hvViewRecord::get_view_list
}


# 主程序
proc ::hvViewRecord::OkExit { args } {

}


proc ::hvViewRecord::Quit { args } {

    ::hwt::UnpostWindow hvViewRecordWin
}


proc ::hvViewRecord::bind_listbox_select_01 { } {
	variable recess
	variable view_name_select
	variable view_list

	# set view_name_select [$recess.listbox_01 get active]
	# puts "call: bind_listbox_select $view_name_select"
	set n_loc [$recess.listbox_01 curselection]
	set view_name_select [lindex $view_list $n_loc]
	puts "call: bind_listbox_select $view_name_select"
	hwc view restore $view_name_select

}

# 获取view相关数据
proc ::hvViewRecord::record_current_view {} {
	variable view_name2tcl
	variable view_name
	variable view_list
	# set cur_view_list [::hvViewRecord::get_view_list]
	# puts $cur_view_list

	if {$view_name in $view_list} {
		set choice [tk_messageBox -type yesnocancel -default yes -message "名字重复,是否覆盖" -icon question ]
		if {$choice != yes} {return}
	}

	set view_matrix_ortho [::hvViewRecord::get_cur_view_matrix_ortho]
	set view_matrix [lindex $view_matrix_ortho 0 ]
	set view_ortho [lindex $view_matrix_ortho 1 ]
	# puts $view_matrix_ortho

	# 记录视角信息 - 暂时无用
	set cmd_tcl [format "hwc view projection orthographic | view matrix %s | view clippingregion %s" $view_matrix $view_ortho]
	dict set view_name2tcl $view_name $cmd_tcl

	# 创建 view 视角
	::hvViewRecord::create_view_matrix_ortho $view_name $view_matrix $view_ortho
	# puts $view_name2tcl 
	
	# return $view_matrix $view_ortho $cmd_tcl

	::hvViewRecord::get_view_list
	return 0
}


# 清空view记录 - 暂停
proc ::hvViewRecord::clear_view {} {
	set choice [tk_messageBox -type yesnocancel -default yes -message "是否清空" -icon question ]
	if {$choice != yes} {return}
	variable view_name2tcl
	set view_name2tcl []
}


# 创建view
proc ::hvViewRecord::create_view_matrix_ortho {view_name view_matrix view_ortho} {

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
			viewctrl_handle SetOrtho "$view_ortho"
			# 保存视角为 $view_name
			viewctrl_handle SaveView $view_name

			# 类型调整
			viewctrl_handle SetProjectionType Orthographic $view_name
	hwi CloseStack
	return 1
}


# 获取所有view的名单
proc ::hvViewRecord::get_view_list {} {

	variable view_list
	catch { hwi CloseStack }
	hwi OpenStack 
		hwi GetSessionHandle session_handle
		session_handle GetProjectHandle project_handle
		project_handle GetPageHandle page_handle [project_handle GetActivePage]
		page_handle GetWindowHandle window_handle [page_handle GetActiveWindow]
		window_handle GetClientHandle client_handle
		window_handle GetViewControlHandle viewctrl_handle
			# viewctrl_handle GetViewList view_list
			set view_list [viewctrl_handle GetViewList]

	hwi CloseStack
	return $view_list
}


# 获取当前视角信息
proc ::hvViewRecord::get_cur_view_matrix_ortho {} {

	catch { hwi CloseStack }
	hwi OpenStack 
		hwi GetSessionHandle session_handle
		session_handle GetProjectHandle project_handle
		project_handle GetPageHandle page_handle [project_handle GetActivePage]
		page_handle GetWindowHandle window_handle [page_handle GetActiveWindow]
		window_handle GetClientHandle client_handle
		window_handle GetViewControlHandle viewctrl_handle
			set view_matrix [viewctrl_handle GetViewMatrix]
			set view_ortho [viewctrl_handle GetOrtho]

	hwi CloseStack
	return "{$view_matrix} {$view_ortho}"
}


# 保存-视角记录
proc ::hvViewRecord::save_view_file {} {
	variable file_dir

	set view_path [tk_getSaveFile -title "保存路径"  -filetypes {"result .txt"} -defaultextension txt -initialdir $file_dir]
	
	if {$view_path == ""} {
		# puts None
		return 
	}
	# puts $view_path
	hwc view export $view_path
}

# 加载-视角记录
proc ::hvViewRecord::load_view_file {} {
	variable file_dir
	set view_path [tk_getOpenFile -title "保存路径"  -filetypes {"result .txt"} -defaultextension txt -initialdir $file_dir]
	
	if {$view_path == ""} {
		# puts None
		return 
	}
	hwc view import $view_path

	# ===================
    ::hvViewRecord::get_view_list
    ::hvViewRecord::bind_listbox_select_01
}


# 删除所选的view
proc ::hvViewRecord::remove_view {} {
	# variable view_name
	
	# 更新
	# ::hvViewRecord::get_view_list
	variable view_name_select

	set choice [tk_messageBox -type yesnocancel -default yes -message "是否删除名称view" -icon question]
	if {$choice != yes} {return}

	catch { hwi CloseStack }
	hwi OpenStack 
		hwi GetSessionHandle session_handle
		session_handle GetProjectHandle project_handle
		project_handle GetPageHandle page_handle [project_handle GetActivePage]
		page_handle GetWindowHandle window_handle [page_handle GetActiveWindow]
		window_handle GetClientHandle client_handle
		window_handle GetViewControlHandle viewctrl_handle
			catch { viewctrl_handle RemoveView $view_name_select }
	hwi CloseStack

	# 更新
	::hvViewRecord::get_view_list
	::hvViewRecord::bind_listbox_select_01

	return 1
}


proc ::hvViewRecord::view_all {} {
	variable view_list

	set choice [tk_messageBox -type yesnocancel -default yes -message "是否遍历视角保存图片" -icon question]
	if {$choice != yes} {return}

	set png_path [tk_getSaveFile  -title "图片保存路径及前缀"]

	

	set len_list [llength $view_list]

	# set cur_view_list
	foreach view_n $view_list {
		hwc view restore $view_n
		# hwc save image page "$png_path_$view_n.PNG"
		hwc save image page [format "%s_%s.PNG" $png_path $view_n]
	}


}

::hvViewRecord::GUI
