# 

import os.path
import math
import sys
import os
# 递归次数
sys.setrecursionlimit(10000)

try:
    input_node_ids = [n for n in sys.argv[1].split(' ') if n]
except:
    # input_node_ids = [str(n) for n in [7374,7375,7422,7427,8169,8170,8217,8222]]
    raise 'error input'


MIN_NODE_NUM = 3
file_dir  = os.path.dirname(__file__)
fem_path  = os.path.join(file_dir, '__temp.fem')

get_line_n = lambda line, n: line[8*n:8*(n+1)].strip()
dis_loc    = lambda loc1, loc2: ((loc1[0]-loc2[0])**2 + (loc1[1]-loc2[1])**2 + (loc1[2]-loc2[2])**2)**0.5


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

    elem2node, node2elem, node2loc = {}, {}, {}
    node_ids, elem_ids = [], []

    f = open(fem_path, 'r')
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
            continue
        
        if "PLOTEL" == line[:6]:
            elem_id = get_line_n(line, 1)
            node_id1 = get_line_n(line, 2)
            node_id2 = get_line_n(line, 3)
            elem2node[elem_id] = [node_id1, node_id2]
            if node_id1 not in node2elem: node2elem[node_id1] = []
            if node_id2 not in node2elem: node2elem[node_id2] = []
            node2elem[node_id1].append(elem_id)
            node2elem[node_id2].append(elem_id)
            node_ids.append(node_id1)
            node_ids.append(node_id2)
            elem_ids.append(elem_id)
            continue

    f.close()

    return elem2node, node2elem, node2loc, node_ids, elem_ids

# 闭环2点单元检索
def elem_search(elem_id, elem2node, node2elem, elem_cirlces=None, node_circles=None):

    if elem_cirlces == None: elem_cirlces = []
    if node_circles == None: node_circles = []
    node_ids = elem2node[elem_id]
    elem_cirlces.append(elem_id)

    for node_id in node_ids:
        if node_id not in node_circles: node_circles.append(node_id)
        elem_ids = node2elem[node_id]
        for elem_id in elem_ids:
            if elem_id in elem_cirlces: continue
            elem_search(elem_id, elem2node, node2elem, elem_cirlces, node_circles)

    return node_circles, elem_cirlces

elem2node, node2elem, node2loc, node_ids, elem_ids = read_data(fem_path)

node_calceds, elem_calceds = [], []
num_cirlce = -1
node_circle_dic, elem_circle_dic = {}, {}

for elem_id in elem_ids:
    if elem_id in elem_calceds:
        continue
    else:
        num_cirlce += 1

    node_circles, elem_cirlces = elem_search(elem_id, elem2node, node2elem)
    node_calceds.extend(node_calceds)
    elem_calceds.extend(elem_cirlces)

    node_circle_dic[num_cirlce] = node_circles
    elem_circle_dic[num_cirlce] = elem_cirlces



target_circle_nums = []
for num_cirlce in elem_circle_dic:
    circle_c = 0
    n_len = len(elem_circle_dic[num_cirlce])
    if n_len <= MIN_NODE_NUM: continue
    for elem_id in elem_circle_dic[num_cirlce]:
        node_id1, node_id2 = elem2node[elem_id]
        circle_c += dis_loc(node2loc[node_id1], node2loc[node_id2])

    for input_node_id in input_node_ids:
        if input_node_id in node_circle_dic[num_cirlce]:
            target_circle_nums.append(num_cirlce)

target_circle_nums = list(set(target_circle_nums))
# print(target_circle_nums)

lines = []
for circle_num in target_circle_nums:
    line = "{" + ' '.join(node_circle_dic[circle_num]) + "}"
    lines.append(line)

print(' '.join(lines))



# target_node_ids = []
# for circle_num in target_circle_nums:
#     one_node_id = elem2node[elem_circle_dic[circle_num][0]][0]
#     target_node_ids.append(one_node_id)

# print(' '.join(target_node_ids))



