# TieSurfToSurfCreate

### 软件版本
+ hypermesh 2017

### 功能
+ 创建Tie接触-面对面

-----------------
### 控制参数
	+ 网格1与网格2的间距允许 mm
	+ 网格1与网格2各自法向量的夹角允许 deg
	+ 网格1与网格2连接处的法向量夹角允许 deg

-----------------
### 操作
1. 选择网格1
2. 选择网格2
3. 设置控制参数, Tie接触名称
4. 在网格1与2间创建Tie接触

-----------------
### 版本更替
+ v4.0 
	+ 利用\*feoutput_select 选择性导出 elem及node
	```tcl
	proc print_elem_node_to_fem {fem_path elem_ids} {
		# 导出指定单元数据到fem
		set altair_dir [hm_info -appinfo ALTAIR_HOME]
		set optistruct_path [format "%s/templates/feoutput/optistruct/optistruct" $altair_dir]
		# elems 1
		eval "*createmark elems 1 $elem_ids"
		# nodes 1
		hm_createmark nodes 1 "by elem" $elem_ids
		# 导出
		hm_answernext yes
		*feoutput_select "$optistruct_path" $fem_path 1 0 0
	}
	```
+ v4.1
	+ 增加tests文件夹, 用于调试程序
	+ 调整控制参数的定义
	```tcl
	namespace eval ::tieCreate {
	    variable surf_name
	    variable dis_limit
	    variable deg_limit
	    variable deg_limit_surf
	    variable recess
	    variable file_dir [file dirname [info script]]
	}

	if {[info exists ::tieCreate::surf_name]==0} {set ::tieCreate::surf_name "Tie_Surf2Surf_n"}
	if {[info exists ::tieCreate::dis_limit]==0} {set ::tieCreate::dis_limit 1}
	if {[info exists ::tieCreate::deg_limit]==0} {set ::tieCreate::deg_limit 10}
	if {[info exists ::tieCreate::deg_limit_surf]==0} {set ::tieCreate::deg_limit_surf 70}

	```