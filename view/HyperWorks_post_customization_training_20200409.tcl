## 练习：将第三页的第三个窗口客户端设置成曲线图；
set t [clock clicks ]
hwi OpenStack
	hwi GetSessionHandle sess$t 
	sess$t  GetProjectHandle proj$t 
	hwi OpenStack
		proj$t  GetPageHandle pg3_$t  3
		pg3_$t  GetWindowHandle win3_$t  3
		win3_$t SetClientType Plot
	hwi CloseStack
hwi CloseStack

## 练习：将第三页的第三个窗口客户端设置成曲线图；
set t [clock clicks ]
hwi OpenStack
	hwi GetSessionHandle sess$t 
	sess$t  GetProjectHandle proj$t 
	proj$t  GetPageHandle pg3_$t  3
	pg3_$t  GetWindowHandle win3_$t  3
	win3_$t SetClientType Plot
	# win3_$t ReleaseHandle 
	# pg3_$t  ReleaseHandle
	# proj$t  ReleaseHandle
	# sess$t  ReleaseHandle
hwi CloseStack

## 练习：如何加载一个云图和结果
##########################################
set t 0 
hwi  OpenStack
	hwi GetSessionHandle sess$t 
	sess$t GetProjectHandle prj$t 
	prj$t GetPageHandle pg3$t [prj$t  GetActivePage ]
	pg3$t GetWindowHandle win$t [pg3$t GetActiveWindow]
	win$t GetClientHandle cln$t 
	set modid [cln$t AddModel {D:\Trainning\HyperWorks_post_customization\truck_test\truck.key} ]
	prj$t GetPageHandle pg1$t 1
	pg1$t GetWindowHandle win1$t 1
	win1$t GetClientHandle cln1_$t  
	cln1_$t AddModel {D:\Trainning\HyperWorks_post_customization\truck_test\truck.key}
	cln1_$t GetModelHandle mdl1_$t 1
	mdl1_$t SetResult {D:\Trainning\HyperWorks_post_customization\truck_test\d3plot}
	cln1_$t Draw 
hwi CloseStack

# 练习：使用查询对象查询单元应力大于200的单元，并输出；
#######################################################
set t 1
hwi  OpenStack
	hwi GetSessionHandle sess$t 
	sess$t GetProjectHandle prj$t
	prj$t GetPageHandle pg$t [prj$t GetActivePage]
	pg$t GetWindowHandle win$t [pg$t GetActiveWindow]
	win$t GetClientHandle cln$t 
	cln$t GetModelHandle mdl$t [cln$t GetActiveModel]
	set setid  [ mdl$t AddSelectionSet element ]
	mdl$t GetSelectionSetHandle elem$t $setid 
	elem$t Add "contour > 200 "
	mdl$t GetQueryCtrlHandle qry$t 
	qry$t SetQuery "element.id,contour.value"
	qry$t SetSelectionSet $setid
	qry$t WriteData result1.csv 
	mdl$t RemoveSelectionSet $setid 
hwi CloseStack


## 练习：Query 和 Iterator 的使用方法；
## 1、查询到1-100 号单元，在每一个simulation下的单元应力，
## 2、每一个simulation下进行截图
## 3、并使用迭代器和数组存储每个1-100 号单元ID和单元应力；
## 4、遍历数组，输出存储的每个simulation下的单元ID和应力到文件中；
set t 2
hwi  OpenStack
	hwi GetSessionHandle sess$t 
	sess$t GetProjectHandle prj$t
	prj$t GetPageHandle pg$t [prj$t GetActivePage]
	pg$t GetWindowHandle win$t [pg$t GetActiveWindow]
	win$t GetClientHandle cln$t 
	cln$t GetModelHandle mdl$t [cln$t GetActiveModel]
	set setid  [ mdl$t AddSelectionSet element ]
	mdl$t GetSelectionSetHandle elem$t $setid 
	elem$t Add "id 1-100"
	mdl$t GetQueryCtrlHandle qry$t 
	qry$t SetQuery "element.id,contour.value"
	qry$t SetSelectionSet $setid

	mdl$t GetResultCtrlHandle res$t 
	set simnumb [res$t  GetNumberOfSimulations 1 ]

	array set resdata [list ]
	for {set i 0} {$i < $simnumb } {incr i} {
		res$t SetCurrentSimulation $i 
		cln$t Draw 

		sess$t CaptureScreen JPEG sim$i.jpg 100 

		qry$t GetIteratorHandle itr$t 

		for {itr$t First} {[itr$t Valid]} {itr$t Next} {
			lappend resdata($i) [itr$t GetDataList ]
		}
		itr$t ReleaseHandle
	}

	for {set i 0} {$i < $simnumb } {incr i} {
		set wf [open rest_sim$i.txt w+]
		foreach onelem $resdata($i) {
			puts $wf $onelem
		}
		close $wf 
	}
hwi  OpenStack

## 练习：应用云图的正确方法：
set t 3
hwi  OpenStack
	hwi GetSessionHandle sess$t 
	sess$t GetProjectHandle prj$t
	prj$t GetPageHandle pg$t [prj$t GetActivePage]
	pg$t GetWindowHandle win$t [pg$t GetActiveWindow]
	win$t GetClientHandle cln$t
	cln$t AddModel {D:\Trainning\HyperWorks_post_customization\truck_test\truck.key}
	cln$t GetModelHandle mdl$t [cln$t GetActiveModel ] 
	mdl$t SetResult {D:\Trainning\HyperWorks_post_customization\truck_test\d3plot}
	mdl$t GetResultCtrlHandle res$t
	res$t GetContourCtrlHandle cont$t
	cln$t Draw 
	## 此时没有云图；需要开启显示设置；
	cont$t SetEnableState true 
	cln$t SetDisplayOptions contour true
	cln$t Draw 
	## 此时云图变灰色；需要指定simulation ID ;	
	res$t SetCurrentSimulation 21
	cln$t Draw
	## 此时云图正确显示;需要开启legend显示设置；
	cln$t SetDisplayOptions legend true
	cln$t Draw
	## 此时legend正确显示
hwi CloseStack


## 练习：
## 1、单独显示每一个simulation下单元应力大于100的单元；
## 2、每个simulation都新生成一个page;
## 3、每一个Page进行截图；
set t 10
hwi  OpenStack
	hwi GetSessionHandle sess$t 
	sess$t GetProjectHandle prj$t
	prj$t GetPageHandle pg$t [prj$t GetActivePage]

	pg$t GetWindowHandle win$t [pg$t GetActiveWindow]
	win$t GetClientHandle cln$t 
	cln$t GetModelHandle mdl$t [cln$t GetActiveModel]

	set pgid  [prj$t GetActivePage]

	mdl$t GetResultCtrlHandle res$t 
	set simnumb [res$t GetNumberOfSimulations 1 ]

	for {set i 1} {$i < $simnumb} {incr i} {
		res$t SetCurrentSimulation $i 
		cln$t Draw

		set setid [ mdl$t AddSelectionSet element ]
		mdl$t GetSelectionSetHandle elem$t  $setid 
		elem$t Add "contour >100"
		mdl$t MaskAll
		mdl$t UnMask $setid 
		cln$t Draw 

		sess$t CaptureScreen JPEG res_sim$i.jpg 100

		prj$t CopyPage $pgid  false 

		set pgnumb [prj$t GetNumberOfPages  ]

		prj$t PastePages $pgnumb 
		prj$t GetPageHandle pg${i}$t [expr $pgnumb +1 ]

		pg${i}$t SetTitle "Sim_$i"
		pg${i}$t SetTitleDisplayed true 
		pg${i}$t Draw 
		pg${i}$t ReleaseHandle

		elem$t ReleaseHandle
		cln$t Draw

		prj$t SetActivePage $pgid
		mdl$t UnMaskAll
		cln$t Draw
	}
hwi  CloseStack

## 练习：
## 自动遍历每一个Page，并将截图输出到PPT报告中；
set templatepath {D:/Trainning/HyperWorks_post_customization/report_temple.pptx}
set t [clock clicks ]
hwi OpenStack
   hwi GetSessionHandle sess$t
   sess$t GetPublishingHandle pub$t
   pub$t GetPPTPublishHandle ppt$t
   ppt$t SetSyncAtPublish false
   ppt$t SetSyncHgNotes false
   ppt$t SetDestination "disk"
   ppt$t SetPathOnDisk $templatepath
   ppt$t Publish
hwi CloseStack


## 练习：
## 生成曲线来源于文件；
set t 13
hwi  OpenStack
	hwi GetSessionHandle sess$t 
	sess$t GetProjectHandle prj$t
	prj$t GetPageHandle pg$t [prj$t GetActivePage]
	pg$t GetWindowHandle win$t [pg$t GetActiveWindow]
	win$t GetClientHandle cln$t 
	set cvid [ cln$t AddCurve ]
	cln$t GetCurveHandle mycur$t  $cvid

	mycur$t GetVectorHandle mycurx$t x
	mycur$t GetVectorHandle mycury$t y

	mycurx$t SetType file 
	mycury$t SetType file 

	mycurx$t SetFilename {D:/Trainning/HyperWorks_post_customization/truck_test/nodout}
	mycury$t SetFilename {D:/Trainning/HyperWorks_post_customization/truck_test/nodout}
	
	mycurx$t SetDataType Time 
	mycurx$t SetRequest Time 
	mycurx$t SetComponent Time 

	mycury$t SetDataType  {Node Data}
	mycury$t SetRequest   {Nodal Point 1500004}
	mycury$t SetComponent {Y Displacement}

	cln$t Recalculate
	cln$t Autoscale
	cln$t Draw
hwi  CloseStack


## 练习：
## 查询曲线文件所支持的DataType,Request,Component 列表；
hwi  OpenStack
	hwi GetSessionHandle sess
	sess GetDataFileHandle dataf 
	dataf SetFilename {D:/Trainning/HyperWorks_post_customization/truck_test/nodout}
	set datatypelist [dataf GetDataTypeList]
	## RequestList 和 ComponentList 的查询都是与datatype 相关的；
	set requestlist  [dataf GetRequestList [lindex $datatypelist 1] ]
	set complist     [dataf GetComponentList [lindex $datatypelist 1] ]
hwi CloseStack


## 练习：
## 生成曲线来源于数学表达式；
set t 14
hwi  OpenStack
	hwi GetSessionHandle sess$t 
	sess$t GetProjectHandle prj$t
	prj$t GetPageHandle pg$t [prj$t GetActivePage]
	pg$t GetWindowHandle win$t [pg$t GetActiveWindow]
	win$t GetClientHandle cln$t 
	set cvid [ cln$t AddCurve ]
	cln$t GetCurveHandle mycur$t  $cvid

	mycur$t GetVectorHandle mycurx$t x
	mycur$t GetVectorHandle mycury$t y

	mycurx$t SetType math
	mycury$t SetType math

	mycurx$t SetExpression  p1w1c1.x 
	mycury$t SetExpression  2*(p1w1c1.y)

	cln$t Recalculate
	cln$t Autoscale
	cln$t Draw

	cln$t GetCurveHandle mycv3$t  $cvid

	mycv3$t GetVectorHandle mycv3x$t x
	mycv3$t GetVectorHandle mycv3y$t y

	mycv3x$t SetType math
	mycv3y$t SetType math

	mycv3x$t SetExpression p1w1c1.x 
	#mycv3y$t SetExpression p2w3c4.y 
	
	mycv3y$t SetExpression 500*sin(x)

	cln$t Recalculate
	cln$t Autoscale
	cln$t Draw

hwi  CloseStack 




## 练习：
## 生成曲线来源于数学表达式；
set t 15
hwi  OpenStack
	hwi GetSessionHandle sess$t 
	sess$t GetProjectHandle prj$t
	prj$t GetPageHandle pg$t [prj$t GetActivePage]
	pg$t GetWindowHandle win$t [pg$t GetActiveWindow]
	win$t GetClientHandle cln$t 
	set cvid [ cln$t AddCurve ]
	cln$t GetCurveHandle mycur$t  $cvid

	mycur$t GetVectorHandle mycurx$t x
	mycur$t GetVectorHandle mycury$t y

	mycurx$t SetType math
	mycury$t SetType math

	mycurx$t SetExpression "0:100:0.1"
	mycury$t SetExpression cos(x)

	cln$t Recalculate
	cln$t Autoscale
	cln$t Draw
hwi  CloseStack 


################################
## 练习：
## 生成note,绑定到曲线最高点，并显示曲线最高点的值；
set t 17
hwi  OpenStack
	hwi GetSessionHandle sess$t 
	sess$t GetProjectHandle prj$t
	prj$t GetPageHandle pg$t [prj$t GetActivePage]
	pg$t GetWindowHandle win$t [pg$t GetActiveWindow]
	win$t GetClientHandle cln$t 
	cln$t GetCurveHandle mycv$t 2
	set noteid [cln$t AddNote ]
	cln$t GetNoteHandle mynt$t $noteid 
	prj$t  GetTemplexHandle temp$t 
	set ind [temp$t Evaluate {indexofmax(p1w1c2.y)}]
	mynt$t SetAttachment "curve"
	mynt$t SetAttachToCurveIndex 2 
	mynt$t SetAttachToPointIndex $ind
	#mynt$t SetAttachToCurveIndex "indexofmax(c2.y)"
	mynt$t SetText "{max(p1w1c2.y)}"
	cln$t  Draw
hwi CloseStack


## 自动报告练习：设定你需要输出的PPTX路径，执行代码，自动截图出报告；
set templatepath {D:/Trainning/HyperWorks_post_customization/report_temple.pptx}
set t [clock clicks ]
hwi OpenStack
   hwi GetSessionHandle sess$t
   sess$t GetPublishingHandle pub$t
   pub$t GetPPTPublishHandle ppt$t
   ppt$t SetSyncAtPublish false
   ppt$t SetSyncHgNotes false
   ppt$t SetDestination "disk"
   ppt$t SetPathOnDisk $templatepath
   ppt$t Publish
hwi CloseStack