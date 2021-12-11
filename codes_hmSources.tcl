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





*createmark points 1 "by lines" 4952
set point_1_id [lindex [hm_getmark points 1] 0]
set loc1 [hm_getcoordinates point $point_1_id]
set loc2 [eval "hm_findclosestpointonline $loc1 $line_id"]
eval "*createnode $loc2 0 0 0"


# 获取线上坐标
set line_id 4952
set point_locs [hm_getcoordinatesofpointsonline $line_id [list 0.0 0.5]]
puts $point_locs



set loc1 [hm_getcoordinates point [lindex $point_circle_ids 0]]

set x [hm_getvalue nodes id=$node_circle_center_id dataname=x]
set y [hm_getvalue nodes id=$node_circle_center_id dataname=y]
set z [hm_getvalue nodes id=$node_circle_center_id dataname=z]









# --------------------------------
# 根据line_id 获取闭环数据 point\line
proc get_circle_data_by_line {line_id} {

	namespace eval ::TempData {
	    variable line_ids []
	    variable point_ids []
	}

	proc line_to_points {line_id} {
		
		if {$line_id in $::TempData::line_ids} {return}
		lappend ::TempData::line_ids "$line_id"

		*createmark points 1 "by lines" $line_id
		set point_ids [hm_getmark points 1]
		if {[llength $point_ids]<2} {
			lappend ::TempData::point_ids $point_ids
			return
		}
		# puts "cal_line : $line_id"
		foreach point_id $point_ids {
			if {$point_id in $::TempData::point_ids} {
				continue
			} else {
				lappend ::TempData::point_ids $point_id
			}

			*createmark lines 1 "by points" $point_id
			set line_2_ids [hm_getmark lines 1]
			# puts "cal_line_2_ids : $line_2_ids"
			foreach line_temp_id $line_2_ids {
				line_to_points $line_temp_id
			}
		}
	}

	set ::TempData::line_ids []
	set ::TempData::point_ids []
	line_to_points $line_id
	# puts "line_ids : $::TempData::line_ids"
	# puts "point_ids : $::TempData::point_ids"
	set line_ids $::TempData::line_ids
	set point_ids $::TempData::point_ids
	set ::TempData::line_ids []
	set ::TempData::point_ids []
	return "{$line_ids} {$point_ids}"
}

# 根据line_id 获取闭环数据 point\line in lines
proc get_circle_data_by_line_in_lines {line_id base_ids} {
	# line_id 需在 base_ids 里

	namespace eval ::TempData {
	    variable line_ids []
	    variable point_ids []
	    variable base_ids []
	}

	proc line_to_points {line_id} {
		
		if {$line_id in $::TempData::line_ids} {return}
		if {$line_id in $::TempData::base_ids} {} else {return}
		lappend ::TempData::line_ids "$line_id"

		*createmark points 1 "by lines" $line_id
		set point_ids [hm_getmark points 1]
		if {[llength $point_ids]<2} {
			lappend ::TempData::point_ids $point_ids
			return
		}
		# puts "cal_line : $line_id"
		foreach point_id $point_ids {
			if {$point_id in $::TempData::point_ids} {
				continue
			} else {
				lappend ::TempData::point_ids $point_id
			}

			*createmark lines 1 "by points" $point_id
			set line_2_ids [hm_getmark lines 1]
			# puts "cal_line_2_ids : $line_2_ids"
			foreach line_temp_id $line_2_ids {
				line_to_points $line_temp_id
			}
		}
	}

	set ::TempData::line_ids []
	set ::TempData::point_ids []
	set ::TempData::base_ids $base_ids
	line_to_points $line_id
	# puts "line_ids : $::TempData::line_ids"
	# puts "point_ids : $::TempData::point_ids"
	set line_ids $::TempData::line_ids
	set point_ids $::TempData::point_ids
	set ::TempData::line_ids []
	set ::TempData::point_ids []
	set ::TempData::base_ids []
	return "{$line_ids} {$point_ids}"
}


# 根据 line 获取 相应面的 闭环line\point id
proc get_surf_data_by_line {line_id} {

	*createmark surfs 1 "by lines" $line_id
	set surf_id [hm_getmark surfs 1]
	*createmark lines 1 "by surface" $surf_id
	set line_surf_ids [hm_getmark lines 1]
	puts "line_surf_ids : $line_surf_ids"
	set line_cur_ids []

	set circle_data [get_circle_data_by_line_in_lines [lindex $line_surf_ids 0] $line_surf_ids]
	set circle_data_list "{$circle_data}"
	set line_cur_ids [concat $line_cur_ids [lindex $circle_data 0]]

	foreach line_surf_id [lrange $line_surf_ids 1 end] {
		if {$line_surf_id in $line_cur_ids} {continue} else {
			set circle_data [get_circle_data_by_line_in_lines $line_surf_id $line_surf_ids]
			lappend circle_data_list $circle_data
			set line_cur_ids [concat $line_cur_ids [lindex $circle_data 0]]			
			puts "cur_line_cur_ids : $line_cur_ids"
		}
	}
	return $circle_data_list
}


set line_id 4954
puts [get_surf_data_by_line $line_id]


# hm_entityrecorder