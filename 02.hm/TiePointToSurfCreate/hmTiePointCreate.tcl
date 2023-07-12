# 适用 2017
# 

namespace eval ::TiePointCreate {
    variable recess;
    variable comp_id_point;
    variable comp_id_surf;
    
    variable name;
    variable tolerance;
    variable c_limit;
    variable deg_limit;

    variable filepath;
    variable temp_path;
    variable py_path;
    
}

set ::TiePointCreate::filepath [file dirname [info script]]
set ::TiePointCreate::temp_path [format "%s/__temp.fem" $::TiePointCreate::filepath]
set ::TiePointCreate::csv_path [format "%s/__temp.csv" $::TiePointCreate::filepath]
set ::TiePointCreate::py_path [format "%s/hmTiePointCreate.py" $::TiePointCreate::filepath]

# *createmark components 1 "K9MD_WYS700_500_LJZJ_001"

proc get_optistruct_path {} {
	set altair_dir [hm_info -appinfo ALTAIR_HOME]
	set optistruct_path [format "%s/templates/feoutput/optistruct/optistruct" $altair_dir]
	return $optistruct_path
}

proc print_fem {temp_path} {
	*createmark components 1 $::TiePointCreate::comp_id_point
	*findedges1 components 1 0 0 0 30
	catch {
		*createmark components 1 "__edges"
		*deletemark components 1
	}
	*createmark comps 1 "^edges"
	set comp_id [hm_getmark comps 1]
	eval "*setvalue comps id=$comp_id name=__edges"

	# hm_answernext yes
	# *feoutputwithdata [get_optistruct_path ] $temp_path 0 0 0 1 2
	
	*createmark elems 1 "by comp" "__edges"
	set elem_output_ids [hm_getmark elems 1]
	*createmark elems 1 "by comp" $::TiePointCreate::comp_id_point
	set elem_output_ids [concat $elem_output_ids [hm_getmark elems 1]]
	*createmark elems 1 "by comp" $::TiePointCreate::comp_id_surf
	set elem_output_ids [concat $elem_output_ids [hm_getmark elems 1]]

	*clearmarkall 1
	print_elem_node_to_fem $temp_path $elem_output_ids

	catch {
		*createmark components 1 "__edges"
		*deletemark components 1
	}
}

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


proc print_comp_elem_ids {comp_id temp_path} {
	*createmark elems 1 "by comp id" $comp_id
	set elem_ids [hm_getmark elems 1]
	# puts $elem_ids
	set f_obj [open $temp_path w]
	puts $f_obj $elem_ids
	close $f_obj
}

proc ::TiePointCreate::circle_node_search {} {
	# 根据comp找edge
	# *createmarkpanel components 1
	set comp_id_point $::TiePointCreate::comp_id_point
	set comp_id_surf $::TiePointCreate::comp_id_surf
	if {[llength $comp_id_point]==1} {
		puts "run"
	} else {
		return 0
	}
	print_comp_edges_fem $::TiePointCreate::comp_id_point $::TiePointCreate::temp_path 
	print_comp_elem_ids $::TiePointCreate::comp_id_surf $::TiePointCreate::csv_path
	set result_py [exec python $::TiePointCreate::py_path $::TiePointCreate::c_limit $::TiePointCreate::tolerance]
	return $result_py
}

if {[grab current] != ""} { return; }

proc ::TiePointCreate::GUI { args } {
    variable recess;

    set minx [winfo pixel . 225p];
    set miny [winfo pixel . 190p]; 
    if {![OnPc]} {set miny [winfo pixel . 240p];}
    set graphArea [hm_getgraphicsarea];
    set x [lindex $graphArea 0];
    set y [lindex $graphArea 1];
    
    # 主窗口
    ::hwt::CreateWindow tiePointCreateWin \
        -windowtitle "TiePointCreate" \
        -cancelButton "Cancel" \
        -cancelFunc ::TiePointCreate::Quit \
        -addButton OK ::TiePointCreate::OkExit no_icon \
        -resizeable 1 1 \
        -propagate 1 \
        -minsize $minx $miny \
        -geometry ${minx}x${miny}+${x}+${y} \
         noGeometrySaving;
    ::hwt::KeepOnTop .tiePointCreateWin;

    set recess [::hwt::WindowRecess tiePointCreateWin];

    grid columnconfigure $recess 1 -weight 1;
    grid rowconfigure    $recess 9 -weight 1;

    # ===================
    label $recess.addLabel -text "Components \n（计算前隐藏不必要单元）";
    grid $recess.addLabel -row 0 -column 0 -padx 2 -pady 2 -sticky nw;

    button $recess.compsButton \
        -text "Point Comp" \
        -command ::TiePointCreate::fun_compsButton \
        -width 16;
    grid $recess.compsButton -row 1 -column 0 -padx 5 -pady 2 -sticky nw;

    button $recess.compsButton2 \
        -text "Surf Comp" \
        -command ::TiePointCreate::fun_compsButton_2 \
        -width 16;
    grid $recess.compsButton2 -row 1 -column 1 -padx 5 -pady 2 -sticky nw;

    # ===================
    # ::hwt::LabeledLine $recess.end_line1 "";
    # grid $recess.end_line1 -row 2 -column 0 -pady 6 -sticky ew -columnspan 2;
    
    label $recess.nEntry_label -text "名称";
    grid $recess.nEntry_label -row 2 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.nEntry -width 16 -textvariable ::TiePointCreate::name
    grid $recess.nEntry -row 2 -column 1 -padx 2 -pady 2 -sticky nw;

    # =======
    label $recess.toleranceEntry_label -text "连接容差:";
    grid $recess.toleranceEntry_label -row 3 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.toleranceEntry -width 16 -textvariable ::TiePointCreate::tolerance
    grid $recess.toleranceEntry -row 3 -column 1 -padx 2 -pady 2 -sticky nw;

    label $recess.cLimitEntry_label -text "圆周长上限:";
    grid $recess.cLimitEntry_label -row 4 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.cLimitEntry -width 16 -textvariable ::TiePointCreate::c_limit
    grid $recess.cLimitEntry -row 4 -column 1 -padx 2 -pady 2 -sticky nw;

    label $recess.aLimitEntry_label -text "deg_limit:";
    grid $recess.aLimitEntry_label -row 5 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.aLimitEntry -width 16 -textvariable ::TiePointCreate::deg_limit
    grid $recess.aLimitEntry -row 5 -column 1 -padx 2 -pady 2 -sticky nw;

    button $recess.calcButton \
        -text "计算" \
        -command ::TiePointCreate::fun_calcButton \
        -width 16;
    grid $recess.calcButton -row 6 -column 0 -padx 2 -pady 2 -sticky nw;

    button $recess.delButton \
        -text "删除对应名称" \
        -command ::TiePointCreate::fun_delButton \
        -width 16;
    grid $recess.delButton -row 7 -column 1 -padx 2 -pady 2 -sticky nw;


    ::hwt::RemoveDefaultButtonBinding $recess;
    ::hwt::PostWindow tiePointCreateWin -onDeleteWindow ::TiePointCreate::Quit;
    hm_highlightmark surfs 1 norm

    set ::TiePointCreate::tolerance 20
    set ::TiePointCreate::c_limit 30
	set ::TiePointCreate::deg_limit 70

}

proc ::TiePointCreate::OkExit { args } {
	*clearmarkall 1
	*clearmarkall 2
	::hwt::UnpostWindow tiePointCreateWin;
}

proc ::TiePointCreate::Quit { args } {
	*clearmarkall 1
	*clearmarkall 2
	::hwt::UnpostWindow tiePointCreateWin;
}

proc ::TiePointCreate::fun_compsButton { args } {
	*createmarkpanel comps 1 "select the comps"
	set ::TiePointCreate::comp_id_point [hm_getmark comps 1]
	if {[llength $::TiePointCreate::comp_id_point]>2} {
		tk_messageBox -message "警告comp超过2个，请重选!!!" -icon warning
	}
}

proc ::TiePointCreate::fun_compsButton_2 { args } {
	*createmarkpanel comps 1 "select the comps"
	set ::TiePointCreate::comp_id_surf [hm_getmark comps 1]
}

proc ::TiePointCreate::fun_calcButton { args } {

    set choice [tk_messageBox -type yesnocancel -default yes -message "是否计算" -icon question ]
    if {$choice == "yes"} {} else {return;}


	set t_start [clock seconds]
	set comp_id_point $::TiePointCreate::comp_id_point
	set comp_id_surf $::TiePointCreate::comp_id_surf
	if {[llength $comp_id_point]==1} {puts "run" } else { return }

	print_fem $::TiePointCreate::temp_path 
	print_comp_elem_ids $::TiePointCreate::comp_id_surf $::TiePointCreate::csv_path
	set result_py [exec python $::TiePointCreate::py_path $::TiePointCreate::c_limit $::TiePointCreate::tolerance $::TiePointCreate::deg_limit]
	if {$result_py} { } else {continue}
	
	set tcl_path  [format "%s/__temp.tcl" $::TiePointCreate::filepath]
	set tcl_path2  [format "%s/__temp2.tcl" $::TiePointCreate::filepath]
	set tcl_path3  [format "%s/__temp3.tcl" $::TiePointCreate::filepath]

	set name_point "$::TiePointCreate::name\_point"
	set name_surf  "$::TiePointCreate::name\_elem"
	source $tcl_path
	set node_ids [hm_getmark nodes 1]
	*createentity sets cardimage=SET_GRID name=$name_point
	*createmark sets 1 $name_point
	*setvalue sets id=[hm_getmark sets 1] ids={nodes [hm_getmark nodes 1]}

	source $tcl_path2
	set elem_ids [hm_getmark elems 1]
	*createentity sets cardimage=SET_ELEM name=$name_surf
	*createmark sets 1 $name_surf
	*setvalue sets id=[hm_getmark sets 1] ids={elems [hm_getmark elems 1]}

	*startnotehistorystate {Interface "$::TiePointCreate::name" created}
	*interfacecreate "$::TiePointCreate::name" 2 3 11
	*createmark groups 2 "$::TiePointCreate::name"
	set group_id [hm_getmark groups 2]
	*dictionaryload groups 2 [get_optistruct_path] "TIE"
	*endnotehistorystate {Attached attributes to group "$::TiePointCreate::name"}

	*setvalue groups id=$group_id STATUS=2 1997="N2S"
	*setvalue groups id=$group_id STATUS=1 3915=$::TiePointCreate::tolerance
	
	*createmark sets 1 "$name_surf"
	*startnotehistorystate {Modified MSID of group}
	*setvalue groups id=$group_id masterentityids={sets [hm_getmark sets 1]}
	*endnotehistorystate {Modified MSID of group}

	*createmark sets 1 "$name_point"
	*startnotehistorystate {Modified SSID of group}
	*setvalue groups id=$group_id slaveentityids={sets [hm_getmark sets 1]}
	*endnotehistorystate {Modified SSID of group}


	file delete $::TiePointCreate::temp_path
	file delete $::TiePointCreate::csv_path
	file delete $tcl_path
	file delete $tcl_path2
	file delete $tcl_path3
	
	set t_end [clock seconds]
	puts "time: [expr $t_end-$t_start] s"
	*clearmarkall 1
	*clearmarkall 2
	tk_messageBox -message "Run End!!!"	

	eval "*createmark nodes 1 $node_ids"
	hm_highlightmark nodes 1 "highlight"

	eval "*createmark elems 1 $elem_ids"
	hm_highlightmark elems 1 "highlight"

}

proc ::TiePointCreate::fun_delButton {args} {
	set choice [tk_messageBox -type yesnocancel -default yes -message "是否删除" -icon question ]
	if {$choice == "yes"} {} else {return;}
	
    *clearmarkall 1
    *clearmarkall 2
    catch {
        set name_point "$::TiePointCreate::name\_point"
        *createmark sets 1 $name_point
        *deletemark sets 1
    }
    catch {
        set name_surf  "$::TiePointCreate::name\_elem"
        *createmark sets 2 $name_surf
        *deletemark sets 2
    }
    catch {
        *createmark groups 2 "$::TiePointCreate::name"
        *deletemark groups 2
    }
}

*clearmarkall 1
*clearmarkall 2
::TiePointCreate::GUI;



