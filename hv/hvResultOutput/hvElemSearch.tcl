# source D:/github/TclPyHyperWorks/opt_fatigue/fatigue_search_node_ids.tcl
# 
# 

namespace eval ::hvElemSearch {
    variable result_path
    variable fem_path
    variable dis_limit

    variable recess
    variable file_dir [file dirname [info script]]
}


# UI界面
proc ::hvElemSearch::GUI { args } {
    variable recess

    set minx [winfo pixel . 300p]
    set miny [winfo pixel . 100p]
    
    # 主窗口
    ::hwt::CreateWindow hvElemSearchWin \
        -windowtitle "hvElemSearch" \
        -cancelButton "Cancel" \
        -cancelFunc ::hvElemSearch::Quit \
        -addButton OK ::hvElemSearch::OkExit no_icon \
        -resizeable 1 1 \
        -propagate 1 \
        -minsize $minx $miny \
         noGeometrySaving

    ::hwt::KeepOnTop .hvElemSearchWin

    set recess [::hwt::WindowRecess hvElemSearchWin]

    grid columnconfigure $recess 1 -weight 1
    grid rowconfigure    $recess 10 -weight 1

    # ===================
    ::hwt::LabeledLine $recess.end_line1 "路径选择" -font {MS 10}
    grid $recess.end_line1 -row 2 -column 0 -pady 6 -sticky ew -columnspan 2

    # ===================
    button $recess.button_01 \
        -text "结果保存" \
        -command ::hvElemSearch::set_result_path \
        -width 16 -font {MS 10}
    grid $recess.button_01 -row 3 -column 0 -padx 2 -pady 2 -sticky nw

    entry $recess.entry1 -width 40 -textvariable ::hvElemSearch::result_path
    grid $recess.entry1 -row 3 -column 1 -padx 2 -pady 2 -sticky nw

    # ===================
    button $recess.button_02 \
        -text "完整fem加载" \
        -command ::hvElemSearch::set_fem_path \
        -width 16 -font {MS 10}
    grid $recess.button_02 -row 4 -column 0 -padx 2 -pady 2 -sticky nw

    entry $recess.entry2 -width 40 -textvariable ::hvElemSearch::fem_path
    grid $recess.entry2 -row 4 -column 1 -padx 2 -pady 2 -sticky nw


    # ===================
    ::hwt::LabeledLine $recess.end_line2 "设置"
    grid $recess.end_line2 -row 5 -column 0 -pady 6 -sticky ew -columnspan 2

    # label $recess.entryLabel3 -text "damage limit"
    # grid $recess.entryLabel3 -row 6 -column 0 -padx 2 -pady 2 -sticky nw
    # entry $recess.entry3 -width 16 -textvariable ::hvElemSearch::value_limit
    # grid $recess.entry3 -row 6 -column 1 -padx 2 -pady 2 -sticky nw

    label $recess.entryLabel4 -text "dis limit"
    grid $recess.entryLabel4 -row 7 -column 0 -padx 2 -pady 2 -sticky nw
    entry $recess.entry4 -width 16 -textvariable ::hvElemSearch::dis_limit
    grid $recess.entry4 -row 7 -column 1 -padx 2 -pady 2 -sticky nw


    # ===================
    ::hwt::RemoveDefaultButtonBinding $recess
    ::hwt::PostWindow hvElemSearchWin -onDeleteWindow ::hvElemSearch::Quit
}


# 主程序
proc ::hvElemSearch::OkExit { args } {
    variable result_path
    variable file_dir
    variable fem_path
    variable dis_limit

    set py_path [format "%s/sub_fatigue_result.py" $file_dir]
    set temp_csv_path [format "%s/__temp.csv" $file_dir]
    # puts $temp_csv_path

    # 导出目标csv数据
    ::hvElemSearch::output_cur_query $temp_csv_path

    set comp2elems [exec python $py_path "ELEM2COMP_ELEM_CSV" $fem_path $dis_limit $temp_csv_path]
    set comp_ids [dict keys $comp2elems]

    set file_obj [open $result_path w]
    puts $file_obj $comp2elems
    close $file_obj

    tk_messageBox -message "Run End!!!" 
}


proc ::hvElemSearch::Quit { args } {

    ::hwt::UnpostWindow hvElemSearchWin
}


proc ::hvElemSearch::set_result_path {} {
    variable file_dir
    variable result_path
    set result_path [tk_getSaveFile -title "保存路径"  -filetypes {"result .txt"} -defaultextension txt  -initialdir $file_dir]
}


proc ::hvElemSearch::set_fem_path {} {
    variable file_dir
    variable fem_path
    set fem_path [tk_getOpenFile -title "保存路径"  -filetypes {"2021.1 fem .fem"} -defaultextension fem  -initialdir $file_dir]
}

# 
proc ::hvElemSearch::output_cur_query {csv_path} {
    
    catch { hwi CloseStack }
    hwi OpenStack
        hwi GetSessionHandle session_handle
        session_handle GetProjectHandle project_handle
        project_handle GetPageHandle page_handle [project_handle GetActivePage]
        page_handle GetWindowHandle window_handle [page_handle GetActiveWindow]
        window_handle GetClientHandle client_handle
        client_handle GetModelHandle model_handle [client_handle GetActiveModel]
        model_handle  GetQueryCtrlHandle query_handle
            query_handle SetQuery "element.id,component.name"
            query_handle WriteData $csv_path
    hwi CloseStack
}


::hvElemSearch::GUI


