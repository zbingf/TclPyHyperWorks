# -------------------------------------
# hypermesh 13.0
# 二次开发菜单，运行时创建GUI界面
# 根据各个按钮，调用其他代码
# source D:/github/TclPyHyperWorks/hm/hmGUI.tcl

namespace eval ::hmGUI {
    variable filepath;
    variable label_width;
    variable button_width 20; 
}


# 列-创建
proc create_label_button {loc line} {

	set line_title [lindex $line 0]
	set line_button [lrange $line 1 end]

	label .f.top.$loc.0  -text "$line_title" -width $::hmGUI::label_width -height 1 -font {MS 10}  -compound center
	set num [llength $line_button]
	set n_cur 1
	foreach button_data $line_button {
		set name [lindex $button_data 0]
		set file_command [lindex $button_data 1]
		button .f.top.$loc.$n_cur -text "$name" -command [format "source %s/%s" $::hmGUI::filepath $file_command] -bg #99ff99 -width $::hmGUI::button_width -font {MS 10}
		if {$n_cur==$num} { break }
		set n_cur [expr $n_cur+1]
	}	
}


# -------------------------------------
set ::hmGUI::filepath [file dirname [info script]]
puts $::hmGUI::filepath
set ::hmGUI::label_width $::hmGUI::button_width

# -------------------------------------
# 初始设置
destroy .f
frame .f
frame .f.top
pack .f.top -side top -fill both;
# frame .f.bottom
# pack .f.bottom -side bottom -fill x -expand 0;

for { set i 1 } { $i < 10 } { incr i 1 } {
	frame .f.top.$i
	pack .f.top.$i -side left -fill x -anchor nw 
}
# -------------------------------------
# 正则
# .*-text "(\S+)".*%s/(\S+)".*
# lappend line "{$1} {$2}"\n

# -------------------
set 	line "Comp编辑"
lappend line "{Comp-加前缀} {Component/hmCompNameEdit.tcl;comp_edit front}"
lappend line "{Comp-加后缀} {Component/hmCompNameEdit.tcl;comp_edit rear}"
lappend line "{Comp-替换} {Component/hmCompNameEdit.tcl;comp_edit replace}"
lappend line "{Comp-去重} {Component/hmCompEdit.tcl}"
create_label_button 1 $line

# -------------------
set 	line "Solid"
lappend line "{Comp分类_厚度测量} {hmSolidThickness.tcl}"
create_label_button 2 $line

# -------------------
set 	line "网格划分-处理-1"
lappend line "{Elem_以solid复制} {ElemCopyBySolid/hmElemCopyBySolid.tcl}"
lappend line "{Beam_矩形钢_创建} {BeamRectangularBox/hmBeamRectangularBoxPoint16.tcl}"
lappend line "{Node_孔周围_创建} {HoleMesh/hmHoleMesh01.tcl}"
create_label_button 3 $line

# -------------------
set 	line "网格划分-处理-2"
lappend line "{Tie_面对面_创建} {TieSurfToSurfCreate/hmTieSurfToSurfCreate.tcl}"
lappend line "{Tie_点对面_Select} {TiePointToSurfCreateSelect/hmTiePointToSurfCreateSelect.tcl}"
lappend line "{基于Tie_检查_网格连接} {CheckElemAttachTie/hmCheckElemAttachTie.tcl}"
create_label_button 4 $line

# -------------------
set 	line "网格划分-处理-3"
lappend line "{Bolt_孔连接_创建} {BoltHoleConnect/hmBoltHoleConnect.tcl}"
lappend line "{Bolt_孔对称_校正} {BoltHoleCorrect/hmBoltHoleCorrect.tcl}"
lappend line "{Bolt_孔对称_检查} {BoltHoleCheck/hmBoltHoleCheck.tcl}"
lappend line "{Bolt_螺栓孔_分类} {BoltHoleClassify/hmBoltHoleClassify.tcl}"
lappend line "{bar2_平行Z轴_校正} {BoltHoleAxisZCorrect/hmBoltHoleAxisZCorrect.tcl}"
create_label_button 5 $line

# -------------------
set 	line "卡片创建"
lappend line "{mnf创建设置} {FlexBody/hmMnfSet.tcl}"
lappend line "{模态分析设置} {hmModalSet.tcl}"
lappend line "{ASET编号} {AsetNodeIdRename/hmAsetIdRename.tcl}"
lappend line "{Node创建} {AsetNodeIdRename/hmNodeCreate.tcl}"
create_label_button 6 $line

# -------------------
set 	line "材料相关"
lappend line "{一般材料创建} {Materials/hmMaterials.tcl}"
lappend line "{Mat_去重_ENR} {Materials/hmMatEdit_ENR.tcl}"
lappend line "{Prop_去重_SS} {Materials/hmPropertyEdit_Pshell_Psolid.tcl}"
lappend line "{Mat_Rename} {Materials/hmMatRename.tcl}"
lappend line "{Prop_Rename} {Materials/hmPropRename.tcl}"
create_label_button 7 $line

# -------------------
set 	line "其他"
# lappend line "{悬架提载创建} {hmSusLoadSet.tcl}"
lappend line "{模态叠加相关UI} {TransientLoad/hmGUI.tcl}"
lappend line "{删除-无用卡片} {hmDelEmptyEntity.tcl}"
lappend line "{测试} {zing_NodeToSurf/hmNodeToSurf.tcl}"
create_label_button 8 $line


# -----------------------
# pack
for { set hloc 0 } { $hloc < 10 } { incr hloc 1 } {
	for { set vloc 1 } { $vloc < 10 } { incr vloc 1 } {
		catch {
			pack .f.top.$vloc.$hloc -side top -anchor nw -padx 4 -pady 2
		}
	}
}


# -----------------------
hm_framework addpanel .f "二次开发插件"
hm_framework drawpanel .f



