

import tkinter
import tkinter.filedialog
import re
import os

tcl_path = '__temp2.tcl'

# 隐藏主窗口
tkobj = tkinter.Tk(); tkobj.withdraw()

# 获取文件
file_path = tkinter.filedialog.askopenfilename(filetypes = (('files',['*.*']),))


cmd_2d = 'xy load file=#file_path# subcase= "SUBCASE 1" ydatatype= "Stress (2D)" yrequestfilter= * yrequest= E#id# ycomponent= "XX (Z1)" - "ZX (Z1)" , "XX (Z2)" - "ZX (Z2)" xdatatype= Index'


# ===============================

cmd_plot_del = 'xy curve delete range= "p:all w:all i:all"'
# cmd_plot_create = re.sub('file\s*=.*?\sydatatype\s*=','file=#file_path# ydatatype=', cmd)

# cmd_plot_create = 'xy load file=#file_path# ydatatype= "Marker Displacement" yrequest= "REQ/10000007 Knuckle-left from Dummy_for_vehBody(Front Left Wheel Center Displacement)" , "REQ/70000087 Dummy_for_vehBody from Knuckle-right(Front Right Wheel Center Displacement)" , "REQ/10000010 Knuckle-right from Dummy_for_vehBody(Rear Right Wheel Center Displacements)" , "REQ/30101011 Coil spring-left on Strut tube (lwr strut)-left(Left Coil Spring Displacement)" , "REQ/30104110 Lwr control arm-right from Vehicle Body(Right jounce bumper disp)" ycomponent= DZ'

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


f = open(tcl_path, 'w')

element_ids = [680,693]
file_path = file_path.replace('\\\\', '/')

for element_id in element_ids:

	cmd_plot_create = cmd_2d.replace('#file_path#', file_path).replace('#id#', str(element_id))

	tcl_cmds = [
		f'# {file_path}',
		'hwc ' + cmd_plot_del,
		'hwc ' + cmd_plot_create,
		tcl_output_rpc.replace('#file_path#', file_path[:-4]+f'_E{element_id}.txt')
	]

	print('\n'.join(tcl_cmds))
	f.write('\n'.join(tcl_cmds)+'\n\n')


f.close()


