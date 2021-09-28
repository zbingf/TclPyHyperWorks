# -------------------------------------
# hmMaterials.tcl
# hypermeh 2021.1
# Property重命名
# -------------------------------------




# 数值字符替换
proc str_change {str1} {

    set str1 [string map ". p" $str1]
    set str1 [string map "e-09 e" $str1]
    set str1 [string map "e-9 e" $str1]
    # set str1 [string map "- n" $str1]
    set str1 [string map "e E" $str1]

    return $str1
}

proc prop_rename {} {

    puts "---------prop_rename start---------\n"

    *createmark properties  1 "all"
    set prop_ids [hm_getmark properties  1]
    # set mat_datas [list]

    
    foreach prop_id $prop_ids {
        set cur_num 1
        
        set prop_name [hm_entityinfo name properties $prop_id]

        set cardimage [hm_getvalue properties id=$prop_id dataname=cardimage] 

        if {$cardimage!="PSHELL" & $cardimage!="PSOLID"} {
            continue
        }

        set mat_id [hm_getvalue properties id=$prop_id dataname=materialid] 
        set mat_name [hm_entityinfo name materials $mat_id]
        
        
        set isRename 0
        if {$cardimage=="PSHELL"} {
            set thickness [hm_getvalue properties id=$prop_id dataname=thickness]
            # set target_name [format "%s_%s_T%s_%s" $cardimage $mat_name [str_change $thickness] $cur_num]
            set target_name [format "%s_%s_T%s_%s" $cardimage $mat_id [str_change $thickness] $cur_num]
            # puts $target_name
            set isRename 1
        } elseif {$cardimage=="PSOLID"} {
            # set target_name [format "%s_%s_%s" $cardimage $mat_name $cur_num]
            set target_name [format "%s_%s_%s" $cardimage $mat_id $cur_num]
            set isRename 1
        }

        while {$isRename} {
            set status [catch {
                *setvalue props id=$prop_id name="$target_name"
            } res]
            if {$status} {
                puts "prop rename error: $target_name"

                set cur_num [expr $cur_num+1]
                if {$cardimage=="PSHELL"} {
                    # set target_name [format "%s_%s_T%s_%s" $cardimage $mat_name [str_change $thickness] $cur_num]
                    set target_name [format "%s_%s_T%s_%s" $cardimage $mat_id [str_change $thickness] $cur_num]
                } elseif {$cardimage=="PSOLID"} {
                    # set target_name [format "%s_%s_%s" $cardimage $mat_name $cur_num]
                    set target_name [format "%s_%s_%s" $cardimage $mat_id $cur_num]
                }
                
                puts "  reset: $target_name"
            } else {
                # 没报错-中断
                break
            }
        }
    }
    puts "\n---------prop_rename end---------\n"
}

prop_rename
