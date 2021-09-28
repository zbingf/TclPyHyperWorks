# -------------------------------------
# hmMaterials.tcl
# hypermeh 2021.1
# material 重命名
# -------------------------------------


proc mat_rename {} {

    puts "---------mat_rename start---------\n"

    *createmark materials  1 "all"
    set mat_ids [hm_getmark materials  1]
    # set mat_datas [list]

    foreach mat_id $mat_ids {

        set cur_num 1
        
        set mat_name [hm_entityinfo name materials $mat_id]
        set cardimage [hm_getvalue materials id=$mat_id dataname=cardimage] 
        set value_st [hm_getvalue materials id=$mat_id dataname=341] 
        set value_sc [hm_getvalue materials id=$mat_id dataname=343]

        set E   [hm_getvalue materials id=$mat_id dataname=E]
        set Nu  [hm_getvalue materials id=$mat_id dataname=Nu]
        set Rho [hm_getvalue materials id=$mat_id dataname=Rho]

        # set E [str_change $E]
        set E [expr int($E/1000)]

        # set Nu [str_change $Nu]
        set Nu [expr int($Nu*100)]

        # set Rho [str_change $Rho]
        set Rho [expr int($Rho*1E11)]
        
        # set target_name [format "%s_E%s_Nu%s_Rho%s_st%s_sc%s_%s" $cardimage $E $Nu $Rho $value_st $value_sc $cur_num]
        set target_name [format "%s_E%s_Nu%s_Rho%s_%s" $cardimage $E $Nu $Rho $cur_num]
        # puts "mat-name: $mat_name ; ST: $value_st ; SC: $value_sc ; cardimage: $cardimage"
        # puts $target_name
        while {1} {
            set status [catch {
                *setvalue mats id=$mat_id name="$target_name"
            } res]
            if {$status} {
                puts "mat rename error: $target_name"

                set cur_num [expr $cur_num+1]
                # set target_name [format "%s_E%s_Nu%s_Rho%s_st%s_sc%s_%s" $cardimage $E $Nu $Rho $value_st $value_sc $cur_num]
                set target_name [format "%s_E%s_Nu%s_Rho%s_%s" $cardimage $E $Nu $Rho $cur_num]
                
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
