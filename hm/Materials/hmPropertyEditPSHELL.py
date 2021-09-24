
from pprint import pprint
import os.path


file_dir  = os.path.dirname(__file__)
prop_path = os.path.join(file_dir, '__temp_prop.csv')
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
prop_data = read_csv_data(prop_path)

# print(comp_data)
# print(prop_data)

# ---------------------------------
# property 设置
"prop_name,prop_id,material_name,material_id,cardimage_name,thickness"
prop_to_prop_dic  = {}
value_to_prop_dic = {}
prop_dic  = {}
prop_sts  = []
prop_name_dels = []
prop_id_dels   = []
for line in prop_data:
    if line[-2] != 'PSHELL': continue
    prop_name = line[0]
    value_str = ','.join(line[2:])
    prop_dic[prop_name] = {'value_str': value_str, 'name': line[0], 'id':line[1]}

    if value_str not in prop_sts:
        prop_sts.append(value_str)
        prop_to_prop_dic[prop_name] = prop_name
        value_to_prop_dic[value_str] = prop_name
        continue
    prop_to_prop_dic[prop_name] = value_to_prop_dic[value_str]
    prop_name_dels.append(prop_name)
    prop_id_dels.append(prop_dic[prop_name]['id'])

# ---------------------------------
# material 设置
new_comp_data = []
"comp_name,comp_id,prop_name,prop_id"
for line in comp_data:
    cur_prop_name = line[2]
    cur_prop_id   = line[3]
    if cur_prop_name not in prop_to_prop_dic: continue
    new_prop_name = prop_dic[prop_to_prop_dic[cur_prop_name]]['name']
    new_prop_id   = prop_dic[prop_to_prop_dic[cur_prop_name]]['id']
    new_line = line[:2] + [new_prop_name, new_prop_id]
    new_comp_data.append(new_line)


# ---------------------------------
# 变更comps的属性从属
cmds_setvalue = []
for line in new_comp_data:
    cmd = "*setvalue comps id={} propertyid={{props {}}}".format(line[1], line[3])
    cmds_setvalue.append(cmd)

# 当个删除命令
str_del_single = """
    set status [
        catch {
            *createmark properties 1 #id#
            *deletemark properties 1  
            #puts "del : name=#prop_name# ; id=#id#"
        } res ]
    if {$status} {
        puts "del error: name=#prop_name# ; id=#id#"
    }
"""

# 删除命令开头
str_del_1 = """
set status [
    catch {
        hm_createmark properties 1 "by id only" "#ids_str#"
        *deletemark properties 1 

    } res ]
if {$status} {
    puts "del properties single"
"""
# 删除命令结束
str_del_2 = "}"

# 删除多余prop
cmds_delprop = []
ids_str = ' '.join(prop_id_dels) # 删除目标ID拼接
if ids_str:
    cmds_delprop.append(str_del_1.replace('#ids_str#', ids_str))

for prop_name in prop_name_dels:
    prop_id = prop_dic[prop_name]['id']
    # cmds_delprop.append('*createmark properties 1 "{}"'.format(prop_name))
    # cmds_delprop.append('*deletemark properties 1')
    output_str_n = str_del_single.replace('#prop_name#',prop_name)
    output_str_n = output_str_n.replace('#id#',prop_id)
    cmds_delprop.append(output_str_n)

if ids_str: 
    cmds_delprop.append(str_del_2)
    

# 生成tcl
with open(tcl_path, 'w') as f:
    f.write('\n'.join(cmds_setvalue))
    f.write('\n')
    f.write('\n'.join(cmds_delprop))


print(True)

# pprint(prop_name_dels)
# pprint(prop_to_prop_dic)
# pprint(prop_dic)
# pprint(value_dic)




