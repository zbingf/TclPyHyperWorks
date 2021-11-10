"""
    tcl命令生成
    hypergraph2d 导出模态应力数据
        单元element数据导出
"""

import tk_ui
TkUi = tk_ui.TkUi

import re
import os
import logging
import os.path
PY_FILE_NAME = os.path.basename(__file__).replace('.py', '')
LOG_PATH = PY_FILE_NAME+'.log'


tcl_path = '__temp.txt'
cmd_path = 'hg2d_stress_tcl.txt'


def fem_node2elems_2d(file_path):

    with open(file_path, 'r') as f:
        lines = [line for line in f.read().split('\n') if line and '$' not in line]

    node2elems = {}
    for line in lines:
        if 'CQUAD4' in line:
            list_elem = [value for value in line.split(' ') if value]
            elem_id = int(list_elem[1])
            node_ids = [int(value) for value in list_elem[-4:]]

        elif 'CTRIA3' in line:
            list_elem = [value for value in line.split(' ') if value]
            elem_id = int(list_elem[1])
            node_ids = [int(value) for value in list_elem[-3:]]

        else:
            continue

        for node_id in node_ids:
            if node_id not in node2elems: node2elems[node_id] = []
            if elem_id not in node2elems[node_id]:
                node2elems[node_id].append(elem_id)

    return node2elems


def tcl_command_create(file_path, element_ids):

    if isinstance(element_ids, int):
        element_ids = [element_ids]

    # ===============================
    # 命令
    with open(cmd_path, 'r') as f:
        cmd_str = f.read()

    # 写入
    f = open(tcl_path, 'w')
    file_path = file_path.replace('\\\\', '/')

    id_str = ' , '.join(['E'+str(element_id) for element_id in element_ids])

    new_cmd_str = cmd_str.replace('#file_path#', file_path).replace('#id_str#', id_str)
    new_cmd_str = new_cmd_str.replace('#xy_path#', file_path[:-4]+f'_xy_data.txt')
    print(new_cmd_str)
    f.write(new_cmd_str+'\n\n')

    f.close()
    os.popen(tcl_path)

    return None


class ModalStressTclUi(TkUi):

    def __init__(self, title, frame=None):
        super().__init__(title, frame=frame)

        self.frame_loadpath({
            'frame':'result_file', 'var_name':'result_file', 'path_name':'result_file(h3d,op2..)',
            'path_type':'.*', 'button_name':'result_file(h3d,op2..)',
            'button_width':20, 'entry_width':40,
            })

        self.frame_entry({
            'frame':'element_ids', 'var_name':'element_ids', 'label_text':'element_ids',
            'label_width':20, 'entry_width':40,
            })

        self.frame_loadpath({
            'frame':'fem_path', 'var_name':'fem_path', 'path_name':'fem_path',
            'path_type':'.fem', 'button_name':'fem_path',
            'button_width':20, 'entry_width':40,
            })

        self.frame_entry({
            'frame':'node_ids', 'var_name':'node_ids', 'label_text':'node_ids',
            'label_width':20, 'entry_width':40,
            })


        self.frame_buttons_RWR({
            'frame' : 'rrw',
            'button_run_name' : '运行',
            'button_write_name' : '保存',
            'button_read_name' : '读取',
            'button_width' : 15,
            'func_run' : self.fun_run,
            })

        self.frame_note()


    def fun_run(self):

        self.print('开始计算')

        params = self.get_vars_and_texts()

        result_file = params['result_file']
        element_ids = params['element_ids']
        fem_path    = params['fem_path']
        node_ids    = params['node_ids']

        if isinstance(node_ids, str) or node_ids==None or not node_ids:
            tcl_command_create(result_file, element_ids)
        else:
            if isinstance(node_ids, int): node_ids = [node_ids]
            new_element_ids = []
            node2elems = fem_node2elems_2d(fem_path)
            for node_id in node_ids:
                new_element_ids.extend(node2elems[node_id])

            tcl_command_create(result_file, new_element_ids)

        self.print('计算完成')



if __name__=='__main__':
    
    ModalStressTclUi('Hg2D-Stress-Tcl').run()



    # # 获取文件
    # file_path = tkinter.filedialog.askopenfilename(filetypes = (('files',['*.*']),))
    # element_ids = [680, 693]

    # tcl_command_create(file_path, element_ids)