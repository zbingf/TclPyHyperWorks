
import os

def search_recalc_fems(root):
	recalc_fems = []

	h3ds,fems,fem2dir = [], [], {}
	for dirpath, dirnames, filenames in os.walk(root):
		for filename in filenames:
			if filename[-4:] == '.h3d':
				h3ds.append(filename[:-4])
			elif filename[-4:] == '.fem':
				fem = filename[:-4]
				fems.append(fem)
				fem2dir[fem] = (dirpath)

	for fem in fems:
		if fem not in h3ds:
			if '\\03_autocalc\\' in fem2dir[fem]:
				print(fem2dir[fem])
				recalc_fems.append(fem2dir[fem]+'.fem')

	return recalc_fems

if __name__ == '__main__':
	root = r'D:\04_FastCalc\fatigue_new_damper'
	search_recalc_fems(root)