"""
	模态应力导出
	单元element数据导出
"""


import tkinter
import tkinter.filedialog
import re
import os

tcl_path = '__temp.txt'
cmd_path = 'modal_stress_tcl.txt'

# 隐藏主窗口
tkobj = tkinter.Tk(); tkobj.withdraw()

# 获取文件
file_path = tkinter.filedialog.askopenfilename(filetypes = (('files',['*.*']),))



# ===============================
# 命令
# with open(cmd_path, 'r') as f:
# 	cmd_str = f.read()



cmd_plot_del = 'xy curve delete range= "p:all w:all i:all"'
cmd_plot_create1 = 'xy load file=#file_path# subcase= "SUBCASE 1" ydatatype= "Stress (2D)" yrequest= E#id# ycomponent= "XX (Z1)" - "ZX (Z1)" xdatatype= Frequency'
cmd_plot_create2 = 'xy load file=#file_path# subcase= "SUBCASE 1" ydatatype= "Stress (2D)" yrequest= E#id# ycomponent= "XX (Z2)" - "ZX (Z2)" xdatatype= Frequency'
# cmd_plot_create = 'xy load file=#file_path# subcase= "SUBCASE 1" ydatatype= "Stress (2D)" yrequest= E#id# ycomponent= "XX (Z1)" , "YY (Z1)", "ZZ (Z1)" , "XY (Z1)", "YZ (Z1)" , "ZX (Z1)" , "XX (Z2)" , "YY (Z2)", "ZZ (Z2)" , "XY (Z2)", "YZ (Z2)" , "ZX (Z2)"  xdatatype= Frequency'

# xy load file=D:/00_CAE_project/202111_01_modal_stress_read/lca_flexbody_50.op2 subcase= "SUBCASE 1" ydatatype= "Stress (2D)" yrequest= E680 ycomponent= "XX (Z2)" - "ZX (Z2)" xdatatype= Frequency

tcl_output_rpc = """
hwi GetSessionHandle sess;
sess GetClientManagerHandle pm Plot;
pm GetExportCtrlHandle ex
ex SetFormat "xy data"
ex SetFilename "#file_path#"
ex GetFilename
ex Export
hwi CloseStack
"""

element_ids = [680, 693]


f = open(tcl_path, 'w')
file_path = file_path.replace('\\\\', '/')

for element_id in element_ids:
	# print(element_id)
	tcl_cmds = [
		f'# {file_path}',
		'hwc ' + cmd_plot_del,
		'hwc ' + cmd_plot_create1.replace('#file_path#', file_path).replace('#id#', str(element_id)),
		'hwc ' + cmd_plot_create2.replace('#file_path#', file_path).replace('#id#', str(element_id)),
		tcl_output_rpc.replace('#file_path#', file_path[:-4]+f'_E{element_id}.txt')
	]

	print('\n'.join(tcl_cmds))
	f.write('\n'.join(tcl_cmds)+'\n\n')


f.close()


os.popen(tcl_path)


