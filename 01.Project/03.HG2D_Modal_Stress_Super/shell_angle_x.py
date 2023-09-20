"""
    
    
"""

import os.path
import math
import sys
import os
import re


get_line_n = lambda line, n: line[8*n:8*(n+1)].strip()
dis_loc    = lambda loc1, loc2: ((loc1[0]-loc2[0])**2 + (loc1[1]-loc2[1])**2 + (loc1[2]-loc2[2])**2)**0.5
v_abs      = lambda loc1: (loc1[0]**2 + loc1[1]**2 + loc1[2]**2)**0.5
v_one      = lambda loc1: [loc1[0]/v_abs(loc1), loc1[1]/v_abs(loc1), loc1[2]/v_abs(loc1)]


RAD_2_DEG = 180/math.pi


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

# 向量 加
def v_add(loc1, loc2):
    x1, y1, z1 = loc1
    x2, y2, z2 = loc2
    return [x1+x2, y1+y2, z1+z2]

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

#
def str2float(str1):

    if '-' in str1[1:]:
        new_str1 = str1[0] + str1[1:].replace('-', 'e-')
    elif '+' in str1[1:]:
        new_str1 = str1[0] + str1[1:].replace('+', 'e+')
    else:
        new_str1 = str1

    return float(new_str1)


# 获取elem的法向量
def get_v_element(locs):

    v1 = v_sub(locs[1], locs[0])
    v2 = v_sub(locs[2], locs[1])
    return v_multi_x(v1, v2)


# 读取&解析数据
def read_data(fem_path):


    grid_dic, elem_dic = {}, {}
    f = open(fem_path, 'r')
    while True:
        line = f.readline()
        if not line :break
        if "$" == line[0]: continue
        
        if "GRID" in line[:6]:
            g_id = get_line_n(line, 1)
            x = str2float(get_line_n(line, 3))
            y = str2float(get_line_n(line, 4))
            z = str2float(get_line_n(line, 5))
            grid_dic[g_id] = [x, y, z]
            continue
        
        if "CTRIA3" in line[:6]:
            e_id = get_line_n(line, 1)
            elem_dic[e_id] = [get_line_n(line, n) for n in [3, 4, 5]]
            continue

        if "CQUAD4" in line[:6]:
            e_id = get_line_n(line, 1)
            elem_dic[e_id] = [get_line_n(line, n) for n in [3, 4, 5, 6]]
            continue

    return grid_dic, elem_dic


def calc_shell_angle(fem_path, target_elem_ids, target_vs):

    # 获取fem数据
    grid_dic, elem_dic = read_data(fem_path)

    thetas = {}
    records = {}
    for elem_id, t_v in zip(target_elem_ids,target_vs):
        
        r_ids = elem_dic[str(elem_id)]
        p0 = grid_dic[r_ids[0]]
        p1 = grid_dic[r_ids[1]]
        p2 = grid_dic[r_ids[2]]

        center = [(p0[0]+p1[0]+p2[0])/3, (p0[1]+p1[1]+p2[1])/3, (p0[2]+p1[2]+p2[2])/3]
        # print(r_ids)
        # print(p0, p1, p2)
        # 
        B_startx = v_sub(p1,p0)
        P1_velem = get_v_element([p0,p1,p2])
        # print(B_startx)
        # print(P1_velem)
        
        P2 = v_multi_x(t_v, P1_velem)
        P3 = v_multi_x(B_startx, P2)
        # print(P1_velem, B_startx, P2, t_v, P3)

        # print(angle_2vector(B_startx, P2)*RAD_2_DEG)
        if v_multi_dot(P1_velem, v_multi_x(B_startx, P2))>0:

            theta = 90 + angle_2vector(B_startx, P2)*RAD_2_DEG
        else:
            theta = -90 - angle_2vector(B_startx, P2)*RAD_2_DEG
        # print(theta)
        if theta < -90:
            theta += 180
            
        theta = -theta

        thetas[str(elem_id)] = theta/RAD_2_DEG

        # record = {
        #     'V_x'： {'0':center, '1':v_add(center,v_one(B_startx))},
        #     'V_s': {'0':center, '1':v_add(center,v_one(P1_velem))},
        #     'V_t': {'0':center, '1':v_add(center,v_one(t_v))},
        #     'theta': theta,
        # }

        record = {
            'V_x': {'0':center, '1':v_multi_c(v_one(B_startx), 5)},
            'V_s':{'0':center, '1':v_multi_c(v_one(P1_velem), 5)},
            'V_t': {'0':center, '1':v_multi_c(v_one(t_v), 10)},
            'theta': theta,
        }

        records[str(elem_id)] = record

    # 弧度输出 rad
    return thetas, records


def change_stress(xx, yy, xy, theta):
    # theta 弧度输入

    new_xx = (xx+yy)/2 + (xx-yy)/2*math.cos(2*theta) - xy*math.sin(2*theta)
    # new_xx = (xx+yy)/2 - (xx-yy)/2*math.cos(2*theta) + xy*math.sin(2*theta)

    # new_xy = (xx-yy)/2*math.sin(2*theta) + xy*math.cos(2*theta)
    # new_yy = (xx+yy)/2 - (xx-yy)/2*math.cos(2*theta) + xy*math.sin(2*theta)

    # return new_xx, new_yy, new_xy
    return new_xx


def csv_elem_vs(csv_path, isStr=False):

    """
    elem_id,vx,vy,vz
    18417139,0,0,1
    18415285,0,0,1
    2004699,0,0,1
    """

    if isStr:
        lines = [re.sub('\s','',line) for line in csv_path.split('\n')]
    else:
        with open(csv_path, 'r') as f:
            lines = [re.sub('\s','',line) for line in f.read().split('\n')]

    lines = [line for line in lines if line]

    target_elem_ids = []
    target_vs = []
    for line in lines[1:]:
        values = [value.replace(' ','') for value in line.split(',') if value]
        target_elem_ids.append(int(values[0]))
        target_vs.append([float(value) for value in values[1:4]])

    return target_elem_ids, target_vs




if __name__ == '__main__':

    import time
    
    csv_str = """
    elem_id,vx,vy,vz
    18417139,0,0,1
    18415285,0,0,1
    2004699,0,0,1
    """
    # target_elem_ids, target_vs = csv_elem_vs(csv_str, True)
    
    fem_path = 'test.fem'
    target_elem_ids, target_vs = csv_elem_vs('test02.csv')
    

    # target_elem_ids = [18417139,18415285,2004699]
    # target_vs = [[0,0,1],[0,0,1],[0,0,1]]

    thetas = calc_shell_angle(fem_path, target_elem_ids, target_vs)
    print(thetas)





    # # 获取fem数据
    # grid_dic, elem_dic = read_data(fem_path)

    # target_elem_ids = [18417139,18415285,2004699]
    # target_vs = [[0,0,1],[0,0,1],[0,0,1]]

    # for elem_id, t_v in zip(target_elem_ids,target_vs):
    #     r_ids = elem_dic[str(elem_id)]
    #     p0 = grid_dic[r_ids[0]]
    #     p1 = grid_dic[r_ids[1]]
    #     p2 = grid_dic[r_ids[2]]

    #     # 
    #     B = v_sub(p1,p0)
    #     P1 = get_v_element([p0,p1,p2])
        
    #     # 
    #     P2 = v_multi_x(P1, t_v)

    #     theta = 90 - angle_2vector(B, P2)*RAD_2_DEG

    #     print(theta)


