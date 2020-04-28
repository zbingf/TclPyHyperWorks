# -------------------------------------
# hmGUi.tcl
# source E:/github/For_Hyperworks/hmGUI.tcl
# 创建gui界面,调用其他代码
# -------------------------------------

set filepath [file dirname [info script]]
puts $filepath

destroy .f
frame .f
frame .f.top
pack .f.top -side top -fill both;
frame .f.bottom
pack .f.bottom -side bottom -fill x -expand 0;

# 1层
frame .f.top.0 -bg #99ff99
pack .f.top.0 -anchor nw

foreach i {1 2 3 4 5 6 7 8 9} {
	frame .f.top.$i
	pack .f.top.$i -side left -fill x
}
# 2层-0行
label .f.top.0.1 -text "CompEdit" -width 13 -height 1
label .f.top.0.2 -text "梁单元" -width 13 -height 1
label .f.top.0.3 -text "分析设置" -width 12 -height 1
label .f.top.0.4 -text "材料属性" -width 13 -height 1
label .f.top.0.5 -text "瞬态-模态分析" -width 13 -height 1
label .f.top.0.6 -text "其他分析" -width 12 -height 1
label .f.top.0.7 -text "其他插件" -width 26 -height 1
foreach i {1 2 3 4 5 6 7} {
	pack .f.top.0.$i -side left -anchor nw
}

# 2层-1列
button .f.top.1.1 -text "加前缀" -command [format "source %s/hmCompEdit.tcl;comp_edit front" $filepath] -bg #99ff99 -width 10
button .f.top.1.2 -text "加后缀" -command [format "source %s/hmCompEdit.tcl;comp_edit rear" $filepath] -bg #99ff99 -width 10
button .f.top.1.3 -text "替换" -command [format "source %s/hmCompEdit.tcl;comp_edit replace" $filepath] -bg #99ff99 -width 10
foreach i {1 2 3} {
	pack .f.top.1.$i -side top -anchor nw -padx 5 -pady 1
}

# 2层-2列
button .f.top.2.1 -text "矩形钢" -command [format "source %s/hmRectangularBox.tcl" $filepath] -bg #99ff99 -width 10
button .f.top.2.2 -text "厚度测量" -command [format "source %s/hmSolidThickness.tcl" $filepath] -bg #99ff99 -width 10
foreach i {1 2} {
	pack .f.top.2.$i -side top -anchor nw -padx 5 -pady 1
}
# 2层-3列
button .f.top.3.1 -text "mnf创建设置" -command [format "source %s/hmMnfSet.tcl" $filepath] -bg #99ff99 -width 10
button .f.top.3.2 -text "悬架提载创建" -command [format "source %s/hmSusLoadSet.tcl" $filepath] -bg #99ff99 -width 10
button .f.top.3.3 -text "模态分析设置" -command [format "source %s/hmModalSet.tcl" $filepath] -bg #99ff99 -width 10
foreach i {1 2 3} {
	pack .f.top.3.$i -side top -anchor nw -padx 5 -pady 1
}
# 2层-4列
button .f.top.4.1 -text "材料创建" -command [format "source %s/hmMaterials.tcl" $filepath] -bg #99ff99 -width 10
foreach i {1} {
	pack .f.top.4.$i -side top -anchor nw -padx 5 -pady 1
}
# 2层-5列
button .f.top.5.1 -text "del-OMIT" -command [format "source %s/hmTransientModal1.tcl" $filepath] -bg #99ff99 -width 10
button .f.top.5.2 -text "del-RIGID" -command [format "source %s/hmTransientModal2.tcl" $filepath] -bg #99ff99 -width 10
foreach i {1 2} {
	pack .f.top.5.$i -side top -anchor nw -padx 5 -pady 1
}


# ----d
button .f.bottom.button -text "return" -command hm_exitpanel -bg #C06060 -width 10
pack .f.bottom.button -side right -anchor e;
hm_framework addpanel .f "二次开发插件"
hm_framework drawpanel .f



