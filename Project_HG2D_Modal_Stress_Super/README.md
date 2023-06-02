
## 基于hypergraph2D读取应力数据进行叠加计算

### 流程
1、 通过hypergraph2D打开模型文件
2、 导出指定单元ID的应变数据【CSV-01】
3、 解析【CSV-01】 & 读取模态坐标数据【RSP】
4、 进行数据叠加,输出叠加后的结果【CSV-02】, 带方向SignVonmises


+ hg2d_stress_tcl.py    在hg2d中导出模态应力


+ linear_susp_elem_sign_vonmises.py
	单元应力采集
	对应 nocde的elem应变采集
	结果：整体应力较Ncode虚拟应变略高，比例关系




+ linear_susp_node_sign_vonmises.py
	待定

注: 当前与RB2共节点的应力数据不准  ？ 