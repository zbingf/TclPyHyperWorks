
namespace eval ::BoltHoleCheck {
    variable recess

    variable angle_limit

    variable file_dir [file dirname [info script]]
    variable fem_path
    variable py_path
}

# 初始化
set ::BoltHoleCheck::fem_path [format "%s/__temp.fem" $::BoltHoleCheck::file_dir]
set ::BoltHoleCheck::csv_path [format "%s/__temp.csv" $::BoltHoleCheck::file_dir]
set ::BoltHoleCheck::py_path   [format "%s/hmBoltHoleCheck_bar2.py" $::BoltHoleCheck::file_dir]

if {[info exists ::BoltHoleCheck::angle_limit]==0} {set ::BoltHoleCheck::angle_limit 3}

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

# 显示全部
proc show_all {} {
    *createmark comps 1 "all"
    *unmaskentitymark comps 1 "all" 1 0
    *createmark elems 1 "all"
    *unmaskentitymark elements 1 0    
}

# -----------------------------
# GUI
proc ::BoltHoleCheck::GUI { args } {
    variable recess;

    set minx [winfo pixel . 225p];
    set miny [winfo pixel . 80p];
    if {![OnPc]} {set miny [winfo pixel . 240p];}
    set graphArea [hm_getgraphicsarea];
    set x [lindex $graphArea 0];
    set y [lindex $graphArea 1];
    
    # 主窗口
    ::hwt::CreateWindow winBoltHoleCorrect \
        -windowtitle "BoltHoleCheck" \
        -cancelButton "Cancel" \
        -cancelFunc ::BoltHoleCheck::Quit \
        -addButton OK ::BoltHoleCheck::OkExit no_icon \
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
    ::hwt::LabeledLine $recess.line2 "控制参数" -font {MS 10}
    grid $recess.line2 -row 5 -column 0 -pady 6 -sticky ew -columnspan 2;

    label $recess.entryLabel1 -text "允许的角度偏差 deg:" -font {MS 10}
    grid $recess.entryLabel1 -row 6 -column 0 -padx 2 -pady 2 -sticky nw;

    entry $recess.entry1 -width 16 -textvariable ::BoltHoleCheck::angle_limit -font {MS 10}
    grid $recess.entry1 -row 6 -column 1 -padx 2 -pady 2 -sticky nw;

    ::hwt::RemoveDefaultButtonBinding $recess;
    ::hwt::PostWindow winBoltHoleCorrect -onDeleteWindow ::BoltHoleCheck::Quit;
}

# -----------------------------
# 主程序
proc ::BoltHoleCheck::OkExit { args } {

    set choice [tk_messageBox -type yesnocancel -default yes -message "是否计算" -icon question ]
    if {$choice != yes} {return;}

    set fem_path        $::BoltHoleCheck::fem_path
    set py_path         $::BoltHoleCheck::py_path
    set angle_limit     $::BoltHoleCheck::angle_limit
    set csv_path        $::BoltHoleCheck::csv_path

    # 显示全部
    show_all
    *createmark elems 1 "by config" bar2
    set bar2_ids [hm_getmark elems 1]
    set f_obj [open $csv_path w]
    puts $f_obj $bar2_ids
    close $f_obj

    # bar周围单元导出
    *appendmark elems 1 "by adjacent"
    set elems_ids [hm_getmark elems 1]
    *clearmarkall 1
    print_elem_node_to_fem $fem_path $elems_ids

    # 查找-不匹配的单元
    set bar2_target_ids [exec python $py_path $angle_limit]
    eval "*createmark elems 1 $bar2_target_ids"
    *appendmark elems 1 "by adjacent"
    *appendmark elems 1 "by adjacent"
    *maskentitymark elems 1 0  
    *maskreverse elems

    # ------------------------------------------
    # 删除临时文件
    file delete $fem_path
    file delete $csv_path

    puts "-----End-----"
    *clearmarkall 1
    *clearmarkall 2
    tk_messageBox -message "计算结束!!!" 

}

proc ::BoltHoleCheck::Quit { args } {
    *clearmarkall 1
    *clearmarkall 2
    ::hwt::UnpostWindow winBoltHoleCorrect;
}


::BoltHoleCheck::GUI