# hmElemCopyBySolid

## 用途
+ 复制几何网格到相同的solid

## 原理
+ 复制Base solid ;Elems复制并随动
+ 移动Base solid 到 Target Solid 
	+ 平移-对齐-几何中心point1
	+ 旋转-对齐-离中心最远point2
	+ 旋转-对齐-离point1\point2都最远的点
	+ (对于具有对称性的Solid, 当前需经过多次迭代调整)
+ 通过solid的体积\面积\转动惯量判断Solid是否移动到位
+ 循环移动复制

