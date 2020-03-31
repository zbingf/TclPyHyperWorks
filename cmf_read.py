# cmf_read.py

import os.path 
class CmfFile:
	def __init__(self,filepath):
		self.filepath = filepath
		self.start_time = os.path.getmtime(filepath)
		self.listlast = self.cmf_file_read()
		self.listupdata = ''
	def is_updata(self):
		''' 
			根据文件修改时间判断文件是否变更
		'''
		current_time = os.path.getmtime(filepath)
		if self.start_time != current_time:
			# 时间变更
			self.start_time = current_time
			listnew = self.cmf_file_read()
			old_len = len(self.listlast)
			new_new = len(listnew)
			if new_new > old_len:
				self.listupdata = listnew[old_len:]
				self.listlast = listnew
				return True
			elif new_new < old_len:
				self.listupdata = listnew
				self.listlast = listnew
				return False
		return False

	def cmf_file_read(self):
		filepath  = self.filepath
		with open(filepath,'r') as f:
			str1 = f.read()

		str1 = str1.replace('(',' ')
		str1 = str1.replace(')',' ')
		str1 = str1.replace(',',' ')
		list1 = str1.split('\n')
		list2 = []
		del_list = ['*viewset','*rotateabout']
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
		self.listfile = list2
		return list2

if __name__ == '__main__':
	filepath = r'C:\Users\ABing\Documents\command.cmf'
	cmf = CmfFile(filepath)
	print('\n'.join(cmf.listlast))
	while True:
		if cmf.is_updata():
			print('\n'.join(cmf.listupdata))
			print('\n')
		else:
			pass

