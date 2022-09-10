
namespace eval ::BoltHoleConnect {
    variable recess
    
    variable new_edge_name "__edges"
    variable hole_comp_name 
    variable isDoubleCircle
    variable type_connect

    variable elem_ids
    
    variable file_dir [file dirname [info script]]
    variable fem_path
    variable py_path
}

# 初始化
set ::BoltHoleConnect::fem_path [format "%s/__temp.fem" $::BoltHoleConnect::file_dir]
set ::BoltHoleConnect::py_path   [format "%s/hmBoltHoleConnect_Shell.py" $::BoltHoleConnect::file_dir]
set ::BoltHoleConnect::elem_ids []

if {[info exists ::BoltHoleConnect::hole_comp_name]==0} {set ::BoltHoleConnect::hole_comp_name "__HoleConnect"}
if {[info exists ::BoltHoleConnect::isDoubleCircle]==0} {set ::BoltHoleConnect::isDoubleCircle 1}
if {[info exists ::BoltHoleConnect::type_connect]==0} {set ::BoltHoleConnect::type_connect 1}


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


# 创建edge并重命名,返回对应comp_id
proc create_elem_edge {elem_ids new_edge_name} {

    eval *createmark elems 1 $elem_ids
    # 创建edge
    *findedges1 elems 1 0 0 0 30
    catch {
        *createmark comps 1 $new_edge_name
        *deletemark comps 1
    }

    *createmark comps 1 "^edges"
    set edge_comp_id [hm_getmark comps 1]
    *setvalue comps id=$edge_comp_id name=$new_edge_name
    return $edge_comp_id
}


# 创建edge并重命名,返回对应comp_id
proc create_comp_edge {comp_id new_edge_name} {

    eval *createmark comps 1 $comp_id
    # 创建edge
    *findedges1 comps 1 0 0 0 30
    catch {
        *createmark comps 1 $new_edge_name
        *deletemark comps 1
    }

    *createmark comps 1 "^edges"
    set edge_comp_id [hm_getmark comps 1]
    *setvalue comps id=$edge_comp_id name=$new_edge_name
    return $edge_comp_id
}




# 根据孔周围点找对应连接单元
proc search_bar2_rbe2_from_circle_node {node_ids} {

    # 判定是否是RBE2
    proc sub_isRBE2 {elem_id} {
        set type_name [hm_getvalue elems id=$elem_id dataname=typename]
        if {$type_name == "RBE2"} {
            return 1
        } else {
            return 0
        }
    }

    # 检索 RBE2
    proc sub_search_rbe2 {elem_ids} {
        set rbe2_ids []
        foreach elem_id $elem_ids {
            if {[sub_isRBE2 $elem_id]} {
                lappend rbe2_ids $elem_id
            }
        }
        return $rbe2_ids
    }

    # 判定是否是RBE2
    proc sub_isBAR2 {elem_id} {
        set type_name [hm_getvalue elems id=$elem_id dataname=typename]
        if {$type_name in "{CBAR} {CBEAM} {CMBEAM}"} {
            return 1
        } else {
            return 0
        }
    }

    # 检索 RBE2
    proc sub_search_bar2 {elem_ids} {
        set bar2_ids []
        foreach elem_id $elem_ids {
            if {[sub_isBAR2 $elem_id]} {
                lappend bar2_ids $elem_id
            }
        }
        return $bar2_ids
    }

    *createmark elems 1 "by node" $node_ids
    set elem_ids [hm_getmark elems 1]
    set rbe2_ids [sub_search_rbe2 $elem_ids]
    eval *createmark elems 1 $rbe2_ids
    *appendmark elems 1 "by adjacent"
    set bar2_ids [sub_search_bar2 [hm_getmark elems 1]]

    eval *createmark elems 1 $bar2_ids
    *appendmark elems 1 "by adjacent"
    return [hm_getmark elems 1]
}

# -----------------------------
# GUI
proc ::BoltHoleConnect::GUI { args } {
    variable recess;

    set minx [winfo pixel . 225p];
    set miny [winfo pixel . 180p];
    if {![OnPc]} {set miny [winfo pixel . 240p];}
    set graphArea [hm_getgraphicsarea];
    set x [lindex $graphArea 0];
    set y [lindex $graphArea 1];
    
    # 主窗口
    ::hwt::CreateWindow boltHoleConnect \
        -windowtitle "BoltHoleConnect" \
        -cancelButton "Cancel" \
        -cancelFunc ::BoltHoleConnect::Quit \
        -addButton OK ::BoltHoleConnect::OkExit no_icon \
        -resizeable 1 1 \
        -propagate 1 \
        -minsize $minx $miny \
        -geometry ${minx}x${miny}+${x}+${y} \
         noGeometrySaving;
    ::hwt::KeepOnTop .boltHoleConnect;

    set recess [::hwt::WindowRecess boltHoleConnect];

    grid columnconfigure $recess 1 -weight 1;
    grid rowconfigure    $recess 10 -weight 1;

    # ===================
    ::hwt::LabeledLine $recess.end_line1 "Elem 选择";
    grid $recess.end_line1 -row 2 -column 0 -pady 6 -sticky ew -columnspan 2;


    radiobutton $recess.radio_1 -text "单层Washer"  -variable ::BoltHoleConnect::isDoubleCircle -value 1 -anchor w -font {MS 10}
    radiobutton $recess.radio_2 -text "双层Washer" -variable ::BoltHoleConnect::isDoubleCircle -value 2 -anchor w -font {MS 10}
    grid $recess.radio_1 -row 3 -column 0 -padx 2 -pady 2 -sticky nw;
    grid $recess.radio_2 -row 3 -column 1 -padx 2 -pady 2 -sticky nw;

    
    radiobutton $recess.radio_3 -text "Rb2_123456"  -variable ::BoltHoleConnect::type_connect -value 1 -anchor w -font {MS 10}
    radiobutton $recess.radio_4 -text "Bar2" -variable ::BoltHoleConnect::type_connect -value 2 -anchor w -font {MS 10}
    grid $recess.radio_3 -row 4 -column 0 -padx 2 -pady 2 -sticky nw;
    grid $recess.radio_4 -row 4 -column 1 -padx 2 -pady 2 -sticky nw;    


    # ===================
    label $recess.baseLabel -text "选择目标两个 Elems";
    grid $recess.baseLabel -row 5 -column 0 -padx 2 -pady 2 -sticky nw;

    button $recess.baseButton \
        -text "Elems" \
        -command ::BoltHoleConnect::fun_baseButton \
        -width 16;
    grid $recess.baseButton -row 6 -column 0 -padx 2 -pady 2 -sticky nw;

    # ===================
    ::hwt::LabeledLine $recess.end_line "";
    grid $recess.end_line -row 7 -column 0 -pady 6 -sticky ew -columnspan 2;

    label $recess.entryLabel3 -text "孔网格-Comp名称:";
    grid $recess.entryLabel3 -row 8 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry3 -width 16 -textvariable ::BoltHoleConnect::hole_comp_name
    grid $recess.entry3 -row 8 -column 1 -padx 2 -pady 2 -sticky nw;

    ::hwt::RemoveDefaultButtonBinding $recess;
    ::hwt::PostWindow boltHoleConnect -onDeleteWindow ::BoltHoleConnect::Quit;
}

# -----------------------------
# 主程序
proc ::BoltHoleConnect::OkExit { args } {
    
    set choice [tk_messageBox -type yesnocancel -default yes -message "是否计算" -icon question ]
    if {$choice != yes} {return;}

    # -------------------------------
    set new_edge_name   $::BoltHoleConnect::new_edge_name
    set elem_ids        $::BoltHoleConnect::elem_ids
    set fem_path        $::BoltHoleConnect::fem_path
    set py_path         $::BoltHoleConnect::py_path
    set hole_comp_name  $::BoltHoleConnect::hole_comp_name
    set isDoubleCircle  $::BoltHoleConnect::isDoubleCircle
    set type_connect    $::BoltHoleConnect::type_connect
    # -------------------------------


    catch { *createentity comps name=$::BoltHoleConnect::hole_comp_name }
    *currentcollector components "$::BoltHoleConnect::hole_comp_name"
    
    # 创建edge
    eval *createmark elems 1 $elem_ids
    *appendmark elems 1 "by attached"
    *createmark elems 1 "by comp" [create_elem_edge [hm_getmark elems 1] $new_edge_name]
    set elem_output_ids [hm_getmark elems 1]
    
    # 导出数据-fem (仅导出显示的数据)
    *clearmarkall 1
    print_elem_node_to_fem $fem_path $elem_output_ids
    catch {
        *createmark comps 1 $new_edge_name
        *deletemark comps 1
    }

    
    hm_createmark nodes 1 "by elem" "$elem_ids"
    set target_nodes [hm_getmark nodes 1]
    # puts "elem_ids : $elem_ids"
    # puts "target_nodes: $target_nodes"

    # ------------------------------------------
    # 调用 python数据
    set node_ids [exec python $py_path "$target_nodes"]
    set circle_node_ids_1 [lindex $node_ids 0]
    set circle_node_ids_2 [lindex $node_ids 1]
    # puts "circle_node_ids_1: $circle_node_ids_1"
    # puts "circle_node_ids_2: $circle_node_ids_2"

    
    if {$isDoubleCircle == 2} { 
        # 双层washer
        hm_createmark elems 1 "by node" "$circle_node_ids_1"
        hm_createmark nodes 1 "by elems" "[hm_getmark elems 1]"
        set circle_node_ids_1 [hm_getmark nodes 1]

        hm_createmark elems 2 "by node" "$circle_node_ids_2"
        hm_createmark nodes 2 "by elems" "[hm_getmark elems 2]"
        set circle_node_ids_2 [hm_getmark nodes 2]
    }

        
    hm_entityrecorder elems on
    hm_entityrecorder nodes on
        hm_createmark nodes 1 "$circle_node_ids_1"
        *rigidlinkinodecalandcreate 1 0 0 123456
    hm_entityrecorder nodes off
    hm_entityrecorder elems off
    set elem_circle_rb2_id_1 [hm_entityrecorder elems ids]
    set node_circle_rb2_id_1 [hm_entityrecorder nodes ids]

    hm_entityrecorder elems on
    hm_entityrecorder nodes on
        hm_createmark nodes 2 "$circle_node_ids_2"
        *rigidlinkinodecalandcreate 2 0 0 123456
    hm_entityrecorder nodes off
    hm_entityrecorder elems off
    set elem_circle_rb2_id_2 [hm_entityrecorder elems ids]
    set node_circle_rb2_id_2 [hm_entityrecorder nodes ids]
    
    # puts "$elem_circle_rb2_id_1 $elem_circle_rb2_id_2"
    # puts "$node_circle_rb2_id_1 $node_circle_rb2_id_2"

    if {$type_connect == 1} {
        hm_createmark nodes 1 "$node_circle_rb2_id_1 $node_circle_rb2_id_2"
        *rigidlinkinodecalandcreate 1 0 0 123456
    } elseif {$type_connect == 2} {
        *createvector 1 0 0 -1
        *barelementcreatewithoffsets $node_circle_rb2_id_1 $node_circle_rb2_id_2 1 0 0 0 0 "" 1 0 0 0 1 0 0 0
        # *startnotehistorystate {Updated Bar elements}
        #     *createmark elements 1 33643
        #     *attributeupdateintmark elements 1 4841 1 2 0 1
        #     *createmark elements 1 33643
        #     *attributeupdatestringmark elements 1 4842 1 2 0 "GGG"
        # *endnotehistorystate {Updated Bar elements}
        # *mergehistorystate "" ""
    }



    if {[llength $node_ids]==0} {
        tk_messageBox -message "无匹配数据,结束计算!!!" 
        return;
    }

    # hm版本
    set hm_version [lindex [split [hm_info -appinfo DISPLAYVERSION] .] 0]




    # ------------------------------------------
    # 删除临时文件
    file delete $fem_path

    puts "-----End-----"
    *clearmarkall 1
    *clearmarkall 2
    tk_messageBox -message "计算结束!!!" 


}


proc ::BoltHoleConnect::Quit { args } {
    *clearmarkall 1
    *clearmarkall 2
    ::hwt::UnpostWindow boltHoleConnect;
}


proc ::BoltHoleConnect::fun_baseButton { args } {
    *createmarkpanel elems 1 "select the elems"
    set ::BoltHoleConnect::elem_ids [hm_getmark elems 1]
    if {[llength $::BoltHoleConnect::elem_ids] != 2} {
        set ::BoltHoleConnect::elem_ids []
        tk_messageBox -message "elems 必选,且只能选2个!!\n请重选!!!" -icon warning
    }
    # puts $::BoltHoleConnect::elem_ids 
}


::BoltHoleConnect::GUI