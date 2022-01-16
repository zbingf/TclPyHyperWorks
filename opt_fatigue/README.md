
# opt_fatigue
用于optistruct的耐久计算

## hmCompChange_2021to2017.py
+ fem版本切换
	+ 2021.1 转 2017

## fem_fatigue_edit.py
+ optistruct fatigue计算文件 fem编辑
	+ 替换h3d、mrf路径

## fatigue_search_node_ids.tcl
+ hyperview 二次开发, 根据elem id截取圈选区域内的数据
+ 调用文件
	+ fatigue_result.py
		+ 根据fem查找数据


