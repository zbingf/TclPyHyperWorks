# -*- coding:utf-8 -*-

# optistruct
# 指定文件夹, 自动运行fem

import os
import subprocess
import time
import shutil

# 系统添加全局变量
# hwsolvers\scripts\.
opt_path = r'optistruct_v2017.bat'  # .bat文件
# 运行路径
run_dir = r'U:/'


def search_fem_file(file_dir):

    target_dir = os.path.abspath(file_dir)
    
    fem_paths = []
    for file_name in os.listdir(target_dir):
        if file_name[-4:].lower() == '.fem':
            file_path = os.path.join(target_dir, file_name)
            fem_paths.append(file_path)
    return fem_paths


def run_fem(fem_path):
	# cmd_str = "{} {}".format(opt_path, fem_path)
	# return subprocess.check_output(cmd_str)
	return subprocess.check_output([opt_path, fem_path])


if __name__=='__main__':
	os.chdir(run_dir)
	while True:

		fem_paths = search_fem_file(run_dir)
		if fem_paths:
			print("fem_paths:", fem_paths)
		else:
			print("waiting")

		for loc, fem_path in enumerate(fem_paths):
			fem_name = os.path.basename(fem_path)
			cur_time = str(round(time.time()*10))
			cur_dir_name = fem_name[:-4]+'_'+cur_time
			cur_dir = os.path.join(run_dir, cur_dir_name)
			new_fem_path = os.path.join(cur_dir, fem_name)

			os.mkdir(cur_dir)
			os.chdir(cur_dir)
			shutil.copy(fem_path, new_fem_path)
			os.remove(fem_path)
			print('当前运行: {}'.format(fem_path))
			if loc == len(fem_paths)-1:
				print('当前为最后1个')
			else:
				print('下一个： {}'.format(fem_paths[loc+1]))

			print(run_fem(new_fem_path))
			os.chdir(run_dir)
			
			time.sleep(1)
		time.sleep(1)





