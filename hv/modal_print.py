


animate_output = """
animate mode transient
animate frame {}
animate mode modal
save animation page {}
"""

def str_single_print(num, gif_path):
	return animate_output.format(num, gif_path)


def str_single_prints(nums, gif_paths):
	
	return '\n'.join([str_single_print(num, gif_path) \
				for num, gif_path in zip(nums, gif_paths)])


import os.path
png_dir = r'D:\temp\temp'

path_num = lambda file_dir, name, file_type, num: \
		os.path.join(png_dir, f'{name}_{num}.{file_type}')

n_start = 7
n_end   = 271


gif_paths = [path_num(png_dir, 'fig', 'gif', n)  for n in range(n_start, n_end)]

# gif_paths = path_num(png_dir, 'fig', 'gif', 10)

cmd_gif_paths = str_single_prints(
	range(n_start+1,n_end+1), 
	gif_paths)


with open( os.path.join(png_dir, 'test_hwc.hwc') , 'w') as f:
	f.write(cmd_gif_paths)

