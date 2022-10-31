
contour_plot = """
result scalar legend values levelvalue="1 0"
result scalar legend values levelvalue="2 100"
result scalar legend values levelvalue="3 200"
result scalar legend values levelvalue="4 300"
result scalar legend values levelvalue="5 400"
result scalar legend values levelvalue="6 500"
result scalar legend values levelvalue="7 550"
result scalar legend values levelvalue="8 600"
result scalar legend values levelvalue="9 700"
result scalar legend values levelvalue="10 750"
"""

animate_output = """
animate frame {}
save image window {}
"""

def str_single_print(num, png_path):
	return animate_output.format(num, png_path)


def str_single_prints(nums, png_paths):
	
	return '\n'.join([str_single_print(num, png_path) \
				for num, png_path in zip(nums, png_paths)])


import os.path
png_dir = r'D:\temp\temp'

path_num = lambda file_dir, name, file_type, num: \
		[os.path.join(png_dir, f'{name}_{n+1}.{file_type}') for n in range(num)]

png_paths = path_num(png_dir, 'fig', 'png', 10)

cmd_png_paths = str_single_prints(range(1,11), png_paths)


with open('test_hwc.hwc', 'w') as f:
	f.write(contour_plot)
	f.write(cmd_png_paths)

