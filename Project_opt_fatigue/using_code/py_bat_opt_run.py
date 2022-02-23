# -*- coding:utf-8 -*-

# optistruct
# 指定文件夹, 自动运行fem

import os
import subprocess
import time
import shutil
import logging
import pprint



def search_fem_file(file_dir):

    target_dir = os.path.abspath(file_dir)
    
    fem_paths = []
    for file_name in os.listdir(target_dir):
        if file_name[-4:].lower() == '.fem':
            file_path = os.path.join(target_dir, file_name)
            fem_paths.append(file_path)
    return fem_paths


def run_fem(opt_path, fem_path):
    # cmd_str = "{} {}".format(opt_path, fem_path)
    # return subprocess.check_output(cmd_str)
    return subprocess.check_output([opt_path, fem_path])


# def waitting_file_copy_finish(fem_path):
#     # while 1:
#     #     size_1 = os.path.getsize(fem_path)
#     #     time.sleep(2)
#     #     size_2 = os.path.getsize(fem_path)
#     #     if size_2 != 0 and size_1 == size_2:
#     #         return True
#     file_size = 0
#     while True:
#         file_info = os.stat(fem_path)
#         size_1 = file_info.st_size
#         time.sleep(2)
#         size_2 = file_info.st_size
#         if size_2 > 0 and size_1 == size_2:
#         # if file_info.st_size == 0 or file_info.st_size > file_size:
#             file_size = file_info.st_size
#             sleep(1)
#             break

def opt_run(opt_path, run_dir, is_break=False):
    """
        批处理调用Optistruct(opt_path)计算run_dir目录下的fem文件

        is_break : True没有fem文件会中断运行, False持续保持检测运算状态
    """

    # log_path = os.path.join(run_dir, 'Auto_cal.log')
    # logging.basicConfig(level=logging.INFO, filename=log_path, filemode='w')
    logger = logging.getLogger('opt_run')
    new_fem_paths = []

    os.chdir(run_dir)
    run_n = 0
    while True:

        fem_paths = search_fem_file(run_dir)
        if fem_paths:
            print("fem_paths:", fem_paths)
            str1 = pprint.pformat(fem_paths)
            logger.info('fem_paths: {}'.format(str1))
        else:
            print("waiting")
            if run_n > 5 and is_break:
                print('break opt_run')
                break


        for loc, fem_path in enumerate(fem_paths):
            
            # 等待fem文件复制完整
            # waitting_file_copy_finish(fem_path)
            if not os.path.exists(fem_path): continue


            fem_name = os.path.basename(fem_path)
            cur_time = str(round(time.time()*10))
            cur_dir_name = fem_name[:-4]+'_'+cur_time
            cur_dir = os.path.join(run_dir, cur_dir_name)
            new_fem_path = os.path.join(cur_dir, fem_name)


            os.mkdir(cur_dir)
            os.chdir(cur_dir)
            # shutil.copy(fem_path, new_fem_path)
            # os.remove(fem_path)

            # 直接操作可操作则表示复制完成
            while 1:
                if not os.path.exists(fem_path): break

                try:
                    shutil.move(fem_path, cur_dir)
                    break
                except:
                    time.sleep(2)
                    continue
            
            print('当前运行: {}'.format(fem_path))
            logger.info('当前运行: {}'.format(fem_path))
            if loc == len(fem_paths)-1:
                print('当前为最后1个')
                logger.info('当前为最后1个')
            else:
                str1 = '下一个 {}'.format(fem_paths[loc+1])
                print(str1)
                logger.info(str1)

            # 运行
            str1 = run_fem(opt_path, new_fem_path).decode()
            print(str1)
            logger.info('运行结果: {}'.format(str1))
            os.chdir(run_dir)
            
            new_fem_paths.append(new_fem_path)
            time.sleep(1)

        time.sleep(1)
        run_n += 1

    return new_fem_paths
    
# ==========================================
# ==========================================

import tkui
TkUi = tkui.TkUi

# UI模块
class BatOptRunUI(TkUi):
    """
        AdmSim 主程序
    """
    def __init__(self, title):
        super().__init__(title)
        str_label = '-'*40

        self.frame_entry({
            'frame':'run_dir','var_name':'run_dir','label_text':'运行路径',
            'label_width':15,'entry_width':30,
            })

        self.frame_entry({
            'frame':'opt_path','var_name':'opt_path','label_text':'opt_bat 路径',
            'label_width':15,'entry_width':30,
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
        self.vars['run_dir'].set(r'E:\AutoCal')
        self.vars['opt_path'].set('optistruct_v2021p1.bat')


    def fun_run(self):
        """
            运行按钮调用函数
            主程序
        """
        self.print('运行中... 若要终止直接关闭')
        # 获取界面数据
        params = self.get_vars_and_texts()
        run_dir = params['run_dir']
        opt_path = params['opt_path']
        opt_run(opt_path, run_dir, is_break=True)
        
        self.print('计算结束')

        return True



if __name__=='__main__':

    # # 系统添加全局变量
    # # hwsolvers\scripts\.
    # opt_path = r'optistruct_v2017.bat'  # .bat文件
    # # 运行路径
    # run_dir = r'E:\AutoCal'

    # opt_run(opt_path, run_dir)

    BatOptRunUI('OptFemRun').run()

