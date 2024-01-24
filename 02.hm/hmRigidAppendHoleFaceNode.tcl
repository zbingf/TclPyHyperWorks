

proc washer_add_3d_mesh {} {
	# rigid de node append node by solid hold surface 
	# 2023/01/22

	*createmarkpanel node 1 "select rbe2 "

	*appendmark node 1 "node for by face search"
	set list1 [hm_getmark node 1]

	*createmarkpanel elem 1 
	set rbe2_id [hm_getmark elem 1]

	set node1_id [hm_getvalue elems id=$rbe2_id dataname=nodes]
	set node2_id [lrange $node1_id 1 end]

	set new_node_ids [concat $node2_id $list1]
	set node_id_inde [lindex $node1_id 0]

	hm_createmark nodes 1 $new_node_ids
	*rigidlinkupdate $rbe2_id $node_id_inde 1

	puts "calc end"
}

washer_add_3d_mesh