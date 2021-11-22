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

# 路径定义
set filepath [file dirname [info script]]
set temp_path [format "%s/__temp.csv" $filepath]
set py_path [format "%s/hole_mesh.py" $filepath]
# set tcl_path [format "%s/__temp_cmd_mat_edit.tcl" $filepath]


proc get_point_circle_ids {line_id} {

	*createmark points 1 "by lines" $line_id
	set point_id_1 [lindex [hm_getmark points 1] 0]
	# puts "point_id_1: $point_id_1"

	*createmark surfs 1 "by lines" $line_id
	set surf_id [hm_getmark surfs 1]
	# puts "surf_id : $surf_id"

	if {[llength surf_ids]>1} {
		tk_messageBox -message "警告!!line非自由边"
	}

	*edgesmarkaddpoints 1 2

	*createmark points 1 "by surface" $surf_id
	set point_ids [hm_getmark points 1]
	# puts "point_ids: $point_ids"

	*createmark lines 1 "by points" $point_id_1
	set line_ids [hm_getmark lines 1]
	set line_id_1 [lindex $line_ids 0]
	set line_id_2 [lindex $line_ids 1]

	*createmark points 1 "by lines" $line_id_1
	set point_ids [hm_getmark points 1]
	if {[lindex $point_ids 0] == $point_id_1} {
		set point_id_2 [lindex $point_ids 1]
	} else {
		set point_id_2 [lindex $point_ids 0]
	}

	*createmark points 1 "by lines" $line_id_2
	set point_ids [hm_getmark points 1]
	if {[lindex $point_ids 0]==$point_id_1} {
		set point_id_3 [lindex $point_ids 1]
	} else {
		set point_id_3 [lindex $point_ids 0]
	}

	set point_circles "$point_id_1 $point_id_2 $point_id_3"
	return $point_circles
}

proc create_circle_center_node {point_circle_ids} {
	
	# 中心点创建
	*clearmark nodes 1

	eval "*createmark points 1 $point_circle_ids"
	*createbestcirclecenternode points 1 0 1 0

	*createmarklast nodes 1
	set node_circle_center_id [hm_getmark nodes 1]
	# puts "node_circle_center_id: $node_circle_center_id"
	return $node_circle_center_id
}

# 点到点距离及矢量 - 坐标输入
proc dis_point_to_point_loc {point_a_loc point_b_loc} {

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
	return $dis
}

# 根据线id获取圆心数据
proc line_to_circle_center {line_id} {

	set point_circle_ids [get_point_circle_ids $line_id]
	# puts "point_circle_ids: $point_circle_ids"
	set node_circle_center_id [create_circle_center_node $point_circle_ids]
	# puts "node_circle_center_id: $node_circle_center_id"
	set loc1 [hm_getcoordinates point [lindex $point_circle_ids 0]]

	set x [hm_getvalue nodes id=$node_circle_center_id dataname=x]
	set y [hm_getvalue nodes id=$node_circle_center_id dataname=y]
	set z [hm_getvalue nodes id=$node_circle_center_id dataname=z]
	set circle_center_loc "$x $y $z"

	set r_circle [dis_point_to_point_loc $loc1 $circle_center_loc]
	# puts "r_circle: $r_circle"
	return "$node_circle_center_id {$circle_center_loc} $r_circle"
}


# =============================
set v_dot_limit 0.1

puts "---start---"
# 目标线 ID  - 必须为圆
*createmarkpanel lines 1
set line_id [hm_getmark lines 1]
puts "line_id : $line_id"
# 根据线获取面
*createmark surfs 1 "by lines" $line_id
set surf_id [hm_getmark surfs 1]

set circle_data [line_to_circle_center $line_id]
puts "$circle_data"
set R_circle [lindex $circle_data 2]
set circle_center_loc [lindex $circle_data 1]

*createmark points 1 "by surface" $surf_id
set point_ids [hm_getmark points 1]

*createmark lines 1 "by surface" $surf_id
set line_surf_ids [hm_getmark lines 1]

# set point_target_ids {}
set point_target_locs {}
set line_target_ids {}
foreach point_id $point_ids {
	set loc1 [hm_getcoordinates point $point_id]
	set dis1 [dis_point_to_point_loc $loc1 $circle_center_loc]
	if {[expr abs($dis1-$R_circle)] > 1} {
		# puts "dis1: $dis1"
		dict set point_target_dic $point_id "$loc1"
		# lappend point_target_ids $point_id
		# lappend point_target_locs "$loc1"
		*createmark lines 1 "by points" $point_id
		set line_ids [hm_getmark lines 1]
		foreach line_id $line_ids {
			if {$line_id in $line_target_ids} {continue}
			if {$line_id in $line_surf_ids} {
				lappend line_target_ids $line_id	
			}
		}
	}
}


# 只支持4点
if {[llength $line_target_ids]==4} {} else {return 0}
# puts "point_target_locs: $point_target_locs"

# 根据线获取 线的矢量
proc get_v_by_line {line_id point_target_dic} {
	*createmark points 1 "by lines" $line_id
	set point_ids [hm_getmark points 1]
	set v1 [v_sub [dict get $point_target_dic [lindex $point_ids 0]] [dict get $point_target_dic [lindex $point_ids 1]]]
	return $v1
}

# 各线的矢量判断
set v0 [get_v_by_line [lindex $line_target_ids 0] $point_target_dic]
set v1 [get_v_by_line [lindex $line_target_ids 1] $point_target_dic]
set v2 [get_v_by_line [lindex $line_target_ids 2] $point_target_dic]

if {[v_multi_dot $v0 $v1] < $v_dot_limit} {
	set v_u $v0
	set v_v $v1
} elseif {[v_multi_dot $v0 $v2] < $v_dot_limit} {
	set v_u $v0
	set v_v $v1
} 

# 垂直轴-坐标系基准
set new_v [v_multi_c [v_one $v_v] $R_circle]
set new_u [v_multi_c [v_one $v_u] $R_circle]

# 坐标相对远点的矢量
set v_1 [v_multi_c [v_one [v_add $new_v $new_u]] $R_circle]
set v_2 [v_multi_c $v_1 -1]
set v_3 [v_multi_c [v_one [v_sub $new_v $new_u]] $R_circle]
set v_4 [v_multi_c $v_3 -1]

# 各点坐标
# node_loc1 node_loc2 对角
# node_loc3 node_loc4 对角
set node_loc1 [v_add $v_1 $circle_center_loc]
eval "*createnode $node_loc1 0 0 0"
set node_loc2 [v_add $v_2 $circle_center_loc]
eval "*createnode $node_loc2 0 0 0"
set node_loc3 [v_add $v_3 $circle_center_loc]
eval "*createnode $node_loc3 0 0 0"
set node_loc4 [v_add $v_4 $circle_center_loc]
eval "*createnode $node_loc4 0 0 0"


# puts "point_target_ids: $point_target_ids"
# puts "point_target_locs: $point_target_locs"

puts "---end---"
