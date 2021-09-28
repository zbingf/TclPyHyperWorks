
from pprint import pprint
import os.path


file_dir  = os.path.dirname(__file__)
prop_path = os.path.join(file_dir, '__temp_prop.csv')
mat_path = os.path.join(file_dir, '__temp_mat.csv')
tcl_path  = os.path.join(file_dir, '__temp_cmd_mat_edit.tcl')

def read_csv_data(file_path):
    data = []
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.read().split('\n')[1:]
    for line in lines:
        if line:
            list1d = [value for value in line.split(',') if value]
            data.append(list1d)

    return data


mat_data = read_csv_data(mat_path)
prop_data = read_csv_data(prop_path)


# -----------------------------------
# mat_data
# pprint(mat_data)
mat_id_to_targetid = {}
mat_name_to_id_dic = {}
del_matids = []
for line in mat_data:
    cardimage = line[1]
    data_name = cardimage + ',' + ','.join(line[3:])
    mat_id = line[2]
    if data_name in mat_name_to_id_dic:
        mat_name_to_id_dic[data_name].append(mat_id)
    else:
        mat_name_to_id_dic[data_name] = [mat_id]

for data_name in mat_name_to_id_dic:
    mat_ids = mat_name_to_id_dic[data_name]
    target_id = mat_ids[0]
    for mat_id in mat_ids:
        mat_id_to_targetid[mat_id] = target_id

    if len(mat_ids) > 1:
        del_matids.extend(mat_ids[1:])

del_matids = list(set(del_matids))

# pprint(mat_name_to_id_dic)
# pprint(mat_id_to_targetid)
# pprint(del_matids)

# ---------------------------------
# property 设置
"prop_name,prop_id,material_name,material_id,cardimage_name,thickness"

str_cmd = "*setvalue props id=#prop_id# materialid={mats #mat_id#}"

prop_mat_reset_cmds = [] # 属性重定义mat id
for line in prop_data:
    prop_id = line[1]
    mat_id = line[3]
    cmd = str_cmd.replace("#prop_id#", prop_id).replace("#mat_id#", mat_id_to_targetid[mat_id])
    prop_mat_reset_cmds.append(cmd)

# print(prop_mat_reset_cmds)


str_cmd_del_mat = """
*createmark materials 1 #mat_id#
*deletemark materials 1  
"""
mat_del_cmds = []
for mat_id in del_matids:
    cmd = str_cmd_del_mat.replace("#mat_id#", mat_id)
    mat_del_cmds.append(cmd)


# print(mat_del_cmds)


# 生成tcl
with open(tcl_path, 'w') as f:
    f.write('\n'.join(prop_mat_reset_cmds))
    f.write('\n')
    f.write('\n'.join(mat_del_cmds))




print(True)


