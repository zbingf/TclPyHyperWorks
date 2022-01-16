# source 
# 
# 

namespace eval ::hvSearchNode {
    variable result_path
    variable value_limit
    variable dis_limit

    variable recess
    variable file_dir [file dirname [info script]]
}


# UI界面
proc ::hvSearchNode::GUI { args } {
    variable recess;

    set minx [winfo pixel . 300p];
    set miny [winfo pixel . 100p];
    
    # 主窗口
    ::hwt::CreateWindow hvSearchNodeWin \
        -windowtitle "hvSearchNode" \
        -cancelButton "Cancel" \
        -cancelFunc ::hvSearchNode::Quit \
        -addButton OK ::hvSearchNode::OkExit no_icon \
        -resizeable 1 1 \
        -propagate 1 \
        -minsize $minx $miny \
         noGeometrySaving;

    ::hwt::KeepOnTop .hvSearchNodeWin;

    set recess [::hwt::WindowRecess hvSearchNodeWin];

    grid columnconfigure $recess 1 -weight 1;
    grid rowconfigure    $recess 10 -weight 1;

    # ===================
    ::hwt::LabeledLine $recess.end_line1 "路径选择";
    grid $recess.end_line1 -row 2 -column 0 -pady 6 -sticky ew -columnspan 2;

    # ===================
    button $recess.csvPathButton \
        -text "结果保存" \
        -command ::hvSearchNode::set_result_path \
        -width 16;
    grid $recess.csvPathButton -row 3 -column 0 -padx 2 -pady 2 -sticky nw;

    # ===================
    entry $recess.entry1 -width 40 -textvariable ::hvSearchNode::result_path
    grid $recess.entry1 -row 3 -column 1 -padx 2 -pady 2 -sticky nw;

    # ===================
    ::hwt::LabeledLine $recess.end_line2 "设置";
    grid $recess.end_line2 -row 4 -column 0 -pady 6 -sticky ew -columnspan 2;

    label $recess.entryLabel2 -text "value limit";
    grid $recess.entryLabel2 -row 5 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry2 -width 16 -textvariable ::hvSearchNode::value_limit;
    grid $recess.entry2 -row 5 -column 1 -padx 2 -pady 2 -sticky nw;

    label $recess.entryLabel3 -text "dis limit";
    grid $recess.entryLabel3 -row 6 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry3 -width 16 -textvariable ::hvSearchNode::dis_limit;
    grid $recess.entry3 -row 6 -column 1 -padx 2 -pady 2 -sticky nw;


    # ===================
    ::hwt::RemoveDefaultButtonBinding $recess;
    ::hwt::PostWindow hvSearchNodeWin -onDeleteWindow ::hvSearchNode::Quit;
}


# 主程序
proc ::hvSearchNode::OkExit { args } {
	
	set py_path [format "%s/fatigue_result.py" $::hvSearchNode::file_dir]
	set temp_csv_path [format "%s/__temp.csv" $::hvSearchNode::file_dir]

	fatigue_result_damdage temp_csv_path $::hvSearchNode::value_limit

	set comp2elems [exec python $py_path "ELEM_CSV" $::hvSearchNode::dis_limit temp_csv_path]
	# set comp_ids [dict keys $comp2elems]

	set file_obj [open $::hvSearchNode::result_path w]
	puts $file_obj $comp2elems
	close $file_obj


	tk_messageBox -message "Run End!!!" 

}


proc ::hvSearchNode::Quit { args } {

    ::hwt::UnpostWindow hvSearchNodeWin;

}


proc ::hvSearchNode::set_result_path {} {

	set result_path [tk_getSaveFile -title "保存路径"  -filetypes {"result .txt"} -defaultextension csv]
	set ::hvSearchNode::result_path $result_path

}


proc fatigue_result_damdage {csv_path damage_limit} {
	set t 1
	hwi  OpenStack
		hwi GetSessionHandle sess$t 
		sess$t GetProjectHandle prj$t
		prj$t GetPageHandle pg$t [prj$t GetActivePage]
		pg$t GetWindowHandle win$t [pg$t GetActiveWindow]
		win$t GetClientHandle cln$t 
		cln$t GetModelHandle mdl$t [cln$t GetActiveModel]
		set setid  [ mdl$t AddSelectionSet element ]
		mdl$t GetSelectionSetHandle elem$t $setid 
		elem$t Add "contour > $damage_limit "
		mdl$t GetQueryCtrlHandle qry$t 
		qry$t SetQuery "element.id,contour.value"
		qry$t SetSelectionSet $setid
		qry$t WriteData $csv_path
		mdl$t RemoveSelectionSet $setid 
	hwi CloseStack
}


::hvSearchNode::GUI;
