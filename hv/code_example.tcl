
# ================================================
# ================================================
# 模态批量查看

set num_window 5
set loc_frame 7

# 
hwc animate mode transient

for {set i 1} {$i <= $num_window} {incr i} {
	hwc hwd page current activewindow=$i
	hwc animate frame $loc_frame
}


# ================================================
# ================================================
# 截图
hwc save image window D:/github/TclPyHyperWorks/hv/temp.png



# ================================================
# ================================================
# 选择文件
set path [tk_chooseDirectory -title "Choose a directory to save"]


# 读取文件
*readfile("E:/HyperWorks/test/20190601/frame_assembly_3.hm")