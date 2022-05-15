# version: hyperview 2021.1


# 导出目标csv数据, elemID,ContourValue
proc search_fatigue_result_damdage {csv_path damage_limit} {
    set t 1
    catch { hwi CloseStack }
    hwi  OpenStack
        hwi GetSessionHandle sess$t 
        sess$t GetProjectHandle prj$t
        prj$t GetPageHandle pg$t [prj$t GetActivePage]
        pg$t GetWindowHandle win$t [pg$t GetActiveWindow]
        win$t GetClientHandle cln$t 
        cln$t GetModelHandle mdl$t [cln$t GetActiveModel]
        set setid  [ mdl$t AddSelectionSet element ]
        mdl$t GetSelectionSetHandle elem$t $setid 
        elem$t Add "contour > $damage_limit "
        mdl$t GetQueryCtrlHandle qry$t 
        qry$t SetQuery "element.id,contour.value"
        qry$t SetSelectionSet $setid
        qry$t WriteData $csv_path
        mdl$t RemoveSelectionSet $setid 
    hwi CloseStack
}


# 



hwc "result scalar load type=Stress component=vonMises layer=Max"
hwc "animate transient time 7"
search_fatigue_result_damdage "D:/github/TclPyHyperWorks/Project_StrainPoint/temp.csv" 0


