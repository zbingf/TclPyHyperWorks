
namespace eval ::BoltHoleCorrect {
    variable recess

    variable angle_limit
    variable comp_base_id
    variable isSaveSelect
    variable moveType

    variable file_dir [file dirname [info script]]
    variable fem_path
    variable py_path
    variable csv_path

}

# 初始化
set ::BoltHoleCorrect::comp_base_id []
set ::BoltHoleCorrect::fem_path [format "%s/__temp.fem" $::BoltHoleCorrect::file_dir]
set ::BoltHoleCorrect::csv_path [format "%s/__temp.csv" $::BoltHoleCorrect::file_dir]
set ::BoltHoleCorrect::py_path   [format "%s/hmBoltHoleCorrect.py" $::BoltHoleCorrect::file_dir]

if {[info exists ::BoltHoleCorrect::angle_limit]==0} {set ::BoltHoleCorrect::angle_limit 3}
if {[info exists ::BoltHoleCorrect::moveType]==0} {set ::BoltHoleCorrect::moveType 1}

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

# 矢量 - abs
proc v_abs {loc} {
    set x [lindex $loc 0]
    set y [lindex $loc 1]
    set z [lindex $loc 2]
    set value [expr ($x**2+$y**2+$z**2)**0.5]
    return $value
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

# 判定是否是RBE2
proc isRBE2 {elem_id} {
    set type_name [hm_getvalue elems id=$elem_id dataname=typename]
    if {$type_name == "RBE2"} {
        return 1
    } else {
        return 0
    }
}

# 检索 RBE2
proc search_rbe2 {elem_ids} {
    set rbe2_ids []
    foreach elem_id $elem_ids {
        if {[isRBE2 $elem_id]} {
            lappend rbe2_ids $elem_id
        }
    }
    return $rbe2_ids
}

# -----------------------------
# GUI
proc ::BoltHoleCorrect::GUI { args } {
    variable recess;

    set minx [winfo pixel . 225p];
    set miny [winfo pixel . 180p];
    if {![OnPc]} {set miny [winfo pixel . 240p];}
    set graphArea [hm_getgraphicsarea];
    set x [lindex $graphArea 0];
    set y [lindex $graphArea 1];
    
    # 主窗口
    ::hwt::CreateWindow winBoltHoleCorrect \
        -windowtitle "BoltHoleCorrect" \
        -cancelButton "Cancel" \
        -cancelFunc ::BoltHoleCorrect::Quit \
        -addButton OK ::BoltHoleCorrect::OkExit no_icon \
        -resizeable 1 1 \
        -propagate 1 \
        -minsize $minx $miny \
        -geometry ${minx}x${miny}+${x}+${y} \
         noGeometrySaving;
    ::hwt::KeepOnTop .winBoltHoleCorrect;

    set recess [::hwt::WindowRecess winBoltHoleCorrect];

    grid columnconfigure $recess 1 -weight 1;
    grid rowconfigure    $recess 10 -weight 1;

    # ===================
    ::hwt::LabeledLine $recess.line1 "Comps选择" -font {MS 10}
    grid $recess.line1 -row 2 -column 0 -pady 6 -sticky ew -columnspan 2;

    # ===================
    label $recess.baseLabel -text "以Base Comp为基准校正" -font {MS 10}
    grid $recess.baseLabel -row 3 -column 0 -padx 2 -pady 2 -sticky nw;

    button $recess.baseButton \
        -text "Base Comp" \
        -command ::BoltHoleCorrect::fun_baseButton \
        -width 16 -font {MS 10}
    grid $recess.baseButton -row 4 -column 0 -padx 2 -pady 2 -sticky nw;

    # ===================
    ::hwt::LabeledLine $recess.line2 "控制参数" -font {MS 10}
    grid $recess.line2 -row 5 -column 0 -pady 6 -sticky ew -columnspan 2;

    label $recess.entryLabel1 -text "允许的角度偏差 deg:" -font {MS 10}
    grid $recess.entryLabel1 -row 6 -column 0 -padx 2 -pady 2 -sticky nw;

    entry $recess.entry1 -width 16 -textvariable ::BoltHoleCorrect::angle_limit -font {MS 10}
    grid $recess.entry1 -row 6 -column 1 -padx 2 -pady 2 -sticky nw;

    # ===================
    ::hwt::LabeledLine $recess.line3 "校正类型-选择" -font {MS 10}
    grid $recess.line3 -row 7 -column 0 -pady 6 -sticky ew -columnspan 2;

    radiobutton $recess.radio_1 -text Move-RBE2  -variable ::BoltHoleCorrect::moveType -value 1 -anchor w -font {MS 10}
    radiobutton $recess.radio_2 -text Move-Node -variable ::BoltHoleCorrect::moveType -value 2 -anchor w -font {MS 10}
    grid $recess.radio_1 -row 8 -column 0 -padx 2 -pady 2 -sticky nw;
    grid $recess.radio_2 -row 8 -column 1 -padx 2 -pady 2 -sticky nw;


    # checkbutton $recess.checkSelect \
    #     -text "计算后保留选择" \
    #     -onvalue 1 \
    #     -offvalue 0 \
    #     -variable ::BoltHoleCorrect::isSaveSelect
    # grid $recess.checkSelect -row 9 -column 0 -padx 2 -pady 2 -sticky nw;

    ::hwt::RemoveDefaultButtonBinding $recess;
    ::hwt::PostWindow winBoltHoleCorrect -onDeleteWindow ::BoltHoleCorrect::Quit;
}

# -----------------------------
# 主程序
proc ::BoltHoleCorrect::OkExit { args } {

    set choice [tk_messageBox -type yesnocancel -default yes -message "是否计算" -icon question ]
    if {$choice != yes} {return;}

    # ----------
    set fem_path        $::BoltHoleCorrect::fem_path
    set py_path         $::BoltHoleCorrect::py_path
    set angle_limit     $::BoltHoleCorrect::angle_limit
    set comp_base_id    $::BoltHoleCorrect::comp_base_id
    set csv_path        $::BoltHoleCorrect::csv_path
    set moveType        $::BoltHoleCorrect::moveType
    # ----------
    # 隐藏
    *createmark elems 1 "by config" bar2
    # set bar2_ids [hm_getmark elems 1]
    *maskentitymark elems 1 0

    # ----------
    # comp
    *createmark elems 1 "by comp" $comp_base_id
    *appendmark elems 1 "by adjacent"
    set elem_ids [hm_getmark elems 1]
    if {[llength $elem_ids]<1} {return;}
    
    # 基础rbe2输出
    set rbe2_ids [search_rbe2 $elem_ids]
    set f_obj [open $csv_path w]
    puts $f_obj $rbe2_ids
    close $f_obj

    # ----------
    # 显示
    *createmark elems 1 "by config" bar2
    *appendmark elems 1 "by adjacent"
    set rbe2_with_bar_ids [hm_getmark elems 1]
    *unmaskentitymark elems 1 0

    # ----------
    # fem导出
    *clearmarkall 1
    print_elem_node_to_fem $fem_path $rbe2_with_bar_ids

    # ------------------------------------------
    # 调用 python数据
    set result_py [exec python $py_path $angle_limit]
    # puts [llength $result_py]
    if {[llength $result_py]==0} {
        tk_messageBox -message "无匹配数据,结束计算!!!" 
        return;
    }

    foreach data $result_py {
        set rbe2_id [lindex $data 0]
        set rbe2_center_id [lindex $data 1]
        set v [lrange $data 2 end]
        set v_abs [v_abs $v]
        set new_v [v_one $v]
        
        if {$moveType == 1} {
            *createmark elements 1 $rbe2_id
            eval "*createvector 1 $new_v"
            *translatemark elems 1 1 $v_abs    
        } else {
            *createmark nodes 1 $rbe2_center_id
            eval "*createvector 1 $new_v"
            *translatemark nodes 1 1 $v_abs    
        }
    }

    # ------------------------------------------
    # 删除临时文件
    file delete $fem_path
    file delete $csv_path

    puts "-----End-----"
    *clearmarkall 1
    *clearmarkall 2
    tk_messageBox -message "计算结束!!!" 

    set ::BoltHoleCorrect::comp_base_id []
    # if {$::BoltHoleCorrect::isSaveSelect==0} {
    #     set ::BoltHoleCorrect::comp_base_id []
    # }
}


proc ::BoltHoleCorrect::Quit { args } {
    *clearmarkall 1
    *clearmarkall 2
    ::hwt::UnpostWindow winBoltHoleCorrect;
}


proc ::BoltHoleCorrect::fun_baseButton { args } {
    *createmarkpanel comps 1 "select the comps"
    set ::BoltHoleCorrect::comp_base_id [hm_getmark comps 1]
    if {[llength $::BoltHoleCorrect::comp_base_id] != 1} {
        set ::BoltHoleCorrect::comp_base_id []
        tk_messageBox -message "警告Base Comp必选,且只能选一个!!\n请重选!!!" -icon warning
    }
}

::BoltHoleCorrect::GUI