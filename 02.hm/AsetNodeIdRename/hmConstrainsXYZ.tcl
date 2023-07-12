# ASET 所属NodeId 编号重命名


set filepath [file dirname [info script]]
set csv_path [format "%s/__temp_nodes.txt" $filepath]


# 获取node id 坐标
proc get_node_locs {node_id prefix} {
	set x [hm_getvalue nodes id=$node_id dataname=x]
	set y [hm_getvalue nodes id=$node_id dataname=y]
	set z [hm_getvalue nodes id=$node_id dataname=z]
	if {$prefix == []} {
		return "$x $y $z"
	} else {
		return "$x$prefix$y$prefix$z"
	}
}


# 
proc print_csv_aset_node_id_loc {csv_path c_type} {
	# 获取所有 ASET 对应的 nodeID 及 坐标数据
	# 创建csv文件路径

	set f_obj [open $csv_path w]
	puts $f_obj "ASET_node_id,x,y,z"
	puts "ASET_node_id, x, y, z"

	*createmark loads 1 all
	set loads_ids [hm_getmark loads 1]
	foreach load_id $loads_ids {
		# node id
		set node_id [hm_getvalue loads id=$load_id dataname=location]
		# 约束类型
		set type_name [hm_getvalue loads id=$load_id dataname=typename]

		# puts "NodeId: $node_id  type: $type_name"
		if {$type_name == "$c_type"} {
			# puts "type is ASET"
			set locs [get_node_locs $node_id "," ]
			# puts "$node_id,$locs"
			puts $f_obj "$node_id,$locs"
			puts "$node_id, $locs"
		} 
	}
	close $f_obj

	return true
}


# -----------------------------------

print_csv_aset_node_id_loc $csv_path ASET
