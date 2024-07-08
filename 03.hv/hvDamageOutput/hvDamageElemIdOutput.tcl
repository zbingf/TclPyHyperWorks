

namespace eval ::hvElemDamageOutput {
    variable elem_ids 
    variable recess
    variable curfile_dir [file dirname [info script]]
}


# UI界面
proc ::hvElemDamageOutput::GUI { args } {
    variable recess

    set minx [winfo pixel . 300p]
    set miny [winfo pixel . 100p]
    
    # 主窗口
    ::hwt::CreateWindow hvElemDamageOutputWin \
        -windowtitle "hvElemDamageOutput" \
        -resizeable 1 1 \
        -propagate 1 \
        -minsize $minx $miny \
        -cancelButton "Cancel" \
        -cancelFunc ::hvElemDamageOutput::Quit \
        noGeometrySaving
        # -addButton OK ::hvElemDamageOutput::OkExit no_icon \

    ::hwt::KeepOnTop .hvElemDamageOutputWin

    set recess [::hwt::WindowRecess hvElemDamageOutputWin]

    grid columnconfigure $recess 2 -weight 1
    grid rowconfigure    $recess 10 -weight 1

    # ===================
    ::hwt::LabeledLine $recess.end_line1 "ELement Ids \[eg:111,222\]" -font {MS 10}
    grid $recess.end_line1 -row 1 -column 0 -pady 6 -sticky ew -columnspan 2

    # label $recess.nEntry_label -text "ELementId编号" -font {MS 10}
    # grid $recess.nEntry_label -row 2 -column 0 -padx 2 -pady 2 -sticky nw;
    entry $recess.nEntry -width 50 -textvariable ::hvElemDamageOutput::elem_ids
    grid $recess.nEntry -row 2 -column 0 -padx 2 -pady 2 -sticky nw;

    # ===================
    button $recess.calcButton \
        -text "自动导出elem损伤&合并各工况" \
        -command ::hvElemDamageOutput::fun_calcButton \
        -width 40 \
        -font {MS 10}

    grid $recess.calcButton -row 3 -column 0 -padx 2 -pady 2 -sticky nw;
    # ===================


    # ===================
    ::hwt::RemoveDefaultButtonBinding $recess
    ::hwt::PostWindow hvElemDamageOutputWin -onDeleteWindow ::hvElemDamageOutput::Quit

}


# 主程序
proc ::hvElemDamageOutput::OkExit { args } {

}


proc ::hvElemDamageOutput::Quit { args } {

    ::hwt::UnpostWindow hvElemDamageOutputWin
}



proc output_damage {csv_path setid} \
{
    hwi OpenStack
        hwi GetSessionHandle sessObj
        sessObj GetProjectHandle proObj
        proObj GetPageHandle pagObj [proObj GetActivePage]
        pagObj GetWindowHandle winObj [pagObj GetActiveWindow]
        winObj GetClientHandle postObj
        postObj GetModelHandle modelObj [postObj GetActiveModel]
        modelObj GetResultCtrlHandle resultObj

        modelObj GetSelectionSetHandle selectionObj [modelObj AddSelectionSet elem]
        selectionObj Add "idlist $setid"

        modelObj GetQueryCtrlHandle qryObj 

        qryObj SetQuery "element.id,contour.value"
        qryObj SetSelectionSet [selectionObj GetID]
        qryObj WriteData $csv_path
    hwi CloseStack
}


proc ::hvElemDamageOutput::fun_calcButton { args } {

    variable elem_ids
    variable curfile_dir

    set choice [tk_messageBox -type yesnocancel -default yes -message "是否计算" -icon question ]
    if {$choice == "yes"} {} else {return;}

    set py_path   [format "%s/hvDamageCsvCombine.py" $curfile_dir]

    set model_path [tk_getOpenFile -title "open model_path"]
    set result_paths [tk_getOpenFile -multiple 1  -title "open result_paths"]
    # set setid "15147,14537,14520"

    foreach result_path $result_paths {
        # open damdage
        hwc open animation modelandresult $model_path $result_path
        # load subcase
        hwc result subcase "Loadcase 1"
        # set type
        # hwc result scalar load type=Stress component=vonMises layer=Max
        hwc result scalar load type=Damage
        # csv path
        set csv_path "$result_path.csv"
        puts "csv_path: $csv_path"
        
        output_damage $csv_path $elem_ids
    }

    set result_py [exec python $py_path ]


    puts "\n=======calc end=======\n"
}


::hvElemDamageOutput::GUI;

# source "D:/github/TclPyHyperWorks/03.hv/hvDamageOutput/hvDamageElemIdOutput.tcl"