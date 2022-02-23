# 稳定杆计算平台搭建
# source "D:/github/TclPyHyperWorks/P_Platform_ARB/platform_antiroll.tcl"


# # 双页显示
# hwc hwd page current layout=1

# # 左页
# hwd page current activewindow=1
# # hm页面(只支持1页)
# hwd window type=HyperMesh

# # 右页
# hwd page current activewindow=2
# # hv页面
# hwd window type=HyperView


# ==========================================
# 网格划分




# ==========================================
# 求解计算




# ==========================================
# 界面切换
hwc hwd page makecurrent 1
catch {hwc hwd page delete 2}
hwc hwd page add title=Result
hwc hwd page makecurrent 2
hwc hwd window type=HyperView


# 加载结果并显示
set h3d_path "D:/00_CAE_project/202201_01_platform_antiroll/LCA.h3d"

set value_legend_max 700
set value_legend_min 100 
set legend_dis 100


set h3d_dir [file dirname $h3d_path]
set fig_path1 [file join $h3d_dir test1.png]
set fig_path2 [file join $h3d_dir test2.png]
set fig_path3 [file join $h3d_dir test3.png]


# 加载结果
set model_path $h3d_path
set result_path $h3d_path
hwc open animation modelandresult $model_path $result_path

# 显示
# hwc result scalar load type=Stress component=vonMises layer=Max
hwc result scalar load type=Stress component=vonMises avgmode=advanced layer=Max system=global

hwc show legends


set n_legend [expr $value_legend_max / $legend_dis + 1]
# puts "n_legend: $n_legend"
hwc result scalar legendmaxenabled true
hwc result scalar legendminenabled true

hwc result scalar legend layout levels=$n_legend
hwc result scalar legend values levelvalue="0 $value_legend_max"
hwc result scalar legend values levelvalue="0 $value_legend_min"

hwc result scalar legendmax $value_legend_max
hwc result scalar legendmin $value_legend_min

# test
hwc animate transient time 7
# ``````````````````````````````````````````````````````````````` 修改显示

hwc annotation measure "Static MinMax Result" display visibility=true
hwc annotation measure "Static MinMax Result" display  min=false

hwc annotation measure global autohide=true
hwc annotation measure global transparency=false
hwc annotation measure global prefix=false


hwc view orientation top
hwc save image window $fig_path1


hwc view orientation bottom
hwc save image window $fig_path2


hwc view orientation iso
hwc save image window $fig_path3

