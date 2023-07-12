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



# ===================================================================
# ===================================================================
# ===================================================================

# # --------------
# # 创建圆心node by point
# proc create_circle_center_node_by_point {point_circle_ids} {
    
#     # 中心点创建
#     *clearmark nodes 1

#     eval "*createmark points 1 $point_circle_ids"
#     *createbestcirclecenternode points 1 0 1 0

#     *createmarklast nodes 1
#     set node_circle_center_id [hm_getmark nodes 1]
#     # puts "node_circle_center_id: $node_circle_center_id"
#     return $node_circle_center_id
# }


# # --------------
# # 
# proc get_end_line_id_by_surf {surf_id} {
#     *createmark lines 1 "by surface" $surf_id
#     set line_ids [lsort -integer [hm_getmark lines 1]]
#     # puts "get_end_line_id_by_surf : surf_id $surf_id line_ids:$line_ids"
#     return [lindex $line_ids end]
# }


# # --------------
# # old
# proc create_circle_node_4_with_v {new_v new_u circle_center_loc dis} {

#     # 顺序连线
#     set v_1 [v_multi_c [v_one [v_add $new_v $new_u]] $dis]
#     set v_2 [v_multi_c [v_one [v_sub $new_v $new_u]] $dis]
#     set v_3 [v_multi_c $v_1 -1]
#     set v_4 [v_multi_c $v_2 -1]
    
#     set node_ids []

#     foreach v_cur "{$v_1} {$v_2} {$v_3} {$v_4}" {
#         *clearmark nodes 1
#         set node_loc1 [v_add $v_cur $circle_center_loc]
#         eval "*createnode $node_loc1 0 0 0"
#         *createmarklast nodes 1
#         lappend node_ids [hm_getmark nodes 1]

#     }
#     return $node_ids
# }


# # --------------
# # old
# proc create_circle_node_6_with_v {new_v new_u circle_center_loc dis} {

#     set circle_v [v_one [v_multi_x $new_v $new_u]]
#     set new_u [v_one $new_u]
#     set node_ids []
#     foreach num "0 1 2 3 4 5" {
#         set loc1 [v_rotate_point $circle_v $new_u [expr double($num)*60.0 / 180.0*3.141592654]]
#         set loc1 [v_multi_c $loc1 $dis]
#         # puts "num:$num ; loc1:$loc1"
#         *clearmark nodes 1
#         set node_loc1 [v_add $loc1 $circle_center_loc]
#         eval "*createnode $node_loc1 0 0 0"
#         *createmarklast nodes 1
#         lappend node_ids [hm_getmark nodes 1]
#     }
#     return $node_ids
# }

# # --------------
# # old
# proc create_circle_node_8_with_v {new_v new_u circle_center_loc dis} {

#     # 顺序连线
#     set v_1 [v_multi_c [v_one [v_add $new_v $new_u]] $dis]
#     set v_2 [v_multi_c [v_one $new_v] $dis]
#     set v_3 [v_multi_c [v_one [v_sub $new_v $new_u]] $dis]
#     set v_4 [v_multi_c [v_one $new_u] [expr -1*$dis]]
#     set v_5 [v_multi_c $v_1 -1]
#     set v_6 [v_multi_c $v_2 -1]
#     set v_7 [v_multi_c $v_3 -1]
#     set v_8 [v_multi_c [v_one $new_u] $dis]
#     set node_ids []
#     foreach v_cur "{$v_1} {$v_2} {$v_3} {$v_4} {$v_5} {$v_6} {$v_7} {$v_8}" {
#         *clearmark nodes 1
#         set node_loc1 [v_add $v_cur $circle_center_loc]
#         eval "*createnode $node_loc1 0 0 0"
#         *createmarklast nodes 1
#         lappend node_ids [hm_getmark nodes 1]

#     }
#     return $node_ids
# }

# # --------------
# # surf分割, 1组node列表前后连接分割
# proc surf_split_by_nodes_try_old {surf_id node_ids insert_point_num} {
#     # ---------------------
#     # surf 面
#     # node_ids 列表
#     # insert_point_num 线段插入point点数量
#     # ---------------------

#     set node_len [llength $node_ids]
#     set line_datas []
    
#     # 获取面的法向量
#     set surf_v [lrange [hm_getsurfacenormalatcoordinate $surf_id 0 0 0] 0 2]
#     # puts "surf_v: $surf_v"
#     # set surf_temp_ids [$surf_id]
#     for { set i 0 } { $i < $node_len } { incr i 1 } {
#         if {$i < [expr $node_len-1]} {
#             set loc1 [get_node_locs [lindex $node_ids $i]]
#             set loc2 [get_node_locs [lindex $node_ids [expr $i+1]]]
#             set line_id [create_line_by_node [lindex $node_ids $i] [lindex $node_ids [expr $i+1]]]
#         } else {
#             set loc1 [get_node_locs [lindex $node_ids 0]]
#             set loc2 [get_node_locs [lindex $node_ids end]]
#             set line_id [create_line_by_node [lindex $node_ids 0] [lindex $node_ids end]]
#         }

#         # -------------------------
#         # 分割面
#         set line_data [surf_split_with_lines_try $surf_id $line_id $surf_v $loc1 $loc2]
#         # 删除分割用的的线
#         *createmark lines 1 $line_id
#         *deletemark lines 1
#         if {$line_data==0} { continue }

#         if {[llength [lindex $line_data 0]] > 0} {
#             # 判定是否为目标面
#             set line_surf_id [lindex $line_data 2]
#             if {[is_target_surf_by_line_and_nodes $surf_id $line_surf_id $node_ids]==0} {
#                 set surf_id [lindex $line_data 0]
#             }
#             set line_data "{$surf_id} {[lindex $line_data 1]} {[lindex $line_data 2]}"
#         }
#         lappend line_datas $line_data    
#         # puts "line_data: $line_data"
#     }
    
#     # -------------------------
#     # 插入point
#     if {$insert_point_num!=0} {
#         set surf_target_id [lindex [lindex $line_datas end] 0]
#         set line_target_id [lindex [lindex $line_datas end] 2]
#         # puts "surf_split_by_nodes_try_old:: \n  *surf_target_id : $surf_target_id\n  *line_target_id : $line_target_id"

#         *createmark lines 1 "by surface" $surf_target_id
#         set circle_lines_data [get_circle_data_by_line_in_lines $line_target_id [hm_getmark lines 1]]
#         # puts "circle_lines_data : $circle_lines_data"
#         set circle_lines_ids [lindex $circle_lines_data 0]

#         foreach circle_lines_id $circle_lines_ids {
#             *createmark lines 1 $circle_lines_id
#             *edgesmarkaddpoints 1 $insert_point_num    
#         }
#     }
#     return $line_datas
# }


# ===================================================================
# ===================================================================
# ===================================================================

# 获取node 对应坐标
proc get_node_locs {node_id} {
    set x [hm_getvalue nodes id=$node_id dataname=x]
    set y [hm_getvalue nodes id=$node_id dataname=y]
    set z [hm_getvalue nodes id=$node_id dataname=z]
    return "$x $y $z"
}


# 根据line_id 获取闭环数据 point\line
proc get_circle_data_by_line {line_id} {

    namespace eval ::TempData {
        variable line_ids []
        variable point_ids []
    }

    proc line_to_points {line_id} {
        
        if {$line_id in $::TempData::line_ids} {return}
        lappend ::TempData::line_ids "$line_id"

        *createmark points 1 "by lines" $line_id
        set point_ids [hm_getmark points 1]
        if {[llength $point_ids]<2} {
            lappend ::TempData::point_ids $point_ids
            return
        }
        # puts "cal_line : $line_id"
        foreach point_id $point_ids {
            if {$point_id in $::TempData::point_ids} {
                continue
            } else {
                lappend ::TempData::point_ids $point_id
            }

            *createmark lines 1 "by points" $point_id
            set line_2_ids [hm_getmark lines 1]
            # puts "cal_line_2_ids : $line_2_ids"
            foreach line_temp_id $line_2_ids {
                line_to_points $line_temp_id
            }
        }
    }

    set ::TempData::line_ids []
    set ::TempData::point_ids []
    line_to_points $line_id
    # puts "line_ids : $::TempData::line_ids"
    # puts "point_ids : $::TempData::point_ids"
    set line_ids $::TempData::line_ids
    set point_ids $::TempData::point_ids
    set ::TempData::line_ids []
    set ::TempData::point_ids []
    return "{$line_ids} {$point_ids}"
}


# 根据line_id 获取闭环数据 point\line in lines
proc get_circle_data_by_line_in_lines {line_id base_ids} {
    # line_id 需在 base_ids 里

    namespace eval ::TempData {
        variable line_ids []
        variable point_ids []
        variable base_ids []
    }

    proc line_to_points {line_id} {
        
        if {$line_id in $::TempData::line_ids} {return}
        if {$line_id in $::TempData::base_ids} {} else {return}
        lappend ::TempData::line_ids "$line_id"

        *createmark points 1 "by lines" $line_id
        set point_ids [hm_getmark points 1]
        if {[llength $point_ids]<2} {
            lappend ::TempData::point_ids $point_ids
            return
        }
        # puts "cal_line : $line_id"
        foreach point_id $point_ids {
            if {$point_id in $::TempData::point_ids} {
                continue
            } else {
                lappend ::TempData::point_ids $point_id
            }

            *createmark lines 1 "by points" $point_id
            set line_2_ids [hm_getmark lines 1]
            # puts "cal_line_2_ids : $line_2_ids"
            foreach line_temp_id $line_2_ids {
                line_to_points $line_temp_id
            }
        }
    }

    set ::TempData::line_ids []
    set ::TempData::point_ids []
    set ::TempData::base_ids $base_ids
    line_to_points $line_id
    # puts "line_ids : $::TempData::line_ids"
    # puts "point_ids : $::TempData::point_ids"
    set line_ids $::TempData::line_ids
    set point_ids $::TempData::point_ids
    set ::TempData::line_ids []
    set ::TempData::point_ids []
    set ::TempData::base_ids []
    return "{$line_ids} {$point_ids}"
}


# 获取各node的均值坐标点
proc get_nodes_center_loc {node_ids} {
    set x_sum 0
    set y_sum 0
    set z_sum 0
    set n_len [llength $node_ids]
    foreach node_id $node_ids {
        set loc1 [get_node_locs $node_id]
        set x_sum [expr $x_sum + [lindex $loc1 0]]
        set y_sum [expr $y_sum + [lindex $loc1 1]]
        set z_sum [expr $z_sum + [lindex $loc1 2]]
    }
    return "[expr double($x_sum) / double($n_len)] [expr double($y_sum) / double($n_len)] [expr double($z_sum) / double($n_len)]"
}


# 根据线id获取圆心数据
proc create_circle_center_node_data_by_line {line_id} {

    set node_circle_center_id [create_circle_center_node_by_line $line_id]
    set circle_center_loc [get_node_locs $node_circle_center_id]

    set point_locs [hm_getcoordinatesofpointsonline $line_id [list 0.0 0.5]]
    # set loc1 [hm_getcoordinates point [lindex $point_circle_ids 0]]
    set loc1 [lindex $point_locs 0]

    set r_circle [dis_point_to_point_loc $loc1 $circle_center_loc]
    # puts "$node_circle_center_id {$circle_center_loc} $r_circle"
    return "$node_circle_center_id {$circle_center_loc} $r_circle"
}


# 创建圆心node by line
proc create_circle_center_node_by_line {line_id} {
    
    *clearmark nodes 1
    *createmark lines 1 $line_id
    *createbestcirclecenternode lines 1 0 1 0
    *createmarklast nodes 1
    set node_circle_center_id [hm_getmark nodes 1]
    return $node_circle_center_id
}


# 线创建
proc create_line_by_node {node_id1 node_id2} {
    hm_entityrecorder lines on
    *createlist nodes 1 $node_id1 $node_id2
    *linecreatefromnodes 1 0 0 0 0
    hm_entityrecorder lines off
    set line_id [hm_entityrecorder lines ids]
    return $line_id
}


# 根据矢量创建node点, 默认环绕圆
proc create_circle_node_with_vector {new_v new_u circle_center_loc dis node_num start_angle} {
    set circle_v [v_one [v_multi_x $new_v $new_u]]
    set new_u [v_one $new_u]
    set node_ids []
    set start_rad [expr double($start_angle) / 180.0 * 3.141592654]
    # puts "start_rad: $start_rad"
    
    for { set i 0 } { $i < $node_num } { incr i 1 } {

        set loc1 [v_rotate_point $circle_v $new_u [expr $start_rad + double($i)*2.0*3.141592654 / double($node_num)]]
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


# 根据圆孔创建node点 - edit
proc create_circle_node_by_line {line_circle_id line_base_2_locs dis_offsets node_nums start_angles} {
    # line_circle_id 线对应的ID
    # line_base_id   基础轴线的ID 对应坐标 line_base_2_locs

    # 根据线获取面
    *createmark surfs 1 "by lines" $line_circle_id
    set surf_id [hm_getmark surfs 1]

    # set line_base_2_locs [hm_getcoordinatesofpointsonline $line_base_id [list 0.0 0.1]]
    set line_base_v [v_sub [lindex $line_base_2_locs 0] [lindex $line_base_2_locs 1]]

    # 根据线获取圆
    set circle_data [create_circle_center_node_data_by_line $line_circle_id]
    set circle_node_id [lindex $circle_data 0]
    set circle_center_loc [lindex $circle_data 1]
    set R_circle [lindex $circle_data 2]
    # puts "line_circle_id : $line_circle_id \n surf_id : $surf_id \n circle_data : $circle_data"

    *createmark points 1 "by lines" $line_circle_id
    set point_circle_ids [hm_getmark points 1]
    set point_circle_1_id [lindex $point_circle_ids 0]

    set surf_normal_2_locs [hm_getsurfacenormal points $point_circle_1_id ]
    if {[lindex $surf_normal_2_locs 0] != 1} {return 0}
    if {[lindex $surf_normal_2_locs 4] != $surf_id} {return 0}

    # 面法向量
    set surf_v [lrange $surf_normal_2_locs 1 3]
    # puts "surf_normal_2_locs: $surf_normal_2_locs \n surf_v : $surf_v"

    # 矢量轴 
    set line_ver_v [v_multi_x $surf_v $line_base_v]
    # puts "{$line_ver_v} {$line_base_v} {$surf_v}"

    set line_base_v [v_multi_x $surf_v $line_ver_v]

    # 垂直轴-坐标系基准
    set new_v [v_multi_c [v_one $line_base_v] $R_circle]
    set new_u [v_multi_c [v_one $line_ver_v] $R_circle]

    set circle_num [llength $dis_offsets]
    # puts "len circle_num : $circle_num ; dis_offsets: $dis_offsets ; node_nums:$node_nums"
    for { set num 0 } { $num < $circle_num } { incr num 1 } {
        # # 坐标相对远点的矢量
        set dis_offset  [lindex $dis_offsets $num]
        set node_num    [lindex $node_nums $num]
        set start_angle [lindex $start_angles $num]

        set dis [expr $R_circle+$dis_offset]
        set node_ids [create_circle_node_with_vector $new_v $new_u $circle_center_loc $dis $node_num $start_angle]

        dict set node_ids_dic $dis_offset "$node_ids"

    }
    dict set node_ids_dic "circle" "$circle_node_id"
    return $node_ids_dic
}


# 判断两线是否接近共线
proc is_close_line_locs_in_surf {line_1_locs line_2_locs tolerance} {

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


# 用于1线分割面，左右surf判定的情况
# 判定是否为目标面(以line为界限, 各node的均值坐标点, 与surf的几何中心是否一致) 
proc is_target_surf_by_line_and_nodes {surf_id line_id node_ids} {
    # line_id 在 surf_id对应的面上
    # 通过法向量是否通向进行判断

    set tolerance 0.01

    *createmark surfs 1 $surf_id
    set surf_loc [hm_getcentroid surfs 1]

    # *createmark points 1 "by lines" $line_id
    # set point_line_ids [hm_getmark points 1]
    # set base_loc [hm_getcoordinates point [lindex $point_line_ids 0]]
    # set base_loc2 [hm_getcoordinates point [lindex $point_line_ids 1]]
    set point_locs [hm_getcoordinatesofpointsonline $line_id [list 0.0 1.0]]
    set base_loc  [lindex $point_locs 0]
    set base_loc2 [lindex $point_locs 1]
    set node_center_loc [get_nodes_center_loc $node_ids]

    set v_base_line [v_sub $base_loc2 $base_loc]
    set v_base_to_node_center [v_sub $node_center_loc $base_loc]
    set v_base_to_surf_center [v_sub $surf_loc $base_loc]

    # 叉乘获得法向量
    # 点乘判定是否同向
    set is_same [v_multi_dot [v_multi_x $v_base_line $v_base_to_node_center] [v_multi_x $v_base_line $v_base_to_surf_center] ]
    
    # puts "is_same : $is_same"
    if {$is_same > 0} {
        return 1
    } else {
        return 0 
    }
}


# 判定是否为目标面, 根据面上的点是否包含所有inner_node_ids点
proc is_target_surf_by_nodes {surf_id inner_node_ids} {

    # 
    set node_locs []
    foreach node_id $inner_node_ids {
        set loc1 [get_node_locs $node_id]
        set new_loc1 [v_loc_round_num $loc1 1]
        lappend node_locs $new_loc1
    }

    set point_locs []
    *createmark points 1 "by surface" $surf_id
    foreach point_id [hm_getmark points 1] {
        set loc1 [hm_getcoordinates point $point_id]
        set new_loc1 [v_loc_round_num $loc1 1]
        lappend point_locs $new_loc1
    }
    set num_ture 0
    foreach node_loc $node_locs {
        if {$node_loc in $point_locs} {
            set num_ture [expr $num_ture+1]
        }
    }
    if {$num_ture == [llength $inner_node_ids]} {
        return 1
    } else {
        return 0
    }
}


# 连点坐标分割面
proc surf_split_with_coords {surf_id loc1 loc2} {
    set tolerance_angle 5
    set tolerance_dis_percent 0.01

    hm_entityrecorder lines on
    hm_entityrecorder surfs on
    eval "*surfacesplitwithcoords $surf_id $loc1 $loc2"
    hm_entityrecorder lines off
    hm_entityrecorder surfs off
    set surf_ids [hm_entityrecorder surfs ids]
    set line_ids [hm_entityrecorder lines ids]
    
    set line_angles []
    set line_dels []
    foreach line_id $line_ids {
        set point_locs [hm_getcoordinatesofpointsonline $line_id [list 0.0 1.0]]
        set line_v [v_sub [lindex $point_locs 0] [lindex $point_locs 1]]
        set line_v_2 [v_sub $loc1 $loc2]

        if {[v_abs $line_v] < 0.01} { continue }
        set angle [lindex [angle_2vector $line_v $line_v_2] 1]
        set dis_del_percent [ expr double(abs(([v_abs $line_v]-[v_abs $line_v_2])) / double([v_abs $line_v])) ]
        if {[expr abs($angle)] < $tolerance_angle | [expr abs($angle-180)] < $tolerance_angle} {
            if {$dis_del_percent < $tolerance_dis_percent} {
                set line_new_id $line_id
                break
            }
        }
        # puts "line_id: $line_id ; angle: $angle ; dis_del_percent: $dis_del_percent"
    }
    # puts "corder_surf_ids: $surf_ids"
    # puts "corder_line_ids: $line_ids"
    # puts "corder_line_new_id: $line_new_id"
    return "{$surf_ids} {$line_ids} {$line_new_id}"
}


# surf分割, 1组node列表前后连接分割
proc surf_split_by_nodes {surf_id node_ids insert_point_num} {
    # surf 面
    # node_ids 列表
    # insert_point_num 线段插入point点数量
    set node_len [llength $node_ids]
    set line_datas []
    for { set i 0 } { $i < [expr $node_len-1] } { incr i 1 } {
        set loc1 [get_node_locs [lindex $node_ids $i]]
        set loc2 [get_node_locs [lindex $node_ids [expr $i+1]]]
        set line_data [surf_split_with_coords $surf_id $loc1 $loc2]
        lappend line_datas $line_data
        if {$insert_point_num!=0} {
            *createmark lines 1 [lindex $line_data 2]
            *edgesmarkaddpoints 1 $insert_point_num    
        }
    }
    set loc1 [get_node_locs [lindex $node_ids 0]]
    set loc2 [get_node_locs [lindex $node_ids end]]
    set line_data [surf_split_with_coords $surf_id $loc1 $loc2]
    lappend line_datas $line_data
    if {$insert_point_num!=0} {
        *createmark lines 1 [lindex $line_data 2]
        *edgesmarkaddpoints 1 $insert_point_num    
    }

    return $line_datas
}


# surf分割, 两组等长node列表分别连接分割
proc surf_split_by_two_nodes {surf_id node_1_ids node_2_ids insert_point_num} {
    set node_len [llength $node_1_ids]
    set line_datas []
    for { set i 0 } { $i < $node_len } { incr i 1 } {
        set loc1 [get_node_locs [lindex $node_1_ids $i]]
        set loc2 [get_node_locs [lindex $node_2_ids $i]]
        set line_data [surf_split_with_coords $surf_id $loc1 $loc2]
        lappend line_datas $line_data
        if {$insert_point_num!=0} {
            *createmark lines 1 [lindex $line_data 2]
            *edgesmarkaddpoints 1 $insert_point_num    
        }
    }
    return $line_datas
}



# 连点坐标分割面 - try
proc surf_split_with_lines_try {surf_id line_id surf_v loc1 loc2} {
    set tolerance_dis 0.1

    set status [catch {
        *createmark surfaces 1 $surf_id
        *createmark lines 1 $line_id
        eval "*createvector 1 $surf_v"
        hm_entityrecorder lines on
        hm_entityrecorder surfs on
        # *surfacemarksplitwithlines 1 1 1 1 0.5
        *surfacemarksplitwithlines 1 1 0 13 0
        hm_entityrecorder lines off
        hm_entityrecorder surfs off
        set surf_ids [hm_entityrecorder surfs ids]
        set line_ids [hm_entityrecorder lines ids]
    } res]
    if {$status} { return 0}

    # puts "corder_surf_ids: $surf_ids"
    # puts "corder_line_ids: $line_ids"
    foreach line_id $line_ids {
        set point_locs [hm_getcoordinatesofpointsonline $line_id [list 0.0 1.0]]
        set line_v [v_sub [lindex $point_locs 0] [lindex $point_locs 1]]
        if {[v_abs $line_v] < 0.1} { continue }
        if {[llength $point_locs]==1} {continue}
        # puts "is_close_line_locs_in_surf {$loc1} {$loc2} $point_locs $tolerance_dis"

        # 查找匹配的line
        set is_close_line [is_close_line_locs_in_surf "{$loc1} {$loc2}" $point_locs $tolerance_dis]
        # puts "is_close_line : $is_close_line"
        # 新创建的line
        if {$is_close_line==1} {set line_new_id $line_id; break}
            
    }
    # puts "corder_line_new_id: $line_new_id"
    return "{$surf_ids} {$line_ids} {$line_new_id}"
}


# surf分割, 1组node列表前后连接分割; 通过内环node点判定surf面是否正确
proc surf_split_by_nodes_try_with_innernodes_tocirlce {surf_id node_ids insert_point_num inner_node_ids} {
    # ---------------------
    # surf 面
    # node_ids 列表
    # insert_point_num 线段插入point点数量
    # ---------------------

    set node_len [llength $node_ids]
    set line_datas []
    
    # 获取面的法向量
    set surf_v [lrange [hm_getsurfacenormalatcoordinate $surf_id 0 0 0] 0 2]
    # puts "surf_v: $surf_v"

    for { set i 0 } { $i < $node_len } { incr i 1 } {
        if {$i < [expr $node_len-1]} {
            set loc1 [get_node_locs [lindex $node_ids $i]]
            set loc2 [get_node_locs [lindex $node_ids [expr $i+1]]]
            set line_id [create_line_by_node [lindex $node_ids $i] [lindex $node_ids [expr $i+1]]]
        } else {
            set loc1 [get_node_locs [lindex $node_ids 0]]
            set loc2 [get_node_locs [lindex $node_ids end]]
            set line_id [create_line_by_node [lindex $node_ids 0] [lindex $node_ids end]]
        }

        # -------------------------
        # 分割面
        set line_data [surf_split_with_lines_try $surf_id $line_id $surf_v $loc1 $loc2]
        # 删除分割用的的线
        *createmark lines 1 $line_id
        *deletemark lines 1
        if {$line_data==0} { continue }

        if {[llength [lindex $line_data 0]] > 0} {
            # 判定是否为目标面
            set line_surf_id [lindex $line_data 2]
            if {[is_target_surf_by_nodes $surf_id $inner_node_ids] == 0} {
                set surf_id [lindex $line_data 0]
            }
            set line_data "{$surf_id} {[lindex $line_data 1]} {[lindex $line_data 2]}"
        }
        lappend line_datas $line_data    
        # puts "line_data: $line_data"
    }
    
    # -------------------------
    # 插入point
    if {$insert_point_num!=0} {
        set surf_target_id [lindex [lindex $line_datas end] 0]
        set line_target_id [lindex [lindex $line_datas end] 2]
        # puts "surf_split_by_nodes_try_with_innernodes_tocirlce:: \n  *surf_target_id : $surf_target_id\n  *line_target_id : $line_target_id"

        *createmark lines 1 "by surface" $surf_target_id
        set circle_lines_data [get_circle_data_by_line_in_lines $line_target_id [hm_getmark lines 1]]
        # puts "circle_lines_data : $circle_lines_data"
        set circle_lines_ids [lindex $circle_lines_data 0]

        foreach circle_lines_id $circle_lines_ids {
            *createmark lines 1 $circle_lines_id
            *edgesmarkaddpoints 1 $insert_point_num    
        }
    }
    return $line_datas
}


# -----------------------------------
# -----------------------------------

# 主函数, 边界双边超过界限(矩形钢适用)，双环
proc main_hole_mesh_2circle_by_two_line {line_base_id line_circle_ids control_params} {
    # -------------------------
    # line_base_id 参考周线line ID
    # line_circle_ids 目标圆孔lineID (1个圆孔1个lineID, 可以为列表)
    # control_params 控制参数
    # -------------------------

    # 边界-node点数
    set edge_num              [dict get $control_params edge_num]
    # 内圆孔-node点数
    set circle_in_num         [dict get $control_params circle_in_num]
    # 外圆孔-node点数
    set circle_out_num        [dict get $control_params circle_out_num]
    # 外圆孔-偏置量(相对于内圆孔)
    set circle_offset         [dict get $control_params circle_offset]
    # 边界-偏置量(相对于内圆孔)
    set edge_offset           [dict get $control_params edge_offset]
    # 网格单元尺寸定义
    set elem_size             [dict get $control_params elem_size]
    # 边界线-line插入point点数
    set edge_line_point_num   [dict get $control_params edge_line_point_num]
    # 外圆孔-line插入point点数
    set cirlce_line_point_num [dict get $control_params cirlce_line_point_num]

    # 起始角 - 外圆孔
    set start_angle_circle_out [dict get $control_params start_angle_circle_out]
    # 起始角 - 内圆孔
    set start_angle_circle_in  [dict get $control_params start_angle_circle_in]
    # 起始角 - 边界
    set start_angle_edge       [dict get $control_params start_angle_edge]

    set line_base_2_locs [hm_getcoordinatesofpointsonline $line_base_id [list 0.0 0.1]]

    foreach line_circle_id $line_circle_ids {
        *createmark points 1 "by lines" $line_circle_id
        dict set cirlce_line_to_point $line_circle_id [lindex [hm_getmark points 1] 0]
    }

    foreach line_circle_id $line_circle_ids {
        *createmark lines 1 "by points" [dict get $cirlce_line_to_point $line_circle_id ]
        set line_circle_id [lindex [hm_getmark lines 1] 0]

        # ----------------------------------------------
        # ----------------------------------------------
        # 压掉圆孔的point点

        # 获取圆孔数据
        set circle_data [get_circle_data_by_line $line_circle_id]
        # puts "circle_data : $circle_data"
        
        eval "*createmark points 1 [lindex $circle_data 1]"
        *verticesmarksuppress 1 180 0

        # 重新获取圆孔 line ID
        *createmarklast points 1
        set point_id [hm_getmark points 1]
        # puts "points: [hm_getmark points 1]"

        *createmark lines 1 "by points" $point_id
        set line_circle_id [hm_getmark lines 1]
        # puts "line_circle_id: $line_circle_id"

        *createmark surfs 1 "by lines" $line_circle_id
        set surf_id [hm_getmark surfs 1]

        
        # ----------------------------------------------
        # ----------------------------------------------
        # ----------------创建node 点
        # *startnotehistorystate {create_node}
        set dis_offsets  "0 $circle_offset $edge_offset"
        set node_nums  "$circle_in_num $circle_out_num $edge_num"
        set start_angles "$start_angle_circle_in $start_angle_circle_out $start_angle_edge"
        set node_ids_dic [create_circle_node_by_line $line_circle_id $line_base_2_locs $dis_offsets $node_nums $start_angles]
        # puts "node_ids_dic : $node_ids_dic"
        # *endnotehistorystate {create_node}

        # ----------------------------------------------
        # ----------------------------------------------
        # ----------------线段分割
        
        # 分割内外圆孔
        if {$circle_in_num == $circle_out_num} {
            # 划分线, 有顺序之分
            set line_1_datas [surf_split_by_two_nodes $surf_id [dict get $node_ids_dic 0] [dict get $node_ids_dic $circle_offset] 0]
            # puts "line_1_datas : $line_1_datas"
        }
        catch {
            set point_loc_1 [hm_getcoordinates point $point_id]
            set is_point_del 1
            foreach node_id [dict get $node_ids_dic 0] {
                set loc_temp [get_node_locs $node_id]
                eval "*surfaceaddpoint $surf_id $loc_temp"
                # 点距离判断 -----------------------------------------------------------------------------------
                if {[v_abs [v_sub $point_loc_1 $loc_temp]] < 0.1} { set is_point_del 0 }
            }
            # 尝试压掉 point_id
            if {$is_point_del == 1} { *createmark points 1 $point_id; *verticesmarksuppress 1 180 0; }
        }

        # ----------------
        # 分割外圆孔
        set line_circle_datas [surf_split_by_nodes $surf_id [dict get $node_ids_dic $circle_offset] $cirlce_line_point_num]
        # puts "line_circle_datas : $line_circle_datas"
        
        # ----------------
        # 分割边界
        set line_edge_datas [surf_split_by_nodes_try_with_innernodes_tocirlce $surf_id [dict get $node_ids_dic $edge_offset] $edge_line_point_num [dict get $node_ids_dic $circle_offset]]
        # puts "line_edge_datas : $line_edge_datas"
        
        # ----------------
        # 获取新创建的面 , 仅适用于当前画法
        # 内外圆孔间的分割面
        set new_surf_ids []
        foreach line_circle_datas $line_circle_datas {
            lappend new_surf_ids [lindex $line_circle_datas 0]
        }
        # 边界圆孔
        lappend new_surf_ids [lindex [lindex $line_edge_datas end] 0]
        # 数据去空
        set surf_temp_ids []
        foreach new_surf_id $new_surf_ids {
            # puts "new_surf_id : $new_surf_id"
            if {$new_surf_id!=""} {
                lappend surf_temp_ids $new_surf_id
            }
        }
        set new_surf_ids $surf_temp_ids
        # puts "base_surf_id : $surf_id \nnew_surf_ids : $new_surf_ids"


        # ----------------------------------------------
        # ----------------------------------------------
        # ----------------网格划分
        *startnotehistorystate {mesh hole elements}
            hm_createmark surfs 1 $new_surf_ids
            set new_surf_ids_len [llength $new_surf_ids]
            *interactiveremeshsurf 1 $elem_size 1 1 2 1 1
            for { set i 0 } { $i < $new_surf_ids_len } { incr i 1 } {
                *set_meshfaceparams $i 5 1 0 0 1 0.5 1 1
                *automesh $i 2 1
            }
            *storemeshtodatabase 1
        *endnotehistorystate {mesh hole elements}
    }
}


# 主函数, 边界双边超过界限(矩形钢适用)，单环
proc main_hole_mesh_1circle_by_two_line {line_base_id line_circle_ids control_params} {
    # -------------------------
    # line_base_id 参考周线line ID
    # line_circle_ids 目标圆孔lineID (1个圆孔1个lineID, 可以为列表)
    # control_params 控制参数
    # -------------------------

    # 内圆孔-node点数
    set circle_in_num         [dict get $control_params circle_in_num]
    # 外圆孔-node点数
    set circle_out_num        [dict get $control_params circle_out_num]
    # 外圆孔-偏置量(相对于内圆孔)
    set edge_offset         [dict get $control_params edge_offset]
    # # 边界-偏置量(相对于内圆孔)
    # 网格单元尺寸定义
    set elem_size             [dict get $control_params elem_size]
    # 外圆孔-line插入point点数
    set cirlce_line_point_num [dict get $control_params cirlce_line_point_num]
    # 起始角 - 外圆孔
    set start_angle_circle_out [dict get $control_params start_angle_circle_out]
    # 起始角 - 内圆孔
    set start_angle_circle_in  [dict get $control_params start_angle_circle_in]

    set line_base_2_locs [hm_getcoordinatesofpointsonline $line_base_id [list 0.0 0.1]]


    foreach line_circle_id $line_circle_ids {
        *createmark points 1 "by lines" $line_circle_id
        dict set cirlce_line_to_point $line_circle_id [lindex [hm_getmark points 1] 0]
    }


    foreach line_circle_id $line_circle_ids {
        *createmark lines 1 "by points" [dict get $cirlce_line_to_point $line_circle_id ]
        set line_circle_id [lindex [hm_getmark lines 1] 0]

        # ----------------------------------------------
        # ----------------------------------------------
        # 内圆孔去点

        # 获取圆孔数据
        set circle_data [get_circle_data_by_line $line_circle_id]
        # puts "circle_data : $circle_data"

        # 压掉圆孔的point点
        eval "*createmark points 1 [lindex $circle_data 1]"
        *verticesmarksuppress 1 180 0

        # 重新获取圆孔 line ID
        *createmarklast points 1
        set point_id [hm_getmark points 1]
        # puts "points: [hm_getmark points 1]"

        *createmark lines 1 "by points" $point_id
        set line_circle_id [hm_getmark lines 1]
        # puts "line_circle_id: $line_circle_id"

        *createmark surfs 1 "by lines" $line_circle_id
        set surf_id [hm_getmark surfs 1]


        # ----------------------------------------------
        # ----------------------------------------------
        # ----------------创建node 点    
        set dis_offsets  "0 $edge_offset"
        set node_nums  "$circle_in_num $circle_out_num"
        set start_angles "$start_angle_circle_in $start_angle_circle_out"
        set node_ids_dic [create_circle_node_by_line $line_circle_id $line_base_2_locs $dis_offsets $node_nums $start_angles]
        # set node_ids_dic [create_circle_node_by_line $line_circle_id $line_base_2_locs "0 $edge_offset" "$circle_in_num $circle_out_num "]
        # puts "node_ids_dic : $node_ids_dic"

        # ----------------------------------------------
        # ----------------------------------------------
        # ----------------分割

        # ----------------
        # 分割内圆孔-添加点
        catch {
            set point_loc_1 [hm_getcoordinates point $point_id]
            set is_point_del 1
            foreach node_id [dict get $node_ids_dic 0] {
                set loc_temp [get_node_locs $node_id]
                eval "*surfaceaddpoint $surf_id $loc_temp"
                # 点距离判断 ------------------------------------------------------------
                if {[v_abs [v_sub $point_loc_1 $loc_temp]] < 0.1} { set is_point_del 0 }
            }
            # 尝试压掉 point_id
            if {$is_point_del == 1} { *createmark points 1 $point_id; *verticesmarksuppress 1 180 0; }
        }

        # ----------------
        # 分割外圆孔(边界)
        set line_circle_datas [surf_split_by_nodes_try_with_innernodes_tocirlce $surf_id [dict get $node_ids_dic $edge_offset] $cirlce_line_point_num [dict get $node_ids_dic 0]]
        # puts "line_circle_datas : $line_circle_datas"
        
        # ----------------
        # 获取新创建的面 , 仅适用于当前画法
        # # 内外圆孔间的分割面
        set new_surf_ids [lindex [lindex $line_circle_datas end] 0]
        # puts "base_surf_id : $surf_id \nnew_surf_ids : $new_surf_ids"



        # ----------------------------------------------
        # ----------------------------------------------
        # ----------------网格划分
        *startnotehistorystate {mesh hole elements}
            hm_createmark surfs 1 $new_surf_ids
            set new_surf_ids_len [llength $new_surf_ids]
            *interactiveremeshsurf 1 $elem_size 1 1 2 1 1
            for { set i 0 } { $i < $new_surf_ids_len } { incr i 1 } {
                *set_meshfaceparams $i 5 1 0 0 1 0.5 1 1
                *automesh $i 2 1
            }
            *storemeshtodatabase 1
        *endnotehistorystate {mesh hole elements}

    }
}


