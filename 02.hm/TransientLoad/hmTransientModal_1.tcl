# -------------------------------------
# hmTransientModal.tcl
# hypermesh 
# 瞬态分析-模态法
# 用于nastran ， bdf导入时
# -------------------------------------

# 删除OMIT 卡片
catch {
	*createmark card 1  "OMIT"
	*deletemark cards 1
}

# 删除 grid_auto comp 卡片
catch {
	*createmark comps 1  "RBE2_to_del"
	*deletemark comps 1
}

