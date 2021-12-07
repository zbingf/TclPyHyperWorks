# hm 2017
# 

set choice [tk_messageBox -type yesnocancel -default yes -message "是否计算\n根据Tie接触,显示未连接网格" -icon question]
if {$choice != yes} {return;}


proc get_group_tie_ids {} {
    *createmark groups 1 "all"
    set group_ids [hm_getmark groups 1]
    set tie_node2surf_ids []
    set tie_surf2surf_ids []
    foreach group_id $group_ids {
        set group_type [hm_getvalue groups id=$group_id dataname=cardimage]
        if {$group_type in "TIE CONTACT"} {
            set master_type [hm_getvalue groups id=$group_id dataname=masterdefinition]
            if {$master_type==5} {
                lappend tie_surf2surf_ids $group_id
            } else {
                lappend tie_node2surf_ids $group_id
            }
        }
    }
    return "{$tie_node2surf_ids} {$tie_surf2surf_ids}"
}

proc get_tie_ssid {group_id} {
    return [hm_getvalue groups id=$group_id dataname=slaveentityids]
}

proc get_tie_msid {group_id} {
    return [hm_getvalue groups id=$group_id dataname=masterentityids]
}

# 显示全部
proc show_all_except_geometry {} {
    *createmark comps 1 "all"
    # *unmaskentitymark comps 1 "all" 1 0
    *displaycollectorsallbymark 1 "all" 1 0
    *createmark elems 1 "all"
    *unmaskentitymark elements 1 0    
}

proc hmCheckElemAttachTie {} {

    show_all_except_geometry

    set tie_ids [get_group_tie_ids ]
    set tie_node2surf_ids [lindex $tie_ids 0]
    set tie_surf2surf_ids [lindex $tie_ids 1]

    set surf_elem_ids []
    foreach tie_surf2surf_id $tie_surf2surf_ids {
        set surf1_id [get_tie_ssid $tie_surf2surf_id]
        set surf2_id [get_tie_msid $tie_surf2surf_id]
        set surf1_elem_ids [hm_getvalue contactsurfs id=$surf1_id dataname=elements]
        set surf2_elem_ids [hm_getvalue contactsurfs id=$surf2_id dataname=elements]
        set surf_elem_ids [concat $surf_elem_ids [concat $surf1_elem_ids $surf2_elem_ids]]
    }

    *createmark groups 2 "all"
    *createstringarray 2 "elements_on" "geometry_on"
    *isolateonlyentitybymark 2 1 2
    *createmark elems 1 "displayed"
    set node2elem_ids [hm_getmark elems 1]

    show_all_except_geometry
    eval *createmark elems 1 [concat $surf_elem_ids $node2elem_ids]
    *appendmark elems 1 "by attached"
    *maskentitymark elems 1 0

}


hmCheckElemAttachTie