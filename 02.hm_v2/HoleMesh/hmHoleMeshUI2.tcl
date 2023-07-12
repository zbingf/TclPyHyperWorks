# source D:/github/TclPyHyperWorks/hm/HoleMesh/hmtieCreate.tcl
# 

namespace eval ::HoleMesh {
    variable circle_offset
    variable edge_offset
    variable elem_size

    variable line_base_id
    variable line_circle_ids

    variable recess
    variable isSaveSelect
    variable meshType

    variable circle_in_num 
    variable circle_out_num
    variable edge_num 
    variable cirlce_line_point_num 
    variable edge_line_point_num 
    variable start_angle_circle_in 
    variable start_angle_circle_out 
    variable start_angle_edge 

    variable file_dir [file dirname [info script]]
    variable tcl_path
}

# set ::HoleMesh::tcl_path [format "%s/hmHoleMesh01.tcl" $::HoleMesh::file_dir]
set ::HoleMesh::tcl_path [format "%s/hmHoleMesh.tcl" $::HoleMesh::file_dir]
if {[info exists ::HoleMesh::circle_offset]==0} {set ::HoleMesh::circle_offset 5}
if {[info exists ::HoleMesh::edge_offset]==0} {set ::HoleMesh::edge_offset 15}
if {[info exists ::HoleMesh::elem_size]==0} {set ::HoleMesh::elem_size 10}
if {[info exists ::HoleMesh::isSaveSelect]==0} {set ::HoleMesh::isSaveSelect 0}
if {[info exists ::HoleMesh::meshType]==0} {set ::HoleMesh::meshType 1}


if {[info exists ::HoleMesh::circle_in_num]==0} {set ::HoleMesh::circle_in_num 8}
if {[info exists ::HoleMesh::circle_out_num]==0} {set ::HoleMesh::circle_out_num 8}
if {[info exists ::HoleMesh::edge_num]==0} {set ::HoleMesh::edge_num 4}
if {[info exists ::HoleMesh::cirlce_line_point_num]==0} {set ::HoleMesh::cirlce_line_point_num 0}
if {[info exists ::HoleMesh::edge_line_point_num]==0} {set ::HoleMesh::edge_line_point_num 3}
if {[info exists ::HoleMesh::start_angle_circle_in]==0} {set ::HoleMesh::start_angle_circle_in 0}
if {[info exists ::HoleMesh::start_angle_circle_out]==0} {set ::HoleMesh::start_angle_circle_out 0}
if {[info exists ::HoleMesh::start_angle_edge]==0} {set ::HoleMesh::start_angle_edge 45}


# -------------------------------------
# GUI
if {[grab current] != ""} { return; }

# UI界面
proc ::HoleMesh::GUI { args } {
    variable recess;

    set minx [winfo pixel . 225p];
    set miny [winfo pixel . 320p];
    if {![OnPc]} {set miny [winfo pixel . 240p];}
    set graphArea [hm_getgraphicsarea];
    set x [lindex $graphArea 0];
    set y [lindex $graphArea 1];
    
    # 主窗口
    ::hwt::CreateWindow winHoleMesh \
        -windowtitle "HoleMesh" \
        -cancelButton "Cancel" \
        -cancelFunc ::HoleMesh::Quit \
        -addButton OK ::HoleMesh::OkExit no_icon \
        -resizeable 1 1 \
        -propagate 1 \
        -minsize $minx $miny \
        -geometry ${minx}x${miny}+${x}+${y} \
         noGeometrySaving;
    ::hwt::KeepOnTop .winHoleMesh;

    set recess [::hwt::WindowRecess winHoleMesh];
    set ::HoleMesh::recess $recess

    grid columnconfigure $recess 1 -weight 1;
    grid rowconfigure    $recess 22 -weight 1;

    # ===================
    ::hwt::LabeledLine $recess.end_line1 "单元选择";
    grid $recess.end_line1 -row 2 -column 0 -pady 6 -sticky ew -columnspan 2;

    # ===================
    label $recess.baseLabel -text "参考-轴线" -font {MS 10} ;
    grid $recess.baseLabel -row 3 -column 0 -padx 2 -pady 2 -sticky nw;

    button $recess.baseButton \
        -text "轴线选择" \
        -command ::HoleMesh::fun_baseButton \
        -width 16 \
        -font {MS 10};
    grid $recess.baseButton -row 4 -column 0 -padx 2 -pady 2 -sticky nw;

    # ===================
    label $recess.targetLabel -text "目标-圆孔线" -font {MS 10} ;
    grid $recess.targetLabel -row 3 -column 1 -padx 2 -pady 2 -sticky nw;

    button $recess.targetButton \
        -text "CircleLine" \
        -command ::HoleMesh::fun_targetButton \
        -width 16 \
        -font {MS 10};
    grid $recess.targetButton -row 4 -column 1 -padx 2 -pady 2 -sticky nw;

    # ===================
    ::hwt::LabeledLine $recess.end_line "";
    grid $recess.end_line -row 5 -column 0 -pady 6 -sticky ew -columnspan 2;

    label $recess.entryLabel1 -text "外圈偏置距离" -font {MS 10};
    grid $recess.entryLabel1 -row 6 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry1 -width 16 -textvariable ::HoleMesh::circle_offset
    grid $recess.entry1 -row 6 -column 1 -padx 2 -pady 2 -sticky nw;

    label $recess.entryLabel2 -text "边界偏置距离" -font {MS 10};
    grid $recess.entryLabel2 -row 7 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry2 -width 16 -textvariable ::HoleMesh::edge_offset
    grid $recess.entry2 -row 7 -column 1 -padx 2 -pady 2 -sticky nw;

    label $recess.entryLabel3 -text "Elem Size" -font {MS 10};
    grid $recess.entryLabel3 -row 8 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry3 -width 16 -textvariable ::HoleMesh::elem_size
    grid $recess.entry3 -row 8 -column 1 -padx 2 -pady 2 -sticky nw;


    radiobutton $recess.radio_1 -text "2Circle"  -variable ::HoleMesh::meshType -value 1 -anchor w -font {MS 10} \
        -command ::HoleMesh::fun_meshType
    radiobutton $recess.radio_2 -text "1Circle" -variable ::HoleMesh::meshType -value 2 -anchor w -font {MS 10} \
        -command ::HoleMesh::fun_meshType
    grid $recess.radio_1 -row 9 -column 0 -padx 2 -pady 2 -sticky nw;
    grid $recess.radio_2 -row 9 -column 1 -padx 2 -pady 2 -sticky nw;
    # grid $recess.radio_5 -row 11 -column 1 -padx 2 -pady 2 -sticky nw;

    label $recess.entryLabel4 -text "内圆孔点数" -font {MS 10} ;
    grid $recess.entryLabel4 -row 10 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry4 -width 16 -textvariable ::HoleMesh::circle_in_num
    grid $recess.entry4 -row 10 -column 1 -padx 2 -pady 2 -sticky nw;

    label $recess.entryLabel5 -text "外圆孔点数" -font {MS 10} ;
    grid $recess.entryLabel5 -row 11 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry5 -width 16 -textvariable ::HoleMesh::circle_out_num
    grid $recess.entry5 -row 11 -column 1 -padx 2 -pady 2 -sticky nw;

    label $recess.entryLabel6 -text "边界node点数" -font {MS 10} ;
    grid $recess.entryLabel6 -row 12 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry6 -width 16 -textvariable ::HoleMesh::edge_num
    grid $recess.entry6 -row 12 -column 1 -padx 2 -pady 2 -sticky nw;
    
    label $recess.entryLabel7 -text "外圆孔线插入点数" -font {MS 10} ;
    grid $recess.entryLabel7 -row 13 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry7 -width 16 -textvariable ::HoleMesh::cirlce_line_point_num
    grid $recess.entry7 -row 13 -column 1 -padx 2 -pady 2 -sticky nw;
    
    label $recess.entryLabel8 -text "边界线插入点数" -font {MS 10} ;
    grid $recess.entryLabel8 -row 14 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry8 -width 16 -textvariable ::HoleMesh::edge_line_point_num
    grid $recess.entry8 -row 14 -column 1 -padx 2 -pady 2 -sticky nw;
    
    label $recess.entryLabel9 -text "内圈node起始角 deg" -font {MS 10} ;
    grid $recess.entryLabel9 -row 15 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry9 -width 16 -textvariable ::HoleMesh::start_angle_circle_in
    grid $recess.entry9 -row 15 -column 1 -padx 2 -pady 2 -sticky nw;
    
    label $recess.entryLabel10 -text "外圈node起始角 deg" -font {MS 10} ;
    grid $recess.entryLabel10 -row 16 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry10 -width 16 -textvariable ::HoleMesh::start_angle_circle_out
    grid $recess.entry10 -row 16 -column 1 -padx 2 -pady 2 -sticky nw;
    
    label $recess.entryLabel11 -text "边界node起始角 deg" -font {MS 10} ;
    grid $recess.entryLabel11 -row 17 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.entry11 -width 16 -textvariable ::HoleMesh::start_angle_edge
    grid $recess.entry11 -row 17 -column 1 -padx 2 -pady 2 -sticky nw;

    # checkbutton $recess.checkSelect \
    #     -text "保留参考线选择" \
    #     -onvalue 1 \
    #     -offvalue 0 \
    #     -variable ::HoleMesh::isSaveSelect \
    #     -command ::HoleMesh::fun_checkSelectButton \
    #     -font {MS 10} 
    #     # -width 16;
    # grid $recess.checkSelect -row 20 -column 0 -padx 2 -pady 2 -sticky nw;

    ::hwt::RemoveDefaultButtonBinding $recess;
    ::hwt::PostWindow winHoleMesh -onDeleteWindow ::HoleMesh::Quit;

    ::HoleMesh::fun_meshType
}

# 主程序
proc ::HoleMesh::OkExit { args } {
    
    set choice [tk_messageBox -type yesnocancel -default yes -message "是否计算" -icon question ]
    if {$choice != yes} {return;}

    puts "---start---"
    # *nodecleartempmark

    set line_base_id $::HoleMesh::line_base_id
    set line_circle_ids $::HoleMesh::line_circle_ids

    dict set control_params circle_offset           $::HoleMesh::circle_offset
    dict set control_params edge_offset             $::HoleMesh::edge_offset
    dict set control_params elem_size               $::HoleMesh::elem_size
    dict set control_params circle_in_num           $::HoleMesh::circle_in_num
    dict set control_params circle_out_num          $::HoleMesh::circle_out_num
    dict set control_params edge_num                $::HoleMesh::edge_num
    dict set control_params cirlce_line_point_num   $::HoleMesh::cirlce_line_point_num
    dict set control_params edge_line_point_num     $::HoleMesh::edge_line_point_num
    
    dict set control_params start_angle_circle_in   $::HoleMesh::start_angle_circle_in
    dict set control_params start_angle_circle_out  $::HoleMesh::start_angle_circle_out
    dict set control_params start_angle_edge        $::HoleMesh::start_angle_edge

    if {$::HoleMesh::meshType==1} {
        source $::HoleMesh::tcl_path
        main_hole_mesh_2circle_by_two_line $line_base_id $line_circle_ids $control_params

    } elseif {$::HoleMesh::meshType==2} {
        source $::HoleMesh::tcl_path
        main_hole_mesh_1circle_by_two_line $line_base_id $line_circle_ids $control_params
    }


    # -----------------------------------
    
    puts "-----End-----"
    *clearmarkall 1
    *clearmarkall 2
    tk_messageBox -message "Run End!!!" 
    
    ::HoleMesh::fun_checkSelectButton
    
}


proc ::HoleMesh::Quit { args } {
    *clearmarkall 1
    *clearmarkall 2
    ::hwt::UnpostWindow winHoleMesh;
   # ::HoleMesh::OkExit;
}


proc ::HoleMesh::fun_baseButton { args } {
    *createmarkpanel lines 1 "select base_line_select"
    # hm_highlightmark elems 1 norm
    set line_id [hm_getmark lines 1]
    if {[llength $line_id]>1} {
        set line_id []
        tk_messageBox -message "警告Axle line必选, 且只能选一个!!\n请重选!!!" -icon warning   
    }
    set ::HoleMesh::line_base_id $line_id
}


proc ::HoleMesh::fun_targetButton { args } {
    *createmarkpanel lines 1 "circle_line_select"
    set line_ids [hm_getmark lines 1]
    if {[llength $line_ids]<1} {
        set line_ids []
        tk_messageBox -message "警告Cirlce line必选, 至少选1个!!\n请重选!!!" -icon warning   
    }
    set ::HoleMesh::line_circle_ids $line_ids
}


proc ::HoleMesh::fun_checkSelectButton {args} {
    if {$::HoleMesh::isSaveSelect==0} {
        set ::HoleMesh::line_base_id []
    }
    set ::HoleMesh::line_circle_ids []
}


proc ::HoleMesh::fun_meshType {args} {

    set recess $::HoleMesh::recess 
    if {$::HoleMesh::meshType==1} {
        catch {
            label $recess.entryLabel1 -text "外圈偏置距离" -font {MS 10} ;
            grid $recess.entryLabel1 -row 6 -column 0 -padx 2 -pady 2 -sticky nw;
            entry $recess.entry1 -width 16 -textvariable ::HoleMesh::circle_offset
            grid $recess.entry1 -row 6 -column 1 -padx 2 -pady 2 -sticky nw;

            label $recess.entryLabel6 -text "边界node点数" -font {MS 10} ;
            grid $recess.entryLabel6 -row 12 -column 0 -padx 2 -pady 2 -sticky nw;
            entry $recess.entry6 -width 16 -textvariable ::HoleMesh::edge_num
            grid $recess.entry6 -row 12 -column 1 -padx 2 -pady 2 -sticky nw;

            label $recess.entryLabel8 -text "边界线插入点数" -font {MS 10} ;
            grid $recess.entryLabel8 -row 14 -column 0 -padx 2 -pady 2 -sticky nw;
            entry $recess.entry8 -width 16 -textvariable ::HoleMesh::edge_line_point_num
            grid $recess.entry8 -row 14 -column 1 -padx 2 -pady 2 -sticky nw;
            
            label $recess.entryLabel11 -text "边界node起始角 deg" -font {MS 10} ;
            grid $recess.entryLabel11 -row 17 -column 0 -padx 2 -pady 2 -sticky nw;
            entry $recess.entry11 -width 16 -textvariable ::HoleMesh::start_angle_edge
            grid $recess.entry11 -row 17 -column 1 -padx 2 -pady 2 -sticky nw;
        }

    } elseif {$::HoleMesh::meshType==2} {
        catch {
            destroy $recess.entryLabel1
            destroy $recess.entry1

            destroy $recess.entryLabel6
            destroy $recess.entry6

            destroy $recess.entryLabel8
            destroy $recess.entry8

            destroy $recess.entryLabel11
            destroy $recess.entry11
        }
    }
}



*clearmarkall 1
*clearmarkall 2
::HoleMesh::GUI;
