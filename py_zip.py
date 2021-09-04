import zipfile
import os.path
import os
import time
#获取今天的字符串

def dir_to_zip(start_dir, target_dir):
    start_dir = start_dir  # 要压缩的文件夹路径
    
    today = time.strftime("%Y%m%d",time.localtime(time.time()))

    file_name = os.path.split(start_dir)[-1]
    file_news = os.path.join(target_dir, file_name) + f'_{today}.zip'
    # print(file_news)
    # return None

    z = zipfile.ZipFile(file_news, 'w', zipfile.ZIP_DEFLATED)
    for dir_path, dir_names, file_names in os.walk(start_dir):
        f_path = dir_path.replace(start_dir, '')  # 这一句很重要，不replace的话，就从根目录开始复制
        f_path = f_path and f_path + os.sep or ''  # 实现当前文件夹以及包含的所有文件的压缩
        for filename in file_names:
            z.write(os.path.join(dir_path, filename), f_path + filename)
    z.close()
    return file_news


if __name__ == '__main__':

    start_dir = os.path.join(os.getcwd()) # ,'pyadams')
    # print(start_dir)
    import tkinter as tk
    import tkinter.filedialog

    # tk.Tk().withdraw()
    # target_dir = tkinter.filedialog.askdirectory()
    target_dir = r'E:\01_code\00_备份'

    dir_to_zip(start_dir, target_dir)
    import os
    os.startfile(target_dir)
    
