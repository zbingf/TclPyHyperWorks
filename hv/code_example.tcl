
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

