# source "D:/github/TclPyHyperWorks/hm_v2/test_cal.tcl"

# 路径定义
set script_dir [file dirname [info script]]

set sub_dir $script_dir
if {$script_dir in $auto_path} {} else {
	lappend auto_path $script_dir	
} 


package require SubGeometry 1.0



puts [v_abs "1 2 3"]

puts [angle2rad 180]


# puts $auto_path


