# source D:/github/TclPyHyperWorks/hm/tieCreate/hmtieCreate.tcl


namespace eval ::tieCreate {
	variable surf_name "comp5"
	variable dis_limit 4
	variable deg_limit 10
    variable recess;
    variable file_dir;
}

set ::tieCreate::file_dir  [file dirname [info script]]

# 获取optistruct_path
proc get_optistruct_path {} {
	set altair_dir [hm_info -appinfo ALTAIR_HOME]
	set optistruct_path [format "%s/templates/feoutput/optistruct/optistruct" $altair_dir]
	return $optistruct_path
}



# -------------------------------------
# GUI
if {[grab current] != ""} { return; }

# UI界面
proc ::tieCreate::GUI { args } {
    variable recess;

    set minx [winfo pixel . 225p];
    set miny [winfo pixel . 180p];
    if {![OnPc]} {set miny [winfo pixel . 240p];}
    set graphArea [hm_getgraphicsarea];
    set x [lindex $graphArea 0];
    set y [lindex $graphArea 1];
    
    # 主窗口
    ::hwt::CreateWindow tieCreateWin \
        -windowtitle "tieCreate" \
        -cancelButton "Cancel" \
        -cancelFunc ::tieCreate::Quit \
        -addButton OK ::tieCreate::OkExit no_icon \
        -resizeable 1 1 \
        -propagate 1 \
        -minsize $minx $miny \
        -geometry ${minx}x${miny}+${x}+${y} \
         noGeometrySaving;
    ::hwt::KeepOnTop .tieCreateWin;

    set recess [::hwt::WindowRecess tieCreateWin];

    grid columnconfigure $recess 1 -weight 1;
    grid rowconfigure    $recess 9 -weight 1;

    # ===================
    ::hwt::LabeledLine $recess.end_line1 "单元选择";
    grid $recess.end_line1 -row 2 -column 0 -pady 6 -sticky ew -columnspan 2;

    # ===================
    label $recess.baseLabel -text "Base Elems";
    grid $recess.baseLabel -row 3 -column 0 -padx 2 -pady 2 -sticky nw;

    button $recess.baseButton \
        -text "Select Base Elems" \
        -command ::tieCreate::fun_baseButton \
        -width 16;
    grid $recess.baseButton -row 4 -column 0 -padx 2 -pady 2 -sticky nw;

    # ===================
    label $recess.targetLabel -text "Target Elems";
    grid $recess.targetLabel -row 3 -column 1 -padx 2 -pady 2 -sticky nw;

    button $recess.targetButton \
        -text "Select Target Elems" \
        -command ::tieCreate::fun_targetButton \
        -width 16;
    grid $recess.targetButton -row 4 -column 1 -padx 2 -pady 2 -sticky nw;

    # ===================
    ::hwt::LabeledLine $recess.end_line "";
    grid $recess.end_line -row 5 -column 0 -pady 6 -sticky ew -columnspan 2;

    label $recess.entryLabel1 -text "Surf Name";
    grid $recess.entryLabel1 -row 6 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry1 -width 16 -textvariable ::tieCreate::surf_name
    grid $recess.entry1 -row 6 -column 1 -padx 2 -pady 2 -sticky nw;

    label $recess.entryLabel2 -text "Dis Limit";
    grid $recess.entryLabel2 -row 7 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry2 -width 16 -textvariable ::tieCreate::dis_limit
    grid $recess.entry2 -row 7 -column 1 -padx 2 -pady 2 -sticky nw;

    label $recess.entryLabel3 -text "Deg Limit";
    grid $recess.entryLabel3 -row 8 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry3 -width 16 -textvariable ::tieCreate::deg_limit
    grid $recess.entry3 -row 8 -column 1 -padx 2 -pady 2 -sticky nw;


    ::hwt::RemoveDefaultButtonBinding $recess;
    ::hwt::PostWindow tieCreateWin -onDeleteWindow ::tieCreate::Quit;
    hm_highlightmark surfs 1 norm

    # 默认值
    set ::tieCreate::surf_name "surf_n"
    set ::tieCreate::dis_limit 30
    set ::tieCreate::deg_limit 10
}

# 主程序
proc ::tieCreate::OkExit { args } {

	set elem_ids_b $::tieCreate::elem_ids_b
	set elem_ids_t $::tieCreate::elem_ids_t

	# 参数
	set surf_1_name "$::tieCreate::surf_name\_A"
	set surf_2_name "$::tieCreate::surf_name\_B"
	set dis_limit $::tieCreate::dis_limit
	set deg_limit $::tieCreate::deg_limit


	# 路径定义
	
	set temp_path [format "%s/__temp.csv" $::tieCreate::file_dir]
	set fem_path  [format "%s/__temp.fem" $::tieCreate::file_dir]
	set tcl_path  [format "%s/__temp.tcl" $::tieCreate::file_dir]
	set tcl_path2  [format "%s/__temp2.tcl" $::tieCreate::file_dir]
	set tcl_path3  [format "%s/__temp3.tcl" $::tieCreate::file_dir]
	set tcl_path4  [format "%s/__temp4.tcl" $::tieCreate::file_dir]
	set py_path   [format "%s/hmTieCreate.py" $::tieCreate::file_dir]


	# 导出数据-fem (仅导出显示的数据)
	hm_answernext yes
	*feoutputwithdata [get_optistruct_path] $fem_path 0 0 0 1 2

	# 写入文档数据
	set f_obj [open $temp_path w]
	# *createmarkpanel elems 1
	# set elem_ids_b [hm_getmark elems 1]
	puts $f_obj $elem_ids_b
	# *maskentitymark elems 1 0

	# *createmarkpanel elems 2
	# set elem_ids_t [hm_getmark elems 2]
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
	*dictionaryload contactsurfs 2 [get_optistruct_path] "SURF"
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
	*dictionaryload contactsurfs 2 [get_optistruct_path] "SURF"
	*startnotehistorystate {Attached attributes to contactsurf "$surf_2_name"}
	*attributeupdateint contactsurfs 1 3240 1 2 0 1
	*endnotehistorystate {Attached attributes to contactsurf "$surf_2_name"}

	# 方向修正
	catch {
		source $tcl_path4
		*reversecontactsurfnormals "$surf_2_name" 1 1
	}


	# *startnotehistorystate {Interface "surf_n" created}
	# *interfacecreate "surf_n" 2 3 11
	# *createmark groups 2 "surf_n"
	# *dictionaryload groups 2 "D:/software/Altair/2019/templates/feoutput/optistruct/optistruct" "TIE"
	# *startnotehistorystate {Attached attributes to group "surf_n"}
	# *attributeupdateint groups 1 3240 1 2 0 1
	# *attributeupdatestring groups 1 130 1 0 0 "ERROR"
	# *attributeupdateint groups 1 10397 1 0 0 123
	# *attributeupdatedouble groups 1 3915 1 0 0 0
	# *attributeupdateint groups 1 2137 1 2 0 1
	# *attributeupdatestring groups 1 2138 1 2 0 "        "
	# *attributeupdatestring groups 1 1997 1 2 0 "        "
	# *attributeupdateentity groups 1 10419 1 0 0 sets 0
	# *endnotehistorystate {Attached attributes to group "surf_n"}
	# *endnotehistorystate {Interface "surf_n" created}


	# file delete $temp_path
	# file delete $fem_path
	file delete $tcl_path
	file delete $tcl_path2
	file delete $tcl_path3
	file delete $tcl_path4


	puts "-----End-----"
	*clearmarkall 1
	*clearmarkall 2
	tk_messageBox -message "Run End!!!"	

	# set ::tieCreate::elem_ids_b []
	# set ::tieCreate::elem_ids_t []
    
}

proc ::tieCreate::Quit { args } {
	*clearmarkall 1
	*clearmarkall 2
	::hwt::UnpostWindow tieCreateWin;
   # ::tieCreate::OkExit;
}


proc ::tieCreate::fun_baseButton { args } {
	*createmarkpanel elems 1 "select the elems"
	set elem_ids [hm_getmark elems 1]
	set ::tieCreate::elem_ids_b $elem_ids
}

proc ::tieCreate::fun_targetButton { args } {
	*createmarkpanel elems 1 "select the elems"
	set elem_ids [hm_getmark elems 1]
	set ::tieCreate::elem_ids_t $elem_ids
}

*clearmarkall 1
*clearmarkall 2
::tieCreate::GUI;
