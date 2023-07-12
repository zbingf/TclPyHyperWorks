# hm 2017
# 带孔的矩形网格面复制

# 获取surf面积
proc get_surf_area {surf_ids} {
	set area_sum 0
	foreach surf_id $surf_ids {
		set value [hm_getareaofsurface surfs $surf_id]
		set area_sum [expr $area_sum + $value]
	}
	return $area_sum
}


