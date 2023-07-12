# BoltHoleClassify

### 软件版本
+ hypermesh 2017

### 功能
+ 螺栓孔-螺栓尺寸分类, 并赋予梁单元

-----------------
### 控制参数
+ 名称前缀

-----------------
### 操作
1. 设置控制参数
2. 计算

-----------------
## 原理
1. 根据孔周围单元elem，获取bar单元及rbe2单元
2. 根据根据孔上3点坐标获取圆的半径，选择bar两端孔最小半径的孔径作为螺栓半径
3. 根据 int((r+0.05)*2)/2 定义Beam的半径尺寸
4. 对bar进行分类并创建BEAM单元

-----------------
### 版本更替
+ v1.0 

+ v1.1 
	* 对elem选择增加额外判定

+ v1.2
	* 孔半径判定改为3点确定半径
	* 增减BEAM创建
+ V1.3
	* 兼容性校正

	```python
def points2circle(p1, p2, p3):
	# temp = (temp03 @ temp03) / (temp01 @ temp01) / (temp02 @ temp02)
    temp = v_multi_dot(temp03, temp03) / v_multi_dot(temp01, temp01) / v_multi_dot(temp02, temp02)
    ...
	# temp3 = np.array([p1 @ p1, p2 @ p2, p3 @ p3]).reshape(3, 1)
    temp3 = np.array([v_multi_dot(p1, p1), v_multi_dot(p2, p2), v_multi_dot(p3, p3)]).reshape(3, 1)
	```
