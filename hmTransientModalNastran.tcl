
# 当前文件路径
set filepath [file dirname [info script]]


# 删除 SOL 以及 PARAM 卡片
catch {
	*createmark card 1  "SOL"
	*deletemark cards 1
}
catch {
	*createmark card 1  "PARAM"
	*deletemark cards 1
}

# 删除所有 loadstep 
*createmark loadstep 1 all
catch {*deletemark loadstep 1}


# 创建 SOL 卡片
*cardcreate "SOL"
*createmark cards 1 "SOL"
set idnum [hm_getmark cards 1 ]
*attributeupdateint cards $idnum 3240 1 2 0 1
*attributeupdateint cards $idnum 179 1 2 0 10

# 创建 PARAM 卡片
*cardcreate "PARAM"
*createmark cards 1 "PARAM"
set idnum [hm_getmark cards 1 ]

# 输出 op2 格式设置
*attributeupdateint cards $idnum 310 1 2 0 1
*attributeupdateint cards $idnum 311 1 1 0 -1

# 频率截断设置
*attributeupdateint cards $idnum 3295 1 0 0 2
*createstringarray $idnum  "LFREQ" "HFREQ"
*attributeupdatestringarray cards $idnum 3296 1 2 0 1 2
*createstringarray $idnum  "1.0" "1000.0"
*attributeupdatestringarray cards $idnum 3297 1 2 0 1 2


# 模态设置卡片 EIGRL
# 提前删除卡片
*createmark loadcols 1 "EIGRL_1"
catch {*deletemark loadcols 1}

*collectorcreate loadcols "EIGRL_1" "" 11
*createmark loadcols 1  "EIGRL_1"
*dictionaryload loadcols 1 [format "%s/sets/optistruct" $filepath] "EIGRL"
*attributeupdateint loadcols [hm_getmark loadcols 1] 3240 1 2 0 1
*attributeupdatedouble loadcols [hm_getmark loadcols 1] 802 1 0 0 0
*attributeupdatedouble loadcols [hm_getmark loadcols 1] 803 1 0 0 0
# 模态设置 10阶
*attributeupdateint loadcols [hm_getmark loadcols 1] 804 1 1 0 10
*attributeupdateint loadcols [hm_getmark loadcols 1] 805 1 0 0 1
*attributeupdateint loadcols [hm_getmark loadcols 1] 806 1 0 0 7
*attributeupdatedouble loadcols [hm_getmark loadcols 1] 807 1 0 0 0
*attributeupdatestring loadcols [hm_getmark loadcols 1] 808 1 2 0 "MASS"



# loadstep 设置 - 模态分析步

*createmark loadcols 1  "EIGRL_1"
set idnum [hm_getmark loadcols 1]

*createmark outputblocks 1
*createmark groups 1
*loadstepscreate "tran_modal" 1
*createmark loadsteps 1  "tran_modal"
set idnum_1 [hm_getmark loadsteps 1]

*attributeupdateint loadsteps $idnum_1 4143 1 1 0 1
*attributeupdateint loadsteps $idnum_1 4709 1 1 0 8
*attributeupdateentity loadsteps $idnum_1 4966 1 1 0 loadcols $idnum
*attributeupdateint loadsteps $idnum_1 3800 1 1 0 0
*attributeupdateint loadsteps $idnum_1 2396 1 1 0 0
# ansys 设置
*attributeupdateint loadsteps $idnum_1 4059 1 2 0 1
*attributeupdatestring loadsteps $idnum_1 4060 1 2 0 "MODES"

*attributeupdateint loadsteps $idnum_1 351 1 2 0 1
*attributeupdateint loadsteps $idnum_1 3048 1 2 0 1
*attributeupdateint loadsteps $idnum_1 3052 1 2 0 1
*attributeupdateint loadsteps $idnum_1 3281 1 2 0 1
*attributeupdatestring loadsteps $idnum_1 3055 1 2 0 "PLOT"


# loadstep 设置 - 加载
*createmark loadcols 1  "EIGRL_1"
set idnum [hm_getmark loadcols 1]

*createmark outputblocks 1
*createmark groups 1
*loadstepscreate "tran_load" 1
*createmark loadsteps 1  "tran_load"
set idnum_1 [hm_getmark loadsteps 1]

*attributeupdateint loadsteps $idnum_1 4143 1 1 0 1
*attributeupdateint loadsteps $idnum_1 4709 1 1 0 8
*attributeupdateentity loadsteps $idnum_1 4966 1 1 0 loadcols $idnum
*attributeupdateint loadsteps $idnum_1 3800 1 1 0 0
*attributeupdateint loadsteps $idnum_1 2396 1 1 0 0


*attributeupdateint loadsteps $idnum_1 351 1 2 0 1
*attributeupdateint loadsteps $idnum_1 4584 1 2 0 1
*attributeupdateint loadsteps $idnum_1 4577 1 2 0 1
*attributeupdateint loadsteps $idnum_1 4582 1 2 0 1
*attributeupdatestring loadsteps $idnum_1 4580 1 2 0 "PUNCH"



# 更改 EIGRL_1 节点
*createmark loadcols 1  "EIGRL_1"
set idnum [hm_getmark loadcols 1]
set eigrl_1_id 98900000
*setvalue loadcols id=$idnum id={loadcols $eigrl_1_id}
