

import os
import shutil
import tkui
TkUi = tkui.TkUi


from fatigue_fem_fatdef_split_limit import split_fatigue_fatdef_set_limit
from fatigue_fem_path_edit import fatigue_fem_path_edit
from py_bat_opt_run import opt_run
from stat_time_read import stat_time_read


def movefile(srcfile, dstfile):

    if not os.path.isfile(srcfile):
        print("%s not exist!"%(srcfile))
    else:
        fpath, fname = os.path.split(dstfile)    #分离文件名和路径
        if not os.path.exists(fpath):
            os.mkdir(fpath)                #创建路径
        shutil.move(srcfile, dstfile)          #移动文件
        print("move %s -> %s"%( srcfile,dstfile))


def movefiles_dir(srcfiles, dstdir):

	new_files = []
	for srcfile in srcfiles:
		new_file = os.path.join(dstdir, os.path.split(srcfile)[1])
		movefile(srcfile, new_file)
		new_files.append(new_file)

	return new_files


def main_calc(opt_path, flexbody_path, base_fem_path, mrf_paths, base_folder_dir, set_id_range, set_limit=15000):

	"""
		+ optistruct.bat 解算器调用文件
		+ flexbody.h3d 目标柔性体h3d文件
		+ optistruct_fatigue.fem 耐久计算用fem基础文件未拆分set及设置路径前
		+ motionsolve_result.mrf(s) 计算结果mrf文件

		+ base_folder_path 基础文件夹路径
		+ set_id_range 计算目标set的ID范围
		+ set_limit 单元截取限制, default:15000
	"""

	base_fem_dir = os.path.join(base_folder_dir, '02_fem')
	base_autocalc_dir = os.path.join(base_folder_dir, '03_autocalc')
	base_resulth3d_dir = os.path.join(base_folder_dir, '04_result_h3d')
	base_stat_dir = os.path.join(base_folder_dir, '05_result_stat')
	base_sush3d_dir = os.path.join(base_folder_dir, '06_sus_h3d')

	# ======
	# 创建路径
	base_dirs = [base_fem_dir, base_autocalc_dir, base_resulth3d_dir, base_stat_dir, base_sush3d_dir]
	for base_dir in base_dirs:
		try:
			os.mkdir(base_dir)
		except:
			pass

	# =====
	fem_split_paths = split_fatigue_fatdef_set_limit(base_fem_path, set_id_range, max_num=set_limit)
	fem_split_paths = movefiles_dir(fem_split_paths, base_fem_dir)
	
	fem_edit_paths = fatigue_fem_path_edit(fem_split_paths, flexbody_path, mrf_paths)
	fem_edit_paths = movefiles_dir(fem_edit_paths, base_autocalc_dir)

	new_fem_paths = opt_run(opt_path, base_autocalc_dir, is_break=True)

	h3d_paths = [path_n[:-3]+'h3d' for path_n in new_fem_paths]
	stat_paths = [path_n[:-3]+'stat' for path_n in new_fem_paths]

	h3d_paths = movefiles_dir(h3d_paths, base_resulth3d_dir)
	stat_paths = movefiles_dir(stat_paths, base_stat_dir)

	log_path = os.path.join(base_stat_dir, '00_result.csv')
	stat_time_read(stat_paths, log_path)

	return h3d_paths


class FatigueMainUI(TkUi):

    def __init__(self, title):
        super().__init__(title)
        str_label = '-'*40

        self.frame_entry({
            'frame':'base_dir','var_name':'base_dir','label_text':'主文件夹',
            'label_width':15,'entry_width':30,
            })

        self.frame_loadpath({
            'frame':'fem_path', 'var_name':'fem_path', 'path_name':'fem file',
            'path_type':'.fem', 'button_name':'基础fem路径',
            'button_width':15, 'entry_width':40,
            })

        self.frame_loadpath({
            'frame':'h3d_path', 'var_name':'h3d_path', 'path_name':'h3d file',
            'path_type':'.h3d', 'button_name':'flexbody h3d路径',
            'button_width':15, 'entry_width':40,
            })

        self.frame_loadpaths({
            'frame':'mrf_paths', 'var_name':'mrf_paths', 'path_name':'mrf files',
            'path_type':'.mrf', 'button_name':'mrf路径(s)',
            'button_width':15, 'entry_width':40,
            })

        self.frame_loadpath({
            'frame':'opt_path', 'var_name':'opt_path', 'path_name':'opt bat file',
            'path_type':'.bat', 'button_name':'opt_bat 路径',
            'button_width':15, 'entry_width':40,
            })

        self.frame_entry({
            'frame':'set_limit','var_name':'set_limit','label_text':'网格上限',
            'label_width':15,'entry_width':30,
            })

        self.frame_entry({
            'frame':'set_id_range','var_name':'set_id_range','label_text':'Set ID Range',
            'label_width':15,'entry_width':30,
            })

        # self.frame_entry({
        #     'frame':'set_id_min','var_name':'set_id_min','label_text':'SetID min',
        #     'label_width':15,'entry_width':30,
        #     })

        # self.frame_entry({
        #     'frame':'set_id_max','var_name':'set_id_max','label_text':'SetID max',
        #     'label_width':15,'entry_width':30,
        #     })

        self.frame_checkbutton({
            'frame':'isSetLimit',
            'var_name':'isSetLimit',
            'check_text':'SET ELEM ID限制',
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
        self.vars['set_limit'].set(15000)
        self.vars['set_id_range'].set('10000,1000000')
        self.vars['isSetLimit'].set(True)
        self.vars['opt_path'].set('optistruct_v2021p1.bat')


    def fun_run(self):
        """
            运行按钮调用函数
            主程序
        """
        # 获取界面数据
        params = self.get_vars_and_texts()
        # print(params)
        opt_path = params['opt_path']
        base_fem_path = params['fem_path']
        flexbody_path = params['h3d_path']
        mrf_paths = params['mrf_paths']
        base_folder_dir = params['base_dir']
        set_id_range = params['set_id_range']
        set_limit = params['set_limit']

        self.print('计算中')
        main_calc(opt_path, flexbody_path, base_fem_path, 
        	mrf_paths, base_folder_dir, set_id_range, set_limit)

        self.print('\n\n----计算结束----\n\n')

        return True


if __name__=='__main__':

	obj = FatigueMainUI('FatigueMain').run()




	




