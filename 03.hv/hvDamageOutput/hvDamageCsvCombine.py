'''
    批量读取csv文件,格式如下
        id,value
        14520, 8.881E-09
        14537, 9.581E-09
        15147, 6.782E-09
    
    要求:
        + 数据总共2列
        + 首列数据,顺序一致
        + 文件名称为第2列标题

    合并后数据,格式如下:
        id,lca_flexbody_50_01.op2,lca_flexbody_50_02.op2
        14520, 8.881E-09, 8.881E-09
        14537, 9.581E-09, 9.581E-09
        15147, 6.782E-09, 6.782E-09

'''


import csv
import os
import tkinter.filedialog
import copy


def read_csv_path(csv_path):

    with open(csv_path) as f:
        lines = [line.split(',') for line in f.read().split('\n') if line]

    title = os.path.basename(csv_path)[:-4]
    lines[0][1] = title
    return lines


def sum_csv_paths(sum_csv_path, csv_paths):
    new_lines = []
    for num, csv_path in enumerate(csv_paths):
        
        lines = read_csv_path(csv_path)
        if num == 0:
            new_lines = copy.deepcopy(lines)
            continue
        
        for new_line, line in zip(new_lines, lines):
            new_line.append(line[1])


    f = open(sum_csv_path, 'w')
    for line in new_lines:
        f.write(','.join(line))
        f.write('\n')

    f.close()



# csv_path = r'D:\00_CAE_project\202401_01_multiDamageOutput\lca_flexbody_50_01.op2.csv'
# csv_path2 = r'D:\00_CAE_project\202401_01_multiDamageOutput\lca_flexbody_50_02.op2.csv'
# sum_csv_path = r'D:\00_CAE_project\202401_01_multiDamageOutput\sum.csv'
# csv_paths = [csv_path,csv_path2]

sum_csv_path = tkinter.filedialog.asksaveasfilename(defaultextension=".csv", filetypes=[("csv files", "*.csv"), ("All Files", "*.*")]) 
csv_paths = tkinter.filedialog.askopenfilenames(defaultextension=".csv", filetypes=[("csv files", "*.csv"), ("All Files", "*.*")]) 

sum_csv_paths(sum_csv_path, csv_paths)


print('calc suscess')

