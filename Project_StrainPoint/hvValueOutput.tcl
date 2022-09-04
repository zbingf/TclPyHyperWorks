# version: hyperview 2021.1

# poIQueryCtrl SetQuery  输出数据详细信息

proc output_value {csv_path select_type expression query_type} {
    catch { hwi CloseStack }
    hwi  OpenStack
        hwi GetSessionHandle sess_obj 
        sess_obj GetProjectHandle prj_obj
        prj_obj GetPageHandle pg_obj [prj_obj GetActivePage]
        pg_obj GetWindowHandle win_obj [pg_obj GetActiveWindow]
        win_obj GetClientHandle cln_obj 
        cln_obj GetModelHandle mdl_obj [cln_obj GetActiveModel]

        set setid  [ mdl_obj AddSelectionSet $select_type ]
        mdl_obj GetSelectionSetHandle elem_obj $setid 
        
        # 阀值限制
        elem_obj Add $expression
        mdl_obj GetQueryCtrlHandle qry_obj 

        # 输出内容
        qry_obj SetQuery $query_type

        qry_obj SetSelectionSet $setid
        qry_obj WriteData $csv_path
        mdl_obj RemoveSelectionSet $setid 
    hwi CloseStack
}

#  ---------------------------------------------
# element
# 导出目标csv数据, elemID,ContourValue
proc output_elem_value_by_upperlimit {csv_path upperlimit} {
    output_value $csv_path "element" "contour > $upperlimit " "element.id,contour.value,element.centroid,misc.load,misc.sim"
}

proc output_elem_value_by_ids {csv_path elem_ids} {
    output_value $csv_path "element" "idlist $elem_ids" "element.id,contour.value,element.centroid,misc.load,misc.sim"
}


#  ---------------------------------------------
# node
# 导出目标csv数据, nodeID,ContourValue
proc output_node_value_by_upperlimit {csv_path upperlimit} {
    output_value $csv_path "node" "contour > $upperlimit " "node.id,contour.value,node.coords,misc.load,misc.sim"
}


# 导出目标csv数据, nodeID,ContourValue
proc output_node_value_by_ids {csv_path node_ids} {
    output_value $csv_path "node" "idlist $node_ids" "node.id,contour.value,node.coords,misc.load,misc.sim"
}


# 

hwc "result scalar load type=Stress component=vonMises layer=Max"
hwc "animate transient time 7"

hwc result scalar load type=Stress avgmode=none layer=none
output_elem_value_by_upperlimit "D:/github/TclPyHyperWorks/Project_StrainPoint/temp_elem_upperlimit.csv" 1000
output_elem_value_by_ids "D:/github/TclPyHyperWorks/Project_StrainPoint/temp_elem_ids.csv" "18500,18512,12179"


hwc result scalar load type=Stress avgmode=advanced system=global
output_node_value_by_upperlimit "D:/github/TclPyHyperWorks/Project_StrainPoint/temp_node_upperlimit.csv" 1000
output_node_value_by_ids "D:/github/TclPyHyperWorks/Project_StrainPoint/temp_node_ids.csv" "22216,49233,49070"

