
# CSV格式
# ID,  x,  y,  z,   type,    DOF, log
# 1 , 10, 10, 10,   ASET, 123456, 备注



proc read_csv {csv_path} {
	set csv_obj [open $csv_path r]
	set titles [lrange [split [gets $csv_obj] ","] 0 6]
	set data []
	while {![eof $csv_obj]} {
		set lines [lrange [split [gets $csv_obj] ","] 0 6]
		if {[llength $lines]<3} {continue}
		# set loc  [lrange $lines 1 3]
		# set id   [lindex $lines 0]
		# set type [lindex $lines 4]
		# set dof  [lindex $lines 5]
		# set log  [lindex $lines 6]
		set line_dict []
		dict set line_dict loc  [lrange $lines 1 3]
		dict set line_dict id   [lindex $lines 0]
		dict set line_dict type [lindex $lines 4]
		dict set line_dict dof  [lindex $lines 5]
		dict set line_dict log  [lindex $lines 6]
		lappend data $line_dict
	}
	close $csv_obj
	return $data
}


# 
proc create_node_by_loc {loc} {
	hm_entityrecorder nodes on
		eval "*createnode $loc 0 0 0"
	hm_entityrecorder nodes off
	set node_id [hm_entityrecorder nodes ids]
	return $node_id
}
# create_node_by_loc "0 0 0"


proc create_ASET_by_node_id {node_id dof} {
	set dof [string trim $dof]
	set dof_len [string length $dof]
	set dof_str "1 2 3 4 5 6"
	for { set i 0 } { $i < $dof_len } { incr i 1 } {
		set cur_dof [string index $dof $i]
		set dof_str [string map "$cur_dof 0" $dof_str]
		# puts "cur_dof: $cur_dof ; dof_str : $dof_str"
	}
	set dof_sets []
	foreach cur_dof $dof_str {
		if {$cur_dof>0} {
			lappend dof_sets -999999
		} else {
			lappend dof_sets 0
		}
	}
	eval "*createmark nodes 1 $node_id"
	hm_entityrecorder loads on
		# puts "*loadcreateonentity_curve nodes 1 3 8 $dof_sets 0 0 0 0 0"
		eval "*loadcreateonentity_curve nodes 1 3 8 $dof_sets 0 0 0 0 0"
	hm_entityrecorder loads off
	return [hm_entityrecorder loads ids]
}


proc create_comp_by_name {comp_name} {
	hm_entityrecorder comps on
		*createentity comps name=$comp_name
	hm_entityrecorder comps off
	set comp_id [hm_entityrecorder comps ids]
	return $comp_id
}


proc create_comp_by_name_try {comp_name} {
	set status [catch {
		set comp_id [create_comp_by_name $comp_name]
		return $comp_id
	}]
	if {$status} {
		return [hm_getvalue comps name=$comp_name dataname=id]
	}
	
}


proc create_loadcol_by_name {loadcol_name} {
	hm_entityrecorder loadcols on
		*createentity loadcols name=$loadcol_name
	hm_entityrecorder loadcols off
	set loadcol_id [hm_entityrecorder loadcols ids]
	return $loadcol_id
}


proc create_loadcol_by_name_try {loadcol_name} {
	set status [catch {
		set loadcol_id [create_loadcol_by_name $loadcol_name]
		return $loadcol_id
	}]
	if {$status} {
		return [hm_getvalue loadcols name=$loadcol_name dataname=id]
	}
}


proc current_loadcol_by_name {loadcol_name} {
	*currentcollector loadcols $loadcol_name
}


proc current_comp_by_name {comp_name} {
	*currentcollector comps $comp_name
}


proc create_rigid_by_nodes_default {node_ids} {
	eval "*createmark nodes 1 $node_ids"
	hm_entityrecorder elems on
		*rigidlinkinodecalandcreate 1 0 0 123456
	hm_entityrecorder elems off
	return [hm_entityrecorder elems ids]
}


# ID重命名
proc rename_node_id {node_id target_node_id} {
	if {$node_id==$target_node_id} {return 1}

	set incr_id 1000000
	set cur_id $target_node_id
	while {1} {
		eval "*createmark nodes 1 $target_node_id"
		if {[llength [hm_getmark nodes 1]]<1} { break }
		set cur_id [expr $cur_id + $incr_id]
		catch {
			*renumbersolverid nodes 1 $cur_id 1 0 0 0 0 0 0	
		}
	}
	eval "*createmark nodes 1 $node_id"
	*renumbersolverid nodes 1 $target_node_id 1 0 0 0 0 0 0
}


proc main_cal {csv_path} {
	set data [read_csv $csv_path]

	set loadcol_id [create_loadcol_by_name_try "ASET"]
	current_loadcol_by_name "ASET"
	set comp_id [create_comp_by_name_try "__temp_rigid"]
	current_comp_by_name "__temp_rigid"

	set node_ids []
	# set ASET_ids []
	# set target_ASET_ids []
	foreach line_dict $data {
		set node_id [create_node_by_loc [dict get $line_dict loc]]
		lappend node_ids $node_id
		set ASET_id [create_ASET_by_node_id $node_id [dict get $line_dict dof]]
		# lappend ASET_ids $ASET_id
		set target_node_id [dict get $line_dict id]
		# lappend target_ASET_ids $target_ASET_id
		# puts "node_id: $node_id; target_node_id: $target_node_id;"
		rename_node_id $node_id $target_node_id
	}

	set rigid_id [create_rigid_by_nodes_default $node_ids]
}

set csv_path [tk_getOpenFile -title "select csv file" -filetypes {{{csv file} {.csv}}}]
main_cal $csv_path