# source D:/github/TclPyHyperWorks/hv/hvMainUI.tcl
# hyperview 2021.1

namespace eval ::hvMainUI {
    variable recess
    variable file_dir [file dirname [info script]]
}


# UI界面
proc ::hvMainUI::GUI { args } {
    variable recess

    set minx [winfo pixel . 150p]
    set miny [winfo pixel . 150p]
    
    # 主窗口
    ::hwt::CreateWindow hvMainUIWin \
        -windowtitle "hvMainUI" \
        -cancelButton "Cancel" \
        -cancelFunc ::hvMainUI::Quit \
        -resizeable 1 1 \
        -propagate 1 \
        -minsize $minx $miny \
         noGeometrySaving

    # -addButton OK ::hvMainUI::OkExit no_icon 
    ::hwt::KeepOnTop .hvMainUIWin

    set recess [::hwt::WindowRecess hvMainUIWin]

    grid columnconfigure $recess 1 -weight 1
    grid rowconfigure    $recess 10 -weight 1

    # ===================
    ::hwt::LabeledLine $recess.end_line1 "程序集成" -font {MS 10}
    grid $recess.end_line1 -row 1 -column 0 -pady 6 -sticky ew -columnspan 2

    # ===================
    button $recess.button_01 \
        -text "视角View管理" \
        -command ::hvMainUI::fun_01 \
        -width 22 -font {MS 10}
    grid $recess.button_01 -row 2 -column 0 -padx 2 -pady 2 -sticky nw

    # ===================
    button $recess.button_02 \
        -text "FatigueLimit" \
        -command ::hvMainUI::fun_02 \
        -width 22 -font {MS 10}
    grid $recess.button_02 -row 3 -column 0 -padx 2 -pady 2 -sticky nw

    # ===================
    button $recess.button_03 \
        -text "CurElemSearch" \
        -command ::hvMainUI::fun_03 \
        -width 22 -font {MS 10}
    grid $recess.button_03 -row 4 -column 0 -padx 2 -pady 2 -sticky nw

    # ===================
    button $recess.button_04 \
        -text "自动导出ElemId损伤" \
        -command ::hvMainUI::fun_04 \
        -width 22 -font {MS 10}
    grid $recess.button_04 -row 5 -column 0 -padx 2 -pady 2 -sticky nw


    # ===================
    ::hwt::RemoveDefaultButtonBinding $recess
    ::hwt::PostWindow hvMainUIWin -onDeleteWindow ::hvMainUI::Quit
}


proc ::hvMainUI::Quit { args } {
    ::hwt::UnpostWindow hvMainUIWin
}


proc ::hvMainUI::fun_01 {args} {
	set cmd_str [format "source %s/%s/%s" $::hvMainUI::file_dir hvViewRecord hvViewRecord.tcl]
	puts $cmd_str
	eval $cmd_str
}


proc ::hvMainUI::fun_02 {args} {
    set cmd_str [format "source %s/%s/%s" $::hvMainUI::file_dir hvResultOutput hvFatigueResultSearch.tcl]
    puts $cmd_str
    eval $cmd_str
}

proc ::hvMainUI::fun_03 {args} {
    set cmd_str [format "source %s/%s/%s" $::hvMainUI::file_dir hvResultOutput hvElemSearch.tcl]
    puts $cmd_str
    eval $cmd_str
}

proc ::hvMainUI::fun_04 {args} {
    set cmd_str [format "source %s/%s/%s" $::hvMainUI::file_dir hvDamageOutput hvDamageElemIdOutput.tcl]
    puts $cmd_str
    eval $cmd_str

}



::hvMainUI::GUI
# source "D:/github/TclPyHyperWorks/03.hv/hvMainUI.tcl"