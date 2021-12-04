
namespace eval ::BoltHoleClassify {
    variable recess

    variable elem_ids
    variable prefix_name

    variable file_dir [file dirname [info script]]
    variable fem_path
    variable py_path
    variable csv_path
}

# 初始化
set ::BoltHoleClassify::fem_path [format "%s/__temp.fem" $::BoltHoleClassify::file_dir]
set ::BoltHoleClassify::csv_path [format "%s/__temp.csv" $::BoltHoleClassify::file_dir]
set ::BoltHoleClassify::py_path   [format "%s/hmBoltHoleClassify.py" $::BoltHoleClassify::file_dir]
set ::BoltHoleClassify::elem_ids []

if {[info exists ::BoltHoleClassify::prefix_name]==0} {set ::BoltHoleClassify::prefix_name "BoltHole"}

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


proc create_comps_name {name} {
    # 创建comps 前检查 是否存在
    *createmark comps 1 $name
    if {[hm_getmark comps 1]==[]} {
        *createentity comps name=$name
    }
    *createmark comps 1 $name
    return [hm_getmark comps 1]
}


proc create_materials_name {materials_name} {
    # 创建材料
    *createmark materials 1 $materials_name

    if {[hm_getmark materials 1]==[]} {
        *collectorcreate materials "$materials_name" 11
        *createmark materials 1 "$materials_name"
        *dictionaryload materials 1 "[hm_info exporttemplate]" "MAT1"
        # puts "append materials_name"
    } else {
        # puts "materials_name isExist"

    }
    *createmark materials 1 $materials_name
    return [hm_getmark materials 1]
}


proc create_properties_name {properties_name materials_name beam_name} {
    # 创建属性
    *createmark properties 1 $properties_name
    *createmark beamsects 1 "$beam_name"
    set beamsect_id [hm_getmark beamsects 1]
    if {[hm_getmark properties 1]==[]} {
        # puts "append properties"
        *collectorcreateonly properties "$properties_name" "" 11
        *createmark materials 1 "$materials_name"
        *createmark properties 1 "$properties_name"
        set prop_id [hm_getmark properties 1]
        set mats_id [hm_getmark materials 1]
        *setvalue props id=$prop_id materialid={mats $mats_id}
        *setvalue props id=$prop_id STATUS=2 3186={beamsects $beamsect_id}
        *dictionaryload properties 1 "[hm_info exporttemplate]" "PBEAM"
    }
    *createmark properties 1 $properties_name
    return [hm_getmark properties 1]
}


# 判定是否是RBE2
proc isBAR2 {elem_id} {
    set type_name [hm_getvalue elems id=$elem_id dataname=typename]
    if {$type_name in "{CBAR} {CBEAM} {CMBEAM}"} {
        return 1
    } else {
        return 0
    }
}

# 检索 RBE2
proc search_bar2 {elem_ids} {
    set bar2_ids []
    foreach elem_id $elem_ids {
        if {[isBAR2 $elem_id]} {
            lappend bar2_ids $elem_id
        }
    }
    return $bar2_ids
}

# -----------------------------
# GUI
proc ::BoltHoleClassify::GUI { args } {
    variable recess;

    set minx [winfo pixel . 225p];
    set miny [winfo pixel . 120p];
    if {![OnPc]} {set miny [winfo pixel . 240p];}
    set graphArea [hm_getgraphicsarea];
    set x [lindex $graphArea 0];
    set y [lindex $graphArea 1];
    
    # 主窗口
    ::hwt::CreateWindow winBoltHoleClassify \
        -windowtitle "BoltHoleClassify" \
        -cancelButton "Cancel" \
        -cancelFunc ::BoltHoleClassify::Quit \
        -addButton OK ::BoltHoleClassify::OkExit no_icon \
        -resizeable 1 1 \
        -propagate 1 \
        -minsize $minx $miny \
        -geometry ${minx}x${miny}+${x}+${y} \
         noGeometrySaving;
    ::hwt::KeepOnTop .winBoltHoleClassify;

    set recess [::hwt::WindowRecess winBoltHoleClassify];

    grid columnconfigure $recess 1 -weight 1;
    grid rowconfigure    $recess 10 -weight 1;

    # ===================
    ::hwt::LabeledLine $recess.line1 "选择孔单元" -font {MS 10}
    grid $recess.line1 -row 1 -column 0 -pady 6 -sticky ew -columnspan 2;

    button $recess.numButton1 \
        -text "Elem" \
        -command ::BoltHoleClassify::fun_Button_select_elem \
        -width 16;
    grid $recess.numButton1 -row 2 -column 0 -padx 2 -pady 2 -sticky nw;

    ::hwt::LabeledLine $recess.line2 "分类名称-前缀设置" -font {MS 10}
    grid $recess.line2 -row 3 -column 0 -pady 6 -sticky ew -columnspan 2;

    label $recess.entryLabel1 -text "Prefix name:" -font {MS 10}
    grid $recess.entryLabel1 -row 4 -column 0 -padx 2 -pady 2 -sticky nw;

    entry $recess.entry1 -width 16 -textvariable ::BoltHoleClassify::prefix_name -font {MS 10}
    grid $recess.entry1 -row 4 -column 1 -padx 2 -pady 2 -sticky nw;

    ::hwt::RemoveDefaultButtonBinding $recess;
    ::hwt::PostWindow winBoltHoleClassify -onDeleteWindow ::BoltHoleClassify::Quit;
}

# -----------------------------
# 主程序
proc ::BoltHoleClassify::OkExit { args } {

    set choice [tk_messageBox -type yesnocancel -default yes -message "是否计算" -icon question ]
    if {$choice != yes} {return;}

    set fem_path        $::BoltHoleClassify::fem_path
    set csv_path        $::BoltHoleClassify::csv_path
    set py_path         $::BoltHoleClassify::py_path
    set prefix_name     $::BoltHoleClassify::prefix_name
    set elem_ids        $::BoltHoleClassify::elem_ids


    # 显示全部
    show_all
    eval "*createmark elems 1 $elem_ids"
    *appendmark elems 1 "by adjacent"
    *appendmark elems 1 "by adjacent"
    *appendmark elems 1 "by adjacent"
    set elems_base_ids [hm_getmark elems 1]
    set bar2_base_ids [search_bar2 $elems_base_ids]
    # *createmark elems 1 "by config" bar2
    # set bar2_ids [hm_getmark elems 1]
    set f_obj [open $csv_path w]
    puts $f_obj $bar2_base_ids
    close $f_obj

    # bar周围单元导出
    *clearmarkall 1
    print_elem_node_to_fem $fem_path $elems_base_ids

    set bar2_datas [exec python $py_path]
    # puts $bar2_datas
    # 分类
    set r_comps []
    foreach bar2_data $bar2_datas {
        set r [lindex $bar2_data 0]
        set bar2_ids [lrange $bar2_data 1 end]
        set comp_name [format "%s_R%s" $prefix_name $r]
        catch { *createentity comps name=$comp_name }
        eval "*createmark elems 1 $bar2_ids"
        *movemark elems 1 "$comp_name"
        lappend r_comps "$r $comp_name"
    }

    
    set sectcol_name bolt_circle
    catch {
        *createentity beamsectcols includeid=0 name=$sectcol_name    
    }
    foreach r_comp $r_comps {
        set r [lindex $r_comp 0]
        set comp_name [lindex $r_comp 1]
        set sect_name "bolt_R$r"

        catch {
            *createentity beamsects includeid=0 name=$sect_name
            *createdoublearray 3 $r 10 10
            *beamsectionsetdatastandard 1 3 1 11 0 "Rod"
            *createmark beamsects 1 "$sect_name"
            *updatehmdb beamsects 1
        }

        *createmark properties 1 "$sect_name"
        set mat_name "BEAM_$prefix_name\_R$r"
        set prop_name "BEAM_$prefix_name\_R$r"
        set mat_id  [create_materials_name $mat_name]
        set prop_id [create_properties_name $prop_name $mat_name $sect_name]

        # comp 赋值属性
        *createmark comps 1 "$comp_name"
        *setvalue comps id=[hm_getmark comps 1] propertyid={props $prop_id}

    }

    # ------------------------------------------
    # 删除临时文件
    file delete $fem_path
    file delete $csv_path

    puts "-----End-----"
    *clearmarkall 1
    *clearmarkall 2
    tk_messageBox -message "计算结束!!!" 
}

proc ::BoltHoleClassify::Quit { args } {
    *clearmarkall 1
    *clearmarkall 2
    ::hwt::UnpostWindow winBoltHoleClassify;
}

proc ::BoltHoleClassify::fun_Button_select_elem { args } {
    *createmarkpanel elems 1 "select the elems"
    set ::BoltHoleClassify::elem_ids [hm_getmark elems 1]
    if {[llength $::BoltHoleClassify::elem_ids] < 1} {
        set ::BoltHoleClassify::elem_ids []
        tk_messageBox -message "Elems 未选择" -icon warning
    }
}




::BoltHoleClassify::GUI