# -------------------------------------
# hmTransientModal2.tcl
# hypermesh 
# 瞬态分析-模态法
# 用于nastran ， bdf导入时
# -------------------------------------

# 删除 grid_auto comp 卡片
catch {
	*createmark comps 1  "GRID_AUTO"
	*deletemark comps 1
}
