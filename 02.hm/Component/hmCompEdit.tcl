# component 去重
puts "------Cal Start------"

# 路径定义
set filepath [file dirname [info script]]
set temp_comp_path [format "%s/__temp_comp.csv" $filepath]
set py_path [format "%s/hmCompEdit.py" $filepath]
set tcl_path [format "%s/__temp_cmd.tcl" $filepath]

proc get_comp_datas {} {
    
    *createmark components  1 "all"
    set comp_ids [hm_getmark components  1]
    set comp_datas [list]
    foreach comp_id $comp_ids {
        *createmark components 1 $comp_id
        set comp_name [hm_entityinfo name components $comp_id ]

        set status [catch {
            set prop_id [hm_getvalue components id=$comp_id dataname=property]
            set prop_name [hm_entityinfo name properties $prop_id]
            } res]
        
        if {$status} {
            set prop_id "#"
            set prop_name "#"
        }

        set comp_name [string map ", _" $comp_name]
        set prop_name [string map ", _" $prop_name]
        set comp_data "$comp_name,$comp_id,$prop_name,$prop_id"
        lappend comp_datas $comp_data
    }
    return $comp_datas
}

proc comp_move {comp_id_cur comp_id_target} {
        
        set status [catch {
            hm_createmark elements 1 "by component id" $comp_id_cur
            set comp_name [hm_entityinfo name components $comp_id_target]
            *movemark elements 1 $comp_name
            } res]
        
        if {$status} {
            puts "error: comp_move $comp_id_cur $comp_id_target"
        }

}

set comp_datas [get_comp_datas]

# ----------------------------------
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

puts "------Cal End------"