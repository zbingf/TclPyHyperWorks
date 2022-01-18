"""
	时长统计
"""
import tkinter
import tkinter.filedialog
import re
import os.path
import logging

file_dir = os.path.dirname(__file__)
log_path = os.path.join(file_dir, 'stat_time_read.log')
with open(log_path, 'w') as f: pass
logging.basicConfig(level=logging.INFO, filename=log_path)  # 设置日志级别
logger = logging.getLogger('stat_time_read')

tkinter.Tk().withdraw()


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


if __name__ == '__main__':

	stat_paths = tkinter.filedialog.askopenfilenames(
	    filetypes = (('stat', '*.stat'),),
	    )

	for stat_path in stat_paths:
		run_time = read_out_time(stat_path)
		stat_name = os.path.basename(stat_path)
		logger.info('{}, {} min'.format(stat_name, run_time))


	# import time
	# time.sleep(300)