

import tkinter
import tkinter.filedialog
import re
import os

tcl_path = '__temp.tcl'

# 隐藏主窗口
tkobj = tkinter.Tk(); tkobj.withdraw()

# 获取文件
file_paths = tkinter.filedialog.askopenfilenames(filetypes = (('abf files',['*.abf']),))


cmd = 'xy load file= D:/github/TclPyHyperWorks/hg2d/abf_file/event_Altoonal_6.abf ydatatype= "Marker Displacement" yrequest= "REQ/10000007 Knuckle-left from Dummy_for_vehBody(Front Left Wheel Center Displacement)" , "REQ/70000087 Dummy_for_vehBody from Knuckle-right(Front Right Wheel Center Displacement)" , "REQ/10000010 Knuckle-right from Dummy_for_vehBody(Rear Right Wheel Center Displacements)" , "REQ/30101011 Coil spring-left on Strut tube (lwr strut)-left(Left Coil Spring Displacement)" , "REQ/30104110 Lwr control arm-right from Vehicle Body(Right jounce bumper disp)" ycomponent= DZ'


# ===============================

cmd_plot_del = 'xy curve delete range= "p:all w:all i:all"'
cmd_plot_create = re.sub('file\s*=.*?\sydatatype\s*=','file=#file_path# ydatatype=', cmd)
# cmd_plot_create = 'xy load file=#file_path# ydatatype= "Marker Displacement" yrequest= "REQ/10000007 Knuckle-left from Dummy_for_vehBody(Front Left Wheel Center Displacement)" , "REQ/70000087 Dummy_for_vehBody from Knuckle-right(Front Right Wheel Center Displacement)" , "REQ/10000010 Knuckle-right from Dummy_for_vehBody(Rear Right Wheel Center Displacements)" , "REQ/30101011 Coil spring-left on Strut tube (lwr strut)-left(Left Coil Spring Displacement)" , "REQ/30104110 Lwr control arm-right from Vehicle Body(Right jounce bumper disp)" ycomponent= DZ'

tcl_output_rpc = """
hwi GetSessionHandle sess;
sess GetClientManagerHandle pm Plot;
pm GetExportCtrlHandle ex
ex SetFormat “RPC”
ex SetFilename "#file_path#"
ex GetFilename
ex Export
hwi CloseStack
"""


f = open(tcl_path, 'w')

for file_path in file_paths:

	file_path = file_path.replace('\\\\', '/')

	tcl_cmds = [
		f'# {file_path}',
		'hwc ' + cmd_plot_del,
		'hwc ' + cmd_plot_create.replace('#file_path#', file_path),
		tcl_output_rpc.replace('#file_path#', file_path[:-4]+'_out.rsp')
	]

	print('\n'.join(tcl_cmds))
	f.write('\n'.join(tcl_cmds)+'\n\n')


f.close()





