"""
    2021.1 fem 文件读取
"""

import os
import re
import tkui


ELEM_SHELL_NAME = ['CQUAD4', 'CTRIA3']
LEN_ELEM_NAME = max([len(v) for v in ELEM_SHELL_NAME])


START_COMP = "$HMNAME COMP"
# comp   1: ID 2： COMP NAME 3 PROP ID
RE_COMP_PROP_ID_NAME = "\$HMNAME\s*COMP\s*(\d+)\"(\S+)\"\s*(\d+)\s*\"(\S+)\".*" 
# RE_PROP_ID_NAME = "\$HMNAME\s+PROP\s+(\d+)\"(\S+)\"_.*\""


get_line_n = lambda line, n: line[8*n:8*(n+1)].strip()

def str2float(str1):
    if '-' in str1[1:]:
        new_str1 = str1[0] + str1[1:].replace('-', 'e-')
    elif '+' in str1[1:]:
        new_str1 = str1[0] + str1[1:].replace('+', 'e+')
    else:
        new_str1 = str1

    return float(new_str1)


# 读取&解析数据
def read_fem_set(fem_path):

    f = open(fem_path, 'r')
    
    set2elems = {}
    # elem2set  = {}

    is_set = False
    lines  = []
    elem_ids  = []
    n_read = -1
    set2line = {}

    prop2elem = {}
    elem2prop = {}
    comp2prop = {}
    comp2name = {}
    prop2name = {}

    while True:
        line = f.readline()
        n_read += 1

        if not line :break
        cline = line.strip()
        lines.append(line)

        if "SET" in cline[:4]:
            set_id = get_line_n(line, 1)
            set_type = get_line_n(line, 2)

            # 过滤条件
            if set_type != 'ELEM': continue

            set2line[set_id] = {}
            is_set = True
            set2line[set_id]['start'] = n_read
            continue

        if is_set: # set设置范围
            if len(cline)<1:
                set2line[set_id]['end'] = n_read
                is_set = False
                set2elems[set_id] = elem_ids
                elem_ids = []

            elif cline[0] == '+': # 续接 set
                n_len = round(len(line)/8)
                for n in range(1, n_len):
                    elem_id = get_line_n(line, n)
                    # if elem_id in elem2set: 
                    #     print_str = 'elem_id在不同set_id中存在: {} ; set_id: {} ; current set_id: {} 覆盖;'.format(elem_id, elem2set[elem_id], set_id)
                    #     # logger.info(print_str)
                    #     print(print_str)
                    
                    # elem2set[elem_id] = set_id
                    elem_ids.append(elem_id)
            
            else: # 中断set读取
                set2line[set_id]['end'] = n_read
                is_set = False
                set2elems[set_id] = elem_ids
                elem_ids = []

        else:
            t_logic = 0
            for elem_name in ELEM_SHELL_NAME:
                if elem_name in line[:LEN_ELEM_NAME]:
                    e_id = get_line_n(line, 1)
                    c_id = get_line_n(line, 2)
                    if c_id not in prop2elem: prop2elem[c_id] = []
                    prop2elem[c_id].append(e_id)
                    elem2prop[e_id] = c_id
                    t_logic = 1
                    break
            if t_logic: continue
            

            if START_COMP in line:
                re_obj1 = re.match(RE_COMP_PROP_ID_NAME, line)
                if re_obj1:
                    comp_id, comp_name, prop_id, prop_name = re_obj1.groups()
                    # print(line)                    
                    # print(comp_id, comp_name, prop_id)
                    # comp2prop[comp_id] = prop_id
                    # comp2name[comp_id] = comp_name
                    prop2name[prop_id] = prop_name

    f.close()

    data = {
        'set2elems': set2elems,
        # 'elem2set': elem2set,
        'lines' : lines,
        'set2line' : set2line,
        'prop2elem' : prop2elem,
        'elem2prop' : elem2prop,
        'prop2name' : prop2name,
    }

    return data


def set_group_by_setid(fem_path, set_id, suffix=None):
    global propname2matname
    data = read_fem_set(fem_path)

    set_elems = data['set2elems'][set_id]
    elem2prop = data['elem2prop']
    prop2name = data['prop2name']


    prop2matname = {}
    matname2prop = {}
    elem_noin_target = []
    prop_noin_target = []

    for prop_id in prop2name:
        # mat_name = prop2name[prop_id].split('_')[2]
        mat_name = propname2matname(prop2name[prop_id])
        if suffix != None: mat_name += suffix
        if mat_name not in matname2prop: matname2prop[mat_name]=[]
        matname2prop[mat_name].append(prop_id)
        prop2matname[prop_id] = mat_name

    matname2elem = {}
    for elem_id in set_elems:
        if elem_id in elem2prop:
            prop_id = elem2prop[elem_id]
        else:
            elem_noin_target.append(elem_id)
            continue

        if prop_id in prop2matname:
            mat_name = prop2matname[prop_id]
        else:
            prop_noin_target.append(prop_id)
            continue

        if mat_name not in matname2elem: matname2elem[mat_name] = []
        matname2elem[mat_name].append(elem_id)

    prop_noin_target = set(prop_noin_target)

    return matname2elem



def main_by_Setid(fem_path, asc_path, set_id, fun_lambda=None, suffix=None):

    global propname2matname

    if fun_lambda == None:
        propname2matname = eval("lambda propname: propname.split('_')[2]")
    else:
        propname2matname = eval(fun_lambda)
        

    matname2elem = set_group_by_setid(fem_path=fem_path, set_id=set_id, suffix=suffix)

    
    cal_elem_num = sum([len(matname2elem[name]) for name in matname2elem])
    print('辨识的elem单元数量: {}'.format(cal_elem_num))

    # asc_path = 'temp_set.asc'
    f = open(asc_path, 'w')

    for name in matname2elem:
        elem_ids = matname2elem[name]
        f.write('Description={}\nEntityType=Element\n'.format(name))
        for elem_id in elem_ids:
            f.write(elem_id+'\n')

    f.close()
    
    return cal_elem_num


if __name__=='__main__':

    fem_path="temp_fatigue_fem.fem"
    asc_path = 'temp_set.asc'
    set_id='1'

    main_by_Setid(fem_path, asc_path, set_id)