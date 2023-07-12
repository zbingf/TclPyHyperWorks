package provide SubTk 1.0


namespace eval ::zbingf_UI {
    # variable lines 
    # variable type 
}


proc ::zbingf_UI::var_set {first second} {

    return [format "::%s::%s" $first $second]
}


proc ::zbingf_UI::main_ui_start {name_ui} {
    eval "set width $[::zbingf_UI::var_set $name_ui width]"
    eval "set height $[::zbingf_UI::var_set $name_ui height]"

    # 主窗口
    ::hwt::CreateWindow win_$name_ui \
        -windowtitle "$name_ui" \
        -cancelButton "Cancel" \
        -cancelFunc [::zbingf_UI::var_set $name_ui Quit] \
        -addButton calc [::zbingf_UI::var_set $name_ui fun_calc] no_icon \
        -resizeable 1 1 \
        -propagate 1 \
        -minsize $width $height \
         noGeometrySaving;
    ::hwt::KeepOnTop .win_$name_ui;

    set [::zbingf_UI::var_set $name_ui recess] [::hwt::WindowRecess win_$name_ui]
}


proc ::zbingf_UI::main_ui_end {name_ui} {

    # ===================
    eval "::hwt::RemoveDefaultButtonBinding $[::zbingf_UI::var_set $name_ui recess]"
    eval "::hwt::PostWindow win_$name_ui -onDeleteWindow [::zbingf_UI::var_set $name_ui Quit]"

    eval "proc [::zbingf_UI::var_set $name_ui Quit] { args } { ::hwt::UnpostWindow win_$name_ui }"
}


proc ::zbingf_UI::tk_entry {name_ui name n_line var_name} {
    eval "set recess $[::zbingf_UI::var_set $name_ui recess]"
    eval "set width $[::zbingf_UI::var_set $name_ui entry_width]"

    eval "label $recess.entry_label_$n_line -text \"$name\" -font {MS 10}"
    eval "grid $recess.entry_label_$n_line -row $n_line -column 0 -padx 2 -pady 2 -sticky nw;"

    eval "entry $recess.entry_$n_line -width $width -textvariable [::zbingf_UI::var_set $name_ui $var_name] -font {MS 10}"
    eval "grid $recess.entry_$n_line -row $n_line -column 1 -padx 2 -pady 2 -sticky nw;"
}


proc ::zbingf_UI::tk_button {name_ui name n_line fun_name} {
    eval "set recess $[::zbingf_UI::var_set $name_ui recess]"
    eval "set width $[::zbingf_UI::var_set $name_ui button_width]"

    button $recess.button_$n_line \
        -text "$name" \
        -command [::zbingf_UI::var_set $name_ui $fun_name] \
        -width $width ;
    grid $recess.button_$n_line -row $n_line -column 0 -padx 2 -pady 2 -sticky nw;
}
