
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

file_dir = os.path.dirname(__file__)
output_path = os.path.join(file_dir, '__temp_create_node.tcl')
template_path = tkinter.filedialog.askopenfilename(
    filetypes = (('template_csv_path', '*.csv'), ),
    initialdir=file_dir)


# ------------------------------------
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



def tcl_write(output_path, data_list):

    f_output = open(output_path, 'w')
    temp_ids = {}
    for node_id, x, y, z in zip(*data_list):
    	node_str = f"""
    	*createnode {x} {y} {z} 0 0 0
    	"""
    	f_output.write(node_str)

    logger.info(output_path)
    f_output.close()

    return True


# ------------------------------------

data_template, data_template_list = template_read(template_path)
result = tcl_write(output_path, data_template_list)
logger.info('End')

print(result)
