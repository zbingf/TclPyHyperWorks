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
        if file_name[-2:].lower() == '.k':
            file_path = os.path.join(target_dir, file_name)
            fem_paths.append(file_path)
    return fem_paths


def run_k(dyna_path, k_path, nthread, m_memory):

    # return subprocess.check_output([dyna_path, k_path, "-nthread", str(nthread)])
    params = [dyna_path, f"i={k_path}", f"ncpu={nthread}", f"memory={m_memory}m"]
    # params = [dyna_path, os.path.basename(k_path)]
    # print(params)
    return subprocess.check_output(params)


def dyna_run(dyna_path, run_dir, is_break=False, nthread=4, m_memory=20):
    """
        批处理调用Optistruct(dyna_path)计算run_dir目录下的fem文件
        is_break : True没有fem文件会中断运行, False持续保持检测运算状态
    """

    # log_path = os.path.join(run_dir, 'Auto_cal.log')
    # logging.basicConfig(level=logging.INFO, filename=log_path, filemode='w')
    # logger = logging.getLogger('dyna_run')
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
            if run_n <= 1: loginfo("------------无计算-waiting------------")

            if run_n > 5 and is_break:
                loginfo('break dyna_run')
                break


        for loc, k_path in enumerate(fem_paths):
            
            # 等待fem文件复制完整
            # waitting_file_copy_finish(k_path)
            if not os.path.exists(k_path): continue


            fem_name = os.path.basename(k_path)
            cur_time = str(round(time.time()*10))
            cur_dir_name = fem_name[:-4]+'_'+cur_time
            cur_dir = os.path.join(run_dir, cur_dir_name)
            new_k_path = os.path.join(cur_dir, fem_name)


            os.mkdir(cur_dir)
            os.chdir(cur_dir)
            # shutil.copy(k_path, new_k_path)
            # os.remove(k_path)

            # 直接操作可操作则表示复制完成
            while 1:
                if not os.path.exists(k_path): break

                try:
                    shutil.move(k_path, cur_dir)
                    break
                except:
                    time.sleep(2)
                    continue
            
            # print('当前运行: {}'.format(k_path))
            loginfo('当前运行: {}'.format(k_path))
            if loc == len(fem_paths)-1:
                # print('当前为最后1个')
                loginfo('当前为最后1个')
            else:
                str1 = '下一个 {}'.format(fem_paths[loc+1])
                # print(str1)
                loginfo(str1)

            # ----------------------
            # 运行 !!!!!!!!!!!!
            str1 = run_k(dyna_path, new_k_path, nthread, m_memory).decode()
            # print(str1)
            loginfo('运行结果: {}'.format(str1))
            os.chdir(run_dir)
            
            new_fem_paths.append(new_k_path)
            time.sleep(1)
            run_n = 0

        time.sleep(1)
        run_n += 1

    return new_fem_paths
    


import sys



dyna_path = sys.argv[1]
run_dir  =  sys.argv[2]
nthread = sys.argv[3]
m_memory = sys.argv[4]

print(dyna_path)
print(run_dir)
print(nthread)
print(m_memory)
nthread = int(nthread)

dyna_run(dyna_path, run_dir, is_break=False, nthread=nthread, m_memory=m_memory)