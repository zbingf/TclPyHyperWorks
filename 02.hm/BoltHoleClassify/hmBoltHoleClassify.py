
import os.path
import math
import os


MIN_NODE_NUM = 3
R_DEFAULT = 1000
file_dir  = os.path.dirname(__file__)
fem_path  = os.path.join(file_dir, '__temp.fem')
csv_path  = os.path.join(file_dir, '__temp.csv')

get_line_n = lambda line, n: line[8*n:8*(n+1)].strip()
dis_loc    = lambda loc1, loc2: ((loc1[0]-loc2[0])**2 + (loc1[1]-loc2[1])**2 + (loc1[2]-loc2[2])**2)**0.5
v_abs      = lambda loc1: (loc1[0]**2 + loc1[1]**2 + loc1[2]**2)**0.5
v_one      = lambda loc1: [loc1[0]/v_abs(loc1), loc1[1]/v_abs(loc1), loc1[2]/v_abs(loc1)]

import numpy as np
from numpy.linalg import det


# 由圆上三点确定圆心和半径
def points2circle(p1, p2, p3):
    """
        INPUT
            # p1   :  - 第一个点坐标, list或者array 1x3
            # p2   :  - 第二个点坐标, list或者array 1x3
            # p3   :  - 第三个点坐标, list或者array 1x3
        
        OUTPUT
            # r    :  - 半径, 标量

    """
    p1 = np.array(p1)
    p2 = np.array(p2)
    p3 = np.array(p3)
    num1 = len(p1)
    num2 = len(p2)
    num3 = len(p3)

    # 输入检查
    if (num1 == num2) and (num2 == num3):
        if num1 == 2:
            p1 = np.append(p1, 0)
            p2 = np.append(p2, 0)
            p3 = np.append(p3, 0)
        elif num1 != 3:
            return '\t仅支持二维或三维坐标输入'
            # return None
    else:
        return '\t输入坐标的维数不一致'
        # return None

    # 共线检查
    temp01 = p1 - p2
    temp02 = p3 - p2
    temp03 = np.cross(temp01, temp02)
    # temp = (temp03 @ temp03) / (temp01 @ temp01) / (temp02 @ temp02)
    temp = v_multi_dot(temp03, temp03) / v_multi_dot(temp01, temp01) / v_multi_dot(temp02, temp02)
    if temp < 10**-6:
        return '\t三点共线, 无法确定圆'
        # return None

    temp1 = np.vstack((p1, p2, p3))
    temp2 = np.ones(3).reshape(3, 1)
    mat1 = np.hstack((temp1, temp2))  # size = 3x4

    m = +det(mat1[:, 1:])
    n = -det(np.delete(mat1, 1, axis=1))
    p = +det(np.delete(mat1, 2, axis=1))
    q = -det(temp1)

    # temp3 = np.array([p1 @ p1, p2 @ p2, p3 @ p3]).reshape(3, 1)
    temp3 = np.array([v_multi_dot(p1, p1), v_multi_dot(p2, p2), v_multi_dot(p3, p3)]).reshape(3, 1)
    temp4 = np.hstack((temp3, mat1))
    temp5 = np.array([2 * q, -m, -n, -p, 0])
    mat2 = np.vstack((temp4, temp5))  # size = 4x5

    A = +det(mat2[:, 1:])
    B = -det(np.delete(mat2, 1, axis=1))
    C = +det(np.delete(mat2, 2, axis=1))
    D = -det(np.delete(mat2, 3, axis=1))
    E = +det(mat2[:, :-1])

    pc = -np.array([B, C, D]) / 2 / A
    r = np.sqrt(B * B + C * C + D * D - 4 * A * E) / 2 / abs(A)

    return r

# 向量叉乘
def v_multi_x(loc1, loc2):
    x1, y1, z1 = loc1
    x2, y2, z2 = loc2
    return [y1*z2-y2*z1, z1*x2-z2*x1, x1*y2-x2*y1]

# 向量点乘
def v_multi_dot(loc1, loc2):
    x1, y1, z1 = loc1
    x2, y2, z2 = loc2
    value = x1*x2 + y1*y2 + z1*z2    
    return value

# 向量数值乘
def v_multi_c(loc1, c):
    x1, y1, z1 = loc1
    return [x1*c, y1*c, z1*c]

# 向量 减
def v_sub(loc1, loc2):
    x1, y1, z1 = loc1
    x2, y2, z2 = loc2
    return [x1-x2, y1-y2, z1-z2]

# 矢量夹角计算
def angle_2vector(base_v_loc, target_v_loc):

    base_abs = v_abs(base_v_loc)
    target_abs = v_abs(target_v_loc)
    a_dot_b = v_multi_dot(base_v_loc, target_v_loc)
    value = a_dot_b / (base_abs*target_abs)
    if value > 1: value = 1
    if value < -1: value = -1

    angle_rad = math.acos(value)
    return angle_rad

# 3点确定平面公式
def surface_3point(loc1, loc2, loc3):
    a = ( (loc2[1]-loc1[1])*(loc3[2]-loc1[2])-(loc2[2]-loc1[2])*(loc3[1]-loc1[1]) )
    b = ( (loc2[2]-loc1[2])*(loc3[0]-loc1[0])-(loc2[0]-loc1[0])*(loc3[2]-loc1[2]) )
    c = ( (loc2[0]-loc1[0])*(loc3[1]-loc1[1])-(loc2[1]-loc1[1])*(loc3[0]-loc1[0]) )
    d = ( 0-(a*loc1[0]+b*loc1[1]+c*loc1[2]) )
    return a, b, c, d

# 点到面距离公式
def dis_point_to_face(loc_c, loc1, loc2, loc3):
    x, y, z = loc_c
    a, b, c, d = surface_3point(loc1, loc2, loc3)
    return abs(a*x+b*y+c*z+d) / (a*a+b*b+c*c)**0.5

# 字符串转float
def str2float(str1):

    if '-' in str1[1:]:
        new_str1 = str1[0] + str1[1:].replace('-', 'e-')
    elif '+' in str1[1:]:
        new_str1 = str1[0] + str1[1:].replace('+', 'e+')
    else:
        new_str1 = str1

    return float(new_str1)

# 读取&解析数据
def read_data(fem_path):

    bar2node, node2loc = {}, {}
    rbe2_indenode2elem, rbe2_elem2indenode = {}, {}
    rbe2_elem2denode, cbar_node2elem = {}, {}
    # rbe2_ids, bar_ids = [], []

    f = open(fem_path, 'r')
    is_rbe2 = False
    while True:
        line = f.readline()
        if not line :break
        if "$" == line[0]: continue
        
        if "GRID" == line[:4]:
            g_id = get_line_n(line, 1)
            x = str2float(get_line_n(line, 3))
            y = str2float(get_line_n(line, 4))
            z = str2float(get_line_n(line, 5))
            node2loc[g_id] = [x, y, z]
            is_rbe2 = False
            continue
        
        if "CBAR" == line[:4] or "CBEAM" == line[:5]:
            e_id = get_line_n(line, 1)
            id1  = get_line_n(line, 3)
            id2  = get_line_n(line, 4)
            bar2node[e_id] = [id1, id2]
            cbar_node2elem[id1] = e_id
            cbar_node2elem[id2] = e_id
            is_rbe2 = False
            continue

        if "RBE2" == line[:4]:
            e_id = get_line_n(line, 1)
            n_len = math.floor(len(line)/8)
            inde_id = get_line_n(line, 2)
            rbe2_indenode2elem[inde_id] = e_id
            rbe2_elem2indenode[e_id]    = inde_id
            rbe2_elem2denode[e_id]      = [get_line_n(line, 4)]
            for n in range(5, n_len):
                cur_id = get_line_n(line, n)
                if cur_id:
                    rbe2_elem2denode[e_id].append(cur_id)
            is_rbe2 = True
            continue

        if line[0] == "+" and is_rbe2:
            n_len= math.floor(len(line)/8)
            for n in range(1, n_len):
                cur_id = get_line_n(line, n)
                if cur_id:
                    rbe2_elem2denode[e_id].append(cur_id)
            continue

        is_rbe2 = False
    f.close()

    return bar2node, node2loc, rbe2_indenode2elem, rbe2_elem2indenode, rbe2_elem2denode, cbar_node2elem

# csv数据读取-bar2 ID
def read_csv_data(csv_path):
    with open(csv_path, 'r') as f:
        lines = [line for line in f.read().split('\n') if line]
    
    line = lines[0]
    bar2_ids = [v for v in line.split(' ') if v]
    return bar2_ids

# 主程序
def main_get_bar2(fem_path, csv_path):
    bar2node, node2loc, rbe2_indenode2elem, rbe2_elem2indenode, rbe2_elem2denode, cbar_node2elem = read_data(fem_path)
    bar2_ids = read_csv_data(csv_path)

    bar2_r_dic = {}
    for bar2_id in bar2_ids:

        center_ids = bar2node[bar2_id]
        if len(center_ids) != 2: continue
        base_center_id = center_ids[0]
        target_center_id = center_ids[1]

        if base_center_id not in rbe2_indenode2elem: continue
        if target_center_id not in rbe2_indenode2elem: continue

        rbe2_base_id = rbe2_indenode2elem[base_center_id]
        rbe2_target_id = rbe2_indenode2elem[target_center_id]

        base_node_ids = rbe2_elem2denode[rbe2_base_id]
        target_node_ids = rbe2_elem2denode[rbe2_target_id]

        base_id_to_dis, target_id_to_dis = {}, {}
        for base_node_id in base_node_ids:
            dis1 = dis_loc(node2loc[base_node_id], node2loc[base_center_id])
            base_id_to_dis[base_node_id] = dis1
        
        for target_node_id in target_node_ids:
            dis1 = dis_loc(node2loc[target_node_id], node2loc[target_center_id])
            target_id_to_dis[target_node_id] = dis1

        # base_dis_list, target_dis_list = [], []
        base_sorted_ids   = sorted(base_id_to_dis, key=lambda v: base_id_to_dis[v])
        target_sorted_ids = sorted(target_id_to_dis, key=lambda v: target_id_to_dis[v])
        b_r = points2circle(*[node2loc[base_node_id] for base_node_id in base_sorted_ids[:3]])
        t_r = points2circle(*[node2loc[target_node_id] for target_node_id in target_sorted_ids[:3]])
        if isinstance(b_r, str): b_r = R_DEFAULT
        if isinstance(t_r, str): t_r = R_DEFAULT
        if isinstance(b_r, str) and isinstance(t_r, str): continue

        # print(base_dis_list, target_dis_list)
        # bar2_r_dic[bar2_id] = {'base':b_r, 'target':t_r}
        bar2_r_dic[bar2_id] = [b_r, t_r]

    return bar2_r_dic




bar2_r_dic = main_get_bar2(fem_path, csv_path)
# print(bar2_r_dic)
r_to_bar2 = {}

for bar2_id in bar2_r_dic:
    
    # base_mean = sum(bar2_r_dic[bar2_id]['base'])/len(bar2_r_dic[bar2_id]['base'])
    # target_mean = sum(bar2_r_dic[bar2_id]['target'])/len(bar2_r_dic[bar2_id]['target'])
    # r = min([base_mean, target_mean])
    r = min(bar2_r_dic[bar2_id])
    r = int((r+0.05)*2)/2
    if r not in r_to_bar2: r_to_bar2[r] = []
    r_to_bar2[r].append(bar2_id)

output_strs = []
for r in r_to_bar2:
    ids_str = ' '.join(r_to_bar2[r])
    output_strs.append('{{{} {}}}'.format(r, ids_str))

print(' '.join(output_strs))


