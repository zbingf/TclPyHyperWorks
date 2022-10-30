# source D:/github/TclPyHyperWorks/hm/RigidSolidPointLink/hmRigidSolidPointLink.tcl

# ==================================
# 
proc sum_list {list1} {
	set value_sum 0
	foreach value $list1 {
		set value_sum [expr $value_sum + $value]
	}
	return $value_sum
}

proc abs_sum_list {list1} {
	set value_sum 0
	foreach value $list1 {
		set value_sum [expr $value_sum + abs($value)]
	}
	return $value_sum
}

# 空间矢量计算 ----------------------
# 矢量 - abs
proc v_abs {loc} {
	set x [lindex $loc 0]
	set y [lindex $loc 1]
	set z [lindex $loc 2]
	set value [expr ($x**2+$y**2+$z**2)**0.5]
	return $value
}

# 矢量 - 点成乘
proc v_multi_dot {loc1 loc2} {
	set x1 [lindex $loc1 0]
	set y1 [lindex $loc1 1]
	set z1 [lindex $loc1 2]

	set x2 [lindex $loc2 0]
	set y2 [lindex $loc2 1]
	set z2 [lindex $loc2 2]

	set value [expr $x1*$x2 + $y1*$y2 + $z1*$z2]
	return $value
}

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

# 矢量 - 减
proc v_sub {loc1 loc2} {
	set x1 [lindex $loc1 0]
	set y1 [lindex $loc1 1]
	set z1 [lindex $loc1 2]

	set x2 [lindex $loc2 0]
	set y2 [lindex $loc2 1]
	set z2 [lindex $loc2 2]

	set x3 [expr $x1-$x2]
	set y3 [expr $y1-$y2]
	set z3 [expr $z1-$z2]
	return "$x3 $y3 $z3"
}

# 矢量 - 加
proc v_add {loc1 loc2} {
	set x1 [lindex $loc1 0]
	set y1 [lindex $loc1 1]
	set z1 [lindex $loc1 2]

	set x2 [lindex $loc2 0]
	set y2 [lindex $loc2 1]
	set z2 [lindex $loc2 2]

	set x3 [expr $x1+$x2]
	set y3 [expr $y1+$y2]
	set z3 [expr $z1+$z2]
	return "$x3 $y3 $z3"
}

# 矢量 - 叉乘
proc v_multi_x {loc1 loc2} {
	set x1 [lindex $loc1 0]
	set y1 [lindex $loc1 1]
	set z1 [lindex $loc1 2]

	set x2 [lindex $loc2 0]
	set y2 [lindex $loc2 1]
	set z2 [lindex $loc2 2]

	set x3 [expr $y1*$z2-$y2*$z1]
	set y3 [expr $z1*$x2-$z2*$x1]
	set z3 [expr $x1*$y2-$x2*$y1]
	return "$x3 $y3 $z3"
}

# 矢量 - 转为单位矢量
proc v_one {loc1} {
	set x1 [lindex $loc1 0]
	set y1 [lindex $loc1 1]
	set z1 [lindex $loc1 2]
	set abs_len [v_abs $loc1]
	set x2 [expr double($x1) / double($abs_len)]
	set y2 [expr double($y1) / double($abs_len)]
	set z2 [expr double($z1) / double($abs_len)]
	return "$x2 $y2 $z2"
}

# 点-绕轴旋转
proc v_rotate_point {vector point_loc rad} {
	# A : vector
	# P : point_loc
	set vector_one [v_one $vector]
	set P_cos [v_multi_c $point_loc [expr cos($rad)]]
	set A_x_P_sin [v_multi_c [v_multi_x $vector_one $point_loc] [expr sin($rad)]]
	set A_dot_P [v_multi_dot $vector_one $point_loc]
	set A_A_dot_P_theta [v_multi_c $vector_one [expr $A_dot_P*(1-cos($rad))]]

	set new_loc [v_add [v_add $P_cos $A_x_P_sin] $A_A_dot_P_theta]
	return $new_loc
}

# 垂点
proc vertical_point {line_p1_loc line_p2_loc p3_loc} {

	set x1 [lindex $line_p1_loc 0]
	set y1 [lindex $line_p1_loc 1]
	set z1 [lindex $line_p1_loc 2]

	set x2 [lindex $line_p2_loc 0]
	set y2 [lindex $line_p2_loc 1]
	set z2 [lindex $line_p2_loc 2]

	set x0 [lindex $p3_loc 0]
	set y0 [lindex $p3_loc 1]
	set z0 [lindex $p3_loc 2]

	set k [expr -(($x1-$x0)*($x2-$x1)+($y1-$y0)*($y2-$y1)+($z1-$z0)*($z2-$z1))/(($x2-$x1)**2+($y2-$y1)**2+($z2-$z1)**2)]

	set xn [expr $k*($x2-$x1) + $x1]
	set yn [expr $k*($y2-$y1) + $y1]
	set zn [expr $k*($z2-$z1) + $z1]
	return "$xn $yn $zn"
}

# 矢量夹角
proc angle_2vector {base_v_loc target_v_loc} {
	# base_v_loc 起始
	# target_v_loc 结束

	set base_abs [v_abs $base_v_loc]
	set target_abs [v_abs $target_v_loc]
	set a_dob_b [v_multi_dot $base_v_loc $target_v_loc]
	set value [expr $a_dob_b / ($base_abs*$target_abs)]
	if { $value > 1 } { 
		puts "warning: acos(value) , value: $value"
		set value 1 
	}
	if { $value < -1 } { 
		puts "warning: acos(value) , value: $value"
		set value -1 
	}
	set rad [expr acos($value)]
	set surf_v [v_multi_x $base_v_loc $target_v_loc]
	set angle [expr $rad*180/3.141592654]
	return "{$surf_v} $angle"
}

# =================================

# 获取node 对应坐标
proc get_node_locs {node_id} {
    set x [hm_getvalue nodes id=$node_id dataname=x]
    set y [hm_getvalue nodes id=$node_id dataname=y]
    set z [hm_getvalue nodes id=$node_id dataname=z]
    return "$x $y $z"
}


# 获取 solid 几何数据
proc get_solid_geometry_data {solid_id} {
	*createmark solids 1 $solid_id
	set I_n [hm_getmoiofsolid $solid_id]
	set loc_center [hm_getcentroid solid 1]
	set volume [hm_getvolumeofsolid solid $solid_id]
	# puts "I: $I_n"
	# puts "loc_center: $loc_center"
	# puts "volume: $volume"
	return "{$I_n} {$loc_center} $volume"
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

    # radiobutton $recess.radio_1_1 -text "1-单个复制"  -variable ::RigidSolidPointLink::copyType -value 1 -anchor w -font {MS 10} 
    # radiobutton $recess.radio_1_2 -text "2-两点矢量方向批量复制" -variable ::RigidSolidPointLink::copyType -value 2 -anchor w -font {MS 10} 
    # grid $recess.radio_1_1 -row 7 -column 0 -padx 2 -pady 2 -sticky nw;
    # grid $recess.radio_1_2 -row 7 -column 1 -padx 2 -pady 2 -sticky nw;

    # radiobutton $recess.radio_2_1 -text "0-放置原comp"  -variable ::RigidSolidPointLink::elemCompType -value 0 -anchor w -font {MS 10} 
    # radiobutton $recess.radio_2_2 -text "1-放置当前comp" -variable ::RigidSolidPointLink::elemCompType -value 1 -anchor w -font {MS 10} 
    # grid $recess.radio_2_1 -row 8 -column 0 -padx 2 -pady 2 -sticky nw;
    # grid $recess.radio_2_2 -row 8 -column 1 -padx 2 -pady 2 -sticky nw;


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

	puts "\n-----Start-----"

    # 写入文档数据
    set f_obj [open $temp_loc_path w]
	foreach solid_id $solid_ids {
		*createmark solids 1 $solid_id
		set loc_center [hm_getcentroid solid 1]
		# eval "*createnode $loc_center 0 0 0"
	    puts $f_obj "$loc_center"
	}
	close $f_obj

	# 
	print_elem_node_to_fem $temp_base_path $elem_ids_base
	print_elem_node_to_fem $temp_target_path $elem_ids_target
	

	*clearmarkall 1
	*clearmarkall 2
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
