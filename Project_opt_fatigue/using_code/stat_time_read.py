"""
    时长统计
"""

import re
import os.path

def read_out_time(stat_path):

    with open(stat_path, 'r') as f:
        lines = [line for line in f.read().split('\n') if line]

    pattern = re.compile('CUMULATIVE\s+RUN\s+TIME.*WALL\s*=\s*(\S+)')
    for line in lines[-5:]:
        re_obj = re.match(pattern, line)
        if re_obj:
            run_time = round(float(re_obj.group(1))/60, 1)

            return run_time
    return None

def stat_time_read(stat_paths, recode_path):

    f = open(recode_path, 'w')

    for stat_path in stat_paths:
        run_time = read_out_time(stat_path)
        stat_name = os.path.basename(stat_path)
        str_n = '{}, {}, min'.format(stat_name, run_time)
        f.write(str_n+'\n')
        print(str_n)

    f.close()


if __name__ == '__main__':

    import tkinter
    import tkinter.filedialog
    tkinter.Tk().withdraw()

    file_dir = os.path.dirname(__file__)
    log_path = os.path.join(file_dir, 'stat_time_read.log')

    stat_paths = tkinter.filedialog.askopenfilenames(
        filetypes = (('stat', '*.stat'),),
        )
    stat_time_read(stat_paths, log_path)


