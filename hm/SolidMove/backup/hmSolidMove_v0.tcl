
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

# 点到点距离及矢量 - 坐标输入
proc point_to_point_loc {point_a_loc point_b_loc} {

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
proc point_to_point_id {point_a_id point_b_id} {
	set point_a_loc [hm_getcoordinates point $point_a_id]
	set point_b_loc [hm_getcoordinates point $point_b_id]
	# set result [point_to_point_loc $point_a_loc $point_b_loc]
	# return $result
	return [point_to_point_loc $point_a_loc $point_b_loc]
}

# solid 点到点复制
proc solid_point_to_point_move {solid_ids point_a_id point_b_id} {
	foreach solid_id $solid_ids {
		set result [point_to_point_id $point_a_id $point_b_id]
		set point_dis [lindex $result 0]
		set x [lindex $result 1]
		set y [lindex $result 2]
		set z [lindex $result 3]
		*createvector 1 $x $y $z
		*createmark solids 1 $solid_id
		*translatemark solids 1 1 $point_dis
	}

}

# solid 点到点移动 - 根据坐标
proc solid_point_to_point_move_loc {solid_ids point_a_loc point_b_loc} {
	foreach solid_id $solid_ids {
		set result [point_to_point_loc $point_a_loc $point_b_loc]
		set point_dis [lindex $result 0]
		set x [lindex $result 1]
		set y [lindex $result 2]
		set z [lindex $result 3]
		*createvector 1 $x $y $z
		*createmark solids 1 $solid_id
		*translatemark solids 1 1 $point_dis
	}
}

# solid间的体积差值百分比
proc solid_volume_delta_percent {solid_id_base solid_id_target} {
	set data_base [get_solid_geometry_data $solid_id_base]
	set data_target [get_solid_geometry_data $solid_id_target]
	set volume_base [lindex $data_base 2]
	set volume_target [lindex $data_target 2]
	set vol_del [expr ($volume_base-$volume_target)/$volume_base]
	return $vol_del
}


# 主函数
# solid 点到点移动
proc main_solid_point_to_point_move {} {
	# solid 点到点复制
	*createmarkpanel solids 1 "select the solids"
	set solid_ids [hm_getmark solids 1]
	*createmarkpanel point 1 "select the point-A"
	set point_a_id [hm_getmark point 1]
	*createmarkpanel point 1 "select the point-B"
	set point_b_id [hm_getmark point 1]
	# set result [point_to_point_id $point_a_id $point_b_id]
	# puts $result
	solid_point_to_point_move $solid_ids $point_a_id $point_b_id
}

# 主函数
# solid 中心到中心复制移动
proc main_solid_center_to_center_copy {} {
	*createmarkpanel solids 1 "select the base-solid"
	set solid_id_base [hm_getmark solids 1]

	*createmarkpanel solids 1 "select the target-solid"
	set solid_id_target [hm_getmark solids 1]	

	set vol_del [solid_volume_delta_percent $solid_id_base $solid_id_target]
	if {$vol_del > 0.00001} {
		continue
		puts $vol_del
	}

	set data_base [get_solid_geometry_data $solid_id_base]
	set data_target [get_solid_geometry_data $solid_id_target]
	set center_base [lindex $data_base 1]
	set center_target [lindex $data_target 1]

	# set result [point_to_point_loc $center_base $center_target]
	# set point_dis [lindex $result 0]
	# set x [lindex $result 1]
	# set y [lindex $result 2]
	# set z [lindex $result 3]
	# *createvector 1 $x $y $z
	*createmark solids 1 $solid_id_base
	*duplicatemark solids 1 1
	set new_solid_id [hm_getmark solids 1]
	solid_point_to_point_move_loc $new_solid_id $center_base $center_target
	# *translatemark solids 1 1 $point_dis
}


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

# 坐标相加
proc loc_add {loc_1 loc_2} {
	list loc_3
	foreach n "0 1 2" {
		set value_1 [lindex $loc_1 $n]
		set value_2 [lindex $loc_2 $n]
		lappend loc_3 [expr $value_1 + $value_2]
	}
	return $loc_3
}

# 两个矢量的法向量
proc two_point_surf_v {v_1_loc v_2_loc} {
	set x1 [lindex $v_1_loc 0]
	set y1 [lindex $v_1_loc 1]
	set z1 [lindex $v_1_loc 2]

	set x2 [lindex $v_2_loc 0]
	set y2 [lindex $v_2_loc 1]
	set z2 [lindex $v_2_loc 2]

	set x3 [expr $y1*$z2-$y2*$z1]
	set y3 [expr $x1*$z2-$x2*$z1]
	set z3 [expr $x1*$y2-$x2*$y1]

	return "$x3 $y3 $z3"
}

# 矢量轴 - 单点&两矢量
proc v_surf_1p_2v {center_loc base_v_loc target_v_loc} {
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
proc v_surf_1p_1v {center_loc surf_v} {
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


# solid旋转 - 单点&矢量轴
proc solid_rotate_1point {solid_id angle center_loc surf_v} {
	v_surf_1p_1v $center_loc $surf_v
	*createmark solid 1 $solid_id
	*rotatemark solids 1 1 $angle
}

# solid旋转 - 
proc solid_rotate_3point {solid_id angle center_loc base_v_loc target_v_loc} {
	v_surf_1p_2v $center_loc $base_v_loc $target_v_loc
	*createmark solid 1 $solid_id
	*rotatemark solids 1 1 $angle
}

# 矢量 - abs
proc v_abs {loc} {
	set x [lindex $loc 0]
	set y [lindex $loc 1]
	set z [lindex $loc 2]
	set value [expr ($x**3+$y**2+$z**2)**0.5]
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

# 矢量 - 叉乘
proc v_multi_x {loc1 loc2} {
	set x1 [lindex $loc1 0]
	set y1 [lindex $loc1 1]
	set z1 [lindex $loc1 2]

	set x2 [lindex $loc2 0]
	set y2 [lindex $loc2 1]
	set z2 [lindex $loc2 2]

	set x3 [expr $y1*$z2-$y2*$z1]
	set x3 [expr $z1*$x2-$z2*$x1]
	set x3 [expr $x1*$y2-$x2*$y1]
	return "$x3 $y3 $z3"
}

# 矢量 - 转为单位矢量
proc v_one {loc1} {
	set x1 [lindex $loc1 0]
	set y1 [lindex $loc1 1]
	set z1 [lindex $loc1 2]
	set abs_len [v_abs $loc1]
	set x2 [expr $x1/$abs_len]
	set y2 [expr $y1/$abs_len]
	set z2 [expr $z1/$abs_len]
	return "$x2 $y2 $z2"
}

proc v_rotate_point {vector point_loc rad} {
	# A : vector
	# P : point_loc
	set vector_one [v_one $vector]
	set P_cos [v_multi_c $point_loc [expr cos($rad)]]
	set A_x_P []

}

# main_solid_center_to_center_copy


# *createmarkpanel solids 1 "select the base-solid"
*createmark solids 1 8
set solid_id_base [hm_getmark solids 1]

# *createmarkpanel solids 1 "select the target-solid"
*createmark solids 1 10
set solid_id_target [hm_getmark solids 1]	

set run_len 100

for {set run_n 0 } { $run_n < $run_len } { incr run_n 1 } {

	# 
	set data_base [get_solid_geometry_data $solid_id_base]
	set data_target [get_solid_geometry_data $solid_id_target]
	set locs [lindex $data_base 1] 
	set x [lindex $locs 0]
	set y [lindex $locs 1]
	set z [lindex $locs 2]

	*createmark solids 1 $solid_id_base
	set r_v 2

	if {$r_v == 0} {
		*createplane 1 1 0 0 $x $y $z	
	} elseif {$r_v == 1} {
		*createplane 1 0 1 0 $x $y $z
	} elseif {$r_v == 2} {
		*createplane 1 0 0 1 $x $y $z
	}

	
	if {$run_n == 0} { 
		set v 1
		set angle 1	
	}
	
	set v_angle [expr $v*$angle]
	*rotatemark solids 1 1 $v_angle
	
	# ========================
	set I_delta [I_delta_solid $solid_id_base $solid_id_target]
	# puts $I_delta
	set d_Ixx [expr abs([lindex $I_delta 0])]
	set d_Iyy [expr abs([lindex $I_delta 1])]
	set d_Izz [expr abs([lindex $I_delta 2])]

	set d_Ixy [expr abs([lindex $I_delta 3])]
	set d_Iyz [expr abs([lindex $I_delta 4])]
	set d_Izx [expr abs([lindex $I_delta 5])]
	set d_list_2 [lsort "$d_Ixy $d_Iyz $d_Izx"]
	set d_max [lindex [lsort -real $d_list_2] end]

	# ========================
	if {$d_Ixy == $d_max} {
		set d_type d_Ixy
	} elseif {$d_Iyz == $d_max} {
		set d_type d_Iyz
	} elseif {$d_Izx == $d_max} {
		set d_type d_Izx
	}

	if {$run_n > 0} {
		set d_last [expr $d_max-$last_d_max]	
		if {$d_last > 0} {
			if {$last_d_type == $d_type} {
				set v [expr -$v]
			}
		}
	}

	# if {$d_Ixy == $d_max} {
	# 	# 转动Z轴
	# 	puts "d_Ixy : $d_Ixy"
	# 	set r_v 2
	# 	set last_d_type d_Ixy
		
	# } elseif {$d_Iyz == $d_max} {
	# 	puts "d_Iyz : $d_Iyz"
	# 	set r_v 0
	# 	set last_d_type d_Iyz
		
	# } elseif {$d_Izx == $d_max} {
	# 	puts "d_Izx : $d_Izx"
	# 	set r_v 1
	# 	set last_d_type d_Izx
	# }

	set r_v 0
	set last_d_max $d_max
	set last_r_v $r_v


	if {$d_max < 100} {
		puts "break: $d_Ixx $d_Iyy $d_Izz $d_Ixy $d_Iyz $d_Izx"
		break
	}
	
	if {$d_Ixy < 100} {
		puts "$d_Ixx $d_Iyy $d_Izz $d_Ixy $d_Iyz $d_Izx"
		set r_v 2
	}
	if {$d_Iyz < 100} {
		puts "$d_Ixx $d_Iyy $d_Izz $d_Ixy $d_Iyz $d_Izx"
		set r_v 0
	}

	if {$d_Izx < 100} {
		puts "$d_Ixx $d_Iyy $d_Izz $d_Ixy $d_Iyz $d_Izx"
		set r_v 1
	}

}


# *createmarkpanel solids 1 "select the solids"
# set solid_ids [hm_getmark solids 1]
# foreach solid_id $solid_ids {
# 	set data [get_solid_geometry_data $solid_id]
# 	set I [lindex $data 0]
# 	set loc_center [lindex $data 1]
# 	set volume [lindex $data 2]
# 	puts "I: $I_n"
# 	puts "loc_center: $loc_center"
# 	puts "volume: $volume"

# }


# *createmarkpanel solids 1 "select the solids"
# set solid_ids [hm_getmark solids 1]
# foreach solid_id $solid_ids {
# 	set data [get_solid_geometry_data $solid_id]
# 	set I [lindex $data 0]
# 	set loc_center [lindex $data 1]
# 	set volume [lindex $data 2]
# 	puts "I: $I_n"
# 	puts "loc_center: $loc_center"
# 	puts "volume: $volume"

# }
