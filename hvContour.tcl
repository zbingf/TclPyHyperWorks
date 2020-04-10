# -------------------------------------
# hvContour.tcl
# hyperview 后处理 代码
# 调用 source [join "[pwd] HW_code/hvContour.tcl" "/"]
# -------------------------------------

proc contourPlot {data_type component} {
	hwi OpenStack
	set currentTIme [clock seconds]

	hwi GetSessionHandle sessObj_$currentTIme
	sessObj_$currentTIme GetProjectHandle proObj_$currentTIme
	proObj_$currentTIme GetPageHandle pagObj_$currentTIme [proObj_$currentTIme GetActivePage]
	pagObj_$currentTIme GetWindowHandle winObj_$currentTIme [pagObj_$currentTIme GetActiveWindow]
	winObj_$currentTIme GetClientHandle clientObj_$currentTIme
	clientObj_$currentTIme GetModelHandle modeObj_$currentTIme [clientObj_$currentTIme GetActiveModel]
	modeObj_$currentTIme GetResultCtrlHandle resultObj_$currentTIme
	resultObj_$currentTIme GetContourCtrlHandle contourObj_$currentTIme

	contourObj_$currentTIme SetDataType "$data_type"
	contourObj_$currentTIme SetDataComponent "$component"
	contourObj_$currentTIme RestorePlotStyle "Deafault Contour"

	contourObj_$currentTIme GetLegendHandle legendObj_$currentTIme
	legendObj_$currentTIme SetType dynamic

	contourObj_$currentTIme SetEnableState true
	clientObj_$currentTIme SetDisplayOptions "contour" true
	clientObj_$currentTIme SetDisplayOptions "legend" true
	clientObj_$currentTIme Draw

	hwi CloseStack
}
proc dx {} {
	contourPlot "Displacement" "x"
}
proc dy {} {
	contourPlot "Displacement" "y"
}
proc dz {} {
	contourPlot "Displacement" "z"
}
proc dm {} {
	contourPlot "Displacement" "mag"
}
proc stress_vm {} {
	contourPlot "Stress" "vonMises"
}