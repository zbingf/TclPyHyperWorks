# source D:/github/TclPyHyperWorks/hm/RigidSolidPointLink/hmRigidSolidPointLink.tcl



proc print_elem_node_to_fem {fem_path elem_ids} {
    # 导出指定单元数据到fem
    set altair_dir [hm_info -appinfo ALTAIR_HOME]
    set optistruct_path [format "%s/templates/feoutput/optistruct/optistruct" $altair_dir]
    # elems 1
    eval "*createmark elems 1 $elem_ids"
    # nodes 1
    hm_createmark nodes 1 "by elem" $elem_ids
    # 导出
    hm_answernext yes
    *feoutput_select "$optistruct_path" $fem_path 1 0 0
}


# ==================================
# ==================================
# GUI

if {[grab current] != ""} { return; }
namespace eval ::RigidSolidPointLink {
    variable recess;
    variable solid_ids;
    variable elem_ids_base;
    variable elem_ids_target;

}

# 路径定义
set filepath [file dirname [info script]]
set ::RigidSolidPointLink::py_path [format "%s/hmRigidSolidPointLinkShell.py" $filepath]
set ::RigidSolidPointLink::temp_loc_path [format "%s/__temp_loc.txt" $filepath]
set ::RigidSolidPointLink::temp_base_path [format "%s/__temp_base.fem" $filepath]
set ::RigidSolidPointLink::temp_target_path [format "%s/__temp_target.fem" $filepath]


proc ::RigidSolidPointLink::GUI { args } {
    variable recess;

    set minx [winfo pixel . 250p];
    set miny [winfo pixel . 200p];
    if {![OnPc]} {set miny [winfo pixel . 240p];}
    set graphArea [hm_getgraphicsarea];
    set x [lindex $graphArea 0];
    set y [lindex $graphArea 1];
    
    # 主窗口
    ::hwt::CreateWindow rigidSolidPointLinkWin \
        -windowtitle "RigidSolidPointLink" \
        -cancelButton "Cancel" \
        -cancelFunc ::RigidSolidPointLink::Quit \
        -addButton OK ::RigidSolidPointLink::OkExit no_icon \
        -resizeable 1 1 \
        -propagate 1 \
        -minsize $minx $miny \
        -geometry ${minx}x${miny}+${x}+${y} \
         noGeometrySaving;
    ::hwt::KeepOnTop .rigidSolidPointLinkWin;

    set recess [::hwt::WindowRecess rigidSolidPointLinkWin];

    grid columnconfigure $recess 1 -weight 1;
    grid rowconfigure    $recess 20 -weight 1;

    # ===================
    label $recess.addLabel -text "Solid";
    grid $recess.addLabel -row 0 -column 0 -padx 2 -pady 2 -sticky nw;

    button $recess.elemsButton \
        -text "目标Solid" \
        -command ::RigidSolidPointLink::fun_solidsButton \
        -width 16 \
        -font {MS 10} ;
    grid $recess.elemsButton -row 1 -column 0 -padx 5 -pady 2 -sticky nw;

    # ===================
    ::hwt::LabeledLine $recess.end_line1 "";
    grid $recess.end_line1 -row 2 -column 0 -pady 6 -sticky ew -columnspan 2;

    # ===================
    label $recess.baseLabel -text "Base Elems" -font {MS 10} ;
    grid $recess.baseLabel -row 3 -column 0 -padx 2 -pady 2 -sticky nw;

    button $recess.baseButton \
        -text "Base Elems" \
        -command ::RigidSolidPointLink::fun_baseButton \
        -width 16 \
        -font {MS 10} ;
    grid $recess.baseButton -row 4 -column 0 -padx 2 -pady 2 -sticky nw;

    # ===================
    label $recess.targetLabel -text "Target Elems" -font {MS 10} ;
    grid $recess.targetLabel -row 3 -column 1 -padx 2 -pady 2 -sticky nw;

    button $recess.targetButton \
        -text "Target Elems" \
        -command ::RigidSolidPointLink::fun_targetButton \
        -width 16 \
        -font {MS 10} ;
    grid $recess.targetButton -row 4 -column 1 -padx 2 -pady 2 -sticky nw;

    # ===================
    ::hwt::LabeledLine $recess.end_line "";
    grid $recess.end_line -row 5 -column 0 -pady 6 -sticky ew -columnspan 2;

    # label $recess.numCopy_label -text "Num Copy" -font {MS 10} ;
    # grid $recess.numCopy_label -row 6 -column 0 -padx 2 -pady 2 -sticky nw;
    # entry $recess.numCopy -width 16 -textvariable ::RigidSolidPointLink::numCopy
    # grid $recess.numCopy -row 6 -column 1 -padx 2 -pady 2 -sticky nw;


    ::hwt::RemoveDefaultButtonBinding $recess;
    ::hwt::PostWindow rigidSolidPointLinkWin -onDeleteWindow ::RigidSolidPointLink::Quit;
    hm_highlightmark surfs 1 norm
}


proc ::RigidSolidPointLink::OkExit { args } {

	set choice [tk_messageBox -type yesnocancel -default yes -message "是否计算" -icon question ]
	if {$choice != yes} {return;}
    variable solid_ids;
    variable elem_ids_base;
    variable elem_ids_target;

    variable temp_loc_path;
    variable temp_base_path;
    variable temp_target_path;

    variable py_path;

	puts "\n-----Start-----"

    # 写入文档数据
    # 几何中心
    set f_obj [open $temp_loc_path w]
	foreach solid_id $solid_ids {
		*createmark solids 1 $solid_id
		set loc_center [hm_getcentroid solid 1]
		# eval "*createnode $loc_center 0 0 0"
	    puts $f_obj "$loc_center"
	}
	close $f_obj

	# 导出fem数据
	print_elem_node_to_fem $temp_base_path $elem_ids_base
	# 导出fem数据
	print_elem_node_to_fem $temp_target_path $elem_ids_target

	# 调用python计算
	set result_py [exec python $py_path]

	eval "$result_py"
	
	file delete $temp_loc_path
	file delete $temp_base_path
	file delete $temp_target_path

    puts "-----End-----"
}

proc ::RigidSolidPointLink::Quit { args } {
	*clearmarkall 1
	*clearmarkall 2
	::hwt::UnpostWindow rigidSolidPointLinkWin;
   # ::RigidSolidPointLink::OkExit;
}

proc ::RigidSolidPointLink::fun_solidsButton { args } {
    variable solid_ids;

	*createmarkpanel solids 1 "select the solids"
	set sids [hm_getmark solids 1]
	if {[llength $sids]<1} {
		tk_messageBox -message "Solid nums need > 1 !!!"
		hm_markclear nodes 1
		return "None"
	}
	set solid_ids $sids
}

proc ::RigidSolidPointLink::fun_baseButton { args } {
    variable elem_ids_base;

	*createmarkpanel elems 1 "select the base-elems"
	set sids [hm_getmark elems 1]
	if {[llength $sids]<1} {
		tk_messageBox -message "Elem nums need > 1 !!!"
		hm_markclear nodes 1
		return "None"
	}
	set elem_ids_base $sids
}

proc ::RigidSolidPointLink::fun_targetButton { args } {
    variable elem_ids_target;

	*createmarkpanel elems 1 "select the target-elems"
	set elem_ids [hm_getmark elems 1]

	if {[llength $elem_ids] < 1} {
		tk_messageBox -message "Elem nums need > 1 !!!"
		hm_markclear nodes 1
		return "None"
	}
	set elem_ids_target $elem_ids
}

*clearmarkall 1
*clearmarkall 2
::RigidSolidPointLink::GUI;
