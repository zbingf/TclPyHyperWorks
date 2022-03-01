# pyuserinput.py
import pykeyboard
import pymouse
import time
import tkinter.filedialog as tk_file
import math
import keyboard
import os.path

m = pymouse.PyMouse()
k = pykeyboard.PyKeyboard()

is_end = False

def run_end():
    global is_end
    is_end = True


def mouse_click_double_loc(loc):

    m.click(*loc)
    time.sleep(0.2)
    m.click(*loc)
    time.sleep(0.2)


def print_string(k_string, str_len=200, time_sleep=0.1):

    # str_len = 200
    n_len = math.ceil(len(k_string)/str_len)
    for loc in range(n_len-1):
        k.type_string(k_string[str_len*loc : str_len*(loc+1)])
        time.sleep(time_sleep)
        if is_end:
            return None

    if str_len*(loc+1) != len(k_string):
        k.type_string(k_string[str_len*(loc+1):])
    
    # k.type_string('\n')


def read_file(file_path):
    
    with open(file_path, 'r', encoding='utf-8') as f:
        str1 = f.read()
    lines = str1.split('\n')

    return str1, lines


def is_Chinese(ch):
    if '\u4e00' <= ch <= '\u9fff':
            return True
    return False


def screen_print(file_path, str_len=200, time_sleep=0.1):
    str_lines, lines = read_file(file_path)
    # str_lines.insert(0, "---~file~---\n")
    # 
    path_name = os.path.basename(file_path)
    str_lines = f"\n---~file:{path_name}~---\n" + str_lines
    str_lines = str_lines.replace(') ', ')^S^')
    str_lines = str_lines.replace('# ', '#^S^')
    
    b_lines = []
    for n in str_lines:
        if is_Chinese(n):
            ne = n.encode('utf-8')
            for n0 in ne: 
                b_lines.append(hex(n0))
            b_lines.append(' ')
        else:
            b_lines.append(n)

    b_str = ''.join([str(v) for v in b_lines])
    print_string(b_str, str_len=str_len, time_sleep=time_sleep)
    # print(b_str)
    return None

# 打印数据
def write_file():

    keyboard.add_hotkey('esc', run_end, args=())
    loc = (1800, 100)
    # mouse_click_double_loc(loc)
    # return None
    file_paths = tk_file.askopenfilenames()
    if not file_paths:
        raise 'None file_path'
    # print(file_path)
    # file_path = r'路径测试')
    mouse_click_double_loc(loc)
    for file_path in file_paths:
        
        screen_print(file_path, 6, 0.1)


if __name__=='__main__':

    write_file()
    # new_file_with_chiness('test.txt', 'new_test.txt')

