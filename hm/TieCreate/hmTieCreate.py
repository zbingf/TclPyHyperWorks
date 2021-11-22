import os.path
import math
import sys

try:
    dis_limit = int(sys.argv[1])
    deg_limit = int(sys.argv[2])
except:
    dis_limit = 30
    deg_limit = 10



file_dir  = os.path.dirname(__file__)
temp_path = os.path.join(file_dir, '__temp.csv')
fem_path  = os.path.join(file_dir, '__temp.fem')
tcl_path  = os.path.join(file_dir, '__temp.tcl')
tcl_path2 = os.path.join(file_dir, '__temp2.tcl')
tcl_path3 = os.path.join(file_dir, '__temp3.tcl')
tcl_path4 = os.path.join(file_dir, '__temp4.tcl')


get_line_n = lambda line, n: line[8*n:8*(n+1)].strip()
dis_loc    = lambda loc1, loc2: ((loc1[0]-loc2[0])**2 + (loc1[1]-loc2[1])**2 + (loc1[2]-loc2[2])**2)**0.5
v_abs      = lambda loc1: (loc1[0]**2 + loc1[1]**2 + loc1[2]**2)**0.5
v_one      = lambda loc1: [loc1[0]/v_abs(loc1), loc1[1]/v_abs(loc1), loc1[2]/v_abs(loc1)]

def v_multi_x(loc1, loc2):
    x1, y1, z1 = loc1
    x2, y2, z2 = loc2
    return [y1*z2-y2*z1, z1*x2-z2*x1, x1*y2-x2*y1]

def v_multi_dot(loc1, loc2):
    x1, y1, z1 = loc1
    x2, y2, z2 = loc2
    value = x1*x2 + y1*y2 + z1*z2    
    return value

def v_multi_c(loc1, c):
    x1, y1, z1 = loc1
    return [x1*c, y1*c, z1*c]

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


def str2float(str1):

    if '-' in str1[1:]:
        new_str1 = str1[0] + str1[1:].replace('-', 'e-')
    elif '+' in str1[1:]:
        new_str1 = str1[0] + str1[1:].replace('+', 'e+')
    else:
        new_str1 = str1

    return float(new_str1)


def get_nodes_center(locs):

    xs, ys, zs = 0, 0, 0
    for loc in locs:
        xs += loc[0]/len(locs)
        ys += loc[1]/len(locs)
        zs += loc[2]/len(locs)

    return [xs, ys, zs]

def get_v_element(locs):

    v1 = v_sub(locs[1], locs[0])
    v2 = v_sub(locs[2], locs[1])
    return v_multi_x(v1, v2)


def read_data(temp_path, fem_path):

    with open(temp_path, 'r') as f:
        lines = [line for line in f.read().split('\n') if line]

    elem_ids_b = [value for value in lines[0].split(' ') if value]
    elem_ids_t = [value for value in lines[1].split(' ') if value]

    grid_dic, elem_dic = {}, {}

    f = open(fem_path, 'r')
    while True:
        line = f.readline()
        if not line :break
        if "$" == line[0]: continue
        
        if "GRID" in line:
            g_id = get_line_n(line, 1)
            x = str2float(get_line_n(line, 3))
            y = str2float(get_line_n(line, 4))
            z = str2float(get_line_n(line, 5))
            grid_dic[g_id] = [x, y, z]
            continue
        
        if "CTRIA3" in line:
            e_id = get_line_n(line, 1)
            elem_dic[e_id] = [get_line_n(line, n) for n in [3, 4, 5]]

        if "CQUAD4" in line:
            e_id = get_line_n(line, 1)
            elem_dic[e_id] = [get_line_n(line, n) for n in [3, 4, 5, 6]]

    return elem_ids_b, elem_ids_t, grid_dic, elem_dic


elem_ids_b, elem_ids_t, grid_dic, elem_dic = read_data(temp_path, fem_path)

# 中心坐标计算
elem_center_dic = {}
for elem_id in elem_dic:
    locs = [grid_dic[node_id] for node_id in elem_dic[elem_id]]
    center_loc = get_nodes_center(locs)
    elem_center_dic[elem_id] = center_loc

# 数据筛选
base_ids, target_ids = [], []
base_vs, target_vs   = {}, {}

for n_b, elem_id_b in enumerate(elem_ids_b):
    
    for elem_id_t in elem_ids_t:
        dis_center = dis_loc(elem_center_dic[elem_id_b], elem_center_dic[elem_id_t])

        if dis_center < dis_limit:
            # 距离小于目标值
            locs_1 = [grid_dic[n] for n in elem_dic[elem_id_b]]
            locs_2 = [grid_dic[n] for n in elem_dic[elem_id_t]]
            v_b = v_one(get_v_element(locs_1))
            v_t = v_one(get_v_element(locs_2))

            # 基础单元指向目标单元, 判定基础单元法向是否正确
            v_b2t = v_sub(elem_center_dic[elem_id_t], elem_center_dic[elem_id_b])
            v_angle = angle_2vector(v_b2t, v_b) * 180 / math.pi
            if v_angle < 90:
                base_vs[elem_id_b] = 1
            else:
                base_vs[elem_id_b] = -1
                v_b = v_multi_c(v_b, -1) # 法向取反校正

            # 目标单元法向判定
            angle = angle_2vector(v_b, v_t) * 180 / math.pi
            if angle > 180-deg_limit or angle < deg_limit:
                if angle > 90:
                    target_vs[elem_id_t] = 1
                else: # 需取反
                    target_vs[elem_id_t] = -1

                base_ids.append(elem_id_b)
                target_ids.append(elem_id_t)

# 去重
base_ids = list(set(base_ids))
target_ids = list(set(target_ids))
# 需取反法向的单元ID
base_vs_f = [key for key in base_vs if base_vs[key]<0]
target_vs_f = [key for key in target_vs if target_vs[key]<0]

with open(tcl_path, 'w') as f: # 基础单元
    f.write("*createmark elems 1 " + ' '.join(base_ids) +'\n')

with open(tcl_path2, 'w') as f: # 目标单元
    f.write("*createmark elems 1 " + ' '.join(target_ids) +'\n')

with open(tcl_path3, 'w') as f: # 基础单元-取反单元
    f.write("*createmark elems 1 " + ' '.join(base_vs_f) +'\n')

with open(tcl_path4, 'w') as f: # 目标单元-取反单元
    f.write("*createmark elems 1 " + ' '.join(target_vs_f) +'\n')


print("1")