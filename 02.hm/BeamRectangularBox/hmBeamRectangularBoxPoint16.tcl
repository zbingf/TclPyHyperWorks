# -------------------------------------
# Main!!!!!!!!!!!!!!
# hypermesh 13.0
# 梁单元生成
# 识别矩形钢
# 针对16点计算,规则矩形钢
# 调用 funHyperWorks.py 函数
# -------------------------------------

namespace eval ::rectangularBox {
	# Beam ID 计数
	variable beamIdNum 1
	# Properties 计数
	variable propertiesNum 1
	# Materials 计数
	variable materialsNum 1
	# 
	variable materialsName steel1
	# 单元尺寸
	variable elementsizeset1 10

	variable filepath;
}


# 子函数
# ————————————————————————————————————————————
# 数值处理
proc  floatToStr {data} {
	# 讲float 以字符串形式输出 保留一位小数
	# 50p5 = 50.5
	set data0 [expr int($data)]
	set data1 [expr round($data*10-int($data)*10)]
	set t [append data0 "p$data1"]
	return $t
}
# ————————————————————————————————————————————
# 创建 
proc createentity_self {entity name} {
	# 创建comps 前检查 是否存在
	*createmark $entity 1 $name
	if {[hm_getmark $entity 1]==[]} {
		*createentity $entity name=$name
	} else {
		puts "$entity name isExist"
	}
}

proc create_comps_name {name} {
	# 创建comps 前检查 是否存在
	*createmark components 1 $name
	if {[hm_getmark comps 1]==[]} {
		*createentity comps name=$name
	}
}

proc create_materials_name {materialsName} {
	# 创建材料
	*createmark materials 1 $materialsName

	if {[hm_getmark materials 1]==[]} {
		*collectorcreate materials "$materialsName" 11
		*createmark materials 1 "$materialsName"
		*dictionaryload materials 1 "[hm_info exporttemplate]" "MAT1"
		incr ::rectangularBox::materialsNum
		puts "append materialsName"
	} else {
		puts "materialsName isExist"
	}
}

proc create_properties_name {propertiesName materialsName beamName} {
	# 创建属性
	*createmark properties 1 $propertiesName
	*createmark beamsects 1 "$beamName"
	set beamId [hm_getmark beamsects 1]
	if {[hm_getmark properties 1]==[]} {
		puts "append properties"
		*collectorcreateonly properties "$propertiesName" "" 11
		*createmark materials 1 "$materialsName"
		*createmark properties 1 "$propertiesName"
		set prop_id [hm_getmark properties 1]
		set mats_id [hm_getmark materials 1]
		*setvalue props id=$prop_id materialid={mats $mats_id}
		*setvalue props id=$prop_id STATUS=2 3186={beamsects $beamId}
		*dictionaryload properties 1 "[hm_info exporttemplate]" "PBEAM"
		incr ::rectangularBox::propertiesNum
	}
}

# ————————————————————————————————————————————
# 删除
proc delAllBeamsectcols {} {
	# 删除所有 beam截面
	*createmark beamsectcols 1 "all"
	if {[hm_getmark beamsectcols 1]!=[]} {
		*deletemark beamsectcols 1 
	}
}
proc delBeamsetsId {targetId} {
	# 删除指定id 截面
	*createmark beamsets 1 "by id only" $targetId
	*deletemark beamsets 1
}

# ————————————————————————————————————————————
# 涉及python
proc pythonCompName {datalist} {
	# 解析python返回数值
	# 输出compsName
	set thickeness [lindex $datalist 1]
	set thickenessStr [floatToStr $thickeness]
	set widthY [lindex $datalist 2]
	set widthYStr [floatToStr $widthY]
	# set t [format "%1$sp%2$s_%3$sp%4$s" $thickeness0 $thickeness1 $widthY0 $widthY1]
	set widthZ [lindex $datalist 3]
	set widthZStr [floatToStr $widthZ]

	set length [lindex $datalist 4]
	set length [floatToStr $length]
	set loc1 [lindex $datalist 5]
	set loc2 [lindex $datalist 6]
	set vy [lindex $datalist 7]

	set compsName "beam $thickenessStr $widthYStr $widthZStr"
	set compsName [join $compsName "_"]
	return $compsName
}

proc pythonBeamName {datalist} {
	# datalist 解析, Beam名称命名
	set thickness [lindex $datalist 1]
	set thicknessStr [floatToStr $thickness]

	set widthY [lindex $datalist 2]
	set widthYStr [floatToStr $widthY]

	set widthZ [lindex $datalist 3]
	set widthZStr [floatToStr $widthZ]

	set beamName "beam $thicknessStr $widthYStr $widthZStr"
	set beamName [join $beamName "_"]
	return $beamName
}

proc pythonBeamCreate {datalist} {
	# 创建指定beam截面
	# datalist 解析

	set beamName [pythonBeamName $datalist]

	set thickness [lindex $datalist 1]
	set thickness [expr round($thickness*10)/10.0]

	set widthY [lindex $datalist 2]
	set widthY [expr round($widthY*10)/10.0]

	set widthZ [lindex $datalist 3]
	set widthZ [expr round($widthZ*10)/10.0]

	*createmark beamsects 1 "$beamName"
	if {[hm_getmark beamsects 1]==[]} {
		incr ::rectangularBox::beamIdNum
		set beamId $::rectangularBox::beamIdNum 
		*beamsectioncreatestandardsolver 0 0 HMBox 0 
		*beamsectionsetdataroot $beamId 1 0 2 7 1 0 1 1 0 0 0 0 
		*createdoublearray 9  $thickness 0.5 0.5 $widthY 10 10 $widthZ 10 10
		*beamsectionsetdatastandard 1 9 $beamId 0 0 HMBox 
		# *createmark beamsects 1  "byId"
		*renamecollector beamsects "box_section.$beamId" "$beamName"
	} else {
		puts "Beam Section isExist"
	}
}

# ————————————————————————————————————————————
# ————————————————————————————————————————————
proc isCuboid {solidLoc} {
	# 矩形钢 计算
	# p判断是否为矩形钢, 并导出数据

	# 获取solids上的 point ID号
	*createmark points 1 "by solids" $solidLoc
	set pointIds [hm_getmark points 1]
	set locDatas []
	foreach pointId $pointIds {
		# 获取坐标
		set pointCoordData [hm_getcoordinates point $pointId]
		# 拼接列表
		set locDatas [concat $locDatas $pointCoordData]
	}
	# puts $locDatas
	set numPoint [expr [llength $locDatas]/3]

	# 长方体 矩形钢
	if {$numPoint==16} {
		# 16点point
		set pyResult [exec python $::rectangularBox::py_path isRectangularBox $locDatas]
		
		# 1 {{True} {5.00} {50.00} {60.00} {357.51} {605.00 -555.94 10.32} {605.00 -734.69 319.93} {-21921.54 -0.00 -0.00}}

		# puts $pyResult
		# eval "set datalist \"$pyResult\"" 

		if {[expr [lindex $pyResult 0]==True]} {
			# puts $locDatas
			set loc1 [lindex $pyResult 5]
			set loc2 [lindex $pyResult 6]
			eval "*linecreatestraight $loc1 $loc2"
			# set compsName [pythonCompName $datalist]
			return "1 {$pyResult}"
		} else {
			# puts $pointIds
			# puts $locDatas 
			# puts $pyResult
			return "16 not_cuboid"
		}
	} elseif {$numPoint>16} {
		# point数大于16点
		return "17 not_cuboid"
	} elseif {$numPoint==8} {
		# point数 等于 8
		return "8 not_cuboid"
	} elseif {$numPoint<8} {
		return "7 not_cuboid"
	} else {
		return "9 not_cuboid"
	}
}

# ————————————————————————————————————————————
## main function
proc solidsCal {solidsId} {

	# 单个 solid 设置计算
	*createmark solids 1 "by id only" $solidsId

	# 默认配置
	set calComp "calTemp"
	set targetComp "endTemp"
	set failComp "failComp_point_"

	create_comps_name $calComp
	*currentcollector components $calComp
	*movemark solids 1 $calComp

	# 是否为矩形钢
	set temp [isCuboid $solidsId]
	puts $temp
	if {[expr [lindex $temp 0] ==1]} {
		set datalist [lindex $temp 1]
		set targetComp [pythonCompName $datalist]
		create_comps_name $targetComp
		pythonBeamCreate $datalist

		set beamName [pythonBeamName $datalist]
		create_properties_name $targetComp $::rectangularBox::materialsName $beamName
		*createmark properties 1 "$targetComp"
		set prop_id [hm_getmark properties 1]
		
		*createmark solids 1 "by comp name" $calComp
		*createmark lines 1 "by comp name" $calComp

		# 尺寸
		*elementsizeset $::rectangularBox::elementsizeset1
		*linemesh_preparedata lines 1 0
		set length [lindex $datalist 4]
		set density [expr round($length/$::rectangularBox::elementsizeset1)]
		*linemesh_saveparameters 0 $density 0 0
		set vy [lindex $datalist 7]
		eval "*createvector 1 $vy"
		*linemesh_savedata_bar lines 1 60 $prop_id 1 0 0 0 0 0 0 0
		*movemark solids 1 $targetComp
		*movemark lines 1 $targetComp
		*createmark elements 1 "by comp name" $calComp
		if {[hm_getmark elements 1]!=[]} {
			*movemark elements 1 $targetComp	
		}

	} else {
		set tempN $failComp
		*createmark solids 1 "by comp name" $calComp
		append tempN [lindex $temp 0]
		create_comps_name $tempN
		*movemark solids 1 $tempN
	}
}



set choice [tk_messageBox -type yesnocancel -default yes -message "是否计算" -icon question ]
if {$choice != yes} {return;}


# 命令交互
set ::rectangularBox::elementsizeset1 [hm_getstring "beam length(mm) =" "input float"]

# ————————————————————————————————————————————
# 获取当前文件路径
set ::rectangularBox::filepath [file dirname [info script]]
puts $::rectangularBox::filepath
set ::rectangularBox::py_path [format "%s/hmBeamRectangularBoxPoint16.py" $::rectangularBox::filepath]


# 材料设置
*createmark materials 1 "all"
set materialId [hm_getmark materials 1]
set ::rectangularBox::materialsNum [llength $materialId]
if {$::rectangularBox::materialsNum==0} {
	set ::rectangularBox::materialsNum 1
}
# 材料创建
create_materials_name $::rectangularBox::materialsName
# 截面数
*createmark beamsects 1 "all"
set beamsetsId [hm_getmark beamsects 1]
set ::rectangularBox::beamIdNum [llength $beamsetsId]


*createmarkpanel solids 1 "Select the solids"

set solidsId [hm_getmark solids 1]
foreach id1 $solidsId {
	solidsCal $id1
}

# 梁单元-显示设置
*detailedelements_beamvis 1