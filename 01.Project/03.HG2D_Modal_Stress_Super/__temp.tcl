# D:/00_CAE_project/202407_02_VirtualStrain_SHEEL/01_virtualstrain_sheel.h3d
hwc hwd window type="HyperGraph 2D"
hwc xy curve delete range= "p:all w:all i:all"
set hwc_command {xy load file=D:/00_CAE_project/202407_02_VirtualStrain_SHEEL/01_virtualstrain_sheel.h3d subcase= "CMS FlexBody" ydatatype= "Stress (Flexbody Elements)" yrequest= E361,E421,E442,E501,E651,E781,E801,E821,E901,E921,E961,E1261,E1561,E2001 ycomponent= "XX (Z1)" , "YY (Z1)" , "ZZ (Z1)" , "XY (Z1)" , "YZ (Z1)" , "ZX (Z1)" , "XX (Z2)" , "YY (Z2)" , "ZZ (Z2)" , "XY (Z2)" , "YZ (Z2)" , "ZX (Z2)" xdatatype= Frequency}
hwc $hwc_command
hwi GetSessionHandle sess;
sess GetClientManagerHandle pm Plot;
pm GetExportCtrlHandle ex
ex SetFormat "xy data"
ex SetFilename "D:/00_CAE_project/202407_02_VirtualStrain_SHEEL/01_virtualstrain_sheel_xy_data.txt"
ex GetFilename
ex Export
hwi CloseStack


