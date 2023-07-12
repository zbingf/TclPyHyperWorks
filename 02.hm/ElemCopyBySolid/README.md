# hmElemCopyBySolid

### 软件版本
+ hypermesh 2017

### 功能
+ 复制几何网格到相同的solid

-----------------
### 控制参数
+ 体积偏差百分比 %
+ 面积差值  
+ 惯性张量(Ixx Iyy Izz Ixy Ixz Iyz)累计差值 

-----------------
### 操作
1. 选择Elems (要复制的网格)
2. 选择Base Solid (要复制solid实体)
3. 选择Target Solids (目标solid实体,可多个)
4. 计算

-----------------
## 原理
+ 复制Base solid ;Elems复制并随动
+ 移动Base solid 到 Target Solid 
	1. 平移-对齐-几何中心point1
	2. 旋转-对齐-离中心最远point2
	3. 旋转-对齐-离point1\point2都最远的点
	4. (对于具有对称性的Solid, 当前需经过多次迭代调整)
+ 通过solid的体积\面积\转动惯量判断Solid是否移动到位
+ 循环移动复制

-----------------
### 版本更替
+ v5.3
	+ 调整默认值设置
	```tcl
	if {[info exists ::ElemCopyBySolid::volume_delta_percent]==0} {set ::ElemCopyBySolid::volume_delta_percent 0.01}
	if {[info exists ::ElemCopyBySolid::area_delta_value]==0} {set ::ElemCopyBySolid::area_delta_value 1}
	if {[info exists ::ElemCopyBySolid::I_delta_value]==0} {set ::ElemCopyBySolid::I_delta_value 10}
	```

+ v5.4
	+ 增加镜像选项