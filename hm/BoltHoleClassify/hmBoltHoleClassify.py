
import os.path
import math
import os


MIN_NODE_NUM = 3
file_dir  = os.path.dirname(__file__)
fem_path  = os.path.join(file_dir, '__temp.fem')
csv_path  = os.path.join(file_dir, '__temp.csv')

get_line_n = lambda line, n: line[8*n:8*(n+1)].strip()
dis_loc    = lambda loc1, loc2: ((loc1[0]-loc2[0])**2 + (loc1[1]-loc2[1])**2 + (loc1[2]-loc2[2])**2)**0.5
v_abs      = lambda loc1: (loc1[0]**2 + loc1[1]**2 + loc1[2]**2)**0.5
v_one      = lambda loc1: [loc1[0]/v_abs(loc1), loc1[1]/v_abs(loc1), loc1[2]/v_abs(loc1)]

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

        base_dis_list, target_dis_list = [], []
        for base_node_id in base_node_ids:
            dis1 = dis_loc(node2loc[base_node_id], node2loc[base_center_id])
            base_dis_list.append(dis1)
        
        for target_node_id in target_node_ids:
            dis1 = dis_loc(node2loc[target_node_id], node2loc[target_center_id])
            target_dis_list.append(dis1)

        # print(base_dis_list, target_dis_list)
        bar2_r_dic[bar2_id] = {'base':base_dis_list, 'target':target_dis_list}

    return bar2_r_dic




bar2_r_dic = main_get_bar2(fem_path, csv_path)
# print(bar2_r_dic)
r_to_bar2 = {}

for bar2_id in bar2_r_dic:
    
    base_mean = sum(bar2_r_dic[bar2_id]['base'])/len(bar2_r_dic[bar2_id]['base'])
    target_mean = sum(bar2_r_dic[bar2_id]['target'])/len(bar2_r_dic[bar2_id]['target'])
    r = min([base_mean, target_mean])
    r = int(r*2)/2
    if r not in r_to_bar2: r_to_bar2[r] = []
    r_to_bar2[r].append(bar2_id)

output_strs = []
for r in r_to_bar2:
    ids_str = ' '.join(r_to_bar2[r])
    output_strs.append('{{{} {}}}'.format(r, ids_str))

print(' '.join(output_strs))


