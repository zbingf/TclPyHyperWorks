# opt_fatigue
用于optistruct的耐久计算, 相关项目


## hmCompChange_2021to2017.py
+ fem版本切换
	+ 2021.1 转 2017


## fatigue_fem_path_edit.py
fatigue 路径替换-计算用

+ optistruct fatigue计算文件 fem编辑
	+ 替换h3d、mrf路径
+ 生成新的fem文件


## fatigue_fem_set_select.py
fatigue set选择性截取


## fatigue_fem_fatdef_split.py
fatigue set分割-计算用

+  fem分割, 创建新的fem文件
+ FATDEF分割成单个set
+ 用于各set单独计算


## stat_time_read.py
stat文件读取, 获取opt计算时长


## fatigue_search_node_ids.tcl
+ hyperview 二次开发, 根据elem id截取圈选区域内的数据
+ 调用文件
	+ sub_fatigue_result.py
		+ 根据fem查找数据

