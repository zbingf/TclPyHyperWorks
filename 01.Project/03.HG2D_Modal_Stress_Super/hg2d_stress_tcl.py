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
import subprocess
import time

PY_FILE_NAME = os.path.basename(__file__).replace('.py', '')
LOG_PATH = PY_FILE_NAME+'.log'


tcl_path = '__temp.tcl'
cmd_path = 'hg2d_stress_tcl.txt'
dat_path = 'hwplot.dat'
# cmd_path = 'hg2d_stress_tcl_flexbody_h3d.txt'


# 根据节点找2D单元
def fem_node2elems_2d(file_path):

    with open(file_path, 'r') as f:
        lines = [line for line in f.read().split('\n') if line and '$' not in line]

    node2elems = {}
    for line in lines:
        if 'CQUAD4' in line[:6]:
            list_elem = [value for value in line.split(' ') if value]
            elem_id = int(list_elem[1])
            node_ids = [int(value) for value in list_elem[-4:]]

        elif 'CTRIA3' in lineline[:6]:
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


# 命令生成
def tcl_command_create(file_path, element_ids, cmd_path, subcase, datatype):

    if isinstance(element_ids, int):
        element_ids = [element_ids]

    # ===============================
    # 命令
    with open(cmd_path, 'r') as f:
        cmd_str = f.read()

    # 写入
    f = open(tcl_path, 'w')
    file_path = file_path.replace('\\\\', '/')

    id_str = ','.join(['E'+str(element_id) for element_id in element_ids])

    new_cmd_str = cmd_str.replace('#file_path#', file_path).replace('#id_str#', id_str)
    new_cmd_str = new_cmd_str.replace('#xy_path#', file_path[:-4]+f'_xy_data.txt')
    new_cmd_str = new_cmd_str.replace('#subcase#', subcase)
    new_cmd_str = new_cmd_str.replace('#datatype#', datatype)

    print(new_cmd_str)
    f.write(new_cmd_str+'\n\n')

    f.close()
    # os.popen(tcl_path)

    return None


class ModalStressTclUi(TkUi):

    def __init__(self, title, frame=None):
        super().__init__(title, frame=frame)

        self.frame_label_only({
            'label_text':'-------------\n读取后处理文件\n导出指定单元应力数据\n调用:hg2d_stress_tcl.txt\n调用:hwplot.dat\n-------------',
            'label_width':15,
            })

        self.frame_loadpath({
            'frame':'result_file', 'var_name':'result_file', 'path_name':'result_file(h3d,op2..)',
            'path_type':'.*', 'button_name':'result_file\neg:(h3d,op2..)',
            'button_width':20, 'entry_width':40,
            })

        self.frame_entry({
            'frame':'subcase', 'var_name':'subcase', 'label_text':'subcase',
            'label_width':20, 'entry_width':40,
            })

        self.frame_entry({
            'frame':'datatype', 'var_name':'datatype', 'label_text':'datatype',
            'label_width':20, 'entry_width':40,
            })

        self.frame_entry({
            'frame':'element_ids', 'var_name':'element_ids', 'label_text':'element_ids\n单元ID',
            'label_width':20, 'entry_width':40,
            })

        self.frame_loadpath({
            'frame':'fem_path', 'var_name':'fem_path', 'path_name':'fem_path',
            'path_type':'.fem', 'button_name':'fem_path\n源文件',
            'button_width':20, 'entry_width':40,
            })

        self.frame_entry({
            'frame':'node_ids', 'var_name':'node_ids', 'label_text':'node_ids\n节点ID\n[根据节点找单元ID]\n[可不选]',
            'label_width':20, 'entry_width':40,
            })


        self.frame_loadpath({
            'frame':'hw_path', 'var_name':'hw_path', 'path_name':'hw exe file',
            'path_type':'.exe', 'button_name':'hw.exe 路径\n后台调用\n需有环境变量索引',
            'button_width':20, 'entry_width':40,
            })


        self.frame_buttons_RWR({
            'frame' : 'rrw',
            'button_run_name' : 'TCL命令生成',
            'button_write_name' : '保存',
            'button_read_name' : '读取',
            'button_width' : 15,
            'func_run' : self.fun_run,
            })

        self.frame_note()


        self.vars['subcase'].set('CMS FlexBody')
        self.vars['datatype'].set('Stress (Flexbody Elements)')
        self.vars['hw_path'].set('hw.exe')


    def fun_run(self):

        self.print('开始计算')

        params = self.get_vars_and_texts()

        result_file = params['result_file']
        element_ids = params['element_ids']
        fem_path    = params['fem_path']
        node_ids    = params['node_ids']
        subcase     = params['subcase']
        datatype    = params['datatype']
        hw_path     = params['hw_path']

        if isinstance(node_ids, str) or node_ids==None or not node_ids:
            tcl_command_create(result_file, element_ids, cmd_path, subcase, datatype)
        else:
            if isinstance(node_ids, int): node_ids = [node_ids]
            new_element_ids = []
            node2elems = fem_node2elems_2d(fem_path)
            for node_id in node_ids:
                new_element_ids.extend(node2elems[node_id])

            tcl_command_create(result_file, new_element_ids, cmd_path, subcase, datatype)


        code_path = os.getcwd()
        run_bat_path = os.path.join(code_path, '__run.bat')
        dat_path1 = os.path.join(code_path, dat_path)
        tcl_path1 = os.path.join(code_path, 'hvAutoRun.tcl')

        bat_str = f'"{hw_path}" /clientconfig "{dat_path1}" -tcl "{tcl_path1}"'
        with open(run_bat_path, 'w', encoding='utf-8') as f:
            f.write(bat_str)

        # =============
        # 运行bat文件进行后处理
        print('run_bat_path', run_bat_path)
        proc = subprocess.Popen(run_bat_path)



        self.print('计算完成')



if __name__=='__main__':
    
    ModalStressTclUi('Hg2D-Stress-Tcl').run()



    # # 获取文件
    # file_path = tkinter.filedialog.askopenfilename(filetypes = (('files',['*.*']),))
    # element_ids = [680, 693]

    # tcl_command_create(file_path, element_ids)