# hmPropertyEdit.tcl
# 1 用于MAT材料属性去重
# 2 重新定义property属性设置
# 3 根据 E Nu RHO 定义
# 编写适用版本: 
#   hypermesh 2021.1
# 关联：
#   hmMatEdit_ENR.py
# 

# 

puts "------Cal Start------"

# 路径定义
set filepath [file dirname [info script]]
set temp_prop_path [format "%s/__temp_prop.csv" $filepath]
set temp_mat_path [format "%s/__temp_mat.csv" $filepath]
set py_path [format "%s/hmMatEdit_ENR.py" $filepath]
set tcl_path [format "%s/__temp_cmd_mat_edit.tcl" $filepath]

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
        } elseif {"PSOLID" == $cardimage_name} {
            set thickness "#"
        } else { continue }
        # puts 1
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

    *createmark materials  1 "all"
    set mat_ids [hm_getmark materials  1]
    set mat_datas [list]

    foreach mat_id $mat_ids {

        set mat_name [hm_entityinfo name materials $mat_id]
        set cardimage [hm_getvalue materials id=$mat_id dataname=cardimage] 
        # puts $cardimage
        if {$cardimage=="MAT1"} {
            set value_st [hm_getvalue materials id=$mat_id dataname=341] 
            set value_sc [hm_getvalue materials id=$mat_id dataname=343]

            set E   [hm_getvalue materials id=$mat_id dataname=E]
            set Nu  [hm_getvalue materials id=$mat_id dataname=Nu]
            set Rho [hm_getvalue materials id=$mat_id dataname=Rho]

            # set target_name [format "%s_E%s_Nu%s_Rho%s_st%s_sc%s_%s" $cardimage $E $Nu $Rho $value_st $value_sc $cur_num]
            # set target_name [format "%s_E%s_Nu%s_Rho%s_%s" $cardimage $E $Nu $Rho $cur_num]

            set mat_name [string map ", _" $mat_name]
            set mat_data "$mat_name,$cardimage,$mat_id,$E,$Nu,$Rho"

            lappend mat_datas $mat_data
        }
    }
    return $mat_datas
}


set mat_datas [get_mat_datas]
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
set f_obj [open $temp_mat_path w]
puts $f_obj "mat_name,cardimage,mat_id,E,Nu,Rho"
foreach mat_data $mat_datas {
    puts $f_obj "$mat_data"    
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
# catch { file delete $temp_mat_path }
# catch { file delete $tcl_path }


puts "------Cal End------"