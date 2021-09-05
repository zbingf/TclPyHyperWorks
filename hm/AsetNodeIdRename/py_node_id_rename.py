
import os.path
import tkinter
import tkinter.filedialog
import logging
import pprint

# logging
PY_FILE_NAME = os.path.basename(__file__).replace('.py', '')
LOG_PATH = PY_FILE_NAME+'.log'

logger = logging.basicConfig(
    level=logging.INFO, filename=LOG_PATH, filemode='w')
logger = logging.getLogger(PY_FILE_NAME)


# 隐藏主窗口
tkobj = tkinter.Tk(); tkobj.withdraw()


# ------------------------------------
# init set

NODE_ID_TEMP_DELTA = 100000
LIMIT_DIS = 30

file_dir = os.path.dirname(__file__)
csv_path = os.path.join(file_dir, 'temp_nodes.txt')
output_path = os.path.join(file_dir, 'temp_node_id_rename.tcl')
template_path = tkinter.filedialog.askopenfilename(
    filetypes = (('template_csv_path', '*.csv'), ),
    initialdir=file_dir)

"""
template_path 格式:
    FlexId,TypeId,SubId,PartId,Name,x,y,z
    990,24,1,10,L_antiroll_in,5.000,-275.000,250.000
    990,24,1,11,R_antiroll_in,5.000,275.000,250.000
    990,24,1,20,L_antiroll_in,200.000,-410.000,250.000
    990,24,1,21,R_antiroll_in,200.000,410.000,250.000
"""


# ------------------------------------

def csv_read(csv_path):
    with open(csv_path, 'r') as f:
        csv_lines = [line for line in f.read().split('\n') if line]

    node_ids, xs, ys, zs = [], [], [], []
    for line in csv_lines[1:]:
        list1d = [value for value in line.split(',') if value]
        node_id, x, y, z = list1d
        node_ids.append(int(node_id))
        xs.append(float(x))
        ys.append(float(y))
        zs.append(float(z))

    data = {'node_ids': node_ids, 'xs': xs, 'ys': ys, 'zs':zs}
    data_list = [node_ids, xs, ys, zs]

    return data, data_list


def template_read(csv_path):
    with open(csv_path, 'r') as f:
        csv_lines = [line for line in f.read().split('\n') if line]

    node_ids, names, xs, ys, zs = [], [], [], [], []
    for line in csv_lines[1:]:
        list1d = [value for value in line.split(',') if value]
        new_id = int(''.join(list1d[:4]))
        node_ids.append(new_id)
        name, x, y, z = list1d[4:]
        names.append(name)
        xs.append(float(x))
        ys.append(float(y))
        zs.append(float(z))

    data = {'node_ids': node_ids, 'xs': xs, 'ys': ys, 'zs':zs, 'names': names}
    data_list = [node_ids, xs, ys, zs]

    return data, data_list


def tcl_write(output_path, node_id_dic):

    f_output = open(output_path, 'w')
    temp_ids = {}
    for node_id in node_id_dic:
        temp_node_id = node_id_dic[node_id] + NODE_ID_TEMP_DELTA

        while temp_node_id in node_id_dic:
            temp_node_id += NODE_ID_TEMP_DELTA

        node_str = f"""
        catch {{
        *createmark nodes 1 {temp_node_id}
        *renumbersolverid nodes 1 1 1 0 0 0 0 0
        }}

        catch {{
        *createmark nodes 1 {node_id}
        *renumbersolverid nodes 1 {temp_node_id} 1 0 0 0 0 0
        }}
        """

        f_output.write(node_str)

        temp_ids[node_id] = temp_node_id

    for node_id in node_id_dic:
        node_str = f"""
        catch {{
        *createmark nodes 1 {temp_ids[node_id]}
        *renumbersolverid nodes 1 {node_id_dic[node_id]} 1 0 0 0 0 0
        *numbersmark nodes 1 1
        }}
        """
        f_output.write(node_str)

    f_output.close()

    return None


def dis_cal(data_list, data_template_list, limit_dis=30):

    node_id_dic = {}
    for node_id, x, y, z in zip(*data_list):

        for node_id_t, x_t, y_t, z_t in zip(*data_template_list):

            temp_dis = ((x-x_t)**2 + (y-y_t)**2 + (z-z_t)**2)**0.5
            if temp_dis < limit_dis:
                node_id_dic[node_id] = node_id_t

    return node_id_dic


# ------------------------------------

def main():

    data, data_list = csv_read(csv_path)
    data_template, data_template_list = template_read(template_path)

    node_id_dic = dis_cal(data_list, data_template_list, limit_dis=LIMIT_DIS)

    logger.info("========Start Running========")
    logger.info(f"output_path :\n {output_path}")
    logger.info(f"csv_path :\n {output_path}")
    logger.info( pprint.pformat(node_id_dic) )

    tcl_write(output_path, node_id_dic)

    logger.info("========End========")

    logging.shutdown()

    if len(node_id_dic) > int(len(data_template_list)/2):
        return True
    else:
        return False


# ------------------------------------

print(main())


