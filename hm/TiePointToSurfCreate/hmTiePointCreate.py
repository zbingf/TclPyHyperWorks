import sys
import os.path
import re
import math

try:
    c_limit = float(sys.argv[1])
    dis_limit = float(sys.argv[2])
    deg_limit = float(sys.argv[3])
except:
    c_limit = 40
    dis_limit = 20
    deg_limit = 45

node_num_limit = 3
file_dir  = os.path.dirname(__file__)
fem_path = os.path.join(file_dir, '__temp.fem')
csv_path = os.path.join(file_dir, '__temp.csv')
tcl_path  = os.path.join(file_dir, '__temp.tcl')
tcl_path2 = os.path.join(file_dir, '__temp2.tcl')
tcl_path3 = os.path.join(file_dir, '__temp3.tcl')

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
        new_str1 = str1[0] + str1[1:].replace('-','e-')
    elif '+' in str1[1:]:
        new_str1 = str1[0] + str1[1:].replace('-','e+')
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


def file_read(fem_path, csv_path):
    
    # =======================
    with open(csv_path, 'r') as f:
        line = [line for line in f.read().split('\n')][0]

    elem_surf_ids = [v for v in line.split(' ') if v]

    # =======================
    with open(fem_path, 'r') as f:
        lines = [line for line in f.read().split('\n') if line]

    elem2node_plotel = {}
    node2elem_plotel = {}
    grid_dic, elem_dic = {}, {}
    elem_ids_plotel = []
    for line in lines:
        if 'GRID' == line[:4]:
            grid_id = get_line_n(line,1)
            x = str2float(get_line_n(line,3))
            y = str2float(get_line_n(line,4))
            z = str2float(get_line_n(line,5))
            grid_dic[grid_id] = [x, y, z]

        if 'PLOTEL' == line[:6]:
            elem_id  = get_line_n(line,1)
            node_id1 = get_line_n(line,2)
            node_id2 = get_line_n(line,3)
            elem2node_plotel[elem_id] = [node_id1, node_id2]
            if node_id1 not in node2elem_plotel: node2elem_plotel[node_id1] = []
            if node_id2 not in node2elem_plotel: node2elem_plotel[node_id2] = []
            node2elem_plotel[node_id1].append(elem_id)
            node2elem_plotel[node_id2].append(elem_id)
            elem_ids_plotel.append(elem_id)

        if "CTRIA3" == line[:6]:
            e_id = get_line_n(line, 1)
            elem_dic[e_id] = [get_line_n(line, n) for n in [3, 4, 5]]
            continue

        if "CQUAD4" == line[:6]:
            e_id = get_line_n(line, 1)
            elem_dic[e_id] = [get_line_n(line, n) for n in [3, 4, 5, 6]]

    elem_surf_ids = set(elem_surf_ids) & set(elem_dic.keys())
    elem_surf_dic = {}
    for e_id in elem_surf_ids:
        elem_surf_dic[e_id] = elem_dic[e_id]
    # print(elem_surf_ids)
    

    return elem_surf_dic, grid_dic, elem2node_plotel, node2elem_plotel, elem_ids_plotel


def elem_search(elem_id, elem2node_plotel, node2elem_plotel, elem_circles=None, node_circles=None):
    if elem_circles == None: elem_circles = []
    if node_circles == None: node_circles = []
    node_ids = elem2node_plotel[elem_id]
    if elem_id in elem_circles:  return node_circles, elem_circles
    elem_circles.append(elem_id)
    # 已计算
    for node_id in node_ids:
        if node_id not in node_circles: node_circles.append(node_id)
        elem_ids_plotel = node2elem_plotel[node_id]
        for elem_id in elem_ids_plotel:
            if elem_id in elem_circles: continue
            elem_search(elem_id, elem2node_plotel, node2elem_plotel, elem_circles, node_circles)

    return node_circles, elem_circles


def circle_node_id_search(grid_dic, elem2node_plotel, node2elem_plotel, elem_ids_plotel):
    node_calceds, elem_calceds = [], []

    n_circle = -1
    node_circle_dic = {}
    elem_circle_dic = {}

    for elem_id in elem_ids_plotel:
        if elem_id in elem_calceds: 
            continue
        else:
            n_circle += 1
        node_circles, elem_circles = elem_search(elem_id, elem2node_plotel, node2elem_plotel)
        node_calceds.extend(node_circles)
        elem_calceds.extend(elem_circles)

        elem_circle_dic[n_circle] = elem_circles
        node_circle_dic[n_circle] = node_circles

    target_node_ids = []
    for n_circle in elem_circle_dic:
        circle_dis = 0
        n_len = len(elem_circle_dic[n_circle])
        if n_len <= node_num_limit : continue
        for elem_id in elem_circle_dic[n_circle]: # 圆周估算
            node_id1, node_id2 = elem2node_plotel[elem_id]
            x1, y1, z1 = grid_dic[node_id1]
            x2, y2 ,z2 = grid_dic[node_id2]
            elem_dis = ((x1-x2)**2+(y1-y2)**2+(z1-z2)**2)**0.5
            circle_dis += elem_dis

        if circle_dis < c_limit:  # 匹配
            target_node_ids.extend(node_circle_dic[n_circle])

    target_node_ids = list(set(target_node_ids))
    return target_node_ids


def center_cal(elem_surf_dic, grid_dic, target_node_ids):
    # 中心坐标计算

    elem_center_dic = {}
    area_2_elem_surf = {}
    # elem_2_area_surf = {}
    area_2_node = {}
    node_2_area = {}
    gain = 1
    # print(elem_surf_dic)
    for elem_id in elem_surf_dic:
        locs = [grid_dic[node_id] for node_id in elem_surf_dic[elem_id]]
        center_loc = get_nodes_center(locs)
        elem_center_dic[elem_id] = center_loc
        x = round(center_loc[0]/dis_limit*gain)
        y = round(center_loc[1]/dis_limit*gain)
        z = round(center_loc[2]/dis_limit*gain)
        key = (x, y, z)
        if key not in area_2_elem_surf:
            area_2_elem_surf[key] = [elem_id]
        else:
            area_2_elem_surf[key].append(elem_id)     
        # elem_2_area_surf[elem_id] = key

    for node_id in target_node_ids:
        x = round(grid_dic[node_id][0]/dis_limit*gain)
        y = round(grid_dic[node_id][1]/dis_limit*gain)
        z = round(grid_dic[node_id][2]/dis_limit*gain)
        key = (x, y, z)
        if key not in area_2_node:
            area_2_node[key] = [node_id]
        else:
            area_2_node[key].append(node_id)
        node_2_area[node_id] = key


    return elem_center_dic, area_2_elem_surf, area_2_node, node_2_area


def area_xyz(x, y, z):
    xs = [x+1, x, x-1]
    ys = [y+1, y, y-1]
    zs = [z+1, z, z-1]
    areas = []
    for x in xs:
        for y in ys:
            for z in zs:
                areas.append((x, y, z))

    return areas


def data_cal(target_node_ids, grid_dic, elem_surf_dic, elem_center_dic, area_2_elem_surf, node_2_area, run_n):
    node_ids = []
    elem_ids = []
    elem_vs  = {}
    cal_n = 0
    area_2_elem_surf_key_sets = set(area_2_elem_surf.keys())
    for node_id in target_node_ids:
        areas = set(area_xyz(*node_2_area[node_id])) & area_2_elem_surf_key_sets

        for area in areas:
            for elem_id in area_2_elem_surf[area]:
                dis_center = dis_loc(elem_center_dic[elem_id], grid_dic[node_id])
                cal_n += 1
                if dis_center < dis_limit:
                    # 距离小于目标值
                    locs_2 = [grid_dic[n] for n in elem_surf_dic[elem_id]]
                    v_b = v_one(v_sub(grid_dic[node_id], elem_center_dic[elem_id]))
                    v_t = v_one(get_v_element(locs_2))

                    # 点到单元的矢量  与 单元法向 夹角计算
                    angle_elem2point = angle_2vector(v_b, v_t) * 180 / math.pi
                    
                    if angle_elem2point <= 180-deg_limit and angle_elem2point >= deg_limit: continue

                    if angle_elem2point > 90:
                        elem_vs[elem_id] = 1
                    else: # 需取反
                        elem_vs[elem_id] = -1

                    elem_ids.append(elem_id)
                    node_ids.append(node_id)
                    continue

    print(len(target_node_ids), len(elem_surf_dic), "cal_n:", cal_n)
    # print(len(base_ids), len(target_ids))
    # 去重

    elem_ids = list(set(elem_ids))
    node_ids = list(set(node_ids))
    # 需取反法向的单元ID
    elem_vs_f = [key for key in elem_vs if elem_vs[key]<0]

    file_path = os.path.join(file_dir, "__temp_run_{}.txt".format(run_n))
    with open(file_path, 'w') as f:
        f.write(','.join(node_ids)+'\n')
        f.write(','.join(elem_ids)+'\n')
        f.write(','.join(elem_vs_f)+'\n')

def read_result(num):

    node_ids, elem_ids, elem_vs_f = [], [], []

    for n in range(num):
        file_path = os.path.join(file_dir, "__temp_run_{}.txt".format(n))
        with open(file_path, 'r') as f:
            lines = [line for line in f.read().split('\n')][:3]

        node_ids_n, elem_ids_n, elem_vs_f_n = [[v for v in line.split(',')] for line in lines]
        node_ids += node_ids_n
        elem_ids += elem_ids_n
        elem_vs_f += elem_vs_f_n

        os.remove(file_path)

    node_ids = list(set(node_ids))
    elem_ids = list(set(elem_ids))
    elem_vs_f = list(set(elem_vs_f))

    return node_ids, elem_ids, elem_vs_f


if __name__ == '__main__':

    import multiprocessing
    import time
    t_start = time.time()
    elem_surf_dic, grid_dic, elem2node_plotel, node2elem_plotel, elem_ids_plotel = file_read(fem_path, csv_path)
    # print('time:', time.time()-t_start)
    target_node_ids = circle_node_id_search(grid_dic, elem2node_plotel, node2elem_plotel, elem_ids_plotel)
    # print('time:', time.time()-t_start)
    elem_center_dic, area_2_elem_surf, area_2_node, node_2_area = center_cal(elem_surf_dic, grid_dic, target_node_ids)
    # print('time:', time.time()-t_start)
    # asdf
    if len(target_node_ids)>1000 or len(elem_surf_dic)>6000:
        num_mp = 6
    else:
        num_mp = 1

    po = multiprocessing.Pool(num_mp)
    t_len = math.ceil(len(target_node_ids)/num_mp)
    for n in range(num_mp):
        if n < num_mp-1:
            bs = target_node_ids[t_len*n:t_len*(n+1)]
        else:
            bs = target_node_ids[t_len*n:]

        po.apply_async(data_cal, (bs, grid_dic, elem_surf_dic, elem_center_dic, area_2_elem_surf, node_2_area, n))

    po.close()
    po.join()
    node_ids, elem_ids, elem_vs_f = read_result(num_mp)

    with open(tcl_path, 'w') as f: # 基础单元
        f.write("*createmark nodes 1 " + ' '.join(node_ids) +'\n')

    with open(tcl_path2, 'w') as f: # 目标单元
        f.write("*createmark elems 1 " + ' '.join(elem_ids) +'\n')

    with open(tcl_path3, 'w') as f: # 取反单元
        f.write("*createmark elems 1 " + ' '.join(elem_vs_f) +'\n')

    print("1")

