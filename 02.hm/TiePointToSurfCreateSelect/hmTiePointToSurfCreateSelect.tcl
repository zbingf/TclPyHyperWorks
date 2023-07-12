

namespace eval ::TiePointToSurfCreateSelect {

	variable recess
	variable node_ids
	variable elem_ids

	variable tie_name
	variable tolerance
	variable isSaveSelect

	variable filepath
	variable temp_path
	variable py_path
}

if {[info exists ::TiePointToSurfCreateSelect::tie_name]==0} {set ::TiePointToSurfCreateSelect::tie_name "Tie_Point2Surf_n"}
if {[info exists ::TiePointToSurfCreateSelect::tolerance]==0} {set ::TiePointToSurfCreateSelect::tolerance 5}
if {[info exists ::TiePointToSurfCreateSelect::isSaveSelect]==0} {set ::TiePointToSurfCreateSelect::isSaveSelect 0}


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
proc ::TiePointToSurfCreateSelect::GUI { args } {
    variable recess;

    set minx [winfo pixel . 225p];
    set miny [winfo pixel . 180p];
    if {![OnPc]} {set miny [winfo pixel . 240p];}
    set graphArea [hm_getgraphicsarea];
    set x [lindex $graphArea 0];
    set y [lindex $graphArea 1];
    
    # 主窗口
    ::hwt::CreateWindow winTiePointToSurfCreateSelect \
        -windowtitle "TiePointToSurfCreateSelect" \
        -cancelButton "Cancel" \
        -cancelFunc ::TiePointToSurfCreateSelect::Quit \
        -addButton OK ::TiePointToSurfCreateSelect::OkExit no_icon \
        -resizeable 1 1 \
        -propagate 1 \
        -minsize $minx $miny \
        -geometry ${minx}x${miny}+${x}+${y} \
         noGeometrySaving;
    ::hwt::KeepOnTop .winTiePointToSurfCreateSelect;

    set recess [::hwt::WindowRecess winTiePointToSurfCreateSelect];

    grid columnconfigure $recess 1 -weight 1;
    grid rowconfigure    $recess 10 -weight 1;

    # ===================
    ::hwt::LabeledLine $recess.end_line1 "选择";
    grid $recess.end_line1 -row 2 -column 0 -pady 6 -sticky ew -columnspan 2;

    # ===================
    label $recess.baseLabel -text "Nodes";
    grid $recess.baseLabel -row 3 -column 0 -padx 2 -pady 2 -sticky nw;

    button $recess.baseButton \
        -text "Node Select" \
        -command ::TiePointToSurfCreateSelect::fun_baseButton \
        -width 16;
    grid $recess.baseButton -row 4 -column 0 -padx 2 -pady 2 -sticky nw;

    # ===================
    label $recess.targetLabel -text "Elems";
    grid $recess.targetLabel -row 3 -column 1 -padx 2 -pady 2 -sticky nw;

    button $recess.targetButton \
        -text "Elems Select" \
        -command ::TiePointToSurfCreateSelect::fun_targetButton \
        -width 16;
    grid $recess.targetButton -row 4 -column 1 -padx 2 -pady 2 -sticky nw;

    # ===================
    ::hwt::LabeledLine $recess.end_line "";
    grid $recess.end_line -row 5 -column 0 -pady 6 -sticky ew -columnspan 2;

    label $recess.entryLabel1 -text "Tie 名称";
    grid $recess.entryLabel1 -row 6 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry1 -width 16 -textvariable ::TiePointToSurfCreateSelect::tie_name
    grid $recess.entry1 -row 6 -column 1 -padx 2 -pady 2 -sticky nw;

    label $recess.entryLabel2 -text "连接容差";
    grid $recess.entryLabel2 -row 7 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry2 -width 16 -textvariable ::TiePointToSurfCreateSelect::tolerance
    grid $recess.entry2 -row 7 -column 1 -padx 2 -pady 2 -sticky nw;

    checkbutton $recess.checkSelect \
        -text "计算后保留选择" \
        -onvalue 1 \
        -offvalue 0 \
        -variable ::TiePointToSurfCreateSelect::isSaveSelect \
        -command ::TiePointToSurfCreateSelect::fun_checkSelectButton
        # -width 16;
    grid $recess.checkSelect -row 10 -column 0 -padx 2 -pady 2 -sticky nw;

    button $recess.delButton \
        -text "删除名称对应的Tie" \
        -command ::TiePointToSurfCreateSelect::fun_delButton \
        -width 16;
    grid $recess.delButton -row 10 -column 1 -padx 2 -pady 2 -sticky nw;

    ::hwt::RemoveDefaultButtonBinding $recess;
    ::hwt::PostWindow winTiePointToSurfCreateSelect -onDeleteWindow ::TiePointToSurfCreateSelect::Quit;
}


proc ::TiePointToSurfCreateSelect::fun_delButton {args} {

    set choice [tk_messageBox -type yesnocancel -default yes -message "是否删除" -icon question ]
    if {$choice != yes} {return;}

    set tie_name $::TiePointToSurfCreateSelect::tie_name

    catch {
        *createmark groups 1 "$tie_name"
        *deletemark groups 1
    }
    
    catch {
        *createmark sets 1 "$tie_name\_point"
        *deletemark sets 1
    }

    catch {
        *createmark sets 1 "$tie_name\_elem"
        *deletemark sets 1
    }

}

proc ::TiePointToSurfCreateSelect::OkExit { args } {
    set choice [tk_messageBox -type yesnocancel -default yes -message "是否计算" -icon question ]
    if {$choice != yes} {return;}

    set node_ids  $::TiePointToSurfCreateSelect::node_ids
    set elem_ids $::TiePointToSurfCreateSelect::elem_ids
    set tolerance $::TiePointToSurfCreateSelect::tolerance
    set tie_name $::TiePointToSurfCreateSelect::tie_name

    set name_point "$tie_name\_point"
    set name_elem  "$tie_name\_elem"

    *createentity sets cardimage=SET_GRID name=$name_point
    *createmark sets 1 $name_point
    eval "*setvalue sets id=[hm_getmark sets 1] ids={nodes $node_ids}"

    *createentity sets cardimage=SET_ELEM name=$name_elem
    *createmark sets 1 $name_elem
	eval "*setvalue sets id=[hm_getmark sets 1] ids={elems $elem_ids}"

	*interfacecreate "$tie_name" 2 3 11
	*createmark groups 1 "$tie_name"
	set group_id [hm_getmark groups 1]
	*dictionaryload groups 1 [get_optistruct_path] "TIE"

	# *setvalue groups id=$group_id STATUS=2 1997=""
	*setvalue groups id=$group_id STATUS=2 3915=$tolerance

	*createmark sets 1 "$name_point"
	*setvalue groups id=$group_id slaveentityids={sets [hm_getmark sets 1]}

	*createmark sets 1 "$name_elem"
	*setvalue groups id=$group_id masterentityids={sets [hm_getmark sets 1]}


	tk_messageBox -message "Run End!!!" 
	
	eval "*createmark nodes 1 $node_ids"
	hm_highlightmark nodes 1 "highlight"
	eval "*createmark elems 1 $elem_ids"
	hm_highlightmark elems 1 "highlight"


	::TiePointToSurfCreateSelect::fun_checkSelectButton
}


proc ::TiePointToSurfCreateSelect::Quit { args } {
    *clearmarkall 1
    *clearmarkall 2
    ::hwt::UnpostWindow winTiePointToSurfCreateSelect;
}


proc ::TiePointToSurfCreateSelect::fun_baseButton {args} {
	*createmarkpanel nodes 1 "select the nodes"
	set ::TiePointToSurfCreateSelect::node_ids [hm_getmark nodes 1]
}

proc ::TiePointToSurfCreateSelect::fun_targetButton {args} {
	*createmarkpanel elems 1 "select the elems"
	set ::TiePointToSurfCreateSelect::elem_ids [hm_getmark elems 1]
}

proc ::TiePointToSurfCreateSelect::fun_checkSelectButton {args} {
    if {$::TiePointToSurfCreateSelect::isSaveSelect==0} {
        set ::TiePointToSurfCreateSelect::node_ids []
        set ::TiePointToSurfCreateSelect::elem_ids []   
    }
}

::TiePointToSurfCreateSelect::GUI