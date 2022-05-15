# -*- coding:utf-8 -*-

# optistruct
# 指定文件夹, 自动运行fem
# hwsolvers\scripts\optistruct.bat

import os
import subprocess
import time
import shutil
import logging
import pprint


logging.basicConfig(level=logging.INFO, filename="00_AutoCalLog.txt", filemode='w')


def loginfo(line):
    logging.info(line)
    print(line)




def search_fem_file(file_dir):

    target_dir = os.path.abspath(file_dir)
    
    fem_paths = []
    for file_name in os.listdir(target_dir):
        if file_name[-4:].lower() == '.fem':
            file_path = os.path.join(target_dir, file_name)
            fem_paths.append(file_path)
    return fem_paths


def run_fem(opt_path, fem_path, nthread):

    # return subprocess.check_output([opt_path, fem_path, "-nthread", str(nthread)])
    params = [opt_path, fem_path, "-nt", str(nthread)]
    # params = [opt_path, os.path.basename(fem_path)]
    # print(params)
    return subprocess.check_output(params)


def opt_run(opt_path, run_dir, is_break=False, nthread=4):
    """
        批处理调用Optistruct(opt_path)计算run_dir目录下的fem文件

        is_break : True没有fem文件会中断运行, False持续保持检测运算状态
    """

    # log_path = os.path.join(run_dir, 'Auto_cal.log')
    # logging.basicConfig(level=logging.INFO, filename=log_path, filemode='w')
    # logger = logging.getLogger('opt_run')
    new_fem_paths = []

    os.chdir(run_dir)
    run_n = 0
    while True:

        fem_paths = search_fem_file(run_dir)
        if fem_paths:
            # print("fem_paths:", fem_paths)
            str1 = pprint.pformat(fem_paths)
            loginfo('fem_paths: {}'.format(str1))
            run_n = 0
        else:
            if run_n <= 1: loginfo("------------waiting------------")

            if run_n > 5 and is_break:
                loginfo('break opt_run')
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
            
            # print('当前运行: {}'.format(fem_path))
            loginfo('当前运行: {}'.format(fem_path))
            if loc == len(fem_paths)-1:
                # print('当前为最后1个')
                loginfo('当前为最后1个')
            else:
                str1 = '下一个 {}'.format(fem_paths[loc+1])
                # print(str1)
                loginfo(str1)

            # ----------------------
            # 运行 !!!!!!!!!!!!
            str1 = run_fem(opt_path, new_fem_path, nthread).decode()
            # print(str1)
            loginfo('运行结果: {}'.format(str1))
            os.chdir(run_dir)
            
            new_fem_paths.append(new_fem_path)
            time.sleep(1)
            run_n = 0

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

        self.frame_entry({
            'frame':'nthread','var_name':'nthread','label_text':'nthread',
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
        self.vars['nthread'].set('4')


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
        nthread = params['nthread']
        opt_run(opt_path, run_dir, is_break=False, nthread=nthread)
        
        self.print('计算结束')

        return True



import sys


if len(sys.argv) <= 1:

# if __name__=='__main__':

    # # 系统添加全局变量
    # # hwsolvers\scripts\.
    # opt_path = r'optistruct_v2017.bat'  # .bat文件
    # # 运行路径
    # run_dir = r'E:\AutoCal'
    # opt_run(opt_path, run_dir)

    BatOptRunUI('OptFemRun').run()

else:
    opt_path = sys.argv[1]
    run_dir  =  sys.argv[2]
    nthread = int(sys.argv[3])

    print(opt_path)
    print(run_dir)
    print(nthread)

    opt_run(opt_path, run_dir, is_break=False, nthread=nthread)
