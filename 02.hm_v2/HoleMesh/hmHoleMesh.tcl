# source "D:/github/TclPyHyperWorks/hm_v2/HoleMesh/hmHoleMesh.tcl"

# 路径定义
set script_dir [file dirname [info script]]
set p_script_dir [file dirname $script_dir]

set sub_dir $p_script_dir
if {$p_script_dir in $auto_path} {} else {
    lappend auto_path $p_script_dir   
} 

package require SubGeometry 1.0
package require SubHm 1.0


# ===================================

puts [v_abs "1 2 3"]


return ;

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


