# optistruct-耐久计算集成: using_code

版本: 2021.1

## 输入参数
+ flexbody.h3d 目标柔性体h3d文件
+ optistruct_fatigue.fem 耐久计算用fem基础文件未拆分set及设置路径前
+ optistruct.bat 解算器调用文件
+ motionsolve_result.mrf(s) 计算结果mrf文件
+ base_folder_path 基础文件夹路径
+ set_limit 单元截取限制, default:15000
+ set_id_range 计算目标set的ID范围

## 流程
1. 创建文件夹
	+ 02_fem: 分割后的fem存放路径
	+ 03_autocalc: 调整后fems存放路径,及指定的计算路径
	+ 04_result_h3d: 计算完成后的h3d存放路径
	+ 05_result_stat: 结果文件之一stat, 记录计算过程即时长
	+ 06_sus_h3d: 空文件加用于存放叠加后的h3d文件

2. 分割fem set
	+ 存放于 02_fem: path_fem
	+ fem_split_lists 列表

3. 重新定义fem路径
	+ 存放于 03_autocalc: path_autocalc
	+ fem_new_lists 列表
	+ 确认文件数量

4. 开始计算fem文件
	+ 自动计算路径: path_autocalc
	+ 计算返回

5. 移动数据
	+ 结果h3d移动到 04_result_h3d: path_result_h3d
		+ result_h3d_lists 列表
	+ 结果stat移动到 05_result_stat: path_result_stat
		+ result_stat_lists 列表

6. 统计计算时长
	+ 解析 result_stat_lists 中的文件数据

## 主函数
1. stat_time_read.py  stat_time_read(stat_paths, recode_path)
2. py_bat_opt_run.py  opt_run(opt_path, run_dir, is_break=False) new_fem_paths
3. fatigue_fem_path_edit.py fatigue_fem_path_edit(fem_paths, h3d_path, mrf_paths) new_fem_paths
4. fatigue_fem_fatdef_split_limit.py split_fatigue_fatdef_set_limit(fem_path, set_range, max_num=15000) new_fem_paths 



# opt_fatigue 各子模块
用于optistruct的耐久计算, 相关项目


## hmCompChange_2021to2017.py
+ fem版本切换
	+ 2021.1 转 2017


## fatigue_fem_path_edit.py
fatigue 路径替换-计算用

+ optistruct fatigue计算文件 fem编辑
	+ 替换h3d、mrf路径
+ 生成新的fem文件


## fatigue_fem_fatdef_split_limit.py
fatigue set分割-计算用, 设置网格调整上限


## fatigue_fem_fatdef_split.py
fatigue set分割-计算用

+ fem分割, 创建新的fem文件
+ FATDEF分割成单个set
+ 用于各set单独计算


## stat_time_read.py
stat文件读取, 获取opt计算时长


## fatigue_search_node_ids.tcl
+ hyperview 二次开发, 根据elem id截取圈选区域内的数据
+ 调用文件
	+ sub_fatigue_result.py
		+ 根据fem查找数据


## hvSumH3dDamage.tcl
hyperview
批量线性叠加损伤结果, 配套耐久分割程序
+ 调用文件
	+ sub_get_h3d_files.py
		+ hyperview tk 无法读取大量文件路径, 故切换python读取


----------------------

# 使用顺序

1、 fatigue_fem_path_edit
+ 对fem文件重定义h3d、mrf路径，生成可计算fem

2、 fatigue_fem_fatdef_split_limit
+ 对fem文件set进行分割，并设置调整网格上限，生成多个

3、 stat_time_read
+ 查看结果计算时长
+ 将结果存放于 stat_time_read.log 中



# 版本差异
+ v08
	+ 集成各功能: main_fatigue.py

+ v09
	+ 修改fatigue_fem_fatdef_split_limit.py
		+ set_id再检索范围内，但不在fatdef耐久计算卡片内时，绕过对应set_id
		+ 在网格分割时，不再计算范围内的set不产生相应的fem文件