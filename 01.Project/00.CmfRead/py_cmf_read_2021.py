'''
	cmf_read.py
	读取cmf文件
	获取并处理成 tcl语言
	适用于 hypermesh 13.0
	2020/03
'''


import os.path 
import time
# import pysnooper

def command_tcl_path_search(file_type='cmf'): # 定位command路径
	'''

	'''
	import glob,re
	fullPath=''
	for npath in range(0,5):
		# 5级 文件夹搜索 adams放置路径
		for n in ['C']:
			locPath=r'\*'*npath
			searchPath=r'{}:{}\*\Documents\command.{}'.format(n, locPath, file_type)
			# print(searchPath)
			fullSearch=glob.glob(searchPath)
			if fullSearch:
				fullPath=fullSearch[0]
				break
		if fullPath:
			break

	# print(fullPath)

	# 路径如果存在空格, 批处理调用
	# 则需加上双引号
	if re.search(r'\s',fullPath):
		fullPath = '\"'+fullPath+'\"'
	return fullPath


class CmfFile:
	# hypermesh 命令记录 文件 cmf 的读取
	del_list = ['*viewset','*rotateabout']

	def __init__(self, file_path):
		self.file_path = file_path
		self.file_obj = open(file_path, 'r')
		self.start_time = os.path.getmtime(file_path)
		self.file_size  = os.path.getsize(file_path)
		self.listlast = self.cmf_file_read()
		self.listupdata = ''
		self.listfile = []
		
	# @pysnooper.snoop()
	def is_updata(self):
		''' 
			根据文件修改时间判断文件是否变更
		'''
		current_time = os.path.getmtime(self.file_path)
		if self.start_time != current_time:
			# 时间变更
			self.start_time = current_time
			return True
		return False

	def updata(self):
		listnew = self.cmf_file_read()
		self.listlast.extend(listnew)
		self.listupdata = listnew
		return True
		# old_len = len(self.listlast)
		# new_new = len(listnew)
		# if new_new > old_len:
		# 	self.listupdata = listnew[old_len:]
		# 	self.listlast = listnew
		# 	return True
		# elif new_new < old_len:
		# 	self.listupdata = listnew
		# 	self.listlast = listnew
		# 	return False

	def cmf_file_read(self):
		'''
			读取文件
		'''
		# file_path  = self.file_path
		# with open(file_path,'r') as f:
		str1 = self.file_obj.read()
		# 数据转化处理
		str1 = str1.replace('(',' ')
		str1 = str1.replace(')',' ')
		str1 = str1.replace(',',' ')
		list1 = str1.split('\n')
		list2 = []
		del_list = self.del_list
		for line in list1:
			logic1 = True
			# 判断命令行是否在删除之列
			for del_line in del_list:
				if del_line in line or line == '':
					logic1 = False
					break
			if logic1:
				list2.append(line)
			if '*quit' in line:
				# 检测到退出命令, 输出清空
				list2 = []
		# print('read:', str1)
		# print('read:', list2)
		self.listfile = list2
		return list2

	def run(self):
		"""
			运行
		"""
		line_one = '# '+ '='*20
		print('\n'.join(self.listlast))
		print(line_one)
		while True:
			time.sleep(0.5) # 检索间隔
			if self.is_updata():
				self.updata()
				print('\n'.join(self.listupdata))
				print(line_one)
			else:
				pass
		return None


class CmfFile2021(CmfFile):

	def __init__(self, file_path):
		super().__init__(file_path)
		self.file_size = os.path.getsize(file_path)

	def is_updata(self):
		cur_file_size = os.path.getsize(self.file_path)
		if self.file_size != cur_file_size:
			self.file_size = cur_file_size
			return True
		return False


if __name__ == '__main__':
	# 输入 cmf 文件路径
	# cmfpath = r'C:\Users\ABING\Documents\command.cmf'

	# cmfpath = command_tcl_path_search('tcl')
	# cmfpath = command_tcl_path_search('cmf')
	cmfpath = r"D:\document\hypermesh\2021p1\command1.tcl"
	cmfpath = r"D:\document\hypermesh\2019\command.tcl"
	print(cmfpath)
	cmf = CmfFile2021(cmfpath)
	cmf.run()
