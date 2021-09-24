# hmPropertyEdit.tcl
# 用于property属性去重
# 重新定义component属性设置
# 编写适用版本: 
#   hypermesh 2019.1
# 关联：
#   hmPropertyEdit.py


puts "------Cal Start------"

# 路径定义
set filepath [file dirname [info script]]
set temp_prop_path [format "%s/__temp_prop.csv" $filepath]
set temp_comp_path [format "%s/__temp_comp.csv" $filepath]
set py_path [format "%s/hmPropertyEditPSHELL.py" $filepath]
set tcl_path [format "%s/__temp_cmd.tcl" $filepath]

# 获取属性卡片数据
proc get_prop_datas {} {
    *createmark properties  1 "all"
    set prop_ids [hm_getmark properties  1]
    # puts $prop_ids
    set prop_datas [list]

    foreach prop_id $prop_ids {
        *createmark properties 1 $prop_id
        # property 名称
        set prop_name [hm_entityinfo name properties $prop_id ]
        # cardimage 名称
        set cardimage_name [hm_getvalue properties id=$prop_id dataname=cardimage]
        
        # 
        if {"PSHELL" == $cardimage_name} {
            set thickness [hm_getvalue properties id=$prop_id dataname=thickness]
        } else {
            continue
            # set thickness "#"
        }
        
        # material 名称
        set material_id [hm_getvalue properties id=$prop_id dataname=material]
        set material_name [hm_entityinfo name materials $material_id ]

        # 对逗号进行替换
        set prop_name [string map ", _" $prop_name]
        set prop_data "$prop_name,$prop_id,$material_name,$material_id,$cardimage_name,$thickness"
        lappend prop_datas $prop_data
        # puts $thickness
    }
    # puts $prop_datas
    return $prop_datas
}



# 获取材料卡片数据
proc get_mat_datas {} {
    *createmark components  1 "all"
    set comp_ids [hm_getmark components  1]
    # puts $comp_ids
    set comp_datas [list]

    foreach comp_id $comp_ids {
        *createmark properties 1 $comp_id
        # component 名称
        set comp_name [hm_entityinfo name components $comp_id ]

        set status [catch {
            # property 名称
            set prop_id [hm_getvalue components id=$comp_id dataname=property]
            set prop_name [hm_entityinfo name properties $prop_id ]
            } res ]
        
        if {$status} {
            set prop_id "#"
            set prop_name "#"
        }
        
        # 对逗号进行替换
        set comp_name [string map ", _" $comp_name]
        set prop_name [string map ", _" $prop_name]
        set comp_data "$comp_name,$comp_id,$prop_name,$prop_id"
        lappend comp_datas $comp_data
    }
    # puts $comp_datas
    return $comp_datas
}


set comp_datas [get_mat_datas]
set prop_datas [get_prop_datas]

# ----------------------------------
# 写入数据
set f_obj [open $temp_prop_path w]
puts $f_obj "prop_name,prop_id,material_name,material_id,cardimage_name,thickness"
foreach prop_data $prop_datas {
    puts $f_obj "$prop_data"    
}
close $f_obj

# 写入数据
set f_obj [open $temp_comp_path w]
puts $f_obj "comp_name,comp_id,prop_name,prop_id"
foreach comp_data $comp_datas {
    puts $f_obj "$comp_data"    
}
close $f_obj

# ----------------------------------

puts "python-call running"
puts "$py_path"
set result_py [exec python $py_path]
puts "python-call end"

if { $result_py == "True" } {
    puts "tcl-call running"
    puts "$tcl_path"
    set result_tcl [source $tcl_path]
    puts "tcl-call end"
}

# catch { file delete $temp_prop_path }
# catch { file delete $temp_comp_path }
# catch { file delete $tcl_path }


puts "------Cal End------"