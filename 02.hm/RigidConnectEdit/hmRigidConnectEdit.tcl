
namespace eval ::RigidEdit {
    variable recess
    
    variable file_dir [file dirname [info script]]
    variable fem_path
    variable py_path
}




# 导出指定单元数据到fem
proc print_elem_node_to_fem {fem_path elem_ids} {
    set altair_dir [hm_info -appinfo ALTAIR_HOME]
    set optistruct_path [format "%s/templates/feoutput/optistruct/optistruct" $altair_dir]
    # elems 1
    eval "*createmark elems 1 $elem_ids"
    # nodes 1
    hm_createmark nodes 1 "by elem" $elem_ids
    # 导出
    hm_answernext yes
    *feoutput_select "$optistruct_path" $fem_path 1 0 0
}


# 创建comp 重复则后缀累加
proc create_comps_name_num { name num } {

    set comp_name [format "%s_%s" $name $num]

    set status [catch {
        *createentity comps name=$comp_name
    } res]
    if {$status} {
        set new_num [expr $num+1]
        return [create_comps_name_num $name $new_num]
    } else {
        return $comp_name
    }

}



puts "--start--"

# 初始化
set ::RigidEdit::fem_path [format "%s/__temp.fem" $::RigidEdit::file_dir]
set ::RigidEdit::py_path   [format "%s/hmRigidConnectEdit.py" $::RigidEdit::file_dir]



# 去重
*createmark elements 1 "displayed"
*createmark elements 2
*elementtestduplicates elements 1 2 1
catch {  *deletemark elems 2 }
puts "finish-duplicates-remove"


#  转换 dependancy
*createmark elems 1 "displayed"
*createmark elems 2
*elementtestdependancy elems 1 2
*element1dswitch 2
puts "finish-dependancy-switch"


# 
*createmark elems 1 "displayed"
*createmark elems 2
*elementtestdependancy elems 1 2

set elem_ids [hm_getmark elems 2]


if {[llength $elem_ids] > 0} {
    # puts $elem_ids
    print_elem_node_to_fem $::RigidEdit::fem_path $elem_ids
    set target_elem_ids [exec python $::RigidEdit::py_path ]
    # puts $target_elem_ids

    set comp_name [create_comps_name_num "__RigidToDel" 0]

    hm_createmark elems 1 "$target_elem_ids"
    *movemark elems 1 $comp_name


    set choice [tk_messageBox -type yesnocancel -default yes -message "冲突Rigid 已移动到 comp:\n\t$comp_name\n\n是否删除?" -icon question ]
    if {$choice == yes} {
        *startnotehistorystate {del RigidToDel}
            hm_createmark comps 1 $comp_name
            *deletemark comps 1
        *endnotehistorystate {del RigidToDel}
    }
}


puts "--end--"





