"""
    用于Tie接触创建计算
    1 确认接触单元的id
    2 确认接触单元需调整方向的id
"""

import os.path
import math
import sys
import os

try:
    dis_limit = int(sys.argv[1])
except:
    dis_limit = 10


file_dir  = os.path.dirname(__file__)
loc_path = os.path.join(file_dir, '__temp_loc.txt')
fem_path_base  = os.path.join(file_dir, '__temp_base.fem')
fem_path_target  = os.path.join(file_dir, '__temp_target.fem')

get_line_n = lambda line, n: line[8*n:8*(n+1)].strip()

#
def str2float(str1):

    if '-' in str1[1:]:
        new_str1 = str1[0] + str1[1:].replace('-', 'e-')
    elif '+' in str1[1:]:
        new_str1 = str1[0] + str1[1:].replace('+', 'e+')
    else:
        new_str1 = str1

    return float(new_str1)



# 读取&解析数据
def read_fem_path(fem_path):

    grid_dic = {}
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
        
    return grid_dic


def read_loc_path(temp_path):

    with open(temp_path, 'r') as f:
        lines = [line for line in f.read().split('\n') if line]

    base_locs = []
    for line in lines:
        loc = [float(v) for v in line.split(' ') if v]
        base_locs.append(loc)

    return base_locs


# 区域扩展
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


def area_loc(locs):
    gain = 1

    areas = []
    for loc in locs:
        x = round(loc[0]/dis_limit*gain)
        y = round(loc[1]/dis_limit*gain)
        z = round(loc[2]/dis_limit*gain)
        key = (x, y, z)
        areas.append(key)

    return areas


# 单元中心坐标计算及区域划分
def area_grid_loc(grid_dic):
    # 中心坐标计算

    elem_center_dic = {}
    area_2_elem_t = {}
    area_2_elem_b = {}
    elem_2_area = {}
    gain = 1

    area_2_grid = {}
    grid_2_area = {}

    for grid_id in grid_dic:
        loc = grid_dic[grid_id]
        x = round(loc[0]/dis_limit*gain)
        y = round(loc[1]/dis_limit*gain)
        z = round(loc[2]/dis_limit*gain)
        key = (x, y, z)
        if key not in area_2_grid:
            area_2_grid[key] = [grid_id]
        else:
            area_2_grid[key].append(grid_id)   

        grid_2_area[grid_id] = key


    return area_2_grid, grid_2_area


fun_loc_dis = lambda loc1, loc2 : sum([(v1-v2)**2 for v1, v2 in zip(loc1, loc2)])**0.5
fun_loc_dis_list = lambda loc1, locs : [fun_loc_dis(loc1, loc2) for loc2 in locs]


if __name__ == '__main__':

    # import time
    
    base_locs = read_loc_path(loc_path)
    grid_dic_base = read_fem_path(fem_path_base)
    grid_dic_target = read_fem_path(fem_path_target)
    
    area_2_grid_b, grid_2_area_b = area_grid_loc(grid_dic_base)
    area_2_grid_t, grid_2_area_t = area_grid_loc(grid_dic_target)

    
    result_strs = []
    loc_areas = area_loc(base_locs)
    for area, loc in zip(loc_areas, base_locs):
        ex_areas = area_xyz(*area)
        grid_ids_b, grid_ids_t = [], []
        for temp_area in ex_areas:
            if temp_area in area_2_grid_b: grid_ids_b.extend(area_2_grid_b[temp_area])
            if temp_area in area_2_grid_t: grid_ids_t.extend(area_2_grid_t[temp_area])

        grid_2_dis_b = {grid_id : fun_loc_dis(loc, grid_dic_base[grid_id]) for grid_id in grid_ids_b}
        grid_2_dis_t = {grid_id : fun_loc_dis(loc, grid_dic_target[grid_id]) for grid_id in grid_ids_t}
        for grid_id in grid_2_dis_t:
            if grid_id in grid_2_dis_b:
                del grid_2_dis_t[grid_id]

        grid_id_b = sorted(grid_2_dis_b, key=lambda x: grid_2_dis_b[x])[0]
        grid_id_t = sorted(grid_2_dis_t, key=lambda x: grid_2_dis_t[x])[0]
        if grid_id_b == grid_id_t:
            raise "error grid_id_b == grid_id_t"
        result_strs.append("*rigid {} {} 123456".format(grid_id_b, grid_id_t))

    print('\n'.join(result_strs))
