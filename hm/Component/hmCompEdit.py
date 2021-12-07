import os.path

file_dir  = os.path.dirname(__file__)
comp_path = os.path.join(file_dir, '__temp_comp.csv')
tcl_path  = os.path.join(file_dir, '__temp_cmd.tcl')

def read_csv_data(file_path):

    data = []
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.read().split('\n')[1:]
    for line in lines:
        if line:
            list1d = [value for value in line.split(',') if value]
            data.append(list1d)

    return data

comp_data = read_csv_data(comp_path)

# -----------------------------------
"comp_name,comp_id,prop_name,prop_id"
propid_to_compid_dic = {}
for line in comp_data:
    comp_name = line[0]
    comp_id   = line[1]
    cur_prop_id   = line[3]
    if cur_prop_id in propid_to_compid_dic:
        propid_to_compid_dic[cur_prop_id].append(comp_id)
    else:
        propid_to_compid_dic[cur_prop_id] = [comp_id]

comp_move_ids = {}
for prop_id in propid_to_compid_dic:
    comp_ids = propid_to_compid_dic[prop_id]
    comp_move_ids[comp_ids[0]] = ' '.join([str(n) for n in comp_ids[1:]])


move_cmds = []
for target_comp_id in comp_move_ids:
    if comp_move_ids[target_comp_id]:
        # cmd = f'comp_move "{comp_move_ids[target_comp_id]}" {target_comp_id}'
        cmd = 'comp_move "{}" {}'.format(comp_move_ids[target_comp_id], target_comp_id)
        move_cmds.append(cmd)


# 生成tcl
with open(tcl_path, 'w') as f:
    f.write('\n'.join(move_cmds))


print(True)


