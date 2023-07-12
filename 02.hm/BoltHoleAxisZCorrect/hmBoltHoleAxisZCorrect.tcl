
set choice [tk_messageBox -type yesnocancel -default yes -message "是否计算" -icon question ]
if {$choice != yes} {return;}


proc get_node_locs {node_id} {
    set x [hm_getvalue nodes id=$node_id dataname=x]
    set y [hm_getvalue nodes id=$node_id dataname=y]
    set z [hm_getvalue nodes id=$node_id dataname=z]
    return "$x $y $z"
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


*createmark elems 1 "by config" bar2
set bar2_ids [hm_getmark elems 1]
set bar2_parallelZ_ids []
foreach bar2_id $bar2_ids {
    set node1_id [hm_getvalue elems id=$bar2_id dataname=node1]
    set node2_id [hm_getvalue elems id=$bar2_id dataname=node2]

    set loc1 [get_node_locs $node1_id]
    set loc2 [get_node_locs $node2_id]

    set v_loc [v_sub $loc1 $loc2]
    set v_x [lindex $v_loc 0]
    set v_y [lindex $v_loc 1]
    if {[expr abs($v_x)] < 0.001} {
        if {[expr abs($v_y)] < 0.001} {
            puts "is Parallel : $v_loc"
            lappend bar2_parallelZ_ids $bar2_id
        }
    }
}


eval "*createmark elems 1 $bar2_parallelZ_ids"
if {[llength [hm_getmark elems 1]] > 0 } {
    *createvector 1 1 1 1
    *barelementupdatewithoffsets 1 1 1 1 0 0 0 0 "" 0 0 0 0 0 0 0 0 0 0 0 0 0
    tk_messageBox -message "校正结束, 计算结束!!!" 
} else {
    tk_messageBox -message "无需校正, 计算结束!!!" 
    return;
}




