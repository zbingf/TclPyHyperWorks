# -------------------------------------
# hvContour.tcl
# hypermesh
# hyperview 后处理 代码
# 调用 source [join "[pwd] HW_code/hvContour.tcl" "/"]
# -------------------------------------

proc contourPlot {data_type component} {
	hwi OpenStack
	catch {	
		# hwISession 创建
		hwi GetSessionHandle sessObj
	}
	catch {	
		# hwIProject 创建
		sessObj GetProjectHandle proObj
	}
	catch {	
		# hwIPage 创建
		proObj GetPageHandle pagObj [proObj GetActivePage]
	}
	catch {	
		# hwIWindow 创建
		pagObj GetWindowHandle winObj [pagObj GetActiveWindow]
	}
	catch {	
		# 获取 Client , 当前为 polPost
		winObj GetClientHandle postObj
	}
	catch {	
		# polModel 创建
		postObj GetModelHandle modeObj [postObj GetActiveModel]
	}
	catch {	
		# polResultCtrl 创建
		modeObj GetResultCtrlHandle resultObj
	}
	catch {	
		# polContourCtrl 创建
		resultObj GetContourCtrlHandle contourObj
	}
	catch {	
		# polLegend 创建
		contourObj GetLegendHandle legendObj
	}

	# polContourCtrl 设置
	contourObj SetDataType "$data_type"
	contourObj SetDataComponent "$component"
	contourObj RestorePlotStyle "Deafault Contour"
	contourObj SetEnableState true
	
	legendObj SetType dynamic

	postObj SetDisplayOptions "contour" true
	postObj SetDisplayOptions "legend" true
	postObj Draw

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