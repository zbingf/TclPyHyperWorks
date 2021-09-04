"""
	删除 多余文件
"""
import os

import tkinter
# import tkinter.messagebox #这个是消息框，对话框的关键
import tkinter.filedialog

tkobj=tkinter.Tk()
# 隐藏隐藏主窗口
tkobj.withdraw()


# 删除文件夹内制定文件
def file_remove_pt(path, prefix=None, file_type=None): 
    '''
        仅仅删除文件夹内的文件，不删除子文件夹
        path 文件夹路径
        prefix 文件前缀
        file_type 文件后缀,类型
        示例：
            file_remove_pt(path,'sim_','adm')

            file_remove_pt(cal_path, prefix=None, file_type='bak') # 删除文件夹内整个带bak后缀的文件

    '''
    path_rems = []

    for line in os.listdir(path):
        # print(os.listdir(path))
        if file_type!=None and file_type.lower() == line[-len(file_type):].lower() or file_type==None:
            if prefix!=None and prefix.lower() == line[:len(prefix)].lower() or prefix==None:
                path_rems.append(line)

    for line in path_rems:
        target = os.path.join(path, line)
        if os.path.isfile(target):
            os.remove(target)
        # print(target)
    return True



if __name__ == '__main__':
	path = tkinter.filedialog.askdirectory()
	print(path)

	# path = r'D:\document\hypermesh\00_antiroll'
	# file_remove_pt(path, file_type='png')
	file_remove_pt(path, file_type='out')
	file_remove_pt(path, file_type='stat')
	file_remove_pt(path, file_type='dlmd')
	file_remove_pt(path, file_type='fei')
