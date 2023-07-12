"""
    叠加
    input:
        h3d_paths, base_sush3d_dir
"""
import os
import subprocess
import time
import logging

logger = logging.getLogger('Auto_hvSumH3dDamage')

def auto_hv_sum_h3d_damage(model_path, h3d_paths, base_sush3d_dir, hw_path):

    code_path = os.getcwd()

    run_bat_path = os.path.join(code_path, '__run.bat')
    dat_path = os.path.join(code_path, 'hwpost.dat')
    tcl_path = os.path.join(code_path, 'hvAutoRun.tcl')
    success_path = os.path.join(code_path, '__calc_end')
    param_path = os.path.join(code_path, '__temp_param')
    try:
        os.remove(success_path)
    except:
        pass

    path_change = lambda path1: path1.replace('\\', '/')
    with open(param_path, 'w', encoding='utf-8') as f:
        f.write(f'{path_change(base_sush3d_dir)}\n')
        f.write(f'{path_change(model_path)}\n')
        f.write(' '.join([f'{{{path_change(h3d_path)}}}' for h3d_path in h3d_paths]) + '\n')

    bat_str = f'"{hw_path}" /clientconfig "{dat_path}" -tcl "{tcl_path}"'
    with open(run_bat_path, 'w', encoding='utf-8') as f:
        f.write(bat_str)
    # print(bat_str)


    # =============
    # 运行bat文件进行后处理
    print_str = f'run_bat_path: {run_bat_path}'
    logger.info(print_str)
    print(print_str)

    proc = subprocess.Popen(run_bat_path)
    # print(proc)

    # =============
    # hyperview 监测
    print_str = f'success_path: {success_path}'
    print(print_str)
    logger.info(print_str)
    n_limit = 60*60
    n = 1
    while True:
        if n > n_limit: break
        if os.path.exists(success_path):
            time.sleep(1)
            break
        n += 1
        time.sleep(1)

    os.remove(success_path)
    os.remove(run_bat_path)
    os.remove(param_path)
    try:
        os.remove(os.path.join(code_path, 'command1.tcl'))
    except:
        pass

    try:
        os.remove(os.path.join(code_path, 'command.tcl'))
    except:
        pass

    return None



import tkui
TkUi = tkui.TkUi

class AutoH3dDamage(TkUi):

    def __init__(self, title):
        super().__init__(title)
        str_label = '-'*40

        self.frame_entry({
            'frame':'base_sush3d_dir','var_name':'base_sush3d_dir','label_text':'结果h3d存放文件夹',
            'label_width':15,'entry_width':30,
            })

        self.frame_loadpath({
            'frame':'model_path', 'var_name':'model_path', 'path_name':'model file',
            'path_type':'*.h3d;*.fem;*.op2', 'button_name':'Load model 后处理',
            'button_width':15, 'entry_width':40,
            })

        self.frame_loadpaths({
            'frame':'h3d_paths', 'var_name':'h3d_paths', 'path_name':'h3d files',
            'path_type':'.h3d', 'button_name':'h3d路径(s)',
            'button_width':15, 'entry_width':40,
            })


        self.frame_loadpath({
            'frame':'hw_path', 'var_name':'hw_path', 'path_name':'hw exe file',
            'path_type':'.exe', 'button_name':'hw.exe 路径',
            'button_width':15, 'entry_width':40,
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

        # 初始化设置
        self.vars['hw_path'].set('hw.exe')


    def fun_run(self):
        """
            运行按钮调用函数
            主程序
        """
        # 获取界面数据
        params = self.get_vars_and_texts()
        base_sush3d_dir = params['base_sush3d_dir']
        h3d_paths = params['h3d_paths']
        model_path = params['model_path']
        hw_path = params['hw_path']

        auto_hv_sum_h3d_damage(model_path, h3d_paths, base_sush3d_dir, hw_path)
        self.print('计算结束')

        return True


if __name__ == '__main__':

    import tkinter.filedialog
    # base_sush3d_dir = r'E:\AutoCal\calc_flexbody_edit7\CW_K9MD-DW0353\04_result_h3d\TEST'

    # hw_path = r'hw.exe'

    # model_path = tkinter.filedialog.askopenfilename(
    # filetypes = (('h3d', '*.h3d'),),
    # )

    # h3d_paths = tkinter.filedialog.askopenfilenames(
    # filetypes = (('h3d', '*.h3d'),),
    # )

    # auto_hv_sum_h3d_damage(model_path, h3d_paths, base_sush3d_dir, hw_path)

    AutoH3dDamage('h3d叠加').run()
