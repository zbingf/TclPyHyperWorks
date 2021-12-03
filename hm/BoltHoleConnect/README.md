# BoltHoleConnect

### 软件版本
+ hypermesh 2017

### 功能
+ 创建孔连接

-----------------
### 控制参数
+ 连接容差 tolerance
+ 闭环-周长上限 c_limit
+ 孔网格-Comp名称

-----------------
### 操作
1. BaseComp选择, node从这选取
2. TargetComp选择, 连接对象, 可多选
3. 设置控制参数
4. 计算

-----------------
## 原理
+ 创建BaseComp的edge(1D PLOTEL单元), 导出elem&node数据为fem
+ Python计算fem, 找出闭环1D单元的周长Cn
	+ 当c_limit小于Cn时, 符合要求, 并记录闭环上的1个node ID
+ 根据python返回的node_ids, 利用命令(1D→connectors→bolt→bolt)创建网格空(连接容差用于此命令)

-----------------
### 版本更替
+ v1.0 
