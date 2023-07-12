# 欧亚龙

#参数名称
set x1vals []
set y1vals []
set z1vals []
set Splitsurfaces_nums []
set Delsurfaces_nums []
set linlengths []
set targtesurface_nums_01 []
set targtelines_num_02 []
set targtline_new_ids [] 
set targtnode_ids []
set targtpoint_ids []
set dis_list []
set lines_ids_final []
set targtelines_nums_03 []
set x1vals_01 []
set y1vals_01 []
set z1vals_01 []
set dds []
set targtline_new_ids_001 []
set points_ids_clockwise []
set targtpoints_ids []
##===============================================================================
*createmarkpanel surfaces 1 "please select transplate_surfaces"
set Transurfaces_num [hm_getmark surfaces 1]
*createmarkpanel nodes 1 "please select direction_nodes"
set nodes_direction_nums [hm_getmark nodes 1]
foreach nodes_direction_num $nodes_direction_nums {
	set x1val [hm_getentityvalue nodes $nodes_direction_num "x" 0 -byid]
	set y1val [hm_getentityvalue nodes $nodes_direction_num "y" 0 -byid]
	set z1val [hm_getentityvalue nodes $nodes_direction_num "z" 0 -byid]
    lappend x1vals $x1val
    lappend y1vals $y1val
    lappend z1vals $z1val
}
set dis_x [expr [lindex $x1vals 0 ]-[lindex $x1vals 1 ] ]
set dis_y [expr [lindex $y1vals 0 ]-[lindex $y1vals 1 ] ]
set dis_z [expr [lindex $z1vals 0 ]-[lindex $z1vals 1 ] ]
*createvector 1 $dis_x $dis_y $dis_z
*createmark surfaces 2 $Transurfaces_num 
hm_entityrecorder surfs on
*duplicatemark surfaces 2 1
*createmark surfaces 1 -1
*translatemark surfaces 2 1 20	
hm_entityrecorder surfs off
set Transurfaces_num_01 [hm_entityrecorder surfs ids]
*createmarkpanel surfaces 1 "please select split_surfaces"
set Splitsurfaces_num [hm_getmark surfaces 1]
hm_entityrecorder surfs on
lappend Splitsurfaces_nums $Splitsurfaces_num
hm_createmark surfaces 1 [lindex $Splitsurfaces_nums 0]
# eval "*createmark surfaces 1 "by id only" $Splitsurfaces_nums"
*createmark surfaces 2 "by id only" $Transurfaces_num_01
*surfmark_trim_by_surfmark 1 2 2
*createmark surfaces 1 "by id only" $Transurfaces_num_01 
*deletemark surfaces 1
hm_entityrecorder surfs off
set Delsurfaces_num [hm_entityrecorder surfs ids]
lappend Delsurfaces_nums $Delsurfaces_num
set Delsurfaces_nums_all_new [concat $Splitsurfaces_num $Delsurfaces_num]
##===============================================================================
##===============================================================================
#计算切割平面后面积计算
foreach Delsurfaces_num_all_new $Delsurfaces_nums_all_new {
	set area_sum 0
	set area_value [hm_getareaofsurface surfs $Delsurfaces_num_all_new]
	if {$area_value <2000} {
		*createmark surfaces 1 $Delsurfaces_num_all_new
		*deletemark surfaces 1
	} else {
		*createmark surfaces 1 $Delsurfaces_num_all_new
		set targtesurface_nums [hm_getmark surfaces 1]
        lappend targtesurface_nums_01 $targtesurface_nums
		}
}


set surf_list1d []
set surf_list2d []
foreach surf_id $targtesurface_nums_01 {
	puts $surf_id
	*createmark surfs 1 $surf_id
	*appendmark surfs 1 "by adjacent"
	*appendmark surfs 1 "by adjacent"
	set surf_ids [hm_getmark surfs 1]

	set new_surf_ids []
	foreach surf_id_1 $surf_ids {
		if {$surf_id_1 in $targtesurface_nums_01} {
			lappend new_surf_ids $surf_id_1
		}
	}

	puts $new_surf_ids
	if {$surf_id in $surf_list1d} { continue }

	set surf_list1d [concat $surf_list1d $new_surf_ids]
	lappend surf_list2d $new_surf_ids
}
# puts $surf_list2d
# puts $surf_list1d
set targtesurface_nums_01 $surf_list1d

#=================================================================================================


foreach targtesurface_num_02 $targtesurface_nums_01 {
	*createmark lines 1 "by surface" $targtesurface_num_02
	set targtelines_num_01 [hm_getmark lines 1]
	lappend targtelines_num_02 $targtelines_num_01
	##增加for语句循环
	set n [llength $targtelines_num_02]
	set a ""
	for {set i 0} {$i < $n} {incr i} {
        set b [lindex $targtelines_num_02 $i] 
        set a [concat $a $b]
	}
}
puts "a:$a"
##=================================================================================================
foreach targtelines_num_03 $a {
set targtlinelength [hm_linelength $targtelines_num_03]
	if {$targtlinelength < 100} {
	*createmark lines 1 $targtelines_num_03
	set targtline_new_id [hm_getmark lines 1]
	lappend targtline_new_ids $targtline_new_id
	}
}
puts "targtline_new_ids:$targtline_new_ids"
foreach dd $targtline_new_ids {
	*createmark points 1 "by lines" $dd
	set targtpoint_ids_nums [hm_getmark points 1]
	puts "targtpoint_ids_nums_01:$targtpoint_ids_nums"
	lappend dds $targtpoint_ids_nums
	set nn [llength $dds]
	set aa ""
	for {set j 0} {$j < $nn} {incr j} {
        set bb [lindex $dds $j] 
        set aa [concat $aa $bb]
	}
}

puts "targtpoint_ids_nums_02:$aa"
#========================================================================
#将points ID号去重
# set points_list []
# foreach rr $aa {
# 	if {$rr in $points_list} {continue}
# lappend points_list $rr
# }
# puts "points_list:$rr"
#======================================================================
##======================================================================
#通过识别目标线生成目标线中心节点
# foreach targtline_new_ids_01 $targtline_new_ids {
# 	hm_entityrecorder points on
# 	*createmark lines 1 "by id only" $targtline_new_ids_01
# 	*edgesmarkaddpoints 1 1
# 	hm_entityrecorder points off
# 	set targtpoint_id [hm_entityrecorder points ids]
#     lappend targtpoint_ids $targtpoint_id
# }
##==============================================================================
#=================================================================================
#以上偏置平面20mm之后切割的面删除
#=================================================================================
# hm_createmark surfaces 2 [lindex $Splitsurfaces_nums 0]
# set aa [hm_getmark surfaces 1]
# puts "aa:$aa"
# *createmark surfaces 1 $Transurfaces_num
# set bb [hm_getmark surfaces 2]
# puts "bb:$bb"
# *surfmark_trim_by_surfmark 1 2 2
#===================================================================================
#===================================================================================
#找到基准平面上的四个points ID号
*createmark points 1 "by surface" $Transurfaces_num
set points_nums [hm_getmark points 1]
puts "points_in_surface:$points_nums"
#====================================================================================
#节点到面距离
proc face3point {point1 point2 point3} {
	set n1x [lindex $point1 0]
	set n1y [lindex $point1 1]
	set n1z [lindex $point1 2]
	set n2x [lindex $point2 0]
	set n2y [lindex $point2 1]
	set n2z [lindex $point2 2]
	set n3x [lindex $point3 0]
	set n3y [lindex $point3 1]
	set n3z [lindex $point3 2]
	set A [expr ($n1y*$n2z)-($n1y*$n3z)-($n2y*$n1z)+($n2y*$n3z)+($n3y*$n1z)-($n3y*$n2z)]
	set B [expr -($n1x*$n2z)+($n1x*$n3z)+($n2x*$n1z)-($n2x*$n3z)-($n3x*$n1z)+($n3x*$n2z)]
	set C [expr ($n1x*$n2y)-($n1x*$n3y)-($n2x*$n1y)+($n2x*$n3y)+($n3x*$n1y)-($n3x*$n2y)]
	set D [expr -($n1x*$n2y*$n3z) + ($n1x*$n3y*$n2z) + ($n2x*$n1y*$n3z) - ($n2x*$n3y*$n1z) - ($n3x*$n1y*$n2z) +($n3x*$n2y*$n1z)]
	return "$A $B $C $D"
}
proc dis_point_to_face {point1 surface_param} {
	set A [lindex $surface_param 0]
	set B [lindex $surface_param 1]
	set C [lindex $surface_param 2]
	set D [lindex $surface_param 3]
	set x1 [lindex $point1 0]
	set y1 [lindex $point1 1]
	set z1 [lindex $point1 2]
	set lower [expr ($A**2 + $B**2 + $C**2)**0.5]
	set upper [expr abs($x1*$A + $y1*$B + $z1*$C + $D)]
	return [expr $upper / $lower]
}

proc dis_point_to_face_by_point {surf_point1 surf_point2 surf_point3 point4} {
	return [dis_point_to_face $point4 [face3point $surf_point1 $surf_point2 $surf_point3]]
}
proc get_point_locs {point_id} {
	set x [hm_getvalue points id=$point_id dataname=x]
	set y [hm_getvalue points id=$point_id dataname=y]
	set z [hm_getvalue points id=$point_id dataname=z]
	return "$x $y $z"
}
#==========================================================================================================
*createmark points 1 "by surface" $Transurfaces_num
set surf_points [hm_getmark points 1]
set surf_point1 [get_point_locs [lindex $surf_points 0]]
set surf_point2 [get_point_locs [lindex $surf_points 1]]
set surf_point3 [get_point_locs [lindex $surf_points 2]]
foreach point_id $aa  {
	set point1 [get_point_locs $point_id]
	set dis [dis_point_to_face_by_point $surf_point1 $surf_point2 $surf_point3 $point1]
	lappend dis_list $dis
	if {$dis < 60 } {
		*createmark lines 1 "by points" $point_id
		set lines_id_final [hm_getmark lines 1]
		puts "lines_id_final_01:$lines_id_final"
		lappend lines_ids_final $lines_id_final
	}
}
puts "lines_id_final_02:$lines_ids_final"
set m [llength $lines_ids_final]
set e ""
for {set j 0} {$j < $m} {incr j} {
    set f [lindex $lines_ids_final $j] 
    set e [concat $e $f]
}
puts "points_id_in_targetsurface:$e"


#============================================================================================
foreach targtelines_num_04 $e {
set targtlinelength_02 [hm_linelength $targtelines_num_04]
	if {$targtlinelength_02 < 100} {
	*createmark lines 1 $targtelines_num_04
	set targtline_new_id_001 [hm_getmark lines 1]
	lappend targtline_new_ids_001 $targtline_new_id_001
	}
}
puts "targtline_new_ids_001:$targtline_new_ids_001"




#=============================================================================================
#line ID去重操作
set lines_list []
foreach vv $targtline_new_ids_001 {
	if {$vv in $lines_list } {continue}
lappend lines_list $vv
}
puts "lines_list:$lines_list"



#=============================================================================================
#以4条lines为一组形成一个新的列表形式
proc 4lines_combine {lines_ids_00} {
	set nnn [llength $lines_ids_00]
	set a ""
	for {set i 0} {$i < $nnn} {incr i 4} {
        set b [lindex $lines_ids_00 $i] 
        set c [lindex $lines_ids_00 [expr $i+1]]
        set d [lindex $lines_ids_00 [expr $i+2]]
        set e [lindex $lines_ids_00 [expr $i+3]]
        lappend a "$b $c $d $e"
	}
	return "$a"
}
set 4line_combines_ids [4lines_combine $lines_list]
puts "4line_combines_ids:$4line_combines_ids"


#==============================================================================================
#=============================================================================================
#按照一定的顺序重新排序line_ID号和points_ID号
# line_ids 为4条线ID
proc get_points {line_ids} {
	set line_id_1 [lindex $line_ids 0]
	*createmark points 1 "by lines" $line_id_1
	set line_1_points [hm_getmark points 1]
	set point_id_1 [lindex $line_1_points 0]
	set point_id_2 [lindex $line_1_points 1]
	*createmark lines 1 "by points" $point_id_1
	foreach line_id [hm_getmark lines 1] {
		if {$line_id == $line_id_1} {continue}
		if {$line_id in $line_ids} {
			set line_id_4 $line_id
			break
		}
	}  
	*createmark points 1 "by lines" $line_id_4
	set line_4_points [hm_getmark points 1]

	if {$point_id_1 == [lindex $line_4_points 0]} {
		set point_id_4 [lindex $line_4_points 1]
	} else {
		set point_id_4 [lindex $line_4_points 0]
	}
	*createmark lines 1 "by points" $point_id_2
	foreach line_id [hm_getmark lines 1] {
		if {$line_id == $line_id_1} {continue}
		if {$line_id in $line_ids} {
			set line_id_2 $line_id
			break
		}
	}  
	*createmark points 1 "by lines" $line_id_2
	set line_2_points [hm_getmark points 1]	 

	if {$point_id_2 == [lindex $line_2_points 0]} {
		set point_id_3 [lindex $line_2_points 1]
	} else {
		set point_id_3 [lindex $line_2_points 0]
	}
	foreach line_id $line_ids {
		if {$line_id==$line_id_1} {continue}
		if {$line_id==$line_id_2} {continue}
		if {$line_id==$line_id_4} {continue}
		set line_id_3 $line_id
	}
	return "{$line_id_1 $line_id_2 $line_id_3 $line_id_4} {$point_id_1 $point_id_2 $point_id_3 $point_id_4}"
	       
}
foreach 4line_combines_id $4line_combines_ids {
	set pointsIDs_and_linesIDs [get_points $4line_combines_id]
	set lines_id_clockwise [lindex [get_points $4line_combines_id] 0]
	set points_id_clockwise [lindex [get_points $4line_combines_id] 1]
	puts "pointsIDs_and_linesIDs:$pointsIDs_and_linesIDs"
	puts "lines_id_clockwise:$lines_id_clockwise"
	puts "points_id_clockwise:$points_id_clockwise"
	set points_all_ids [lappend points_ids_clockwise $points_id_clockwise]
	foreach points_all_ids_to_project $points_id_clockwise {
		hm_entityrecorder points on
			*createmark surfaces 1 "by id only" $Transurfaces_num
			*createmark points 2 "by id only" $points_all_ids_to_project
			*surfaceaddpointsfixed 1 2 22 0
		hm_entityrecorder points off
		set targtpoint_id [hm_entityrecorder points ids]
		puts "targtpoint_id:$targtpoint_id"
		lappend targtpoints_ids $targtpoint_id 
	}
}
puts "targtpoints_ids:$targtpoints_ids"


#========================================================================================================================
set w [llength $points_all_ids]
set t ""
for {set jj 0} {$jj < $w} {incr jj} {
    set l [lindex $points_all_ids $jj] 
    set t [concat $t $l]
}
puts "points_all_ids:$t"

#=========================================================================================================================
#以上程序完成对边界硬点及边界线按一定顺序的识别工作
#========================================================================================================================
set cycle_nums [llength $targtpoints_ids]
for {set k 0} {$k < $cycle_nums} {incr k 4} {
	foreach j "0 1 2 3" {
		
		set j_f [expr $k+$j]
		if {$j == 3} {
			set j_r [expr $k]
		} else {
			set j_r [expr $k+$j+1]
		}
		*surfacemode 4
		*createmark points 1 [lindex $targtpoints_ids $j_f] [lindex $targtpoints_ids $j_r] [lindex $t $j_f] [lindex $t $j_r]
		# *surfacesplinefrompoints points 1 1
		*createplane 1 1 0 0 0 0 0
		*splinesurface points 1 0 1 0
	}
}

*createmark surfaces 1 "displayed"
*multi_surfs_lines_merge 1 0 0
#========================================================================================================================
#因为执行命令会改变point ID号因此此程序只能一步一步框选压印平面


































