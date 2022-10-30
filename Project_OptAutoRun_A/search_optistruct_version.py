import os
import re
import glob
import sys

disks = ['C','D','E','F','G','H','I','J']


def optistruct_bat_path(version): # 定位bat路径
    '''
        定位bat路径
        用于cmd调用
    '''

    fullPath=[]
    for npath in range(0,5):
        # 5级 文件夹搜索 adams放置路径
        for n in disks:
            locPath=r'\*'*npath
            searchPath=r'{}:{}\{}\hwsolvers\scripts\optistruct.bat'.format(n, locPath, version)

            fullSearch=glob.glob(searchPath)
            if fullSearch:
                fullPath=fullSearch[0]
                break
        if fullPath:
            break

    if not fullPath: # 未找到文件
        import tkinter.filedialog
        fullPath = tkinter.filedialog.askopenfilename(filetypes = (('optistruct bat调用路径','bat'),))
        assert fullPath, 'error optistruct bat path'
        with open(file_set_path, 'w') as f:
            f.write(fullPath)

    # 路径如果存在空格, 批处理调用
    # 则需加上双引号
    if re.search(r'\s',fullPath):
        fullPath = '\"'+fullPath+'\"'

    return fullPath


import sys
version = sys.argv[1]

# with open('path.txt', 'w') as f:
#     f.write(optistruct_bat_path(version))

print(optistruct_bat_path(version))