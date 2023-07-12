# hvView.py

from sklearn.linear_model import LinearRegression
import numpy as np
import pprint
import sys

get_v_locs = lambda locs, n: [loc[n] for loc in locs]
v_abs      = lambda loc1: (loc1[0]**2 + loc1[1]**2 + loc1[2]**2)**0.5
v_one      = lambda loc1: [loc1[0]/v_abs(loc1), loc1[1]/v_abs(loc1), loc1[2]/v_abs(loc1)]
v_reverse  = lambda loc1: [-v for v in loc1]


# 向量叉乘
def v_multi_x(loc1, loc2):
    x1, y1, z1 = loc1
    x2, y2, z2 = loc2
    return [y1*z2-y2*z1, z1*x2-z2*x1, x1*y2-x2*y1]



# 读取坐标数据
def read_csv_file(file_path):
	"""
	格式
		 Node ID, Node Coordinates,

		8006,618.32 -494.738 925.906 ,
		8022,618.846 -496.026 945.714 ,
		8006,618.32 -494.738 925.906 ,
		8003,618.176 -493.423 906.081 ,
		8011,617.597 -894.944 917.015 ,
		8021,618.328 -896.219 936.848 ,
		8003,618.176 -493.423 906.081 ,
		8374,698.589 -494.599 925.622 ,
		8257,739.499 -488.878 836.251 ,


	"""
	with open(file_path, 'r') as f:

		lines = [line for line in f.read().split('\n') if line][1:]

	data = []
	for line in lines:
		loc = []
		list1 = [value.strip() for value in line.split(',') if value]
		if len(list1) > 1:
			loc = [float(v) for v in list1[1].split(' ') if v]

		if loc:
			data.append(loc)
	return data


# 拟合空间平面
def fit_surf_v(locs):

	xs = get_v_locs(locs, 0)
	ys = get_v_locs(locs, 1)
	zs = get_v_locs(locs, 2)


	lin_reg = LinearRegression()
	X = np.array([xs, ys]).T
	lin_reg.fit(X, zs)

	# print(lin_reg.intercept_, ) # 截距
	v_x, v_y = lin_reg.coef_
	v_z = -1
	# print(X[0:2])

	surf_v = v_one([v_x, v_y, v_z])

	return surf_v


# 矩阵视角前12位拼接
def join_view_12(axis_x, axis_y, axis_z):
	view_list = []
	for n in range(3):
		view_list.append(axis_x[n])
		view_list.append(axis_y[n])
		view_list.append(axis_z[n])
		view_list.append(0)

	view_12_str = ' '.join([str(v) for v in view_list])
	# print(view_12_str)
	return view_12_str



# 弃用
def create_view_12_by_csv(file_path):
	locs = read_csv_file(file_path)
	axis_z = fit_surf_v(locs)
	axis_x = [1, 0, 0]
	axis_y = v_one(v_multi_x(axis_z, axis_x))

	# pprint.pprint(locs)
	# print(axis_z, axis_x, axis_y)
	cx = np.mean(get_v_locs(locs, 0))
	cy = np.mean(get_v_locs(locs, 1))
	cz = np.mean(get_v_locs(locs, 2))
	camera_center_str1 = '{} {} {}'.format(-cx, -cy, -cz)
	camera_center_str2 = '{} {} {}'.format(-cx, cy, cz)

	view_12_str_1 = join_view_12(axis_x, axis_y, axis_z)
	view_12_str_2 = join_view_12(axis_x, v_reverse(axis_y), v_reverse(axis_z))
	# print(view_12_str_1)
	# print(view_12_str_2)
	return '{%s} {%s} {%s} {%s}'%(view_12_str_1, view_12_str_2, camera_center_str1, camera_center_str2)
	

def create_view_16_by_csv(file_path):
	locs = read_csv_file(file_path)
	axis_x = [1, 0, 0]

	axis_z = fit_surf_v(locs)
	axis_y = v_one(v_multi_x(axis_z, axis_x))
	axis_x = v_one(v_multi_x(axis_y, axis_z))

	# pprint.pprint(locs)
	# print(axis_z, axis_x, axis_y)
	cx = np.mean(get_v_locs(locs, 0)) # - 1063.570
	cy = np.mean(get_v_locs(locs, 1)) # - (-395.717)
	cz = np.mean(get_v_locs(locs, 2)) # - 925.715
	# print(cx, cy, cz)

	# 模型矩阵
	list16_1 = [
		[*axis_x, 0],
		[*axis_y, 0],
		[*axis_z, 0],
		[cx, cy, cz, 1],
		# [0, 0, 0, 1],
	]

	list16_2 = [
		[*axis_x, 0],
		[*v_reverse(axis_y), 0],
		[*v_reverse(axis_z), 0],
		[cx, cy, cz, 1],
		# [0, 0, 0, 1],
	]

	def change(list16):
		array_16 = np.array(list16)
		view_array = np.linalg.inv(array_16)
		# pprint.pprint(array_16)
		# pprint.pprint(view_array)
		view_array = view_array.reshape((1,16))
		# list1 = np.tolist(view_array)
		view_list = view_array.tolist()[0]
		return view_list

	view_16_str_1 = ' '.join([str(v) for v in change(list16_1)])
	view_16_str_2 = ' '.join([str(v) for v in change(list16_2)])
	center_point_loc = [cx, cy, cz]
	center_point_loc_str = ' '.join([str(v) for v in center_point_loc])

	return '{%s} {%s} {%s}'%(view_16_str_1, view_16_str_2, center_point_loc_str)


# file_path = r'result.csv'
# print(create_view_16_by_csv(file_path))

calc_type = sys.argv[1]
file_path = sys.argv[2]

if calc_type.lower().strip() == 'csv_load':
	print(create_view_16_by_csv(file_path))

