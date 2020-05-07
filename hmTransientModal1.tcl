# hmTransientModal.tcl
# 瞬态分析-模态法

# 删除OMIT 卡片
catch {
	*createmark card 1  "OMIT"
	*deletemark cards 1
}
