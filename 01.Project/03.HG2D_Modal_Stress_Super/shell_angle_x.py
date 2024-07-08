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
v_round    = lambda loc1, num: [round(n, num) for n in loc1]



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
    # 向量夹角余弦值
    value = a_dot_b / (base_abs*target_abs)
    if value > 1: value = 1
    if value < -1: value = -1

    # 大于0, 锐角
    # 小于0, 钝角
    angle_rad = math.acos(value)

    if angle_rad < 0:
        angle_rad = math.pi + angle_rad

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
    thetas_deg = {}
    records = {}
    for elem_id, t_v in zip(target_elem_ids,target_vs):
        # t_v 贴片方向
        r_ids = elem_dic[str(elem_id)]
        p0 = grid_dic[r_ids[0]]
        p1 = grid_dic[r_ids[1]]
        p2 = grid_dic[r_ids[2]]

        # 单元前三点中心
        center = [(p0[0]+p1[0]+p2[0])/3, (p0[1]+p1[1]+p2[1])/3, (p0[2]+p1[2]+p2[2])/3]

        # print(r_ids)
        # print(p0, p1, p2)
        # 

        # XX 方向的向量
        B_startx = v_sub(p1,p0)

        # elem的法向量
        P1_velem = get_v_element([p0,p1,p2])
        # print(B_startx)
        # print(P1_velem)
        
        # center = v_round(center, 4)
        # B_startx = v_round(B_startx, 4)
        # t_v = v_round(t_v, 4)

        # 贴片方向与单元法向的 叉乘得到垂直向量
        P2 = v_multi_x(t_v, P1_velem)
        

        P3 = v_multi_x(B_startx, P2)
        # print(P1_velem, B_startx, P2, t_v, P3)
        # print('angle_2vector:====')
        # print(angle_2vector(B_startx, P2)*RAD_2_DEG)
        # print('angle_2vector:====')
        if v_multi_dot(P1_velem, v_multi_x(B_startx, P2))>0:
            # 法向通向, t_x监测方向与B_startx 夹角介于 [-90,90]之间
            if angle_2vector(B_startx, P2)*RAD_2_DEG >= 90:
                # 
                theta = angle_2vector(B_startx, P2)*RAD_2_DEG - 90
            else:
                # 监测位置夹角位于[-90,0]区间, 反向为钝角
                theta = angle_2vector(B_startx, P2)*RAD_2_DEG + 90
        else:
            # 法向反向, t_x监测方向与B_startx 夹角介于 [90,270]之间
            if angle_2vector(B_startx, P2)*RAD_2_DEG >= 90:
                # [90,180]
                theta = (180 - angle_2vector(B_startx, P2)*RAD_2_DEG) + 90 
            else:
                # [180,270]
                theta = 90 - angle_2vector(B_startx, P2)*RAD_2_DEG

        # print(theta)
        # if theta < -90:
        #     theta += 180
            
        # theta = -theta
        theta = 0
        thetas[str(elem_id)] = theta/RAD_2_DEG
        thetas_deg[str(elem_id)] = theta


        V_t_new = v_rotate_point(P1_velem, B_startx, theta/RAD_2_DEG)
        
        # record = {
        #     'V_x'： {'0':center, '1':v_add(center,v_one(B_startx))},
        #     'V_s': {'0':center, '1':v_add(center,v_one(P1_velem))},
        #     'V_t': {'0':center, '1':v_add(center,v_one(t_v))},
        #     'theta': theta,
        # }

        record = {
            'V_x': {'0':center, '1':v_multi_c(v_one(B_startx), 5)},
            'V_s':{'0':center, '1':v_multi_c(v_one(P1_velem), 6)},
            'V_t': {'0':center, '1':v_multi_c(v_one(t_v), 10)},
            'V_t_new': {'0':center, '1':v_multi_c(v_one(V_t_new), 8)},
            'theta': theta,
        }

        records[str(elem_id)] = record

    # 弧度输出 rad
    return thetas, thetas_deg, records



# 点-绕轴旋转
def v_rotate_point(vector, point_loc, rad):
    vector_one = v_one(vector)
    P_cos = v_multi_c(point_loc, math.cos(rad))
    A_x_P_sin = v_multi_c(v_multi_x(vector_one, point_loc), math.sin(rad))
    A_dot_P = v_multi_dot(vector_one, point_loc)
    A_A_dot_P_theta = v_multi_c(vector_one, A_dot_P*(1-math.cos(rad)))
    new_loc = v_add(v_add(P_cos, A_x_P_sin), A_A_dot_P_theta)

    return new_loc


def change_strain(xx, yy, xy, theta, E, v):
    # 弹性模量 E Mpa
    # 泊松比 v
    # theta rad

    ex = (1-v**2)/E * (xx - v/(1-v)*yy)
    ey = (1-v**2)/E * (yy - v/(1-v)*xx)
    txy = 2*(1+v)/E * xy
    e_theta = (ex+ey)/2 + (ex-ey)*math.cos(2*theta)/2 + txy*math.sin(2*theta)/2
    # e_45 = (ex + ey + txy)/2
    # txy = 
    
    # e_theta = (ex+ey)/2 + (ex-ey)*math.cos(2*theta)/2 + txy*math.sin(2*theta)
    # e_theta = ex*math.cos(theta)**2 + 2*txy*math.cos(theta)*math.sin(theta)+ey*math.sin(theta)**2


    return e_theta*1e6


def change_stress(xx, yy, xy, theta):
    # theta 弧度输入
    
    # new_xx = (xx+yy)/2 + (xx-yy)/2*math.cos(2*theta) - xy*math.sin(2*theta)
    new_xx = (xx+yy)/2 + (xx-yy)/2*math.cos(2*theta) + xy*math.sin(2*theta)

    
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
    target_vs = [] # 贴片方向
    for line in lines[1:]:
        values = [value.replace(' ','') for value in line.split(',') if value]
        target_elem_ids.append(int(values[0]))
        target_vs.append([float(value) for value in values[1:4]])


    return target_elem_ids, target_vs




if __name__ == '__main__':

    center = [1,1,3]
    P1_velem = [0,0,1]
    B_startx = [1,0,0]
    theta = 90
    V_t_new = v_sub(v_rotate_point(v_add(P1_velem, center), v_add(B_startx, center), theta/RAD_2_DEG), center)
    print(V_t_new)
    V_t_new = v_sub(v_rotate_point(P1_velem, v_add(B_startx, center), theta/RAD_2_DEG), center)
    print(V_t_new)
    V_t_new = v_rotate_point(P1_velem, B_startx, theta/RAD_2_DEG)
    print(V_t_new)


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


