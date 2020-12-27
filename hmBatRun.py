

import os


def hm_path_search_13(): # 定位hw.exe路径
	'''

	'''
	import glob,re
	fullPath=''
	for npath in range(0,5):
		# 5级 文件夹搜索 adams放置路径
		for n in ['C','D','E','F','G','H','I','J']:
			locPath=r'\*'*npath
			searchPath=r'{}:{}\*\13.0\hm\bin\win64\hmbatch.exe'.format(n,locPath)
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



hm_13 = hm_path_search_13()
print(hm_13)

tcl_path = r'D:\document\hypermesh\batRunTest.tcl'


os.system(f'{hm_13} -tcl {tcl_path}')

# os.system(f'{hm_13} -h')