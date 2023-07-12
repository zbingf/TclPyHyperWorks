# ===================================================================
# ===================================================================
# ===================================================================
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


# 对坐标四舍五入
proc v_loc_round_num {loc1 num} {
    set x [lindex $loc1 0]
    set y [lindex $loc1 1]
    set z [lindex $loc1 2]
    set new_x [expr double(round($x*(10**$num))) / (10**$num)]
    set new_y [expr double(round($y*(10**$num))) / (10**$num)]
    set new_z [expr double(round($z*(10**$num))) / (10**$num)]
    return "$new_x $new_y $new_z"
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

    set k [expr double(-(($x1-$x0)*($x2-$x1)+($y1-$y0)*($y2-$y1)+($z1-$z0)*($z2-$z1))) / double(($x2-$x1)**2+($y2-$y1)**2+($z2-$z1)**2)]

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
    set value [expr double($a_dob_b) / ($base_abs*$target_abs)]
    if { $value > 1 } { 
        # puts "warning: acos(value) , value: $value"
        set value 1 
    }
    if { $value < -1 } { 
        # puts "warning: acos(value) , value: $value"
        set value -1 
    }
    set rad [expr acos($value)]
    set surf_v [v_multi_x $base_v_loc $target_v_loc]
    set angle [expr double($rad*180) / 3.141592654]
    return "{$surf_v} $angle"
}


# 点到点距离 - 坐标输入
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


# 计算点到线的距离
proc dis_point_to_line_loc {point_loc line_1_loc line_2_loc} {
    # 点到直线距离
    set d12 [dis_point_to_point_loc $point_loc $line_1_loc]
    set d13 [dis_point_to_point_loc $point_loc $line_2_loc]
    set d23 [dis_point_to_point_loc $line_1_loc $line_2_loc]
    set p [expr ($d12+$d13+$d23)*0.5]
    set s [expr ($p*($p-$d12) * ($p-$d13) * ($p-$d23)) **0.5]
    set h [expr double($s)*2.0 / $d23]
    return $h
}



# 获取node 对应坐标
proc get_node_locs {node_id} {
    set x [hm_getvalue nodes id=$node_id dataname=x]
    set y [hm_getvalue nodes id=$node_id dataname=y]
    set z [hm_getvalue nodes id=$node_id dataname=z]
    return "$x $y $z"
}



# 根据矢量创建node点, 默认环绕圆
proc create_circle_node_with_vector {new_v new_u circle_center_loc dis node_num start_angle end_angle} {
    set circle_v [v_one [v_multi_x $new_v $new_u]]
    set new_u [v_one $new_u]
    set node_ids []
    set start_rad [expr double($start_angle) / 180.0 * 3.141592654]
    # puts "start_rad: $start_rad"
    
    set rad_single [expr (double($end_angle - $start_angle) / 180 * 3.141592654) / double($node_num)]
    # puts "rad_single: $rad_single"
    for { set i 0 } { $i < $node_num+1 } { incr i 1 } {
        set cur_rad [expr $start_rad + double($i)*$rad_single]
        if {$cur_rad > [expr double($end_angle)/180*3.141592654]} {break}

        set loc1 [v_rotate_point $circle_v $new_u $cur_rad]
        set loc1 [v_multi_c $loc1 $dis]
        *clearmark nodes 1
        set node_loc1 [v_add $loc1 $circle_center_loc]
        set node_loc1 [v_add $loc1 $circle_center_loc]
        eval "*createnode $node_loc1 0 0 0"
        *createmarklast nodes 1
        lappend node_ids [hm_getmark nodes 1]   
    }
    return $node_ids   
}

proc get_vector_locs {vector_id} {
    set x [hm_getvalue vectors id=$vector_id dataname=xcomp]
    set y [hm_getvalue vectors id=$vector_id dataname=ycomp]
    set z [hm_getvalue vectors id=$vector_id dataname=zcomp]    
    return "$x $y $z"
}


# *createmarkpanel loads 1
# set force_id [hm_getmark loads 1]

set start_angle 0
set end_angle 60
set num 3
set value 100



*createmarkpanel nodes 1
set node_id [hm_getmark nodes 1]
set center_loc [get_node_locs $node_id]

*createmarkpanel vectors 1
set vector_id [hm_getmark vectors 1]
set v_u [get_vector_locs $vector_id]


*createmarkpanel vectors 1
set vector_id [hm_getmark vectors 1]
set surf_v [get_vector_locs $vector_id]


set v_v [v_multi_x $v_u $surf_v]

set node_ids [create_circle_node_with_vector $v_v $v_u $center_loc 1 $num $start_angle $end_angle]

set single_angle [expr $end_angle - $start_angle ]
for { set i 0 } { $i < [llength $node_ids] } { incr i 1 } {
    set cur_angle [expr $single_angle * $i + $start_angle]
    set cur_node_id [lindex $node_ids $i]
    set cur_loc [get_node_locs $cur_node_id]
    set cur_v [v_one [v_sub $cur_loc $center_loc]]
    set cur_force_values [v_multi_c $cur_v $value]

    puts "cur_angle:$cur_angle"
    puts "cur_force_values: $cur_force_values"


    *createentity loadcols name="force_$cur_angle\_deg"


    *createmark nodes 1 $node_id
    eval "*loadcreateonentity_curve nodes 1 1 1 $cur_force_values 0 0 $value 0 0 0 0 0"

    *createmark loadcols 1 "force_$cur_angle\_deg"
    set cur_loadcol_id [hm_getmark loadcols 1]    

    *loadstepscreate "load_force_$cur_angle\_deg" 1
    *createmark loadsteps 1 "load_force_$cur_angle\_deg"
    set cur_loadstep_id [hm_getmark loadsteps 1]
    
    # *setvalue loadsteps id=$cur_loadstep_id STATUS=2 4059=1 4060=STATICS OS_LOADID={loadcols $cur_loadcol_id}

    *attributeupdatestring loadsteps $cur_loadstep_id 4060 1 1 0 "STATICS"
    *attributeupdateentity loadsteps $cur_loadstep_id 4147 1 1 0 loadcols $cur_loadcol_id
    *attributeupdateint loadsteps $cur_loadstep_id 4709 1 1 0 1
}






