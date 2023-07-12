# 对rigid进行操作，将单圈washer改为双圈washer
# 2023/02/22
# version 1.0
# zbingf

namespace eval ::BoltHoleDoubleWasher {
    variable recess
}

# 初始化
set ::BoltHoleDoubleWasher::elem_ids []


proc list_remove {node_ids independent_id} {

    set dependent_ids ""
    foreach node_id $node_ids {
        if {$independent_id == $node_id} {
            continue
        }
        lappend dependent_ids $node_id
    }

    return $dependent_ids
}


# -----------------------------
# GUI
proc ::BoltHoleDoubleWasher::GUI { args } {
    variable recess;

    set minx [winfo pixel . 180p];
    set miny [winfo pixel . 100p];
    if {![OnPc]} {set miny [winfo pixel . 240p];}
    set graphArea [hm_getgraphicsarea];
    set x [lindex $graphArea 0];
    set y [lindex $graphArea 1];
    
    # 主窗口
    ::hwt::CreateWindow boltHoleDoubleWasher \
        -windowtitle "BoltHoleDoubleWasher" \
        -cancelButton "Cancel" \
        -cancelFunc ::BoltHoleDoubleWasher::Quit \
        -addButton OK ::BoltHoleDoubleWasher::OkExit no_icon \
        -resizeable 1 1 \
        -propagate 1 \
        -minsize $minx $miny \
        -geometry ${minx}x${miny}+${x}+${y} \
         noGeometrySaving;
    ::hwt::KeepOnTop .boltHoleDoubleWasher;

    set recess [::hwt::WindowRecess boltHoleDoubleWasher];

    grid columnconfigure $recess 1 -weight 1;
    grid rowconfigure    $recess 10 -weight 1;


    # ===================
    label $recess.baseLabel -text "选择目标 Rigid (壳单元不隐藏)";
    grid $recess.baseLabel -row 6 -column 0 -padx 2 -pady 2 -sticky nw;

    button $recess.baseButton \
        -text "Elems" \
        -command ::BoltHoleDoubleWasher::fun_baseButton \
        -width 16;
    grid $recess.baseButton -row 7 -column 0 -padx 2 -pady 2 -sticky nw;


    ::hwt::RemoveDefaultButtonBinding $recess;
    ::hwt::PostWindow boltHoleDoubleWasher -onDeleteWindow ::BoltHoleDoubleWasher::Quit;
}


# -----------------------------
# 主程序
proc ::BoltHoleDoubleWasher::OkExit { args } {
    
    set choice [tk_messageBox -type yesnocancel -default yes -message "是否计算" -icon question ]
    if {$choice != yes} {return;}

    # -------------------------------
    set elem_ids        $::BoltHoleDoubleWasher::elem_ids
    # -------------------------------

    foreach elem_id $elem_ids {

        set independent_id [hm_getvalue elems id=$elem_id dataname=node1]
        # puts "$independent_id"
        set node_ids [hm_getvalue elems id=$elem_id dataname=nodes]
        # puts "$node_ids"
        set dependent_ids [list_remove $node_ids $independent_id]
        # puts "$dependent_ids"

        set target_node_ids ""
        foreach dependent_id $dependent_ids {
            *createmark elems 1 "by node id" $dependent_id
            set n_elem_ids [hm_getmark elems 1]
            set n_elem_ids [list_remove $n_elem_ids $elem_id]
            foreach n_elem_id $n_elem_ids {
                *createmark nodes 1 "by elem" $n_elem_id
                set target_node_ids [concat $target_node_ids [hm_getmark node 1]] 
            }
        }
        # puts "target_node_ids: $target_node_ids"
        hm_createmark nodes 1 $target_node_ids
        *rigidlinkupdate $elem_id $independent_id 1
    }

    puts "-----End-----"
    *clearmarkall 1
    *clearmarkall 2
    tk_messageBox -message "计算结束!!!" 
}

proc ::BoltHoleDoubleWasher::Quit { args } {
    *clearmarkall 1
    *clearmarkall 2
    ::hwt::UnpostWindow boltHoleDoubleWasher;
}

proc ::BoltHoleDoubleWasher::fun_baseButton { args } {
    *createmarkpanel elems 1 "Select the rigids"
    set ::BoltHoleDoubleWasher::elem_ids [hm_getmark elems 1]
}

::BoltHoleDoubleWasher::GUI