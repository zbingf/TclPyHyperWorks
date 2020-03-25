# Auto_GUI.tcl
destroy .f
frame .f
frame .f.top
pack .f.top -side top -fill both;
frame .f.bottom
pack .f.bottom -side bottom -fill x -expand 0;


#1层
frame .f.top.0 -bg #99ff99
pack .f.top.0 -anchor nw

foreach i {1 2 3 4 5 6 7 8 9} {
	frame .f.top.$i
	pack .f.top.$i -side left -fill x
}
#2层0
label .f.top.0.1 -text "几何处理" -width 26 -height 1
# label .f.top.0.2 -text "网格连接" -width 13 -height 1
# label .f.top.0.3 -text "材料属性" -width 12 -height 1
# label .f.top.0.4 -text "刚度分析" -width 13 -height 1
# label .f.top.0.5 -text "强度分析" -width 13 -height 1
# label .f.top.0.6 -text "其他分析" -width 12 -height 1
# label .f.top.0.7 -text "其他插件" -width 26 -height 1
# foreach i {1 2 3 4 5 6 7} {
# 	pack .f.top.0.$i -side left -anchor nw
# }
pack .f.top.0.1 -side left -anchor nw


#2层1
button .f.top.1.1 -text "加前缀" -command "source hmCompEdit.tcl;comp_edit front" -bg #99ff99 -width 10
button .f.top.1.2 -text "加后缀" -command "source hmCompEdit.tcl;comp_edit rear" -bg #99ff99 -width 10
button .f.top.1.3 -text "替换" -command "source hmCompEdit.tcl;comp_edit replace" -bg #99ff99 -width 10
foreach i {1 2 3} {
	pack .f.top.1.$i -side top -anchor nw -padx 5 -pady 1
}

button .f.bottom.button -text "return" -command hm_exitpanel -bg #C06060 -width 10
pack .f.bottom.button -side right -anchor e;
hm_framework addpanel .f "二次开发插件"
hm_framework drawpanel .f



