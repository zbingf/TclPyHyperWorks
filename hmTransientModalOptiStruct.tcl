# 当前文件路径
set filepath [file dirname [info script]]


# 删除所有 loadstep 
*createmark loadstep 1 all
catch {*deletemark loadstep 1}


# 删除所有 卡片
catch {
	*createmark card 1  all
	*deletemark cards 1
}


# PARAM 卡片设置
*cardcreate "PARAM"
*createmark cards 1 "PARAM"
set idnum [hm_getmark cards 1 ]

*attributeupdateint cards $idnum 3240 1 2 0 1
*attributeupdateint cards $idnum 2018 1 2 0 1
*attributeupdateint cards $idnum 8119 1 2 0 1
*attributeupdateint cards $idnum 1342 1
*attributeupdateint cards $idnum 310 1 2 0 1
# LFREQ
*attributeupdatedouble cards $idnum 8120 1 2 0 1.0
# HFREQ
*attributeupdatedouble cards $idnum 2019 1 2 0 1000.0
# post
*attributeupdateint cards $idnum 311 1 2 0 -1


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




# loadsteps - 模态分析步

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

# ansys 设置
*attributeupdateint loadsteps $idnum_1 4059 1 2 0 1
*attributeupdatestring loadsteps $idnum_1 4060 1 2 0 "MODES"

# OUTPUT - STRESS 设置
*attributeupdateint loadsteps $idnum_1 351 1 2 0 1
*attributeupdateint loadsteps $idnum_1 2431 1 2 0 1
*attributeupdateint loadsteps $idnum_1 1923 1 2 0 1
*attributeupdatestring loadsteps $idnum_1 4325 1 2 0 "OUTPUT2"


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

# output 设置
*attributeupdateint loadsteps $idnum_1 351 1 2 0 1
*attributeupdateint loadsteps $idnum_1 7333 1 2 0 1

*attributeupdatestring loadsteps $idnum_1 7334 1 2 0 "PUNCH"
