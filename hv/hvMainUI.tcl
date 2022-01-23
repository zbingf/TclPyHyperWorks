# source D:/github/TclPyHyperWorks/hv/hvMainUI.tcl
# hyperview 2021.1


namespace eval ::hvMainUI {
    variable result_path
    variable value_limit
    variable dis_limit

    variable recess
    variable file_dir [file dirname [info script]]
}


# UI界面
proc ::hvMainUI::GUI { args } {
    variable recess;

    set minx [winfo pixel . 150p];
    set miny [winfo pixel . 100p];
    
    # 主窗口
    ::hwt::CreateWindow hvMainUIWin \
        -windowtitle "hvMainUI" \
        -cancelButton "Cancel" \
        -cancelFunc ::hvMainUI::Quit \
        -resizeable 1 1 \
        -propagate 1 \
        -minsize $minx $miny \
         noGeometrySaving;

    # -addButton OK ::hvMainUI::OkExit no_icon 
    ::hwt::KeepOnTop .hvMainUIWin;

    set recess [::hwt::WindowRecess hvMainUIWin];

    grid columnconfigure $recess 1 -weight 1;
    grid rowconfigure    $recess 10 -weight 1;

    # ===================
    ::hwt::LabeledLine $recess.end_line1 "程序集成";
    grid $recess.end_line1 -row 2 -column 0 -pady 6 -sticky ew -columnspan 2;

    # ===================
    button $recess.csvPathButton \
        -text "视角记录" \
        -command ::hvMainUI::fun_01 \
        -width 16;
    grid $recess.csvPathButton -row 3 -column 0 -padx 2 -pady 2 -sticky nw;


    # ===================
    ::hwt::RemoveDefaultButtonBinding $recess;
    ::hwt::PostWindow hvMainUIWin -onDeleteWindow ::hvMainUI::Quit;
}


proc ::hvMainUI::Quit { args } {
    ::hwt::UnpostWindow hvMainUIWin;
}


proc ::hvMainUI::fun_01 {args} {
	set cmd_str [format "source %s/%s/%s" $::hvMainUI::file_dir ing_hvViewRecoder hvViewRecoder.tcl]
	puts $cmd_str
	eval $cmd_str
}



::hvMainUI::GUI;
