## Hypermesh 相关二次开发

version 1.5.0
20230222


+ hmGUI : 主文件
+ hmGUI_ForMesh : 主文件(截取部分功能)

----------------------
+ 网格处理相关功能
	+ ElemCopyBySolid    根据solid复制Elem( solid一模一样的的情况 )
	+ BeamRectangularBox 根据16点point的矩形钢实体solid, 创建BEAM单元
	+ HoleMesh 			 孔网格划分(要求:圆孔离边界较远)


+ 螺栓孔相关
	+ BoltHoleAxisZCorrect bar2-参考Z轴校正
	+ BoltHoleCheck 	螺栓孔对称性-检查
	+ BoltHoleClassify  圆孔分类, 自动生成
	+ BoltHoleConnect 	螺栓孔-连接
	+ BoltHoleCorrect	螺栓孔对称性-校正

+ Tie接触相关
	+ TieSurfToSurfCreate 	面-面接触
	+ TiePointToSurfCreateSelect 点-面接触-手动
	+ TiePointToSurfCreate  点-面接触-未完成!!
	+ CheckElemAttachTie 	根据接触的网格检查所有网格的共节点情况


----------------------
## 相关变更

+ 20211207
	+ 孔分类
		+ 主函数-删除1D单元显示设置
		+ 更新README.md

	+ 全部
		* 打印兼容性考虑， f'' 替换

	+ 孔Z轴校正
		* 开头增加"是否计算判断"

	+ 调整GUI界面 第4与第5行对调

