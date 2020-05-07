# -*- coding: utf-8 -*-
'''
瞬态分析-模态法
加载数据处理
创建TLOAD1 TABLED1 DAREA
所需数据
'''
INIT_ELEMENT_ID = 99900000
INIT_GRID_ID = 99800000
INIT_TABLED1_ID = 99700000
INIT_TLOAD1_ID = 99600000
INIT_DAREA_ID = 99500000
INIT_TSTEP_ID = 99400000 
INIT_COMP_ID = 99300000 # COMP 编号
INIT_DLOAD_ID = 99200000  # DLOAD 编号
INIT_TABDMP1_ID = 99100000
INIT_FORCE_ID = 99000000


def create_force_1_comp(load_id,name,grid_id,v,color=5):
	'''
		单位力 or 力矩加载

	'''
	str_start = '$HMNAME LOADCOL         {}"FORCE_{}"\n'.format(strint8(load_id),name) +\
	'$HWCOLOR LOADCOL        {}{}\n'.format(strint8(load_id),strint8(color))
	if v == 1:
		str1 = 'FORCE   {}{}       01.0     1.0     0.0     0.0  \n'.format(
			strint8(load_id),strint8(grid_id))
	elif v == 2:
		str1 = 'FORCE   {}{}       01.0     0.0     1.0     0.0  \n'.format(
			strint8(load_id),strint8(grid_id))
	elif v == 3:
		str1 = 'FORCE   {}{}       01.0     0.0     0.0     1.0  \n'.format(
			strint8(load_id),strint8(grid_id))
	elif v == 4:
		str1 = 'MOMENT  {}{}       01.0     1.0     0.0     0.0  \n'.format(
			strint8(load_id),strint8(grid_id))
	elif v == 5:
		str1 = 'MOMENT  {}{}       01.0     0.0     1.0     0.0  \n'.format(
			strint8(load_id),strint8(grid_id))
	elif v == 6:
		str1 = 'MOMENT  {}{}       01.0     0.0     0.0     1.0  \n'.format(
			strint8(load_id),strint8(grid_id))
	return str_start + str1

def create_force_1_comps(load_ids,names,grid_ids,vtype=3):
	'''
		创建单位力集
		load_ids names  vlist 长度一致
		grid_ids 可能较短 长度 与 load_ids 成倍数
		vtype 每个加载点的方向
	'''
	strlist = []
	if len(load_ids) == len(grid_ids):
		# 加载通道 与 硬点个数 数量一致,直接调用
		for load_id,name,grid_id in zip(load_ids,names,grid_ids):
			strlist.append(create_force_1_comp(load_id+INIT_FORCE_ID,name,
				grid_id+INIT_GRID_ID,int(vtype)))
	else:
		# 长度成倍数
		# 力值加载
		new_grids = []
		i_num = int(len(load_ids) / len(grid_ids))
		for n in grid_ids:
			for n1 in range(i_num):
				new_grids.append(n)
		vlist = [int(n) for n in str(vtype)]*len(grid_ids)
		for load_id,name,grid_id,v in zip(load_ids,names,new_grids,vlist):
			strlist.append(create_force_1_comp(load_id+INIT_FORCE_ID,name,
				grid_id+INIT_GRID_ID,v))

	return '\n'.join(strlist)

def create_tstep(num,name,tsnum,step,color=11):
	'''
	'''
	str1 = '$HMNAME LOADCOL         {}"TSTEP_{}"\n'+\
	'$HWCOLOR LOADCOL        {}      {}\n'+\
	'TSTEP   {}{}       {}      \n'
	num = strint8(num)
	tsnum = strint8(tsnum)
	step = strfloat8(step)
	str1 = str1.format(num,name,num,color,num,tsnum,step)

def create_gird(num,x,y,z):
	pass
	'''
		创建grid点
		输入均为数值
	'''
	num = strint8(num)
	x = strfloat8(x)
	y = strfloat8(y)
	z = strfloat8(z)
	return 'GRID    {}        {}{}{}\n'.format(num,x,y,z)

def create_grids(numlist,xlist,ylist,zlist):
	'''
		创建点集
	'''
	strlist = []
	for num,x,y,z in zip(numlist,xlist,ylist,zlist):
		strlist.append(create_gird(num+INIT_GRID_ID,x,y,z))
	return '\n'.join(strlist)

def create_tabled1(num,name,datalist,samplerate,type='LINEAR',color=4):
	'''
		创建 TABLED1
		num : id号
		name : 名称
		datalist : 数值列表 list
		samplerate : 采样频率
		type : 类型
		color : 颜色 数值
		默认类型linear
	'''
	str_start = '${}\n'+\
		'$HMNAME LOADCOL {} "TABLED1_{}"\n'+\
		'$HWCOLOR LOADCOL {} {}\n'+\
		'TABLED1 {}  LINEAR  LINEAR\n'
	str_start = str_start.format(name,num,name,num,color,num)
	linelist = tabled1_translate(datalist,samplerate)
	output = str_start + '\n'.join(linelist)
	return output

def create_tabled1s(numlist,names,datalist,samplerate):
	strlist = []
	for num ,name ,list1 in zip(numlist,names,datalist):
		strlist.append(create_tabled1(num+INIT_TABLED1_ID,name,list1,samplerate))
	return '\n'.join(strlist)

def create_tload1(num,name,tabled1_id,darea_id,color=6):
	'''
		创建 TLOAD1
	'''
	str_start = '$HMNAME LOADCOL {} "TLOAD1_{}"\n'+\
		'$HWCOLOR LOADCOL {} {}\n'+\
		'TLOAD1  {}{}            LOAD{}\n'
	num = strint8(num)
	darea_id = strint8(darea_id)
	tabled1_id = strint8(tabled1_id)
	str_start = str_start.format(num,name,num,color,num,darea_id,tabled1_id)
	return str_start

def create_tload1s(numslist,names,tabled1_ids,darea_ids):
	'''
	'''
	strlist = []
	for num ,name ,tabled1_id ,darea_id in zip(numslist,names,tabled1_ids,darea_ids):
		strlist.append(create_tload1(num+INIT_TLOAD1_ID,name,
			tabled1_id+INIT_TABLED1_ID,darea_id+INIT_DAREA_ID))
	return '\n'.join(strlist)

def create_darea(num,name,node_id,v,color=10):
	'''
	'''
	str_start = '$HMNAME LOADCOL {} "DAREA_{}"\n'+\
		'$HWCOLOR LOADCOL {} {}\n'
	num = strint8(num)
	node_id = strint8(node_id)
	v = strint8(v)
	str_start = str_start.format(num,name,num,color)

	str2 = '$$ DAREA Data\n'+\
		'DAREA   {}{}{}1.0     \n'
	str2 = str2.format(num,node_id,v)

	return str_start+str2

def create_dareas(numlist,names,node_ids,vlist):
	'''
	'''
	strlist = []
	for num ,name ,node_id ,v in zip(numlist,names,node_ids,vlist):
		strlist.append(create_darea(num+INIT_DAREA_ID,name,node_id+INIT_GRID_ID,v))
	return '\n'.join(strlist)

def tabled1_translate(list1,samplerate):
	'''
		将列数据,转化为TABLED1 的数据格式
		注意:数值长度不超过8位,包含符号
		list1 : 数值数据
		samplerate : 采样频率
	'''
	step = 1/float(samplerate)
	linelist = []
	str1 = ''
	for num,value in enumerate(list1):
		t1 = step * num
		strtime = strfloat8(t1)
		strvalue = strfloat8(value)
		if num % 4 == 0:
			if str1 :
				linelist.append(str1)
			str1 = '+       '+strtime+strvalue
		else:
			str1 = str1 + strtime +strvalue
	if num % 4 == 0:
		linelist.append(str1)
		linelist.append('+       ENDT  \n')
	else:
		linelist.append(str1+'ENDT  \n')
		
	return linelist

def strfloat8(value,isright=True):
	'''
		输入整数
		输出 长度8 的整数字符
	'''
	strvalue = str(value)
	valuelen = len(strvalue)
	intlen = len(str(int(value)))
	if valuelen > 8 :
		if intlen < 9:
			if value > 0:
				if value == int(value):
					strvalue = str(round(value,8-intlen))
				else:
					strvalue = str(round(value,8-intlen-1))
			else:
				if value == int(value):
					strvalue = str(round(value,8-intlen-1))
				else:
					strvalue = str(round(value,8-intlen,2))
		else:
			# 数值过大
			print('warning')
			return False
	# str1 = ' '*(8-valuelen)+strvalue
	if len(strvalue) > 8 and strvalue[-2] == '.' :
		strvalue = strvalue[:-2]
	if isright:
		str1 = strvalue.rjust(8,' ') 
	else:
		str1 = strvalue.ljust(8,' ') 
	# print(str1)
	return str1

def strint8(value,isright=True):
	'''
		输入整数
		输出 长度8 的整数字符
	'''
	strvalue = str(value)
	valuelen = len(strvalue)
	if valuelen > 8 :
		print('warning')
		return False
	# str1 = ' '*(8-valuelen)+strvalue
	if isright:
		str1 = strvalue.rjust(8,' ') 
	else:
		str1 = strvalue.ljust(8,' ') 
	# print(str1)
	return str1

def writefile(filepath,stroutput):
	'''
		写入文件
	'''
	with open(filepath,'w') as f:
		f.write(stroutput)

def csvfile(filepath):
	'''
		读取CSV文件
		文件记录坐标数据,格式如下;
			name,id,x,y,z,
			test1,1,10,10,10,
			test2,1,10,-10,10,
	'''
	with open(filepath,'r') as f:
		linelist = f.readlines()
	names,idlist,xlist,ylist,zlist = [],[],[],[],[]
	for num ,line in enumerate(linelist):
		if num == 0:
			continue
		if '\n' in line:
			line = line[:-1]
		list1 = line.split(',')
		if len(list1)>1:
			names.append(list1[0])
			idlist.append(int(list1[1]))
			xlist.append(float(list1[2]))
			ylist.append(float(list1[3]))
			zlist.append(float(list1[4]))
	return { 'name':names,'id':idlist,'x':xlist,'y':ylist,'z':zlist }

def create_rbe2_default(idlist):
	'''
		创建 RBE2 连接各加载点
		名称 : GRID_AUTO
	'''
	str_start = 'GRID    {}        0.0     0.0     0.0   \n'.format(INIT_GRID_ID)+\
		'$HMNAME COMP            {}"GRID_AUTO" \n'.format(INIT_COMP_ID)+\
		'$HWCOLOR COMP           {}      5\n'.format(INIT_COMP_ID)+\
		'$HMMOVE {}\n'.format(INIT_COMP_ID)+\
		'$       {}\n'.format(INIT_ELEMENT_ID)

	newidlist = [n+INIT_GRID_ID for n in idlist]
	# print(newidlist[2:])
	if len(newidlist) == 2:
		return str_start+'RBE2    {}{}  123456{}{}     \n'.format(INIT_ELEMENT_ID,INIT_GRID_ID,
			strint8(newidlist[0]),strint8(newidlist[1]))
	elif len(idlist) ==1:
		return str_start+'RBE2    {}{}  123456{}     \n'.format(INIT_ELEMENT_ID,INIT_GRID_ID,
			strint8(newidlist[0]))
	else:
		str_start1 = 'RBE2    {}{}  123456{}{}     '.format(INIT_ELEMENT_ID,INIT_GRID_ID,
			strint8(newidlist[0]),strint8(newidlist[1]))
		strlist = []
		strlist.append(str_start1)
		str1 = ''
		i_num = 4
		for num,idnum in enumerate(newidlist[2:]):
			# print(num,idnum)
			if num % i_num == 0:
				if str1 :
					strlist.append(str1)
				str1 = '+       {}'.format(idnum)
			else:
				str1 = str1 + '{}'.format(idnum)
		# if num % i_num != 0:
		strlist.append(str1)
		return str_start + '\n'.join(strlist)

def create_dload_default(tload1_ids,tload1_gains,color=5):
	'''
		创建 DLOAD 卡片

	'''

	str_start = '$HMNAME LOADCOL         {}"DLOAD"\n'.format(strint8(INIT_DLOAD_ID))+\
		'$HWCOLOR LOADCOL         {}{}\n'.format(strint8(INIT_DLOAD_ID),strint8(color))

	newidlist = [n+INIT_TLOAD1_ID for n in tload1_ids]
	if len(newidlist) == 3:
		return str_start+'DLOAD   {}1.0     {}{}{}{}{}{}\n'.format(
			INIT_DLOAD_ID,strfloat8(tload1_gains[0]),strint8(newidlist[0]),
			strfloat8(tload1_gains[1]),strint8(newidlist[1]),
			strfloat8(tload1_gains[2]),strint8(newidlist[2]))
	elif len(newidlist) == 2:
		return str_start+'DLOAD   {}1.0     {}{}{}{}\n'.format(
			INIT_DLOAD_ID,strfloat8(tload1_gains[0]),strint8(newidlist[0]),
			strfloat8(tload1_gains[1]),strint8(newidlist[1]))
	elif len(newidlist) == 1:
		return str_start+'DLOAD   {}1.0     {}{}\n'.format(
			INIT_DLOAD_ID,strfloat8(tload1_gains[0]),strint8(newidlist[0]))
	else:
		str_start1 = 'DLOAD   {}1.0     {}{}{}{}{}{}'.format(
			INIT_DLOAD_ID,strfloat8(tload1_gains[0]),strint8(newidlist[0]),
			strfloat8(tload1_gains[1]),strint8(newidlist[1]),
			strfloat8(tload1_gains[2]),strint8(newidlist[2]))
		strlist = []
		strlist.append(str_start1)
		str1 = ''
		i_num = 4
		for num,idnum,gain in zip(range(len(newidlist[3:])),newidlist[3:],tload1_gains[3:]):
			if num % i_num == 0:
				if str1 :
					strlist.append(str1)
				str1 = '+       {}{}'.format(strfloat8(gain),strint8(idnum))
			else:
				str1 = str1 + '{}{}'.format(strfloat8(gain),strint8(idnum))
		strlist.append(str1)
		return str_start + '\n'.join(strlist)

def write_bdf_file(bdfpath,csvpath,tabled1s):
	'''
		生成 bdf 文件

	'''
	grids = csvfile(csvpath)
	# 创建加载点
	str_grid = create_grids(grids['id'],grids['x'],grids['y'],grids['z'])
	# 各通道加载数据
	str_tabled1 = create_tabled1s(tabled1s['id'],tabled1s['name'],
		tabled1s['data'],tabled1s['samplerate'])
	# 加载点对应 load col 及 卡片DAREA 创建
	# str_darea = create_dareas(tabled1s['id'],tabled1s['name'],tabled1s['id'],loads['v'])
	# 创建 load col 及 加载FORCE 
	str_force = create_force_1_comps(tabled1s['id'],tabled1s['name'],
		grids['id'],tabled1s['vtype'])
	# 创建 TLOAD1 卡片
	# tload 与 tabled1 ID 名称 后缀一致 , 并 连接 tabled1 与 加载load 的ID号 
	str_tload1 = create_tload1s(tabled1s['id'],tabled1s['name'],tabled1s['id'],tabled1s['id'])
	# 创建 FORCE 卡片
	# 默认系数 1.0
	str_dload = create_dload_default(tabled1s['id'],[1.0 for n in tabled1s['id']])
	# 创建 RBE2 连接各加载点
	str_rbe2 = create_rbe2_default(grids['id'])

	stroutput = '\n'.join([str_grid,str_rbe2,str_tabled1,str_force,str_tload1,str_dload])

	writefile(bdfpath,stroutput)


list1 = [1,2,3,4,5,6,7,8,9,10]
bdfpath = r'E:\workspace\nastran\test.bdf'
csvpath = r'E:\workspace\nastran\test.csv'
tabled1s = {'id':[n+1 for n in range(12)],'name':['test_{}'.format(n+1) for n in range(12)],
	'data':[list1]*12,'samplerate':50,'vtype':'123456'}

write_bdf_file(bdfpath,csvpath,tabled1s)
# print(create_rbe2_default([1,2,3,4,5,6,7,8,9,10,11]))