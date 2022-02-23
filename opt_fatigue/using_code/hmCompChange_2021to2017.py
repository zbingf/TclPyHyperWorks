"""
    fem版本切换
    主要变更
        comp从属关系
    适用
        2021.1 转 2017 
"""

import re
import tkinter
import tkinter.filedialog
import tkinter.messagebox

tkinter.Tk().withdraw()

def create_hmove(comp_id, elem_ids):
    line_start = '$HMMOVE'.ljust(8) + f'{comp_id}'.rjust(8) + '\n'

    str1 = '$'.ljust(8)
    strs = [line_start]
    for loc, elem_id in enumerate(elem_ids):
        if loc%9 == 0:
            strs.append(str1)

        str2 = f'{elem_id}'.rjust(8)
        strs.append(str2)
        if loc%9 == 8:
            strs.append('\n')

    return ''.join(strs)

def change_fem(fem_path, new_fem_path):

    lines_file = []
    new_lines_file = []
    f = open(fem_path, 'r') 
    while True:
        line = f.readline()
        if not line: break
        line = line.replace('\n', '')
        lines_file.append(line)

    f.close()
    last_comp = None
    comp_start = False
    for line in lines_file:

        re_obj = re.match('^\$HMCOMP\s*ID\s*(\d+).*', line)

        if comp_start:
            if "$" in line:
                comp_start = False
                line_input = create_hmove(comp_id, elem_ids)
                new_lines_file.append(line_input)
            elif '+' in line:
                pass
            else:
                elem_id = int(line[8:16])
                elem_ids.append(elem_id)

        if re_obj:
            comp_id = re_obj.group(1)
            comp_start = True
            elem_ids = []
            continue
        else:
            new_lines_file.append(line)

    new_f = open(new_fem_path, 'w', encoding='utf-8')
    for line in new_lines_file:
        new_f.write(line+'\n')
    new_f.close()

    return None

if __name__ == '__main__':

    fem_path = tkinter.filedialog.askopenfilename(
        filetypes=(('2021版fem', '*.fem'),), )

    if fem_path:
        new_fem_path = fem_path[:-4] + '_py2017.fem'
        change_fem(fem_path, new_fem_path)
        tkinter.messagebox.showinfo('信息', '计算结束')
    else:
        tkinter.messagebox.showwarning('警告', '未选择fem文件')


