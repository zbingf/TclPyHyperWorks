# hyperview tcl代码


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
	qry$t WriteData "result1.csv"
	mdl$t RemoveSelectionSet $setid 
hwi CloseStack
