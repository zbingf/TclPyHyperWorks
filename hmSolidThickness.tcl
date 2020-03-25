# 测量实体厚度
# 抽中面

proc value_cal {value} {
	# 数值处理,四舍六入五保留
	set n [expr [expr int([expr $value * 10])] % 10]
	if {$n > 5} {
		set value [expr round($value)]
	} elseif {$n < 5} {
		set value [expr int($value)]
	}
	return $value
}

proc start_end {} {
	# 开头及结束
	# 清空 comps 1
	*EntityPreviewEmpty comps 1
	if {[hm_getmark comps 1] != []} {
		*deletemark comps 1
		*clearmark comps 1
	}
}

proc surf_thickness {surf_id solid_id comp_name_midsurf} {
	# 根据面id 输出厚度
	# surf 上创建node点
	set surf_geomid [hm_getentityvalue surfs $surf_id "geomid" 0]
	*createnode 0 0 0 0 $surf_id $surf_geomid
	*createmark nodes 1 -1
	set node_id [hm_getmark nodes 1]
	if {[catch {hm_getsurfacethicknessvalues nodes $node_id}]} {
		# 获取中面厚度值失败
		*nodecleartempmark
		*clearmark nodes 1
		if {[catch {*nodecreateatsurfparams surfs $surf_id 0.5 0.5 1 0.5 0.5 1 3 0}]} {
			# 在根据面创建node点 - 再次获取失败
			*createmark solids 1 $solid_id
			*numbersmark solids 1 1
			if {$comp_name_midsurf != []} {
				# 用于判断是否删除 面
				*createmark comps 1 $comp_name_midsurf
				*deletemark comps 1
			}
			# 返回空值
			return []
		} else {
			# 根据面上创建的点,进行关联,获取厚度数组
			*nodecreateatsurfparams surfs $surf_id 0.5 0.5 1 0.5 0.5 1 3 0
			*createmark nodes 1 -1
			set node_id [hm_getmark nodes 1]
			# gro - node edit - associate 关联node与surf
			*nodesassociatetogeometry 1 surfs $surf_id 100
			set node_thick_set [hm_getsurfacethicknessvalues nodes $node_id]
		}
		if {[llength $node_thick_set] > 1} {
			# 当有多组厚度数据是,逐一检索 surfid 是否一致, 一致则应获取对应数组厚度
			set i 0
			while {$i <= [llength $node_thick_set] } {
				if {[lindex [lindex $node_thick_set $i] 0]} {
					set thickness [format "%.1f" [lindex [lindex $node_thick_set $i] 1]]
					break
				}
				incr 1
			}
		} else {
			# 获取厚度数据
			set thickness [format "%.1f" [lindex [lindex $node_thick_set 0] 1]]
		}
	} else {
		set thickness [format "%.1f" [lindex [lindex [hm_getsurfacethicknessvalues nodes $node_id] 0] 1]]
	}
	return thickness
}

proc main_thickness {} {
	# 开始
	start_end
	set solid_id0 [hm_getmark solids 1]

	foreach solid_id $solid_id0 {
		# 显示设置
		*setsurfacenormalsdisplaytype 1
		*normalsoff
		# 选择
		*createmark surfaces 1 "by solids" $solid_id
		# 创建 - 中面
		*midsurface_extract_10 surfaces 1 -1 0 1 1 0 0 2 0 0 10 0 10 -2 undefined 0 0 1
		# 赋值 comp_name_midsurf
		set comp_name_midsurf "Middle Surface"
		# 获取 -中面
		*createmark surfaces 1 "by comp name" $comp_name_midsurf
		if {[hm_getmark surfs 1] == []} {
			# 中面为空,删除中面并进行标记
			# 获取对应 solid
			*createmark solids 1 $solid_id
			# 显示 solid id
			*numbersmark solids 1 1
			# 中面获取
			*createmark comps 1 $comp_name_midsurf
			# 删除中面
			*deletemark comps 1
			continue
		}
		# 中面mark 赋值 surf_id1
		set surf_id1 [hm_getmark surfs 1]
		# 首个 surfid 对应的厚度
		set thickness [surf_thickness [lindex $surf_id1 0] $solid_id $comp_name_midsurf]
		if {$thickness != []} {
			set t0 $thickness
		} else { continue }
		# 厚度数值处理
		set t0 [value_cal $t0]
		# 清除所有temp nodes
		*nodecleartempmark
		# 清理 nodes mark
		*clearmark nodes 1
		# 赋初值
		set i_flag 0
		# 检索各中面
		foreach surf_id $surf_id1 {
			set thickness [surf_thickness $surf_id $solid_id []]
			if {$thickness != []} {
				set t1 $thickness
			} else {
				set i_flag 1
				break
			}
			# 厚度数值处理
			set t1 [value_cal $t1]
			*nodecleartempmark
			*clearmark nodes 1
			if {$t1 != $t0} {
				set i_flag 1
				break
			}
		}
		if {$i_flag == 0} {
			# compo 名称拼接
			
		}

	}
}