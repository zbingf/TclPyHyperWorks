
proc output_damage {csv_path setid} \
{
    hwi OpenStack
        hwi GetSessionHandle sessObj
        sessObj GetProjectHandle proObj
        proObj GetPageHandle pagObj [proObj GetActivePage]
        pagObj GetWindowHandle winObj [pagObj GetActiveWindow]
        winObj GetClientHandle postObj
        postObj GetModelHandle modelObj [postObj GetActiveModel]
        modelObj GetResultCtrlHandle resultObj

        modelObj GetSelectionSetHandle selectionObj [modelObj AddSelectionSet node]
        selectionObj Add "idlist $setid"

        modelObj GetQueryCtrlHandle qryObj 

        qryObj SetQuery "node.id,contour.value"
        qryObj SetSelectionSet [selectionObj GetID]
        qryObj WriteData $csv_path
    hwi CloseStack
}



set model_path [tk_getOpenFile -initialdir "D:\temp\BC22S01\NcodeCalc\Fz30kNFxLoad_target"]
set result_paths [tk_getOpenFile -multiple 1 -initialdir "D:\temp\BC22S01\NcodeCalc\Fz30kNFxLoad_target"]
set setid "60212,60215,49891,49894,51519,51528,71745,71748"


foreach result_path $result_paths {
    hwc open animation modelandresult $model_path $result_path
    hwc result subcase "Loadcase 1"
    hwc result scalar load type=Damage
    set csv_path "$result_path.csv"
    puts "csv_path: $csv_path"
    output_damage $csv_path $setid
}




