# hypermesh 二次开发类型
# Tcl GUI Commands
# Tcl Modify Commands
# Tcl Query Commands
# Utility Menu Commands

# ----------------------------------------
# 提前回答
hm_answernext yes
# 删除模型
*deletemodel


# 路径
set filepath [file dirname [info script]]

# Altair 主目录
# D:/software/Altair/2019
set altair_dir [hm_info -appinfo ALTAIR_HOME]
set optistruct_path [format "%s/templates/feoutput/optistruct/optistruct" $altair_dir]

# 版本
set hm_version [lindex [split [hm_info -appinfo DISPLAYVERSION] .] 0]

# 材料属性 调用路径 optistruct 
set altair_dir [hm_info -appinfo ALTAIR_HOME]
set optistruct_path [format "%s/templates/feoutput/optistruct/optistruct" $altair_dir]


# “文件”面板中导出模板的完整路径和文件名。HyperMesh批处理模式下不能使用该选项。
set a [hm_info exporttemplate]
# D:/software/Altair/2019/templates/feoutput/optistruct/optistruct


# ----------------------------------------
# 获取 整数值 hm_getint
set a [hm_getint]
set count [hm_getint "Count=" "Please specify the count"]

# 获取 浮点值 
set distance [hm_getfloat "Distance=" "Please specify a distance"]

# 获取字符串
hm_getstring



# 命令行输入栏位置设置
hm_setcommandposition top
hm_setcommandposition bottom


# ---------------------------------------
# 选实体solid, 获取相应ID列表
*createmarkpanel solids 1 "Select the solids"
set solidsId [hm_getmark solids 1]

# 视角设置
*view leftside
*view rightside
*view rear
*view iso1



# ---------------------------------------
# 获取 所有loads约束点对应的Node ID 及 约束类型
# HyperWorks Desktop Reference Guides → HyperMesh Data → Names
*createmark loads 1 all
set loads_ids [hm_getmark loads 1]
foreach load_id $loads_ids {
	# node id
	set node_id [hm_getvalue loads id=$load_id dataname=location]
	# 约束类型
	set type_name [hm_getvalue loads id=$load_id dataname=typename]

	puts "NodeId: $node_id  type: $type_name"
	if {$type_name == "ASET"} {
		puts "type is ASET"
	} 
}



# ---------------------------------------

# hm_getlinetype

# 获取特征
# 根据线获取-圆特征线
*createmark lines 1 "by surface" 15
puts [hm_getmark lines 1]
hm_markbyfeature 1 1 "feature_mode 1 min_radius 0.1 max_radius 1"
puts [hm_getmark lines 1]

# 根据面获取-圆特征线
*createmark surfs 1 15
puts [hm_getmark surfs 1]
hm_markbyfeature 1 1 "feature_mode 2 min_radius 0.1 max_radius 1"
puts [hm_getmark lines 1]



