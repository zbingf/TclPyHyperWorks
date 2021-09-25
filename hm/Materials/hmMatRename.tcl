# -------------------------------------
# hmMaterials.tcl
# hypermeh 2019
# 设置材料属性
# 设置前会!删除!原有材料/属性
# 调用文件夹目录下的子文件夹sets中的 optistruct
# -------------------------------------


# =======================================
# 获取optistruct_path
proc get_optistruct_path {} {
    set altair_dir [hm_info -appinfo ALTAIR_HOME]
    set optistruct_path [format "%s/templates/feoutput/optistruct/optistruct" $altair_dir]
    return $optistruct_path
}

# 数值字符替换
proc str_change {str1} {

    set str1 [string map ". p" $str1]
    set str1 [string map "e-09 e" $str1]
    set str1 [string map "e-9 e" $str1]
    # set str1 [string map "- n" $str1]
    set str1 [string map "e E" $str1]

    return $str1
}

proc mat_rename {} {

    puts "---------mat_rename start---------\n"

    *createmark materials  1 "all"
    set mat_ids [hm_getmark materials  1]
    # set mat_datas [list]

    set cur_num 1
    foreach mat_id $mat_ids {

        set mat_name [hm_entityinfo name materials $mat_id]
        set cardimage [hm_getvalue materials id=$mat_id dataname=cardimage] 
        set value_st [hm_getvalue materials id=$mat_id dataname=341] 
        set value_sc [hm_getvalue materials id=$mat_id dataname=343]

        set E   [hm_getvalue materials id=$mat_id dataname=E]
        set Nu  [hm_getvalue materials id=$mat_id dataname=Nu]
        set Rho [hm_getvalue materials id=$mat_id dataname=Rho]

        set E [str_change $E]
        set Nu [str_change $Nu]
        set Rho [str_change $Rho]
        
        set target_name [format "%s_E%s_Nu%s_Rho%s_st%s_sc%s_%s" $cardimage $E $Nu $Rho $value_st $value_sc $cur_num]
        # puts "mat-name: $mat_name ; ST: $value_st ; SC: $value_sc ; cardimage: $cardimage"
        # puts $target_name
        while {1} {
            set status [catch {
                *setvalue mats id=$mat_id name="$target_name"
            } res]
            if {$status} {
                puts "mat rename error: $target_name"

                set cur_num [expr $cur_num+1]
                set target_name [format "%s_E%s_Nu%s_Rho%s_st%s_sc%s_%s" $cardimage $E $Nu $Rho $value_st $value_sc $cur_num]
                
                puts "  reset: $target_name"
            } else {
                # 没报错-中断
                break
            }
        }
    }

    puts "\n---------mat_rename end---------\n"
}

mat_rename
