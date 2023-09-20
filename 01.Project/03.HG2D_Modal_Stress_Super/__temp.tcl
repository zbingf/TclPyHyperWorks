# D:/00_CAE_project/202308_01_VirtualStrain_SHEEL/lca_flexbody_50.h3d
hwc hwd window type="HyperGraph 2D"
hwc xy curve delete range= "p:all w:all i:all"
set hwc_command {xy load file=D:/00_CAE_project/202308_01_VirtualStrain_SHEEL/lca_flexbody_50.h3d subcase= "CMS FlexBody" ydatatype= "Stress (Flexbody Elements)" yrequest= E14610,E15604,E19974,E19535 ycomponent= "XX (Z1)" , "YY (Z1)" , "ZZ (Z1)" , "XY (Z1)" , "YZ (Z1)" , "ZX (Z1)" , "XX (Z2)" , "YY (Z2)" , "ZZ (Z2)" , "XY (Z2)" , "YZ (Z2)" , "ZX (Z2)" xdatatype= Frequency}
hwc $hwc_command
hwi GetSessionHandle sess;
sess GetClientManagerHandle pm Plot;
pm GetExportCtrlHandle ex
ex SetFormat "xy data"
ex SetFilename "D:/00_CAE_project/202308_01_VirtualStrain_SHEEL/lca_flexbody_50_xy_data.txt"
ex GetFilename
ex Export
hwi CloseStack


