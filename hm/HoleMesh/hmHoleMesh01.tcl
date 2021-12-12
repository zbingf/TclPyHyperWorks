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
        # puts "warning: acos(value) , value: $value"
        set value 1 
    }
    if { $value < -1 } { 
        # puts "warning: acos(value) , value: $value"
        set value -1 
    }
    set rad [expr acos($value)]
    set surf_v [v_multi_x $base_v_loc $target_v_loc]
    set angle [expr $rad*180/3.141592654]
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


# =================================
# 获取node 对应坐标
proc get_node_locs {node_id} {
    set x [hm_getvalue nodes id=$node_id dataname=x]
    set y [hm_getvalue nodes id=$node_id dataname=y]
    set z [hm_getvalue nodes id=$node_id dataname=z]
    return "$x $y $z"
}


# 创建圆心node by point
proc create_circle_center_node_by_point {point_circle_ids} {
    
    # 中心点创建
    *clearmark nodes 1

    eval "*createmark points 1 $point_circle_ids"
    *createbestcirclecenternode points 1 0 1 0

    *createmarklast nodes 1
    set node_circle_center_id [hm_getmark nodes 1]
    # puts "node_circle_center_id: $node_circle_center_id"
    return $node_circle_center_id
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


# 根据线id获取圆心数据
proc line_to_circle_center {line_id} {

    set node_circle_center_id [create_circle_center_node_by_line $line_id]
    set circle_center_loc [get_node_locs $node_circle_center_id]

    set point_locs [hm_getcoordinatesofpointsonline $line_id [list 0.0 0.5]]
    # set loc1 [hm_getcoordinates point [lindex $point_circle_ids 0]]
    set loc1 [lindex $point_locs 0]

    set r_circle [dis_point_to_point_loc $loc1 $circle_center_loc]
    # puts "$node_circle_center_id {$circle_center_loc} $r_circle"
    return "$node_circle_center_id {$circle_center_loc} $r_circle"
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


proc get_end_line_id_by_surf {surf_id} {
    *createmark lines 1 "by surface" $surf_id
    set line_ids [lsort -integer [hm_getmark lines 1]]
    # puts "get_end_line_id_by_surf : surf_id $surf_id line_ids:$line_ids"
    return [lindex $line_ids end]
}


# 根据圆孔创建node点
proc create_circle_node_by_line {line_circle_id line_base_id dis_offsets node_nums} {
    # line_circle_id 线对应的ID
    # line_base_id   基础轴线的ID

    # 根据线获取面
    *createmark surfs 1 "by lines" $line_circle_id
    set surf_id [hm_getmark surfs 1]

    set line_base_2_locs [hm_getcoordinatesofpointsonline $line_base_id [list 0.0 0.1]]
    set line_base_v [v_sub [lindex $line_base_2_locs 0] [lindex $line_base_2_locs 1]]

    # 根据线获取圆
    set circle_data [line_to_circle_center $line_circle_id]
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
        set dis_offset [lindex $dis_offsets $num]
        set node_num   [lindex $node_nums $num]

        set dis [expr $R_circle+$dis_offset]
        if {$node_num==4} {
            set node_ids [create_circle_node_4_with_v $new_v $new_u $circle_center_loc $dis]    
        } elseif {$node_num==6} {
            set node_ids [create_circle_node_6_with_v $new_v $new_u $circle_center_loc $dis]
        } elseif {$node_num==8} {
            set node_ids [create_circle_node_8_with_v $new_v $new_u $circle_center_loc $dis]
        }
        dict set node_ids_dic $dis_offset "$node_ids"

    }
    dict set node_ids_dic "circle" "$circle_node_id"
    return $node_ids_dic
}


# 
proc create_circle_node_4_with_v {new_v new_u circle_center_loc dis} {

    # 顺序连线
    set v_1 [v_multi_c [v_one [v_add $new_v $new_u]] $dis]
    set v_2 [v_multi_c [v_one [v_sub $new_v $new_u]] $dis]
    set v_3 [v_multi_c $v_1 -1]
    set v_4 [v_multi_c $v_2 -1]
    
    set node_ids []

    foreach v_cur "{$v_1} {$v_2} {$v_3} {$v_4}" {
        *clearmark nodes 1
        set node_loc1 [v_add $v_cur $circle_center_loc]
        eval "*createnode $node_loc1 0 0 0"
        *createmarklast nodes 1
        lappend node_ids [hm_getmark nodes 1]

    }
    return $node_ids
}


# 
proc create_circle_node_6_with_v {new_v new_u circle_center_loc dis} {

    set circle_v [v_one [v_multi_x $new_v $new_u]]
    set new_u [v_one $new_u]
    set node_ids []
    foreach num "0 1 2 3 4 5" {
        set loc1 [v_rotate_point $circle_v $new_u [expr double($num)*60.0/180.0*3.141592654]]
        set loc1 [v_multi_c $loc1 $dis]
        puts "num:$num ; loc1:$loc1"
        *clearmark nodes 1
        set node_loc1 [v_add $loc1 $circle_center_loc]
        eval "*createnode $node_loc1 0 0 0"
        *createmarklast nodes 1
        lappend node_ids [hm_getmark nodes 1]
    }
    return $node_ids
}


# 
proc create_circle_node_8_with_v {new_v new_u circle_center_loc dis} {

    # 顺序连线
    set v_1 [v_multi_c [v_one [v_add $new_v $new_u]] $dis]
    set v_2 [v_multi_c [v_one $new_v] $dis]
    set v_3 [v_multi_c [v_one [v_sub $new_v $new_u]] $dis]
    set v_4 [v_multi_c [v_one $new_u] [expr -1*$dis]]
    set v_5 [v_multi_c $v_1 -1]
    set v_6 [v_multi_c $v_2 -1]
    set v_7 [v_multi_c $v_3 -1]
    set v_8 [v_multi_c [v_one $new_u] $dis]
    set node_ids []
    foreach v_cur "{$v_1} {$v_2} {$v_3} {$v_4} {$v_5} {$v_6} {$v_7} {$v_8}" {
        *clearmark nodes 1
        set node_loc1 [v_add $v_cur $circle_center_loc]
        eval "*createnode $node_loc1 0 0 0"
        *createmarklast nodes 1
        lappend node_ids [hm_getmark nodes 1]

    }
    return $node_ids
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
        set line_data [func_surfacesplitwithcoords $surf_id $loc1 $loc2]
        lappend line_datas $line_data
        if {$insert_point_num!=0} {
            *createmark lines 1 [lindex $line_data 2]
            *edgesmarkaddpoints 1 $insert_point_num    
        }
    }
    set loc1 [get_node_locs [lindex $node_ids 0]]
    set loc2 [get_node_locs [lindex $node_ids end]]
    set line_data [func_surfacesplitwithcoords $surf_id $loc1 $loc2]
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
        set line_data [func_surfacesplitwithcoords $surf_id $loc1 $loc2]
        lappend line_datas $line_data
        if {$insert_point_num!=0} {
            *createmark lines 1 [lindex $line_data 2]
            *edgesmarkaddpoints 1 $insert_point_num    
        }
    }
    return $line_datas
}



# 连点坐标分割面
proc func_surfacesplitwithcoords {surf_id loc1 loc2} {
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

        set angle [lindex [angle_2vector $line_v $line_v_2] 1]
        set dis_del_percent [ expr abs(([v_abs $line_v]-[v_abs $line_v_2])/[v_abs $line_v]) ]
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



# namespace eval ::HoleMeshControlParam {
#     variable circle_offset
#     variable square_offset
#     variable node_num
#     variable elem_size
# }


# 主函数
proc main_hole_mesh_2circle_by_two_line {line_base_id line_circle_ids control_params} {

    set square_num    [dict get $control_params square_num]
    set circle_in_num    [dict get $control_params circle_in_num]
    set circle_out_num    [dict get $control_params circle_out_num]
    set circle_offset [dict get $control_params circle_offset]
    set square_offset [dict get $control_params square_offset]
    set elem_size     [dict get $control_params elem_size]
    set square_line_point_num [dict get $control_params square_line_point_num]
    set cirlce_line_point_num [dict get $control_params cirlce_line_point_num]

    foreach line_circle_id $line_circle_ids {
        set circle_data [get_circle_data_by_line $line_circle_id]
        # puts "circle_data : $circle_data"

        # -----------------------
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

        # 创建node 点    
        set node_ids_dic [create_circle_node_by_line $line_circle_id $line_base_id "0 $circle_offset $square_offset" "$circle_in_num $circle_out_num $square_num"]
        # puts "node_ids_dic : $node_ids_dic"

        # -----------------------
        # ----------------线段划分
        # 圆孔
        if {$circle_in_num == $circle_out_num} {
            # 划分线, 有顺序之分
            set line_1_datas [surf_split_by_two_nodes $surf_id [dict get $node_ids_dic 0] [dict get $node_ids_dic $circle_offset] 0]
            # puts "line_1_datas : $line_1_datas"
        }
        set point_loc_1 [hm_getcoordinates point $point_id]
        set is_point_del 1
        foreach node_id [dict get $node_ids_dic 0] {
            set loc_temp [get_node_locs $node_id]
            eval "*surfaceaddpoint $surf_id $loc_temp"
            if {[v_abs [v_sub $point_loc_1 $loc_temp]] < 0.1} {
                set is_point_del 0
            }
        }
        if {$is_point_del == 1} {
            # 尝试压掉 point_id
            *createmark points 1 $point_id
            *verticesmarksuppress 1 180 0    
        }
        

        set line_circle_datas [surf_split_by_nodes $surf_id [dict get $node_ids_dic $circle_offset] $cirlce_line_point_num]
        # puts "line_circle_datas : $line_circle_datas"

        set line_square_datas [surf_split_by_nodes $surf_id [dict get $node_ids_dic $square_offset] $square_line_point_num]
        # puts "line_square_datas : $line_square_datas"

        # 获取新创建的面 , 仅适用于当前画法
        set new_surf_ids []
        foreach line_circle_datas $line_circle_datas {
            lappend new_surf_ids [lindex $line_circle_datas 0]
        }
        lappend new_surf_ids [lindex [lindex $line_square_datas end] 0]
        set surf_temp_ids []
        foreach new_surf_id $new_surf_ids {
            # puts "new_surf_id : $new_surf_id"
            if {$new_surf_id!=""} {
                lappend surf_temp_ids $new_surf_id
            }
        }
        set new_surf_ids $surf_temp_ids
        puts "base_surf_id : $surf_id \nnew_surf_ids : $new_surf_ids"

        # -----------------------
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


proc main_test {} {
    dict set control_params circle_offset 5
    dict set control_params square_offset 16
    dict set control_params elem_size 10

    # type 1
    dict set control_params circle_in_num 8
    dict set control_params circle_out_num 8
    dict set control_params square_num 4
    dict set control_params cirlce_line_point_num 0
    dict set control_params square_line_point_num 3

    # # type 2
    # dict set control_params circle_in_num 8
    # dict set control_params circle_out_num 4
    # dict set control_params square_num 4
    # dict set control_params cirlce_line_point_num 1
    # dict set control_params square_line_point_num 3



    # -----------------------------------
    puts "---start---"
    *nodecleartempmark

    *createmarkpanel lines 1 "base_line_select"
    set line_base_id [hm_getmark lines 1]

    # 目标线 ID  - 必须为圆
    *createmarkpanel lines 1 "circle_line_select"
    set line_circle_ids [hm_getmark lines 1]

    main_hole_mesh_2circle_by_two_line $line_base_id $line_circle_ids $control_params

    # *surfaceaddpoint 13 807.272413 201.135743 52.5

    *clearmarkall 1
    *clearmarkall 2
    puts "---end---"
}
