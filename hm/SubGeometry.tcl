package provide SubGeometry 1.0

# ===================================================================
# 空间矢量计算 ----------------------
# 矢量 - abs
proc v_abs {loc} {
    set x [lindex $loc 0]
    set y [lindex $loc 1]
    set z [lindex $loc 2]
    set value [expr (double($x)**2+double($y)**2+double($z)**2)**0.5]
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

    set value [expr double($x1)*double($x2) + double($y1)*double($y2) + double($z1)*double($z2)]
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


# 点-绕矢量轴旋转 v_rotate_point
proc v_rotate_point_rad {vector point_loc rad} {
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


# 点-绕轴旋转
proc v_rotate_point_angle {vector point_loc angle} {
    # A : vector
    # P : point_loc
    set rad [angle2rad $angle]
    set vector_one [v_one $vector]
    set P_cos [v_multi_c $point_loc [expr cos($rad)]]
    set A_x_P_sin [v_multi_c [v_multi_x $vector_one $point_loc] [expr sin($rad)]]
    set A_dot_P [v_multi_dot $vector_one $point_loc]
    set A_A_dot_P_theta [v_multi_c $vector_one [expr $A_dot_P*(1-cos($rad))]]

    set new_loc [v_add [v_add $P_cos $A_x_P_sin] $A_A_dot_P_theta]
    return $new_loc
}


# 对坐标四舍五入, 保留位数num
proc v_loc_round_num {loc1 num} {
    set x [lindex $loc1 0]
    set y [lindex $loc1 1]
    set z [lindex $loc1 2]
    set new_x [expr double(round($x*(10**$num))) / (10**$num)]
    set new_y [expr double(round($y*(10**$num))) / (10**$num)]
    set new_z [expr double(round($z*(10**$num))) / (10**$num)]
    return "$new_x $new_y $new_z"
}



# =========================================
# =========================================
# 单位转换
# 角度转弧度
proc angle2rad {angle} {
    return [expr double($angle) /180.0 * 3.141592654]
}

# 弧度转角度
proc rad2angle {rad} {
    return [expr double($rad*180.0) / 3.141592654]   
}


# =========================================
# =========================================
# 空间几何
# 点到点距离 - 坐标输入 dis_point_to_point_loc
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


# 计算点到线的距离 dis_point_to_line_loc
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


# 垂点 vertical_point
proc loc_vertical_point_in_line {line_p1_loc line_p2_loc p3_loc} {

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


# 矢量夹角 angle_2vector
proc angle_of_2v {base_v_loc target_v_loc} {
    # base_v_loc 起始 指向
    # target_v_loc 结束 
    # 输出夹角为 base_v_loc X target_v_loc 法向量的逆时针角

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
    set angle [rad2angle $rad]
    return "{$surf_v} $angle"
}




# 判断两线是否接近共线
proc logic_line_locs_is_close {line_1_locs line_2_locs tolerance} {

    # set tolerance 0.1
    set line_1_1_loc [lindex $line_1_locs 0]
    set line_1_2_loc [lindex $line_1_locs 1]
    set line_2_1_loc [lindex $line_2_locs 0]
    set line_2_2_loc [lindex $line_2_locs 1]

    # puts "$line_1_locs"
    # puts "$line_2_locs"
    # puts "$tolerance"
    # puts "$line_1_1_loc $line_2_1_loc $line_2_2_loc"
        
    if {[dis_point_to_point_loc $line_1_1_loc $line_1_2_loc] < 0.01} {
        # puts "error : $line_1_1_loc $line_1_2_loc"
        return 0
    }
    if {[dis_point_to_point_loc $line_2_1_loc $line_2_2_loc] < 0.01} {
        # puts "error : $line_2_1_loc $line_2_2_loc"
        return 0
    }

    set status1 [catch {
        set dis1 [dis_point_to_line_loc $line_1_1_loc $line_2_1_loc $line_2_2_loc]
    } res]
    if {$status1} {
        puts "error: dis_point_to_line_loc $line_1_1_loc $line_2_1_loc $line_2_2_loc"
        set dis1 0
    }

    set status2 [catch {
        set dis2 [dis_point_to_line_loc $line_1_2_loc $line_2_1_loc $line_2_2_loc]
    } res]
    if {$status2} {
        puts "error dis_point_to_line_loc $line_1_2_loc $line_2_1_loc $line_2_2_loc"
        set dis2 0
    }

    # puts "dis1 :$dis1 ; dis2 : $dis2"
    if {$dis1 < $tolerance & $dis2 < $tolerance} {
        return 1
    } else {
        return 0
    }
}


# =================
# proc test_logic_line_locs_is_close {} {

#     if {![logic_line_locs_is_close "{0 0 0.5} {0 0 1}" "{0 0 0.5} {0 0 2}" 0.1]} {
#         puts "error"
#     } else {
#         puts "true"
#     }

#     if {![logic_line_locs_is_close "{0 0 0.5} {0 0 2}" "{0 0 0.5} {0 0 2}" 0.1]} {
#         puts "error"
#     } else {
#         puts "true"
#     }

#     if {[logic_line_locs_is_close "{0 0 0.5} {1 0 0}" "{0 0 0.5} {0 0 2}" 0.1]} {
#         puts "error"
#     } else {
#         puts "true"
#     }

#     if {[logic_line_locs_is_close "{0 0 0.5} {1 0 0}" "{0 0 0.5} {0 0 0.6}" 0.1]} {
#         puts "error"
#     } else {
#         puts "true"
#     }

# }

