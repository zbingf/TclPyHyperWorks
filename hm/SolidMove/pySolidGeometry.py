import sys
import os.path

try:
    one_loc = int(sys.argv[1])
    third_loc = int(sys.argv[2])

except:
    one_loc = 0
    third_loc = 0
    pass


file_dir  = os.path.dirname(__file__)
temp_path_base = os.path.join(file_dir, '__temp_base.csv')
temp_path_target = os.path.join(file_dir, '__temp_target.csv')


list_sub = lambda list1, list2: [v1-v2 for v1, v2 in zip(list1, list2)]
dis_loc  = lambda loc: (loc[0]**2 + loc[1]**2 + loc[2]**2 )**0.5
dis_between = lambda list1, list2: dis_loc(list_sub(list1, list2))

# 读取点数据
def read_point(file_path):

    with open(file_path, 'r') as f:
        lines = [line for line in f.read().split('\n') if line]

    center_loc = []
    point_dic  = {}
    for loc, line in enumerate(lines):
        if loc==0:
            center_loc = [float(v) for v in line.split(' ') if v]
            point_dic[0] = center_loc
        else:
            point_id, *point_loc = [float(v) for v in line.split(' ') if v]
            point_id = int(point_id)
            point_dic[point_id] = point_loc

    return point_dic

# 
def dis_sorted(point_dic):
    """
        point_dic :
            key : point_id , 0值为计算目标(point点的id不为零)
            value : [x, y, z]

    """
    dis_dic = {}
    for point_id in point_dic:
        if point_id==0: continue
        p_t_c_dis = dis_loc(list_sub(point_dic[point_id], point_dic[0]))
        dis_dic[point_id] = p_t_c_dis

    sorted_ids = sorted(dis_dic, key=lambda p_id: dis_dic[p_id], reverse=True)
    sorted_diss = [dis_dic[p_id] for p_id in sorted_ids]

    return sorted_ids, sorted_diss

# 垂点
def vertical_point(line_p1_loc, line_p2_loc, p3_loc):
    """
        line_p1_loc 直线上的点 1
        line_p2_loc 直线上的点 2
        目标点p3_loc
    """
    x1, y1, z1 = line_p1_loc
    x2, y2, z2 = line_p2_loc
    x0, y0, z0 = p3_loc

    k = -((x1-x0)*(x2-x1)+(y1-y0)*(y2-y1)+(z1-z0)*(z2-z1))/((x2-x1)**2+(y2-y1)**2+(z2-z1)**2)

    xn = k*(x2-x1) + x1
    yn = k*(y2-y1) + y1
    zn = k*(z2-z1) + z1
    return [xn, yn, zn]

# 第三点排序
def third_sorted(point_dic, max_dis_id):

    center_loc = point_dic[0]
    max_dis_id = point_dic[max_dis_id]
    third_point_dic = {}
    vertical_point_dic = {}
    for p_id in point_dic:
        if p_id==0: continue
        if p_id==max_dis_id: continue

        cur_loc = point_dic[p_id]
        v_loc   = vertical_point(center_loc, max_dis_id, cur_loc)
        cur_dic = dis_between(v_loc, cur_loc)
        third_point_dic[p_id] = cur_dic
        vertical_point_dic[p_id] = v_loc

    third_sorted_ids  = sorted(third_point_dic, key=lambda p_id: third_point_dic[p_id], reverse=True)
    third_sorted_diss = [third_point_dic[p_id] for p_id in third_sorted_ids]

    return third_sorted_ids, third_sorted_diss, vertical_point_dic



base_dic = read_point(temp_path_base)
target_dic = read_point(temp_path_target)

base_sorted_ids, base_sorted_diss = dis_sorted(base_dic)
target_sorted_ids, target_sorted_diss = dis_sorted(target_dic)



base_max_dis_id = base_sorted_ids[0]
target_max_dis_id = target_sorted_ids[one_loc]

base_third_sorted_ids, base_third_sorted_diss, base_vertical_point_dic = third_sorted(base_dic, base_max_dis_id) 
target_third_sorted_ids, target_third_sorted_diss, target_vertical_point_dic = third_sorted(target_dic, target_max_dis_id) 


base_third_dis_id = base_third_sorted_ids[0]
target_third_dis_id = target_third_sorted_ids[third_loc]

# base_v_loc_str = '{' + ' '.join([str(n) for n in base_vertical_point_dic[base_third_dis_id]]) + '}'
# target_v_loc_str = '{' + ' '.join([str(n) for n in target_vertical_point_dic[target_third_dis_id]]) + '}'



# print(f'{base_max_dis_id} {target_max_dis_id} {base_third_dis_id} {target_third_dis_id} {base_v_loc_str} {target_v_loc_str}')
# print( vertical_point([0, 0, 0], [10, 10, 10], [5, 5, 0]) )

print(f'{base_max_dis_id} {target_max_dis_id} {base_third_dis_id} {target_third_dis_id}')





