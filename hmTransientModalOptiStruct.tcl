# ID 设置
# INIT_TABDMP1_ID = 99400000 # TABDMP1
set TABDMP1_ID1 99400001
set EIGRL_ID1 98900001

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
# 预删除
*createmark loadcols 1 "TABDMP1_1"
catch {*deletemark loadcols 1}
*createmark loadcols 1 "EIGRL_1"
catch {*deletemark loadcols 1}

# ----------------------------------------------------
# ----------------------------------------------------
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

# ----------------------------------------------------
# ----------------------------------------------------
# 模态设置卡片 EIGRL

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

*createmark loadcols 1  "EIGRL_1"

# ----------------------------------------------------
# ----------------------------------------------------
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

# ----------------------------------------------------
# ----------------------------------------------------
# TABDMP1 卡片

# 创建
*collectorcreate loadcols "TABDMP1_1" "" 11
*createmark loadcols 2  "TABDMP1_1"
*dictionaryload loadcols 2 [format "%s/sets/optistruct" $filepath] "TABDMP1"

# 获取 $idnum ID
set idnum [hm_getmark loadcols 2] 

*attributeupdateint loadcols $idnum 3240 1 2 0 1
*attributeupdatestring loadcols $idnum 4014 1 2 0 "G"
*attributeupdateint loadcols $idnum 4017 1 0 0 1
*createdoublearray $idnum  0
*attributeupdatedoublearray loadcols $idnum 4015 1 2 0 1 1
*createdoublearray $idnum 0
*attributeupdatedoublearray loadcols $idnum 4016 1 2 0 1 1

# 设置阻尼
*setvalue loadcols id=$idnum STATUS=2 4017=2
*setvalue loadcols id=$idnum STATUS=2 4015={0 100}
*setvalue loadcols id=$idnum STATUS=2 4016={0.05 0.05}

# 更改 TABDMP1_ID1 节点
# *setvalue loadcols id=$idnum id={loadcols $TABDMP1_ID1}


# ----------------------------------------------------
# ----------------------------------------------------
# 输出设置 PUCH
*cardcreate "GLOBAL_OUTPUT_REQUEST"
*attributeupdateint cards 2 3321 1 2 0 0
*attributeupdateint cards 2 3880 1 2 0 0
*attributeupdateint cards 2 4119 1 2 0 0
*attributeupdateint cards 2 4114 1 2 0 0
*attributeupdateint cards 2 7121 1 2 0 0
*attributeupdateint cards 2 2938 1 2 0 0
*attributeupdateint cards 2 2385 1 2 0 0
*attributeupdateint cards 2 4052 1 2 0 0
*attributeupdateint cards 2 3712 1 2 0 0
*attributeupdateint cards 2 3885 1 2 0 0
*attributeupdateint cards 2 274 1 2 0 0
*attributeupdateint cards 2 3057 1 2 0 0
*attributeupdateint cards 2 7113 1 2 0 0
*attributeupdateint cards 2 8500 1 2 0 0
*attributeupdateint cards 2 2419 1 2 0 0
*attributeupdateint cards 2 3809 1 2 0 0
*attributeupdateint cards 2 7125 1 2 0 0
*attributeupdateint cards 2 4877 1 2 0 0
*attributeupdateint cards 2 3325 1 2 0 0
*attributeupdateint cards 2 3333 1 2 0 0
*attributeupdateint cards 2 2423 1 2 0 0
*attributeupdateint cards 2 4047 1 2 0 0
*attributeupdateint cards 2 5463 1 2 0 0
*attributeupdateint cards 2 7329 1 2 0 0
*attributeupdateint cards 2 7333 1 2 0 1
*attributeupdateint cards 2 2427 1 2 0 0
*attributeupdateint cards 2 8153 1 2 0 0
*attributeupdateint cards 2 8150 1 2 0 0
*attributeupdateint cards 2 8144 1 2 0 0
*attributeupdateint cards 2 3642 1 2 0 0
*attributeupdateint cards 2 2431 1 2 0 0
*attributeupdateint cards 2 7337 1 2 0 0
*attributeupdateint cards 2 7117 1 2 0 0
*attributeupdateint cards 2 3891 1 2 0 0
*attributeupdateint cards 2 3329 1 2 0 0
*attributeupdateint cards 2 1920 1 0 0 1
*createstringarray 1  "PUNCH"
*attributeupdatestringarray cards 2 7334 1 2 0 1 1
*createstringarray 1  "REAL"
*attributeupdatestringarray cards 2 7335 1 2 0 1 1
*createstringarray 1  "ALL"
*attributeupdatestringarray cards 2 7336 1 2 0 1 1

