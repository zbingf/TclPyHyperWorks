
import os.path
import math
import sys
import os


file_dir  = os.path.dirname(__file__)
fem_path  = os.path.join(file_dir, '__temp.fem')


# # file_dir  = os.path.dirname(__file__)
# fem_path  = "D:/test.fem"


get_line_n = lambda line, n: line[8*n:8*(n+1)].strip()


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

    node2loc = {}
    rbe2_indenode2elem, rbe2_elem2indenode = {}, {}
    rbe2_elem2denode = {}
    rbe2_denode2elem = {}


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

        if "RBE2" == line[:4]:
            e_id = get_line_n(line, 1)
            n_len = math.floor(len(line)/8)
            inde_id = get_line_n(line, 2)
            if inde_id not in rbe2_indenode2elem:
                rbe2_indenode2elem[inde_id] = [e_id]
            else:
                rbe2_indenode2elem[inde_id].append(e_id)

            rbe2_elem2indenode[e_id]    = inde_id
            de_ids = [get_line_n(line, 4)]
            rbe2_elem2denode[e_id]      = de_ids
            for de_id in de_ids:
                if de_id not in rbe2_denode2elem:
                    rbe2_denode2elem[de_id] = [e_id]
                else:
                    rbe2_denode2elem[de_id].append(e_id)

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

    return node2loc, rbe2_indenode2elem, rbe2_elem2indenode, rbe2_elem2denode, rbe2_denode2elem





node2loc, rbe2_indenode2elem, rbe2_elem2indenode, rbe2_elem2denode, rbe2_denode2elem = read_data(fem_path)

# print(node2loc)
# print(rbe2_indenode2elem)
# print(rbe2_elem2indenode)
# print(rbe2_elem2denode)
# print(rbe2_denode2elem)

# --------------------------------
target_e_id = []
# for inde_id in rbe2_indenode2elem:
#     if len(rbe2_indenode2elem[inde_id]) > 1 :
#         target_e_id.append(rbe2_indenode2elem[inde_id][0])
# print(target_e_id)


# --------------------------------
is_exist = False
for de_id in rbe2_denode2elem:
    e_ids = rbe2_denode2elem[de_id]
    if len(e_ids) > 1 :
        # print(e_ids)
        for e_id in e_ids:
            if e_id in target_e_id:
                is_exist = True
                break
            else:
                is_exist = False
        if not is_exist:
            target_e_id.append(rbe2_denode2elem[de_id][0])
            is_exist = False

target_e_id = list(set(target_e_id))

# print(target_e_id)


# --------------------------------
print(' '.join(target_e_id))

