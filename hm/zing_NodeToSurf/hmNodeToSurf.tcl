
# set tolerance 0.3

# *createmarkpanel nodes 1 "select nodes"
# *createmarkpanel surfs 1 "select surfaces"
# foreach surf_id [hm_getmark surfs 1] {
#     catch {
#         *nodesassociatetogeometry 1 surfs $surf_id $tolerance
#     }
#     *createmark nodes 2 "by surface" $surf_id
#     *markdifference nodes 1 nodes 2
# }



# set tolerance 0.3
# *createmarkpanel nodes 1 "select nodes"
# *createmarkpanel lines 1 "select lines"
# foreach surf_id [hm_getmark lines 1] {
#     catch {
#         *nodesassociatetogeometry 1 lines $surf_id $tolerance
#     }
#     *createmark nodes 2 "by surface" $surf_id
#     *markdifference nodes 1 nodes 2
# }


namespace eval ::NodeToSurf {
    variable tolerance
    variable fem_path
    variable py_path
    variable file_dir [file dirname [info script]]
}


set ::NodeToSurf::fem_path [format "%s/__temp.fem" $::NodeToSurf::file_dir]
set ::NodeToSurf::py_path   [format "%s/hmNodeToSurf.py" $::NodeToSurf::file_dir]



# 导出指定单元数据到fem
proc print_elem_node_to_fem {fem_path elem_ids} {
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

# 矢量 - abs
proc v_abs {loc} {
    set x [lindex $loc 0]
    set y [lindex $loc 1]
    set z [lindex $loc 2]
    set value [expr ($x**2+$y**2+$z**2)**0.5]
    return $value
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

# 点到两点距离
proc dis_point_to_two_point {line_p1_loc line_p2_loc p3_loc} {
    set p4_loc [vertical_point $line_p1_loc $line_p2_loc $p3_loc]
    set v [v_sub $p3_loc $p4_loc]
    set dis [v_abs $v]
    return $dis
}


proc get_node_locs {node_id} {
    set x [hm_getvalue nodes id=$node_id dataname=x]
    set y [hm_getvalue nodes id=$node_id dataname=y]
    set z [hm_getvalue nodes id=$node_id dataname=z]
    return "$x $y $z"
}

# 根据suface获取line ID
proc get_line_from_surface {surf_id} {
    *createmark lines 1 "by surface" $surf_id
    set line_ids [hm_getmark lines 1]
    return $line_ids
}

# 根据line获取point ID
proc get_point_from_line {line_id} {
    *createmark points 1 "by lines" $line_id
    set point_ids [hm_getmark points 1]
    return $point_ids
}

# 根据line获取端点point坐标
proc get_point_loc2_fromt_line {line_id} {
    set two_locs [hm_getcoordinatesofpointsonline $line_id [list 0.0 1.0]]
    return $two_locs
}

# 根据多个surf获取 各line端点坐标
proc get_surfs_line_locs {surf_ids} {
    set line_id_to_loc2 []
    set line_full_ids []
    foreach surf_id $surf_ids {
        set line_ids [get_line_from_surface $surf_id]
        foreach line_id $line_ids {
            set line_loc_2s [get_point_loc2_fromt_line $line_id]
            if {[llength $line_loc_2s] !=2 } {continue;}
            dict set line_id_to_loc2 $line_id "$line_loc_2s"
            lappend line_full_ids $line_id
        }
    }
    return "{$line_full_ids} {$line_id_to_loc2}"
}

# 交互获取surf id
proc panel_get_surface {} {
    *createmarkpanel surfs 1 
    return [hm_getmark surfs 1]
}

# 交互获取elem id
proc panel_get_elem {} {
    *createmarkpanel elems 1
    return [hm_getmark elems 1]
}


# -------------------------------
proc ::NodeToSurf::print_get_elem_edge_node {elem_ids} {

    set py_path   $::NodeToSurf::py_path
    set fem_path  $::NodeToSurf::fem_path
    puts "py_path: $py_path"
    eval "*createmark elems 1 $elem_ids"
    # 创建edge
    *findedges1 elems 1 0 0 0 30

    # *createmark nodes 1 "by comp" "^edges"
    # set node_ids [hm_getmark nodes 1]

    *createmark comps 1 "^edges"
    set edge_comp_id [hm_getmark comps 1]
    *setvalue comps id=$edge_comp_id name="__edges"
    *createmark elems 1 "by comp" "__edges"
    set elem_output_ids [hm_getmark elems 1]
    print_elem_node_to_fem $fem_path $elem_output_ids
    
    set node_ids [exec python $py_path]

    *createmark comps 1 "__edges"
    *deletemark comps 1
    return $node_ids
}

# 点到各line的距离判断
proc ::NodeToSurf::get_node_to_lines {line_full_ids line_id_to_loc2 loc_b tolerance} {
    foreach line_id $line_full_ids {
        # puts "line_id: $line_id"
        set loc_2s [dict get $line_id_to_loc2 $line_id]
        # puts "loc_2s: $loc_2s"
        set loc_1 [lindex $loc_2s 0]
        set loc_2 [lindex $loc_2s 1]

        if {[v_abs [v_sub $loc_1 $loc_2]]==0} {continue}
        # puts "loc_1: $loc_1 ;loc_2: $loc_2"
        set dis [dis_point_to_two_point $loc_1 $loc_2 $loc_b]
        # puts "dis: $dis"
        if {$dis < $tolerance} {
            return $line_id
        }
    }
    return 0
}


proc ::NodeToSurf::main_single {surf_id elem_ids tolerance} {

    if {[llength $surf_id] != 1} {
        tk_messageBox -message "警告surf 能选一个!!\n请重选!!!" -icon warning
        return;
    }

    set surf_loc_data [get_surfs_line_locs $surf_id]
    set line_full_ids [lindex $surf_loc_data 0]
    set line_id_to_loc2 [lindex $surf_loc_data 1]

    set node_ids [::NodeToSurf::print_get_elem_edge_node $elem_ids]

    set line_to_nodes []
    set target_lines []
    foreach node_id $node_ids {
        set loc_b [get_node_locs $node_id]
        set line_id [::NodeToSurf::get_node_to_lines $line_full_ids $line_id_to_loc2 $loc_b $tolerance]
        
        if {$line_id == 0} {
            continue
        } else {
            if {$line_id in $target_lines} {
                set temp_ids [dict get $line_to_nodes $line_id]
                lappend temp_ids $node_id
                dict set line_to_nodes $line_id "$temp_ids"  
            } else {
                lappend target_lines $line_id
                dict set line_to_nodes $line_id "$node_id"
            }
        }
    }

    # node 关联到面
    hm_createmark nodes 1 "by elem" $elem_ids
    *nodesassociatetogeometry 1 surfs $surf_id $tolerance

    # node 关联到线
    foreach line_id $target_lines {
        set node_ids [dict get $line_to_nodes $line_id]
        eval "*createmark nodes 1 $node_ids"
        *nodesassociatetogeometry 1 lines $line_id $tolerance
    }
}



set ::NodeToSurf::tolerance 0.5
set tolerance $::NodeToSurf::tolerance
set surf_id [panel_get_surface ]
set elem_ids [panel_get_elem]

::NodeToSurf::main_single $surf_id $elem_ids $tolerance


