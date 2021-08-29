# -------------------------------------
# hmForSusLoad.tcl
# 力值加载
# -------------------------------------

## 删除原有卡片\载荷\工况
hm_blockerrormessages 1

*createmark card 1 all
catch {*deletemark card 1}

*createmark loadcols 1 all
catch {*deletemark loadcols 1}

*createmark loadstep 1 all
catch {*deletemark loadstep 1}

hm_blockerrormessages 0

##