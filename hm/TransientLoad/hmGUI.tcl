# -------------------------------------
# hypermesh 13.0
# 二次开发菜单，运行时创建GUI界面
# 根据各个按钮，调用其他代码
# source E:/github/For_Hyperworks/hmGUI.tcl

# -------------------------------------
set filepath [file dirname [info script]]
puts $filepath

set label_width 18
set button_width 15

# -------------------------------------
# 初始设置
destroy .f
frame .f
frame .f.top
pack .f.top -side top -fill both;
frame .f.bottom
pack .f.bottom -side bottom -fill x -expand 0;

# -------------------------------------
# 1层
frame .f.top.0 -bg #99ff99
pack .f.top.0 -anchor nw
foreach i {1 2 3 4 5 6 7 8 9} {
	frame .f.top.$i
	pack .f.top.$i -side left -fill x
}

# -------------------------------------
# 2层-1列
label .f.top.0.1 -text "模态叠加相关" -width $label_width -height 1
button .f.top.1.1 -text "del OMIT & RIGID" -command [format "source %s/hmTransientModal_1.tcl" $filepath] -bg #99ff99 -width $button_width


# -----------------------
foreach hloc {0 1 2 3 4 5 6 7 8 9} {
	foreach vloc {0 1 2 3 4 5 6 7 8 9} {
		if { $vloc == 0 } {
			# 标题
			catch {
				pack .f.top.0.$hloc -side left -anchor nw 
			}
		} else {
			catch {
				#  -padx 5 -pady 1
				pack .f.top.$vloc.$hloc -side top -anchor nw -padx 6 -pady 2
			}
		}
	}
}

# -----------------------
button .f.bottom.button -text "return" -command hm_exitpanel -bg #C06060 -width 10
pack .f.bottom.button -side right -anchor e;
hm_framework addpanel .f "二次开发插件"
hm_framework drawpanel .f





