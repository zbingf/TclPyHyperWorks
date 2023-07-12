
namespace eval ::BoltHoleConnect {
    variable recess
    variable isSaveSelect
    variable isDoubleCircle
    
    variable new_edge_name "__edges"
    variable hole_comp_name 

    variable tolerance
    variable c_limit_upper
    variable c_limit_lower

    variable comp_base_id
    variable comp_target_ids
    
    variable file_dir [file dirname [info script]]
    variable fem_path
    variable py_path
}

# 初始化
set ::BoltHoleConnect::fem_path [format "%s/__temp.fem" $::BoltHoleConnect::file_dir]
set ::BoltHoleConnect::py_path   [format "%s/hmBoltHoleConnect_CompBar2.py" $::BoltHoleConnect::file_dir]
set ::BoltHoleConnect::comp_base_id []
set ::BoltHoleConnect::comp_target_ids []   

if {[info exists ::BoltHoleConnect::tolerance]==0} {set ::BoltHoleConnect::tolerance 30}
if {[info exists ::BoltHoleConnect::c_limit_upper]==0} {set ::BoltHoleConnect::c_limit_upper 30}
if {[info exists ::BoltHoleConnect::c_limit_lower]==0} {set ::BoltHoleConnect::c_limit_lower 0}
if {[info exists ::BoltHoleConnect::hole_comp_name]==0} {set ::BoltHoleConnect::hole_comp_name "__HoleConnect"}
if {[info exists ::BoltHoleConnect::isSaveSelect]==0} {set ::BoltHoleConnect::isSaveSelect 0}
if {[info exists ::BoltHoleConnect::isDoubleCircle]==0} {set ::BoltHoleConnect::isDoubleCircle 1}


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
proc create_comp_edge {comp_id new_edge_name} {

    *createmark comps 1 $comp_id
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
    set miny [winfo pixel . 200p];
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
    ::hwt::LabeledLine $recess.end_line1 "Comps选择";
    grid $recess.end_line1 -row 2 -column 0 -pady 6 -sticky ew -columnspan 2;

    # ===================
    label $recess.baseLabel -text "Base Elems";
    grid $recess.baseLabel -row 3 -column 0 -padx 2 -pady 2 -sticky nw;

    button $recess.baseButton \
        -text "Base Comp" \
        -command ::BoltHoleConnect::fun_baseButton \
        -width 16;
    grid $recess.baseButton -row 4 -column 0 -padx 2 -pady 2 -sticky nw;

    # ===================
    label $recess.targetLabel -text "Target Comp";
    grid $recess.targetLabel -row 3 -column 1 -padx 2 -pady 2 -sticky nw;

    button $recess.targetButton \
        -text "Target Comp" \
        -command ::BoltHoleConnect::fun_targetButton \
        -width 16;
    grid $recess.targetButton -row 4 -column 1 -padx 2 -pady 2 -sticky nw;

    # ===================
    ::hwt::LabeledLine $recess.end_line "";
    grid $recess.end_line -row 5 -column 0 -pady 6 -sticky ew -columnspan 2;

    # radiobutton $recess.radio_1 -text "单层Washer"  -variable ::BoltHoleConnect::isDoubleCircle -value 1 -anchor w -font {MS 10}
    # radiobutton $recess.radio_2 -text "双层Washer" -variable ::BoltHoleConnect::isDoubleCircle -value 2 -anchor w -font {MS 10}
    # grid $recess.radio_1 -row 6 -column 0 -padx 2 -pady 2 -sticky nw;
    # grid $recess.radio_2 -row 6 -column 1 -padx 2 -pady 2 -sticky nw;

    label $recess.entryLabel1 -text "连接容差:";
    grid $recess.entryLabel1 -row 7 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry1 -width 16 -textvariable ::BoltHoleConnect::tolerance
    grid $recess.entry1 -row 7 -column 1 -padx 2 -pady 2 -sticky nw;

    label $recess.entryLabel2 -text "圆周长-上限:";
    grid $recess.entryLabel2 -row 8 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry2 -width 16 -textvariable ::BoltHoleConnect::c_limit_upper
    grid $recess.entry2 -row 8 -column 1 -padx 2 -pady 2 -sticky nw;

    label $recess.entryLabel3 -text "圆周长-下限:";
    grid $recess.entryLabel3 -row 9 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry3 -width 16 -textvariable ::BoltHoleConnect::c_limit_lower
    grid $recess.entry3 -row 9 -column 1 -padx 2 -pady 2 -sticky nw;

    label $recess.entryLabel4 -text "孔网格-Comp名称:";
    grid $recess.entryLabel4 -row 10 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry4 -width 16 -textvariable ::BoltHoleConnect::hole_comp_name
    grid $recess.entry4 -row 10 -column 1 -padx 2 -pady 2 -sticky nw;

    checkbutton $recess.checkSelect \
        -text "计算后保留选择" \
        -onvalue 1 \
        -offvalue 0 \
        -variable ::BoltHoleConnect::isSaveSelect \
        -command ::BoltHoleConnect::fun_checkSelectButton
        # -width 16;
    grid $recess.checkSelect -row 10 -column 0 -padx 2 -pady 2 -sticky nw;

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
    set comp_base_id    $::BoltHoleConnect::comp_base_id
    set comp_target_ids $::BoltHoleConnect::comp_target_ids
    set fem_path        $::BoltHoleConnect::fem_path
    set py_path         $::BoltHoleConnect::py_path
    set c_limit_upper         $::BoltHoleConnect::c_limit_upper
    set c_limit_lower         $::BoltHoleConnect::c_limit_lower
    set hole_comp_name  $::BoltHoleConnect::hole_comp_name
    set tolerance       $::BoltHoleConnect::tolerance
    set isDoubleCircle  $::BoltHoleConnect::isDoubleCircle
    # -------------------------------


    catch { *createentity comps name=$::BoltHoleConnect::hole_comp_name }
    *currentcollector components "$::BoltHoleConnect::hole_comp_name"
    
    # 创建edge
    *createmark elems 1 "by comp" [create_comp_edge $comp_base_id $new_edge_name]
    set elem_output_ids [hm_getmark elems 1]
    
    # 导出数据-fem (仅导出显示的数据)
    *clearmarkall 1
    print_elem_node_to_fem $fem_path $elem_output_ids
    catch {
        *createmark comps 1 $new_edge_name
        *deletemark comps 1
    }
    # ------------------------------------------
    # 调用 python数据
    set node_ids [exec python $py_path $c_limit_upper $c_limit_lower]
    if {[llength $node_ids]==0} {
        tk_messageBox -message "无匹配数据,结束计算!!!" 
        return;
    }

    # hm版本
    set hm_version [lindex [split [hm_info -appinfo DISPLAYVERSION] .] 0]

    foreach comp_target_id $comp_target_ids {
        eval "*createmark nodes 1 $node_ids"    
        eval "*createmark comps 1 $comp_target_id $comp_base_id"
                
        switch -exact -- $hm_version {
            "2019" {
                # puts "version 2019"
                *createstringarray 24 "link_elems_geom=elems" "link_rule=now" "relink_rule=none" \
                  "tol_flag=1" "tol=$tolerance" "ce_dir_assign=0" "ce_prop_opt=1" "ce_propertyid=0" \
                  "ce_notuseijk=1" "ce_boltmindiameter=0.000000" "ce_boltmaxdiameter=10.000000" \
                  "ce_boltminfeatureangle=20.000000" "ce_boltmaxfeatureangle=80.000000" "ce_boltthread=1.000000" \
                  "ce_cylinder_diameter_factor =1.500000" "ce_washer_num=0" "ce_washer_elem_num=-1" \
                  "ce_hole_option=1" "ce_adjust_hole=0" "ce_adjust_diameter=0" "ce_new_diameter=10.000000" \
                  "ce_fill_hole=0" "ce_systems=0" "ce_nonnormal=1"
                *CE_ConnectorCreateByMarkAndRealizeWithDetails nodes 1 "bolt" 2 components 1 "optistruct" 1001 53 $tolerance 1 24
            }
            "2017" {
                # 当前版本 2017
                *createstringarray 21 "link_elems_geom=elems" "link_rule=now" "relink_rule=none" \
                    "tol_flag=1" "tol=$tolerance" "ce_dir_assign=0" "ce_prop_opt=1" "ce_propertyid=0" \
                    "ce_notuseijk=1" "ce_boltmindiameter=0.000000" "ce_boltmaxdiameter=200.000000" \
                    "ce_boltminfeatureangle=20.000000" "ce_boltmaxfeatureangle=80.000000" "ce_boltthread=1.000000" \
                    "ce_cylinder_diameter_factor =1.500000" "ce_washer_num=0" "ce_washer_elem_num=-1" \
                    "ce_hole_option=0" "ce_fill_hole=0" "ce_systems=0" "ce_nonnormal=1"
                *CE_ConnectorCreateByMarkAndRealizeWithDetails nodes 1 "bolt" 2 components 1 "optistruct" 1001 53 $tolerance 1 21        
            }
            "2021" {
                *createstringarray 24 "link_elems_geom=elems" "link_rule=now" "relink_rule=none" \
                  "tol_flag=1" "tol=$tolerance" "ce_dir_assign=0" "ce_prop_opt=1" "ce_propertyid=0" \
                  "ce_notuseijk=1" "ce_boltmindiameter=0.000000" "ce_boltmaxdiameter=10.000000" \
                  "ce_boltminfeatureangle=20.000000" "ce_boltmaxfeatureangle=80.000000" "ce_boltthread=1.000000" \
                  "ce_cylinder_diameter_factor =1.500000" "ce_washer_num=0" "ce_washer_elem_num=-1" \
                  "ce_hole_option=1" "ce_adjust_hole=0" "ce_adjust_diameter=0" "ce_new_diameter=10.000000" \
                  "ce_fill_hole=0" "ce_systems=0" "ce_nonnormal=1"
                *CE_ConnectorCreateByMarkAndRealizeWithDetails nodes 1 "bolt" 2 components 1 "optistruct" 1001 53 $tolerance 1 24

            }
            default {
                tk_messageBox -message "版本暂时不兼容!!!" 
                return;
            }
        }
    }

    # 2021需要赋予comp
    if {$hm_version=="2021"} {
        set elem_target_ids [search_bar2_rbe2_from_circle_node $node_ids]
        eval "*createmark elems 1 $elem_target_ids"
        *movemark elems 1 $hole_comp_name
    }
    
    # ------------------------------------------
    # 删除临时文件
    file delete $fem_path

    puts "-----End-----"
    *clearmarkall 1
    *clearmarkall 2
    tk_messageBox -message "计算结束!!!" 

    if {$::BoltHoleConnect::isSaveSelect==0} {
        set ::BoltHoleConnect::comp_base_id []
        set ::BoltHoleConnect::comp_target_ids []   
    }
}


proc ::BoltHoleConnect::Quit { args } {
    *clearmarkall 1
    *clearmarkall 2
    ::hwt::UnpostWindow boltHoleConnect;
}


proc ::BoltHoleConnect::fun_baseButton { args } {
    *createmarkpanel comps 1 "select the comps"
    set ::BoltHoleConnect::comp_base_id [hm_getmark comps 1]
    if {[llength $::BoltHoleConnect::comp_base_id] != 1} {
        set ::BoltHoleConnect::comp_base_id []
        tk_messageBox -message "警告Base Comp必选,且只能选一个!!\n请重选!!!" -icon warning
    }
}


proc ::BoltHoleConnect::fun_targetButton { args } {
    *createmarkpanel comps 1 "select the comps"
    set ::BoltHoleConnect::comp_target_ids [hm_getmark comps 1]
    if {[llength $::BoltHoleConnect::comp_target_ids] < 1} {
        set ::BoltHoleConnect::comp_target_ids []
        tk_messageBox -message "警告Target Comp必选,且只少选一个!!\n请重选!!!" -icon warning   
    }
}


proc ::BoltHoleConnect::fun_checkSelectButton {args} {
    if {$::BoltHoleConnect::isSaveSelect==0} {
        set ::BoltHoleConnect::comp_base_id []
        set ::BoltHoleConnect::comp_target_ids []   
    }
}

::BoltHoleConnect::GUI