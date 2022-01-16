package provide SubHm 1.0
package require SubGeometry 1.0


# =================================
# =================================
# =================================
# 获取

# 根据面板获取单个Line
proc get_single_line_by_panel {} {
    *createmarkpanel lines 1
    set line_id [hm_getmark lines 1]
    if {[llength $line_id]!=1} {
        error "get_single_line_by_panel "
    }
    return $line_id
}


# 获取node的坐标
proc get_loc_by_node {node_id} {
    set x [hm_getvalue nodes id=$node_id dataname=x]
    set y [hm_getvalue nodes id=$node_id dataname=y]
    set z [hm_getvalue nodes id=$node_id dataname=z]
    return "$x $y $z"
}


# 获取point的坐标
proc get_loc_by_point {point_id} {
    set loc1 [hm_getcoordinates point $point_id]
    return $loc1
}


# 获取两个node点的矢量 , 1指向2
proc get_v_by_nodes {node_1_id node_2_id} {
    return [v_sub [get_loc_by_node $node_2_id] [get_loc_by_node $node_1_id]]
}

# 获取两个node点的矢量 , 1指向2
proc get_v_by_points {point_1_id point_2_id} {
    return [v_sub [get_loc_by_point $point_2_id] [get_loc_by_point $point_1_id]]
}


# 获取vector的矢量
proc get_v_by_vector {vector_id} {
    set x [hm_getvalue vectors id=$vector_id dataname=xcomp]
    set y [hm_getvalue vectors id=$vector_id dataname=ycomp]
    set z [hm_getvalue vectors id=$vector_id dataname=zcomp]    
    return "$x $y $z"
}


# 获取line的矢量
proc get_v_by_line {line_id} {
    set point_locs [hm_getcoordinatesofpointsonline $line_id [list 0.0 1]]
    return [v_sub [lindex $point_locs 1] [lindex $point_locs 0]]
}


# 获取line的矢量, 比例
proc get_v_by_line_ratio {line_id ratio} {
    set point_locs [hm_getcoordinatesofpointsonline $line_id [list 0.0 $ratio]]
    return [v_sub [lindex $point_locs 1] [lindex $point_locs 0]]
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


# 获取 solid 面积
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


# 点到点距离及矢量 - id输入
proc get_point_to_point_by_nodes {point_a_id point_b_id} {
    set point_a_loc [get_loc_by_point $point_a_id]
    set point_b_loc [get_loc_by_point $point_b_id]
    return [dis_point_to_point_loc $point_a_loc $point_b_loc]
}


# 根据两点point获取dis和
proc get_dis_and_v_by_points {point_a_id point_b_id} {
    set point_a_loc [get_loc_by_point $point_a_id]
    set point_b_loc [get_loc_by_point $point_b_id]
    return "{[dis_point_to_point_loc $point_a_loc $point_b_loc]} {[v_sub $point_b_loc $point_a_loc]}"
}


# 根据两点node获取dis和
proc get_dis_and_v_by_nodes {node_a_id node_b_id} {
    set point_a_loc [get_loc_by_node $node_a_id]
    set point_b_loc [get_loc_by_node $node_b_id]
    return "{[dis_point_to_point_loc $point_a_loc $point_b_loc]} {[v_sub $point_b_loc $point_a_loc]}"
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


# 两个solid的面积差
proc get_solid_area_delta {solid_id1 solid_id2} {
    set area1 [get_solid_area $solid_id1] 
    set area2 [get_solid_area $solid_id2]
    set delta [expr abs($area1-$area2)]
    return $delta
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
        set loc1 [get_loc_by_node $node_id]
        set x_sum [expr $x_sum + [lindex $loc1 0]]
        set y_sum [expr $y_sum + [lindex $loc1 1]]
        set z_sum [expr $z_sum + [lindex $loc1 2]]
    }
    return "[expr double($x_sum) / double($n_len)] [expr double($y_sum) / double($n_len)] [expr double($z_sum) / double($n_len)]"
}



# =================================
# =================================
# =================================
# 创建

proc add_point_to_surf_by_loc {surf_id one_loc} {
    hm_entityrecorder points on
        eval "*surfaceaddpoint $surf_id $one_loc"
    hm_entityrecorder points off
    set point_id [hm_entityrecorder points ids]
    return $point_id
}



# 根据两点node_id创建线line
proc create_line_by_node {node_id1 node_id2} {
    hm_entityrecorder lines on
        *createlist nodes 1 $node_id1 $node_id2
        *linecreatefromnodes 1 0 0 0 0
    hm_entityrecorder lines off
    set line_id [hm_entityrecorder lines ids]
    return $line_id
}


# 根据矢量创建node点, 根据起始角, 终点角, node点数进行控制
proc create_circle_nodes_with_vector_start_end {new_v new_u circle_center_loc dis node_num start_angle end_angle} {
    
    # 法向Z ; v:X ; u:Y
    set circle_v [v_one [v_multi_x $new_v $new_u]]
    set new_u [v_one $new_u]
    # set node_ids []
    
    set start_rad [angle2rad $start_angle]
    set end_rad   [angle2rad $end_angle]
    # puts "start_rad: $start_rad"
    
    if {$node_num==1} {
        set rad_single [expr (double($end_rad - $start_rad)) / (double($node_num))]
    } else {
        set rad_single [expr (double($end_rad - $start_rad)) / (double($node_num)-1)]        
    }

    # puts "rad_single: $rad_single"
    hm_entityrecorder nodes on
    for { set i 0 } { $i < $node_num } { incr i 1 } {
        set cur_rad [expr $start_rad + double($i)*$rad_single]
        if {$cur_rad > [expr $end_rad + $rad_single*0.1]} {break}

        set loc1 [v_rotate_point $circle_v $new_u $cur_rad]
        set loc1 [v_multi_c $loc1 $dis]
        # *clearmark nodes 1
        set node_loc1 [v_add $loc1 $circle_center_loc]
        set node_loc1 [v_add $loc1 $circle_center_loc]
        eval "*createnode $node_loc1 0 0 0"
        # *createmarklast nodes 1
        # lappend node_ids [hm_getmark nodes 1]   
        # if {$node_num == 1} { break }
    }
    hm_entityrecorder nodes off
    set node_ids [hm_entityrecorder nodes ids]
    return $node_ids   
    # create_circle_nodes_with_vector_start_end "0 0 1" "0 1 0" "0 0 0" 10 3 20 50
}


# 根据矢量创建node点, 默认环绕圆 create_circle_node_with_vector
proc create_circle_nodes_with_vector {new_v new_u circle_center_loc dis node_num start_angle} {
    # start_angle 起始角 0 deg为Y轴指向

    # 法向Z ; v:X ; u:Y
    set circle_v [v_one [v_multi_x $new_v $new_u]]
    set new_u [v_one $new_u]
    # set node_ids []

    set start_rad [rad2angle $start_angle]
    hm_entityrecorder nodes on
    for { set i 0 } { $i < $node_num } { incr i 1 } {

        set loc1 [v_rotate_point $circle_v $new_u [expr $start_rad + double($i)*2.0*3.141592654 / double($node_num)]]
        set loc1 [v_multi_c $loc1 $dis]
        # *clearmark nodes 1
        set node_loc1 [v_add $loc1 $circle_center_loc]
        set node_loc1 [v_add $loc1 $circle_center_loc]
        eval "*createnode $node_loc1 0 0 0"
        # *createmarklast nodes 1
        # lappend node_ids [hm_getmark nodes 1]   
    }
    hm_entityrecorder nodes off
    set node_ids [hm_entityrecorder nodes ids]
    return $node_ids   
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


# 根据线id, 创建圆心, 获取圆心数据
proc create_circle_center_node_data_by_line {line_id} {

    set node_circle_center_id [create_circle_center_node_by_line $line_id]
    set circle_center_loc [get_loc_by_node $node_circle_center_id]

    set point_locs [hm_getcoordinatesofpointsonline $line_id [list 0.0 0.5]]
    # set loc1 [hm_getcoordinates point [lindex $point_circle_ids 0]]
    set loc1 [lindex $point_locs 0]

    set r_circle [dis_point_to_point_loc $loc1 $circle_center_loc]
    # puts "$node_circle_center_id {$circle_center_loc} $r_circle"
    return "$node_circle_center_id {$circle_center_loc} $r_circle"
}


# 根据圆孔创建环绕圆孔,多层node点
proc create_circle_node_by_circle_line {line_circle_id line_base_2_locs dis_offsets node_nums start_angles} {
    # line_circle_id 线对应的ID
    # line_base_id   基础轴线的ID 对应坐标 line_base_2_locs 2点坐标
    # dis_offsets  圆环偏置距离 "0 2 5"
    # node_nums    单环点数 "8 8 4"
    # 

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

    set surf_normal_2_data [hm_getsurfacenormal points $point_circle_1_id ]
    if {[lindex $surf_normal_2_data 0] != 1} {return 0}
    if {[lindex $surf_normal_2_data 4] != $surf_id} {return 0}

    # 面法向量
    set surf_v [lrange $surf_normal_2_data 1 3]
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
        set node_ids [create_circle_nodes_with_vector $new_v $new_u $circle_center_loc $dis $node_num $start_angle]

        dict set node_ids_dic $dis_offset "$node_ids"

    }
    dict set node_ids_dic "circle" "$circle_node_id"
    return $node_ids_dic
}



# ====================================
# 根据line坐标分割面
proc split_surf_with_line {surf_id line_id} {
    set tolerance_dis 0.1

    if {[llength $surf_id]>1} {
        puts "error split_surf_with_line len(surf_id)>1, surf_id: $surf_id"
        return 0
    }

    set surf_v [lrange [hm_getsurfacenormalatcoordinate $surf_id 0 0 0] 0 2]

    set status [catch {
        eval "*createmark surfaces 1 $surf_id"
        eval "*createmark lines 1 $line_id"
        eval "*createvector 1 $surf_v"

        # 分割
        hm_entityrecorder lines on
        hm_entityrecorder surfs on
        hm_entityrecorder points on
            *surfacemarksplitwithlines 1 1 0 13 0
        hm_entityrecorder lines off
        hm_entityrecorder surfs off
        hm_entityrecorder points off

        set surf_ids [hm_entityrecorder surfs ids]
        set line_ids [hm_entityrecorder lines ids]
        set point_ids [hm_entityrecorder points ids]
    } res]
    if {$status} { return 0 }

    return "{$surf_ids} {$line_ids} {$point_ids}"
}


# proc split_surf_with_circle_line_offset {surf_id line_id} {
#     *createmark lines 1 $line_id

#     hm_entityrecorder points on
#         *trim_by_offset_edges 0 $surf_id $line_id 0 0 0
#     hm_entityrecorder points off

# }


# ====================================
# ====================================


# 平移 solid 点到点
proc move_solid_point_to_point {solid_ids point_a_id point_b_id} {
    set dis_and_v [get_dis_and_v_by_points $point_a_id $point_b_id]
    set dis_point [lindex $dis_and_v 0]
    set v_point   [lindex $dis_and_v 1]
    eval "*createvector 1 $v_point"
    eval "*createmark solids 1 $solid_ids"
    *translatemark solids 1 1 $dis_point
}


# 平移 elem 点到点
proc move_elem_point_to_point {elem_ids point_a_id point_b_id} {
    set dis_and_v [get_dis_and_v_by_points $point_a_id $point_b_id]
    set dis_point [lindex $dis_and_v 0]
    set v_point   [lindex $dis_and_v 1]
    eval "*createvector 1 $v_point"
    eval "*createmark elems 1 $elem_ids"
    *translatemark elems 1 1 $dis_point
    return 1
}


# 移动entity
proc move_entity_by_2p {entity_type entity_ids loc1 loc2} {
    set dis_point [dis_point_to_point_loc $loc1 $loc2]
    set v_point   [v_sub $loc2 $loc1]
    eval "*createvector 1 $v_point"
    eval "*createmark $entity_type 1 $entity_ids"
    eval "*translatemark $entity_type 1 1 $dis_point"
}


# 根据point或node对entity进行平移
proc move_entity_by_pid {entity_type entity_ids point_type point_a_id point_b_id} {
    if {$point_type=="point" | $point_type=="points"} {
        set loc1 [get_loc_by_point $point_a_id]
        set loc2 [get_loc_by_point $point_b_id]    
    } else {
        set loc1 [get_loc_by_node  $point_a_id]
        set loc2 [get_loc_by_node  $point_b_id]
    }
    return [move_entity_by_2p $entity_type $entity_ids $loc1 $loc2]
}


# 旋转entity - 单点&矢量轴
proc rotate_entity_by_1p_1v {entity_type entity_ids angle center_loc surf_v} {
    # entity_type 旋转类型
    # entity_ids  id
    # angle旋转角
    # surf_v 法向矢量
    # center_loc 参考点
    eval "*createplane 1 $surf_v $center_loc"
    eval "*createmark $entity_type 1 $entity_ids"
    if {$angle==0} {return 0}
    eval "*rotatemark $entity_type 1 1 $angle"
    return 1
}



# 旋转entity -通过3点
proc rotate_entity_by_3p {entity_type entity_ids center_loc point_1_loc point_2_loc} {
    set v_1 [v_sub $point_1_loc $center_loc]
    set v_2 [v_sub $point_2_loc $center_loc]
    set v_and_angle [angle_of_2v $v_1 $v_2]
    set surf_v [lindex $v_and_angle 0]
    set angle [lindex $v_and_angle 1]
    if {$angle==0} {return "None"}
    rotate_entity_by_1p_1v $entity_type $entity_ids $angle $center_loc $surf_v
}


# ====================================
# 压掉line所在闭环孔的point, 并重新定义起始point位置
proc suppress_circle_point_by_line_loc_newpoint {line_circle_id one_loc} {
        set tolerance_dis 0.1

        *createmark surfs 1 "by lines" $line_circle_id
        set surf_id [hm_getmark surfs 1]

        # 获取圆孔数据
        set circle_data [get_circle_data_by_line $line_circle_id]
        # puts "circle_data : $circle_data"
        set point_ids [lindex $circle_data 1]
        if {[llength $point_ids] != 1} {
            eval "*createmark points 1 [lrange $point_ids 0 end-1]]"
            *verticesmarksuppress 1 180 0
            set point_last_id [lindex $point_ids end]
        } else {
            set point_last_id $point_ids
        }
        
        puts "point_last_id: $point_last_id"
        # if {[llength $point_last_id]!=1} {return 0}
        set point_last_loc [get_loc_by_point $point_last_id]

        if {[dis_point_to_point_loc $point_last_loc $one_loc] > $tolerance_dis} {
            set point_id [add_point_to_surf_by_loc $surf_id $one_loc]
            *createmark points 1 $point_last_id
            *verticesmarksuppress 1 180 0

        } else {
            set point_id $point_last_id
        }

        *createmark lines 1 "by points" $point_id
        set line_circle_id [hm_getmark lines 1]

        # 新的lineID和 pointID
        return "{$line_circle_id} {$point_id}"
}


# ====================================
# ====================================
# 判断

# 判定是否为目标面, 根据面上的点是否包含所有inner_node_ids点
proc logic_nodes_in_surf {surf_id inner_node_ids} {
    # 
    set node_locs []
    foreach node_id $inner_node_ids {
        set loc1 [get_loc_by_node $node_id]
        set new_loc1 [v_loc_round_num $loc1 1]
        lappend node_locs $new_loc1
    }

    set point_locs []
    *createmark points 1 "by surface" $surf_id
    foreach point_id [hm_getmark points 1] {
        set loc1 [get_loc_by_point $point_id]
        # 0.1的容差
        set new_loc1 [v_loc_round_num $loc1 1]
        lappend point_locs $new_loc1
    }

    foreach node_loc $node_locs {
        if {$node_loc in $point_locs} {
            # 
        } else {
            return 0
        }
    }
    return 1
}




# ====================================
# ====================================
# 测试
proc test_split_surf_with_line {} {
    *createmarkpanel lines 1 
    *createmarkpanel surfs 1
    puts [split_surf_with_line [hm_getmark surfs 1] [hm_getmark lines 1]]
}


proc test_suppress_circle_point_by_line_loc_newpoint {one_loc} {
    set line_id [get_single_line_by_panel]
    
    puts [suppress_circle_point_by_line_loc_newpoint $line_id $one_loc]

    # test_suppress_circle_point_by_line "0 5 0"
}


proc test_move_entity_by_pid {} {
    *createmarkpanel solids 1
    set solid_ids [hm_getmark solids 1]
    *createmarkpanel points 1
    set point_1_id [hm_getmark points 1]
    *createmarkpanel points 1
    set point_2_id [hm_getmark points 1]
    move_entity_by_pid "solids" $solid_ids "point" $point_1_id $point_2_id

}