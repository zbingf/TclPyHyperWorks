# source D:/github/TclPyHyperWorks/opt_fatigue/fatigue_search_node_ids.tcl
# 
# 

namespace eval ::hvFatigueResultSearch {
    variable result_path
    variable value_limit
    variable dis_limit
    variable fem_path

    variable recess
    variable file_dir [file dirname [info script]]
}


# UI界面
proc ::hvFatigueResultSearch::GUI { args } {
    variable recess

    set minx [winfo pixel . 300p]
    set miny [winfo pixel . 100p]
    
    # 主窗口
    ::hwt::CreateWindow hvFatigueResultSearchWin \
        -windowtitle "hvFatigueResultSearch" \
        -cancelButton "Cancel" \
        -cancelFunc ::hvFatigueResultSearch::Quit \
        -addButton OK ::hvFatigueResultSearch::OkExit no_icon \
        -resizeable 1 1 \
        -propagate 1 \
        -minsize $minx $miny \
         noGeometrySaving

    ::hwt::KeepOnTop .hvFatigueResultSearchWin

    set recess [::hwt::WindowRecess hvFatigueResultSearchWin]

    grid columnconfigure $recess 1 -weight 1
    grid rowconfigure    $recess 10 -weight 1

    # ===================
    ::hwt::LabeledLine $recess.end_line1 "路径选择" -font {MS 10}
    grid $recess.end_line1 -row 2 -column 0 -pady 6 -sticky ew -columnspan 2

    # ===================
    button $recess.button_01 \
        -text "结果保存" \
        -command ::hvFatigueResultSearch::set_result_path \
        -width 16 -font {MS 10}
    grid $recess.button_01 -row 3 -column 0 -padx 2 -pady 2 -sticky nw

    entry $recess.entry1 -width 40 -textvariable ::hvFatigueResultSearch::result_path
    grid $recess.entry1 -row 3 -column 1 -padx 2 -pady 2 -sticky nw

    # ===================
    button $recess.button_02 \
        -text "完整fem加载" \
        -command ::hvFatigueResultSearch::set_fem_path \
        -width 16 -font {MS 10}
    grid $recess.button_02 -row 4 -column 0 -padx 2 -pady 2 -sticky nw

    entry $recess.entry2 -width 40 -textvariable ::hvFatigueResultSearch::fem_path
    grid $recess.entry2 -row 4 -column 1 -padx 2 -pady 2 -sticky nw


    # ===================
    ::hwt::LabeledLine $recess.end_line2 "设置"
    grid $recess.end_line2 -row 5 -column 0 -pady 6 -sticky ew -columnspan 2

    label $recess.entryLabel3 -text "Contour Limit"
    grid $recess.entryLabel3 -row 6 -column 0 -padx 2 -pady 2 -sticky nw
    entry $recess.entry3 -width 16 -textvariable ::hvFatigueResultSearch::value_limit
    grid $recess.entry3 -row 6 -column 1 -padx 2 -pady 2 -sticky nw

    label $recess.entryLabel4 -text "单元距离限制Dis Limit"
    grid $recess.entryLabel4 -row 7 -column 0 -padx 2 -pady 2 -sticky nw
    entry $recess.entry4 -width 16 -textvariable ::hvFatigueResultSearch::dis_limit
    grid $recess.entry4 -row 7 -column 1 -padx 2 -pady 2 -sticky nw

    # ===================
    # ttk::treeview $recess.listbox_01
    # ttk::scrollbar $recess.listbox_01 \
    #     -listvariable ::hvFatigueResultSearch::view_list
    # grid $recess.listbox_01 -row 8 -column 1 -padx 2 -pady 2 -sticky nw


    # ===================
    ::hwt::RemoveDefaultButtonBinding $recess
    ::hwt::PostWindow hvFatigueResultSearchWin -onDeleteWindow ::hvFatigueResultSearch::Quit
}


# 主程序
proc ::hvFatigueResultSearch::OkExit { args } {
    variable result_path
    variable value_limit
    variable dis_limit
    variable file_dir
    variable fem_path

    set py_path [format "%s/sub_fatigue_result.py" $file_dir]
    set temp_csv_path [format "%s/__temp.csv" $file_dir]
    # puts $temp_csv_path

    # 导出目标csv数据
    ::hvFatigueResultSearch::search_fatigue_result_damdage $temp_csv_path $value_limit

    set comp2elems [exec python $py_path "ELEM2COMP_ELEM_CSV" $fem_path $dis_limit $temp_csv_path]
    # set comp_ids [dict keys $comp2elems]

    set file_obj [open $result_path w]
    puts $file_obj $comp2elems
    close $file_obj

    tk_messageBox -message "Run End!!!" 

}


proc ::hvFatigueResultSearch::Quit { args } {

    ::hwt::UnpostWindow hvFatigueResultSearchWin

}


proc ::hvFatigueResultSearch::set_result_path {} {
    variable file_dir
    variable result_path
    set result_path [tk_getSaveFile -title "保存路径"  -filetypes {"result .txt"} -defaultextension txt  -initialdir $file_dir]
}


proc ::hvFatigueResultSearch::set_fem_path {} {
    variable file_dir
    variable fem_path
    set fem_path [tk_getOpenFile -title "保存路径"  -filetypes {"2021.1 fem .fem"} -defaultextension fem  -initialdir $file_dir]
}

# 导出目标csv数据, elemID,ContourValue
proc ::hvFatigueResultSearch::search_fatigue_result_damdage {csv_path damage_limit} {
    set t 1
    catch { hwi CloseStack }
    hwi  OpenStack
        hwi GetSessionHandle sess$t 
        sess$t GetProjectHandle prj$t
        prj$t GetPageHandle pg$t [prj$t GetActivePage]
        pg$t GetWindowHandle win$t [pg$t GetActiveWindow]
        win$t GetClientHandle cln$t 
        cln$t GetModelHandle mdl$t [cln$t GetActiveModel]
        set setid  [ mdl$t AddSelectionSet element ]
        mdl$t GetSelectionSetHandle elem$t $setid 
        elem$t Add "contour > $damage_limit "
        mdl$t GetQueryCtrlHandle qry$t 
        qry$t SetQuery "element.id,contour.value"
        qry$t SetSelectionSet $setid
        qry$t WriteData $csv_path
        mdl$t RemoveSelectionSet $setid 
    hwi CloseStack
}


::hvFatigueResultSearch::GUI

