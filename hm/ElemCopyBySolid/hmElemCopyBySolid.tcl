# 参考 D:\software\Altair\2021.1\hwdesktop\hm\scripts\preserve_lines.tcl


namespace eval ::ElemCopyBySolid {
	variable temp_path_base
	variable temp_path_target
	variable py_path

	# 监控参数
	variable volume_delta_percent
	variable area_delta_value
	variable I_delta_value
}

# 路径定义
set filepath [file dirname [info script]]
set ::ElemCopyBySolid::temp_path_base [format "%s/__temp_base.csv" $filepath]
set ::ElemCopyBySolid::temp_path_target [format "%s/__temp_target.csv" $filepath]
set ::ElemCopyBySolid::py_path [format "%s/hmElemCopyBySolid.py" $filepath]


# ==================================
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


# 点到点距离及矢量 - 坐标输入
proc get_point_to_point_loc {point_a_loc point_b_loc} {

	set x1 [lindex $point_a_loc 0]
	set y1 [lindex $point_a_loc 1]
	set z1 [lindex $point_a_loc 2]

	set x2 [lindex $point_b_loc 0]
	set y2 [lindex $point_b_loc 1]
	set z2 [lindex $point_b_loc 2]

	set x3 [expr $x2-$x1]
	set y3 [expr $y2-$y1]
	set z3 [expr $z2-$z1]

	set dis [expr ($x3**2 + $y3**2 + $z3**2)**0.5]
	return "$dis $x3 $y3 $z3"
}

# 点到点距离及矢量 - id输入
proc get_point_to_point_id {point_a_id point_b_id} {
	set point_a_loc [hm_getcoordinates point $point_a_id]
	set point_b_loc [hm_getcoordinates point $point_b_id]
	# set result [get_point_to_point_loc $point_a_loc $point_b_loc]
	# return $result
	return [get_point_to_point_loc $point_a_loc $point_b_loc]
}

# solid间的体积差值百分比
proc get_solid_volume_delta_percent {solid_id_base solid_id_target} {
	set data_base [get_solid_geometry_data $solid_id_base]
	set data_target [get_solid_geometry_data $solid_id_target]
	set volume_base [lindex $data_base 2]
	set volume_target [lindex $data_target 2]
	set vol_del [expr double($volume_base-$volume_target) / double($volume_base)]
	return $vol_del
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

proc get_solid_area {solid_id} {
	*createmark surfs 1 "by solids" $solid_id
	set surf_ids [hm_getmark surfs 1]
	set area_sum 0
	foreach surf_id $surf_ids {
		set value [hm_getareaofsurface surfs $surf_id]
		set area_sum [expr $area_sum + $value]
	}
	return $area_sum
}

proc delta_solid_area {solid_id1 solid_id2} {
	set area1 [get_solid_area $solid_id1] 
	set area2 [get_solid_area $solid_id2]
	set delta [expr abs($area1-$area2)]
	return $delta
}


# solid 点到点复制 id
proc edit_solid_point_to_point_move {solid_ids point_a_id point_b_id} {
	foreach solid_id $solid_ids {
		set result [get_point_to_point_id $point_a_id $point_b_id]
		set point_dis [lindex $result 0]
		set x [lindex $result 1]
		set y [lindex $result 2]
		set z [lindex $result 3]
		*createvector 1 $x $y $z
		*createmark solids 1 $solid_id
		*translatemark solids 1 1 $point_dis
		catch { *translatemark elems 1 1 $point_dis }
	}
}

# solid 点到点移动 - 根据坐标
proc edit_solid_point_to_point_move_loc {solid_ids point_a_loc point_b_loc} {
	foreach solid_id $solid_ids {
		set result [get_point_to_point_loc $point_a_loc $point_b_loc]
		set point_dis [lindex $result 0]
		set x [lindex $result 1]
		set y [lindex $result 2]
		set z [lindex $result 3]
		*createvector 1 $x $y $z
		*createmark solids 1 $solid_id
		*translatemark solids 1 1 $point_dis
		catch { *translatemark elems 1 1 $point_dis }
	}
}

# solid旋转 - 单点&矢量轴
proc edit_solid_rotate_1p_1v {solid_id angle center_loc surf_v} {
	edit_v_surf_1p_1v $center_loc $surf_v
	*createmark solid 1 $solid_id
	if {$angle==0} {return "None"}
	*rotatemark solids 1 1 $angle
	catch { *rotatemark elems 1 1 $angle }
}

# solid旋转 - 
proc edit_solid_rotate_1p_2v {solid_id angle center_loc base_v_loc target_v_loc} {
	edit_v_surf_1p_2v $center_loc $base_v_loc $target_v_loc
	*createmark solid 1 $solid_id
	if {$angle==0} {return "None"}
	*rotatemark solids 1 1 $angle
	catch { *rotatemark elems 1 1 $angle }
}

# solid旋转 -3点
proc edit_solid_rotate_3point {solid_id center_loc point_1_loc point_2_loc} {
	set v_1 [v_sub $point_1_loc $center_loc]
	set v_2 [v_sub $point_2_loc $center_loc]

	set v_and_angle [angle_2vector $v_1 $v_2]
	set surf_v [lindex $v_and_angle 0]
	set angle [lindex $v_and_angle 1]
	if {$angle==0} {return "None"}
	edit_solid_rotate_1p_1v $solid_id $angle $center_loc $surf_v
}

# 获取solid的point数据及中心点
proc print_solid_points_and_center {solid_id file_path} {
	set f_obj [open $file_path w]
	*createmark points 1 "by solids" $solid_id

	set data [get_solid_geometry_data $solid_id]
	set center_loc [lindex $data 1]
	puts $f_obj "$center_loc"

	set point_ids [hm_getmark points 1]
	foreach point_id $point_ids {
		set point_loc [hm_getcoordinates point $point_id]
		puts $f_obj "$point_id $point_loc"
	}
	close $f_obj
}

# 转动惯量 -------------------------------------
# 转动惯量差值
proc I_delta {I_base I_target} {
	list list_I_delta
	foreach loc "0 1 2 3 4 5" {
		set base [lindex $I_base $loc]
		set target [lindex $I_target $loc]
		set delta [expr $target-$base]
		lappend list_I_delta $delta
	}
	return $list_I_delta
}

# 实体间的转动惯量差值
proc I_delta_solid {solid_id_base solid_id_target} {
	set data_base [get_solid_geometry_data $solid_id_base]
	set data_target [get_solid_geometry_data $solid_id_target]
	set I_base [lindex $data_base 0]
	set I_target [lindex $data_target 0]
	set I_delta [I_delta $I_base $I_target]
	# puts $I_delta
	return $I_delta
}


# hm旋转轴 ----------------------
# 矢量轴 - 单点&两矢量
proc edit_v_surf_1p_2v {center_loc base_v_loc target_v_loc} {
	# center_loc 旋转中心
	# base_v_loc 矢量1
	# target_v_loc 矢量2
	set surf_v [v_multi_x $base_v_loc $target_v_loc]
	set v_x [ lindex $surf_v 0]
	set v_y [ lindex $surf_v 1]
	set v_z [ lindex $surf_v 2]
	set x [lindex $center_loc 0]
	set y [lindex $center_loc 1]
	set z [lindex $center_loc 2]

	*createplane 1 $v_x $v_y $v_z $x $y $z
}

# 矢量轴 - 单点&旋转矢量
proc edit_v_surf_1p_1v {center_loc surf_v} {
	#
	#
	set v_x [ lindex $surf_v 0]
	set v_y [ lindex $surf_v 1]
	set v_z [ lindex $surf_v 2]
	set x [lindex $center_loc 0]
	set y [lindex $center_loc 1]
	set z [lindex $center_loc 2]

	*createplane 1 $v_x $v_y $v_z $x $y $z
}

# ==========
# solid 及 网格复制移动
proc solid_elems_copy_overlay {solid_id_base solid_id_target elem_ids} {

	catch { hm_createmark elems 1 $elem_ids }
	
	# 复制
	*createmark solids 1 $solid_id_base
	*duplicatemark solids 1 1
	catch { *duplicatemark elems 1 1}

	# id重赋值	
	set solid_id_base [hm_getmark solids 1]

	# =========================
	# 移动
	set center_base [lindex [get_solid_geometry_data $solid_id_base] 1]
	set center_target [lindex [get_solid_geometry_data $solid_id_target] 1]
	catch {edit_solid_point_to_point_move_loc $solid_id_base $center_base $center_target}

	# =========================
	# 旋转
	*createmark points 1 "by solids" $solid_id_target
	set max_n [llength [hm_getmark points 1]]
	# set max_n 4
	for {set one_loc 0} {$one_loc < $max_n} {incr one_loc 1} {
		if {$one_loc > 10} {break}
		# 第一次旋转
		if {$one_loc == 0} {
			# 数据导出
			print_solid_points_and_center $solid_id_base $::ElemCopyBySolid::temp_path_base
			print_solid_points_and_center $solid_id_target $::ElemCopyBySolid::temp_path_target
		}
		# 数据读取
		set result_py [exec python $::ElemCopyBySolid::py_path $one_loc 0]
		set center_base [lindex [get_solid_geometry_data $solid_id_base] 1]
		if {$one_loc == 0 } { set point_1_one_id [lindex $result_py 0] }
		
		set point_2_one_id [lindex $result_py 1]
		set point_1_one_loc [hm_getcoordinates point $point_1_one_id]
		set point_2_one_loc [hm_getcoordinates point $point_2_one_id]
		# 旋转
		edit_solid_rotate_3point $solid_id_base $center_base $point_1_one_loc $point_2_one_loc

		# 第二次旋转
		set point_1_one_loc [hm_getcoordinates point $point_1_one_id]
		set surf_v_second [v_sub $point_1_one_loc $center_base]

		for {set third_loc 0} {$third_loc < $max_n} {incr third_loc 1} {
			if {$third_loc > 10} {break}

			set result_py [exec python $::ElemCopyBySolid::py_path $one_loc $third_loc]
			
			if {[expr $third_loc+$one_loc]==0 } { 
				# 防止坐标变化引起的 id排序变更
				set point_1_third_id [lindex $result_py 2] 
			}
			set point_2_third_id [lindex $result_py 3]
			set point_1_loc [hm_getcoordinates point $point_1_third_id]
			set point_2_loc [hm_getcoordinates point $point_2_third_id]
	
			set point_1_center_loc_base [vertical_point $center_base [v_add $center_base $surf_v_second] $point_1_loc]
			set point_2_center_loc_base [vertical_point $center_base [v_add $center_base $surf_v_second] $point_2_loc]

			set v_1 [v_sub $point_1_loc $point_1_center_loc_base]
			set v_2 [v_sub $point_2_loc $point_2_center_loc_base]
			if {[v_abs $v_1]==0} {continue}
			if {[v_abs $v_2]==0} {continue}
			set angle [lindex [angle_2vector $v_1 $v_2] 1]

			set cur_surf_v [v_multi_x $v_1 $v_2]
			if {[v_multi_dot $cur_surf_v $surf_v_second] < 0} {
				set angle [expr -$angle]
			}
			if { [expr abs([v_abs $v_1] - [v_abs $v_2])] > 1} { continue }
			edit_solid_rotate_1p_1v $solid_id_base $angle $center_base $surf_v_second

			# edit_solid_rotate_3point $solid_id_base $point_center_loc_base $point_1_loc $point_2_loc
			# puts "second-point-1-run$i: $point_1_loc"
			# puts "second-point-2-run$i: $point_2_loc"
			# *nodecleartempmark 
			# eval "*createnode $center_base 0 0 0"
			# eval "*createnode $point_1_one_loc 0 0 0"
			# eval "*createnode $point_1_loc 0 0 0"
			# eval "*createnode $point_2_loc 0 0 0"
			# eval "*createnode $point_1_center_loc_base 0 0 0"

			set delta [abs_sum_list [I_delta_solid $solid_id_base $solid_id_target]]
			if {$delta < $::ElemCopyBySolid::I_delta_value} {
				puts "True: I-delta-run $one_loc - $third_loc : $delta ; Id : $point_1_one_id ,$point_2_one_id ,$point_1_third_id ,$point_2_third_id"
				*createmark solids 1 $solid_id_base
				*deletesolidswithelems 1 0 0
				return 1
			}
		}
	}
	*createmark solids 1 $solid_id_base
	*deletesolidswithelems 1 0 0
	catch { *deletemark elements 1 }
	
	puts "False: del-solid ; I-delta-run-$one_loc - $third_loc : $delta"
	# puts "\n-----End-----\n\n"
	return 0
}

# ==================================
# ==================================
# GUI

if {[grab current] != ""} { return; }
namespace eval ::SolidElemsCopyMove {
    variable recess;
    variable elem_ids;
    variable solid_id_base;
    variable solid_id_targets;
}

proc ::SolidElemsCopyMove::GUI { args } {
    variable recess;

    set minx [winfo pixel . 225p];
    set miny [winfo pixel . 225p];
    if {![OnPc]} {set miny [winfo pixel . 240p];}
    set graphArea [hm_getgraphicsarea];
    set x [lindex $graphArea 0];
    set y [lindex $graphArea 1];
    
    # 主窗口
    ::hwt::CreateWindow solidElemsCopyMoveWin \
        -windowtitle "SolidElemsCopyMove" \
        -cancelButton "Cancel" \
        -cancelFunc ::SolidElemsCopyMove::Quit \
        -addButton OK ::SolidElemsCopyMove::OkExit no_icon \
        -resizeable 1 1 \
        -propagate 1 \
        -minsize $minx $miny \
        -geometry ${minx}x${miny}+${x}+${y} \
         noGeometrySaving;
    ::hwt::KeepOnTop .solidElemsCopyMoveWin;

    set recess [::hwt::WindowRecess solidElemsCopyMoveWin];

    grid columnconfigure $recess 1 -weight 1;
    grid rowconfigure    $recess 9 -weight 1;

    # ===================
    label $recess.addLabel -text "Elements";
    grid $recess.addLabel -row 0 -column 0 -padx 2 -pady 2 -sticky nw;

    button $recess.elemsButton \
        -text "Select Elements" \
        -command ::SolidElemsCopyMove::fun_elemsButton \
        -width 16;
    grid $recess.elemsButton -row 1 -column 0 -padx 5 -pady 2 -sticky nw;

    # ===================
    ::hwt::LabeledLine $recess.end_line1 "";
    grid $recess.end_line1 -row 2 -column 0 -pady 6 -sticky ew -columnspan 2;

    # ===================
    label $recess.baseLabel -text "Base Solid";
    grid $recess.baseLabel -row 3 -column 0 -padx 2 -pady 2 -sticky nw;

    button $recess.baseButton \
        -text "Select Base Solid" \
        -command ::SolidElemsCopyMove::fun_baseButton \
        -width 16;
    grid $recess.baseButton -row 4 -column 0 -padx 2 -pady 2 -sticky nw;

    # ===================
    label $recess.targetLabel -text "Target Solids";
    grid $recess.targetLabel -row 3 -column 1 -padx 2 -pady 2 -sticky nw;

    button $recess.targetButton \
        -text "Select Target Solid" \
        -command ::SolidElemsCopyMove::fun_targetButton \
        -width 16;
    grid $recess.targetButton -row 4 -column 1 -padx 2 -pady 2 -sticky nw;

    # ===================
    ::hwt::LabeledLine $recess.end_line "";
    grid $recess.end_line -row 5 -column 0 -pady 6 -sticky ew -columnspan 2;

    label $recess.vDelEntry_label -text "VolumeDeltaPercent";
    grid $recess.vDelEntry_label -row 6 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.vDelEntry -width 16 -textvariable ::ElemCopyBySolid::volume_delta_percent
    grid $recess.vDelEntry -row 6 -column 1 -padx 2 -pady 2 -sticky nw;

    label $recess.aDelEntry_label -text "AreaDelta";
    grid $recess.aDelEntry_label -row 7 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.aDelEntry -width 16 -textvariable ::ElemCopyBySolid::area_delta_value
    grid $recess.aDelEntry -row 7 -column 1 -padx 2 -pady 2 -sticky nw;

    label $recess.iDelEntry_label -text "I delta";
    grid $recess.iDelEntry_label -row 8 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.iDelEntry -width 16 -textvariable ::ElemCopyBySolid::I_delta_value
    grid $recess.iDelEntry -row 8 -column 1 -padx 2 -pady 2 -sticky nw;


    ::hwt::RemoveDefaultButtonBinding $recess;
    ::hwt::PostWindow solidElemsCopyMoveWin -onDeleteWindow ::SolidElemsCopyMove::Quit;
    hm_highlightmark surfs 1 norm

    # 默认值
    set ::ElemCopyBySolid::volume_delta_percent 0.01
    set ::ElemCopyBySolid::area_delta_value 10
    set ::ElemCopyBySolid::I_delta_value 10
}

proc ::SolidElemsCopyMove::OkExit { args } {

	set choice [tk_messageBox -type yesnocancel -default yes -message "是否计算" -icon question ]
	if {$choice != yes} {return;}

	# puts $::SolidElemsCopyMove::elem_ids
	# puts $::SolidElemsCopyMove::solid_id_base
	# puts $::SolidElemsCopyMove::solid_id_targets
	set elem_ids $::SolidElemsCopyMove::elem_ids
	set solid_id_base $::SolidElemsCopyMove::solid_id_base
	set solid_id_targets $::SolidElemsCopyMove::solid_id_targets

	puts "\n-----Start-----"
	set false_targets []
	foreach solid_id_target $solid_id_targets {
		if {$solid_id_target == $solid_id_base} {continue}
		# 体积判断
		set vol_del [get_solid_volume_delta_percent $solid_id_base $solid_id_target]
		if {$vol_del > $::ElemCopyBySolid::volume_delta_percent} {
			puts "No-Target, volume delta percent: $vol_del"
			lappend false_targets $solid_id_target
			continue
		}
		
		# 面积判断
		set area_del [delta_solid_area $solid_id_base $solid_id_target]
		if {$area_del > $::ElemCopyBySolid::area_delta_value} {
			puts "No-Target, area delta : $area_del"
			lappend false_targets $solid_id_target
			continue
		}
		puts "Is-Target, volume delta percent: $vol_del ; area_del: $area_del"
		set result [solid_elems_copy_overlay $solid_id_base $solid_id_target $elem_ids]
		if {$result == 0} {
			lappend false_targets $solid_id_target
		}
	}
	puts "-----End-----"
	*clearmarkall 1
	*clearmarkall 2
	if { [llength $solid_id_targets] < 1} {
		tk_messageBox -message "Not Calc!!!"	
	} else {
		tk_messageBox -message "Run End!!!"	
	}

	# 将计算失败的solid重新赋予
	set ::SolidElemsCopyMove::solid_id_targets $false_targets

	file delete $::ElemCopyBySolid::temp_path_base
	file delete $::ElemCopyBySolid::temp_path_target

    # ::hwt::UnpostWindow solidElemsCopyMoveWin;
}

proc ::SolidElemsCopyMove::Quit { args } {
	*clearmarkall 1
	*clearmarkall 2
	::hwt::UnpostWindow solidElemsCopyMoveWin;
   # ::SolidElemsCopyMove::OkExit;
}

proc ::SolidElemsCopyMove::fun_elemsButton { args } {
	*createmarkpanel elems 1 "select the elemnets"
	set ::SolidElemsCopyMove::elem_ids [hm_getmark elems 1]
}

proc ::SolidElemsCopyMove::fun_baseButton { args } {
	*createmarkpanel solids 1 "select the base-solid"
	set solid_id_base [hm_getmark solids 1]
	if {[llength $solid_id_base]>1} {
		tk_messageBox -message "solid base should only choose one!!!"
		hm_markclear solids 1
		return "None"
	}
	set ::SolidElemsCopyMove::solid_id_base $solid_id_base
}

proc ::SolidElemsCopyMove::fun_targetButton { args } {
	*createmarkpanel solids 1 "select the target-solid"
	set ::SolidElemsCopyMove::solid_id_targets [hm_getmark solids 1]	
}

*clearmarkall 1
*clearmarkall 2
::SolidElemsCopyMove::GUI;
