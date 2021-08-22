# -------------------------------------
# hypermesh 13.0
# 二次开发菜单，运行时创建GUI界面
# 根据各个按钮，调用其他代码
# source E:/github/For_Hyperworks/hmGUI.tcl

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







# ----d
button .f.bottom.button -text "return" -command hm_exitpanel -bg #C06060 -width 10
pack .f.bottom.button -side right -anchor e;
hm_framework addpanel .f "二次开发插件"
hm_framework drawpanel .f

