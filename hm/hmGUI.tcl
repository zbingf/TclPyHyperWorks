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
for { set i 1 } { $i < 10 } { incr i 1 } {
	frame .f.top.$i
	pack .f.top.$i -side left -fill x
}


# -------------------------------------
# 2层-1列
label .f.top.0.1 -text "卡片编辑" -width $label_width -height 1
button .f.top.1.1 -text "Comp-加前缀" -command [format "source %s/hmCompEdit.tcl;comp_edit front" $filepath] -bg #99ff99 -width $button_width
button .f.top.1.2 -text "Comp-加后缀" -command [format "source %s/hmCompEdit.tcl;comp_edit rear" $filepath] -bg #99ff99 -width $button_width
button .f.top.1.3 -text "Comp-替换" -command [format "source %s/hmCompEdit.tcl;comp_edit replace" $filepath] -bg #99ff99 -width $button_width
button .f.top.1.4 -text "删除无用卡片" -command [format "source %s/hmDelEmptyEntity.tcl" $filepath] -bg #99ff99 -width $button_width


# 2层-2列
label .f.top.0.2 -text "网格划分-处理" -width $label_width -height 1
button .f.top.2.1 -text "beam-矩形钢" -command [format "source %s/RectangularBox/hmRectangularBox.tcl" $filepath] -bg #99ff99 -width $button_width
button .f.top.2.2 -text "厚度测量" -command [format "source %s/hmSolidThickness.tcl" $filepath] -bg #99ff99 -width $button_width


# 2层-3列
label .f.top.0.3 -text "卡片创建" -width $label_width -height 1
button .f.top.3.1 -text "mnf创建设置" -command [format "source %s/FlexBody/hmMnfSet.tcl" $filepath] -bg #99ff99 -width $button_width
button .f.top.3.3 -text "模态分析设置" -command [format "source %s/hmModalSet.tcl" $filepath] -bg #99ff99 -width $button_width
button .f.top.3.4 -text "ASET编号" -command [format "source %s/AsetNodeIdRename/hmAsetIdRename.tcl" $filepath] -bg #99ff99 -width $button_width
button .f.top.3.5 -text "Node创建" -command [format "source %s/AsetNodeIdRename/hmNodeCreate.tcl" $filepath] -bg #99ff99 -width $button_width


# 2层-4列
label .f.top.0.4 -text "材料相关" -width $label_width -height 1
button .f.top.4.1 -text "材料创建" -command [format "source %s/Materials/hmMaterials.tcl" $filepath] -bg #99ff99 -width $button_width
button .f.top.4.2 -text "Mat去重_ENR" -command [format "source %s/Materials/hmMatEdit_ENR.tcl" $filepath] -bg #99ff99 -width $button_width
button .f.top.4.3 -text "Prop去重_SS" -command [format "source %s/Materials/hmPropertyEdit_Pshell_Psolid.tcl" $filepath] -bg #99ff99 -width $button_width
button .f.top.4.4 -text "MatRename" -command [format "source %s/Materials/hmMatRename.tcl" $filepath] -bg #99ff99 -width $button_width
button .f.top.4.5 -text "PropRename" -command [format "source %s/Materials/hmPropRename.tcl" $filepath] -bg #99ff99 -width $button_width


# 2层-5列
label .f.top.0.5 -text "加载" -width $label_width -height 1
button .f.top.5.1 -text "悬架提载创建" -command [format "source %s/hmSusLoadSet.tcl" $filepath] -bg #99ff99 -width $button_width


# 2层-6列
label .f.top.0.6 -text "UI插件" -width $label_width -height 1
button .f.top.6.1 -text "模态叠加相关UI" -command [format "source %s/TransientLoad/hmGUI.tcl" $filepath] -bg #99ff99 -width $button_width


# -----------------------
for { set hloc 0 } { $hloc < 10 } { incr hloc 1 } {
	for { set vloc 0 } { $vloc < 10 } { incr vloc 1 } {
		if { $vloc == 0 } {
			# 标题
			catch {
				pack .f.top.0.$hloc -side left -anchor nw 
			}
		} else {
			catch {
				pack .f.top.$vloc.$hloc -side top -anchor nw -padx 6 -pady 2
			}
		}
	}
}


# -----------------------
# button .f.top.9.1 -text "return" -command hm_exitpanel -bg #C06060 -width 10
# pack .f.top.9.1 -side right -anchor e;
button .f.bottom.button -text "return" -command hm_exitpanel -bg #C06060 -width 10
pack .f.bottom.button -side right -anchor e;
hm_framework addpanel .f "二次开发插件"
hm_framework drawpanel .f



