"""
    fatigue_result 结果数据处理
    
    目标版本：2021.1
    

"""
import tkinter
import tkinter.filedialog
import re
import os
import pysnooper
import sys
import logging

file_dir = os.path.dirname(__file__)
log_path = os.path.join(file_dir, 'fatigue_result.log')
with open(log_path, 'w') as f: pass
logging.basicConfig(level=logging.INFO, filename=log_path)  # 设置日志级别
logger = logging.getLogger('fatigue_result')

tkinter.Tk().withdraw()

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
def read_data(fem_path):

    node2locs, elem2nodes = {}, {}
    node2elems = {}
    comp2elems, elem2comp = {}, {}

    f = open(fem_path, 'r')

    last_comp = None
    comp_start = False
    pattern = re.compile('^\$HMCOMP\s*ID\s*(\d+).*')
    while True:
        line = f.readline()
        if not line :break

        # ---------------
        re_obj = re.match(pattern, line)

        if comp_start:
            if "$" in line: # comp结束
                comp_start = False
                comp2elems[comp_id] = elem_ids

            elif '+' in line:
                pass

            else:
                elem_id = get_line_n(line, 1)
                elem_ids.append(elem_id)
                elem2comp[elem_id] = comp_id
                # if '109080' == elem_id:
                #     logger.info('--------elem_id : {}'.format(elem_id))

        if re_obj:
            comp_id = re_obj.group(1)
            comp_start = True
            elem_ids = []
            continue

        # ---------------
        if "$" == line[0]: continue
        cline = line.strip()
        if "GRID" in cline[:4]:
            g_id = get_line_n(line, 1)
            x = str2float(get_line_n(line, 3))
            y = str2float(get_line_n(line, 4))
            z = str2float(get_line_n(line, 5))
            node2locs[g_id] = [x, y, z]
            continue
        
        if "CTRIA3" in cline[:6]:
            e_id = get_line_n(line, 1)
            elem2nodes[e_id] = [get_line_n(line, n) for n in [3, 4, 5]]

            continue

        if "CQUAD4" in cline[:6]:
            e_id = get_line_n(line, 1)
            elem2nodes[e_id] = [get_line_n(line, n) for n in [3, 4, 5, 6]]
            continue

        # if "SET" in cline[:4]:
        #     set_id = get_line_n(line, 1)
        #     set_type = get_line_n(line, 2)
        #     is_set = 
        #     int(len(line)/8)

    for elem_id in elem2nodes:
        node_ids = elem2nodes[elem_id]
        for node_id in node_ids:
            if node_id not in node2elems: node2elems[node_id] = []
            node2elems[node_id].append(elem_id)

    data = {
        'node2locs': node2locs,
        'elem2nodes': elem2nodes,
        'comp2elems': comp2elems,
        'elem2comp': elem2comp,
        'node2elems': node2elems,
    }

    return data

# 划分单元点
def split_node_to_area(node2locs, dis_limit, gain=1):
    # 中心坐标计算

    area2nodes = {}
    node2area = {}

    for node_id in node2locs:
        loc = node2locs[node_id]
        
        x = round(loc[0]/dis_limit*gain)
        y = round(loc[1]/dis_limit*gain)
        z = round(loc[2]/dis_limit*gain)
        area = (x, y, z)

        if area not in area2nodes: area2nodes[area] = []
        area2nodes[area].append(node_id)            
        node2area[node_id] = area

    return area2nodes, node2area


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


class FemFile:

    def __init__(self, fem_path):
        self.fem_path = fem_path

        self.node2locs = None
        self.area2nodes = None
        self.node2elems = None
        self.elem2comp = None

    def read_fem(self):
        """
            fem文件数据读取
            1、 node2locs 根据node_id找坐标
            2、 area2nodes 根据区域找对应的node_ids, 区域由三个数值确定（X,Y,Z）
            3、 node2elems 根据node_id找关联elem_id
            4、 elem2comp 根据elem_id 获取对应comp_id

        """
        data = read_data(self.fem_path)
        self.node2locs = data['node2locs']
        self.elem2nodes = data['elem2nodes']
        self.comp2elems = data['comp2elems']
        self.elem2comp = data['elem2comp']
        self.node2elems = data['node2elems']

    def split_node_to_area(self, dis_limit):
        node2locs = self.node2locs
        
        area2nodes, node2area = split_node_to_area(node2locs, dis_limit)

        self.area2nodes = area2nodes
        self.node2area = node2area

    def search_elem_by_nodes(self, node_ids):
        """
            fem 根据node_id、目标区域找目标单元
        """
        node2elems = self.node2elems 
        elems = []
        for node_id in node_ids:
            if node_id in node2elems:
                elems.extend(node2elems[node_id])

        return list(set(elems))

    def search_node_by_areas(self, areas):
        """
            根据区域找对应nodes
        """
        area2nodes = self.area2nodes

        # 区域扩展
        cal_areas = []
        for area in areas: 
            cal_areas.extend(area_xyz(*area))

        cal_areas = set(cal_areas)
        nodes = []
        for area in cal_areas:
            if area in area2nodes:
                nodes.extend(area2nodes[area])

        return list(set(nodes))

    def search_area_by_nodes(self, node_ids):

        node2area = self.node2area
        areas = []
        for node_id in node_ids:
            areas.append(node2area[node_id])

        return list(set(areas))

    def search_comp_by_elems(self, elem_ids):

        elem2comp = self.elem2comp

        comp2elems = {}
        for elem_id in elem_ids:
            if elem_id not in elem2comp: 
                logger.info('elem_id not in elem2comp: {}'.format(elem_id))
                continue
            comp_id = elem2comp[elem_id]
            if comp_id not in comp2elems: comp2elems[comp_id] = []
            comp2elems[comp_id].append(elem_id)

        return comp2elems

    def search_node_by_elems(self, elem_ids):

        elem2nodes = self.elem2nodes
        nodes = []
        for elem_id in elem_ids:
            nodes.extend(elem2nodes[elem_id])
        return list(set(nodes))


def calc_comp2elems_by_node(fem_path, dis_limit, node_ids):
    fem_obj = FemFile(fem_path)
    fem_obj.read_fem()
    fem_obj.split_node_to_area(dis_limit)
    # print(fem_obj.comp2elems.keys())

    target_areas = fem_obj.search_area_by_nodes(node_ids)
    # print(target_areas)
    target_nodes = fem_obj.search_node_by_areas(target_areas)
    # print(target_nodes)
    target_elems = fem_obj.search_elem_by_nodes(target_nodes)
    # print(target_elems)
    target_comp2elems = fem_obj.search_comp_by_elems(target_elems)

    return target_comp2elems

def calc_comp2elems_by_elem(fem_path, dis_limit, elem_ids):
    fem_obj = FemFile(fem_path)
    fem_obj.read_fem()
    fem_obj.split_node_to_area(dis_limit)
    # print(fem_obj.comp2elems.keys())

    node_ids = fem_obj.search_node_by_elems(elem_ids)
    logger.info('intput node ids: {}'.format(node_ids))

    target_areas = fem_obj.search_area_by_nodes(node_ids)
    logger.info('target areas : {}'.format(target_areas))    

    target_nodes = fem_obj.search_node_by_areas(target_areas)
    logger.info('target node ids : {}'.format(target_nodes))

    target_elems = fem_obj.search_elem_by_nodes(target_nodes)
    logger.info('target elem ids : {}'.format(target_elems))

    target_comp2elems = fem_obj.search_comp_by_elems(target_elems)
    logger.info('target comp2elems ids : {}'.format(target_comp2elems))
    
    return target_comp2elems


def read_csv(csv_path):
    # 去掉首行
    # 只取首位
    
    with open(csv_path, 'r') as f:
        lines = [line for line in f.read().split('\n') if line]

    values = []
    for line in lines[1:]:
        value = [v for v in line.split(',') if v][0]
        values.append(value)

    return values



def print_comp2elems(comp2elems):
    strs = []
    for key in comp2elems:
        strs.append(key)
        value = ' '.join(comp2elems[key])
        value = '{' + value + '}'
        strs.append(value)
    print(' '.join(strs))



run_type = sys.argv[1]
fem_path = sys.argv[2]
dis_limit = float(sys.argv[3])

# node_ids = ['181597', '181598']
# dis_limit = 20
# fem_path = tkinter.filedialog.askopenfilename(
#         filetypes = (('2021.1 完整fem', '*.fem'),),
#         )

if run_type.upper() == 'ELEM2COMP_ELEM':
    # 根据elemID数据, 获取 comp2elem 数据
    type_ids = sys.argv[4]
    type_ids = [v for v in node_ids.split(' ') if v]
    target_comp2elems = calc_comp2elems_by_elem(fem_path, dis_limit, type_ids)
    print_comp2elems(target_comp2elems)
    
elif run_type.upper() == 'ELEM2COMP_NODE':
    # 根据nodeID数据, 获取 comp2elem 数据
    type_ids = sys.argv[4]
    type_ids = [v for v in node_ids.split(' ') if v]
    target_comp2elems = calc_comp2elems_by_node(fem_path, dis_limit, type_ids)
    print_comp2elems(target_comp2elems)

elif run_type.upper() == 'ELEM2COMP_ELEM_CSV':
    # 根据csv的elem数据, 获取 comp2elem 数据
    csv_path = sys.argv[4]
    type_ids = read_csv(csv_path)
    logger.info('intput elem ids: {}'.format(type_ids))
    target_comp2elems = calc_comp2elems_by_elem(fem_path, dis_limit, type_ids)
    print_comp2elems(target_comp2elems)

# print(target_comp2elems)


# 找node_ids 
# 根据comp创建set
# 根据comp查找properties
# 根据comp
# 根据set创建

