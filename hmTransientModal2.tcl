# hmTransientModal2.tcl


# 删除 grid_auto comp 卡片
catch {
	*createmark comps 1  "GRID_AUTO"
	*deletemark comps 1
}
