# 
# 删除无用卡片
#

set choice [tk_messageBox -type yesnocancel -default yes -message "是否计算" -icon question ]
if {$choice != yes} {return;}


proc del_empty_entity {entity_name dataname} {
	*createmark $entity_name 1 "all"
	set tar_ids [hm_getmark $entity_name 1]

	foreach id_n $tar_ids {
		*createmark $entity_name 1 $id_n
		set n_ids [ hm_getvalue $entity_name id=$id_n dataname=$dataname]
		set n_len [ llength $n_ids ]
		if {$n_len == 0} {
			# puts $n_len
			set a [ hm_getvalue $entity_name id=$id_n dataname=name]
			puts "Delete $entity_name : $a"
			*deletemark $entity_name 1
		}
	}
}

del_empty_entity "sets" ids
del_empty_entity contactsurfs elements
del_empty_entity groups slaveentityids
