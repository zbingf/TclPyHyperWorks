import os

"""
    <Channel>
      <!--  -->
      <!-- <tabfat id="1" type="Time Data">#rps_path#</tabfat> -->
      #Channel#
    </Channel>
    <FatigeEvents>
      #FatigeEvents#
      <Event Configuration="superposition" Gate="0" id="1" name="xml_run_1">
      	<!-- block  -->
      	<!-- tabfatId req file ID -->
      	<!-- subcase  -->
        <Fatload LDM="1" Offset="0" Scale="1" block="4" resultfile="" sim="1" subcase="1" tabfatId="1" tabfatName=""></Fatload>
        <Fatload LDM="1" Offset="0" Scale="1" block="5" resultfile="" sim="2" subcase="1" tabfatId="1" tabfatName=""></Fatload>
        <Fatload LDM="1" Offset="0" Scale="1" block="6" resultfile="" sim="3" subcase="1" tabfatId="1" tabfatName=""></Fatload>
      </Event>

      <Event Configuration="superposition" Gate="0" id="2" name="xml_run_2">
        <Fatload LDM="1" Offset="0" Scale="1" block="7" resultfile="" sim="1" subcase="1" tabfatId="2" tabfatName=""></Fatload>
        <Fatload LDM="1" Offset="0" Scale="1" block="8" resultfile="" sim="2" subcase="1" tabfatId="2" tabfatName=""></Fatload>
        <Fatload LDM="1" Offset="0" Scale="1" block="9" resultfile="" sim="3" subcase="1" tabfatId="2" tabfatName=""></Fatload>
      </Event>

    </FatigeEvents>
"""

LOADCASE_SUM = """
BeginDerivedSubcase : #BeginDerivedSubcase#
    Format = basic
    Title = #title#
	#simulations#
EndDerivedSubcase
#######################
"""


LOADCASE_SIMULATION = """
    BeginSimulation : #BeginSimulation#
        subcase = #subcase#
        simulation = #simulation#
        scale = 1
    EndSimulation
"""


# rsp ID, rsp path
TABFAT_SINGLE = '<tabfat id="{}" type="Time Data">{}</tabfat>\n'
EVENT_START = '<Event Configuration="superposition" Gate="0" id="{}" name="{}">\n'
EVENT_END = '</Event>\n'
# 通道, sim id , 工况, rsp ID
FATLOAD_SINGLE = '<Fatload LDM="1" Offset="0" Scale="1" block="{}" resultfile="" sim="{}" subcase="{}" tabfatId="{}" tabfatName=""></Fatload>\n'

# 批量替换
def str_replaces(line, list_a, list_b):
	# list_a ['#BeginSimulation#', '#subcase#', '#simulation#']
	# list_b [begin_n, subcase, simulation]

	for a, b in zip(list_a, list_b):
		if not isinstance(b, str):
			b = str(b)
		line = line.replace(a,b)
	return line


# 文件读取
def file_read(file_path):
	with open(file_path, 'r') as f:
		file_str = f.read()

	return file_str


# loadcase 文件 cfg生成
def flexbody_loadcase_create(cfg_path, mode_ranges, subcase_id, simulation_add=1, cur_loadcase_start_zero=1000):

	loadcase_sims = []
	begin_ns = []
	mode_ns = []
	for begin_n, n in enumerate(range(mode_ranges[0], mode_ranges[1]+1)):

		subcase = subcase_id
		simulation = n+simulation_add
		begin_n += 1
		single_n = LOADCASE_SIMULATION
		single_n = str_replaces(single_n, ['#BeginSimulation#', '#subcase#', '#simulation#'], [begin_n, subcase, simulation])
		loadcase_sims.append(single_n)
		begin_ns.append(begin_n)
		mode_ns.append(n)

	title = 'flexbody'
	cur_loadcase_id = cur_loadcase_start_zero+1

	loadcase_str = LOADCASE_SUM
	loadcase_str = str_replaces(loadcase_str, ['#BeginDerivedSubcase#', '#title#', '#simulations#'], 
		[cur_loadcase_id, title, ''.join(loadcase_sims)])


	with open(cfg_path, 'w') as f:
		f.write(loadcase_str)

	return begin_ns, mode_ns, cur_loadcase_id


# rsp数据导入
def tabfat_set(rsp_id, rsp_path):

	return TABFAT_SINGLE.format(rsp_id, rsp_path)


# 通道匹配
def fatload_set(rsp_id, sim_id, new_subcase_id, channel_id):
	
	return FATLOAD_SINGLE.format(channel_id, sim_id, new_subcase_id, rsp_id)


def event_set(event_id, event_name, event_strs):
	# 
	# event_strs : fatload_list 个通道匹配 list
	# 
	event_str = EVENT_START.format(event_id, event_name)

	event_set_str = event_str + ''.join(event_strs) + EVENT_END

	return event_set_str



if __name__=='__main__':


	# file_path = r'C:\Users\zheng.bingfeng\Downloads\hyperlife_xml_edit_07\hyperlife_tpl_v01.xml'
	# new_file_path = r'C:\Users\zheng.bingfeng\Downloads\hyperlife_xml_edit_07\hyperlife_auto.xml'
	# cfg_path = r'C:\Users\zheng.bingfeng\Downloads\hyperlife_xml_edit_07\hyperlife_v01.cfg'


	file_dir = os.path.dirname(__file__) 
	tpl_path = os.path.join(file_dir, 'hyperlife_tpl_v01.xml')
	run_path = os.path.join(file_dir, 'hyperlife_auto.xml')
	cfg_path = os.path.join(file_dir, 'hyperlife_v01.cfg')
	# print(tpl_path)
	# print(run_path)
	# print(cfg_path)



	rsp_path = r'D:/04_FastCalc/K9MD_HyperLife/Q_1.rsp'
	rsp_paths = [rsp_path]

	model_path = r'E:/00_program/K9MD_Q4/K9MD_dw0353_Static_rev01_211220_modal_superposion.h3d'
	result_path = model_path

	mode_ranges = [7, 204]
	channel_ranges = [1, 198]
	subcase_id = 100
	cur_loadcase_start_zero=1000

	# simulation id 偏置
	simulation_add=1


	print('--start--')

	# cfg 文件生成
	begin_ns, mode_ns, cur_loadcase_id = flexbody_loadcase_create(cfg_path, mode_ranges, subcase_id, simulation_add=simulation_add, cur_loadcase_start_zero=cur_loadcase_start_zero)

	# rsp 文件加载
	tabfat_str = ''.join([tabfat_set(n+1, rsp_path) for n, rsp_path_n in enumerate(rsp_paths)])

	# load map 设置
	for n, rsp_path_n in enumerate(rsp_paths):
		rsp_id = n+1
		event_id = n+1
		event_name = 'event_auto_{}_{}'.format(event_id, os.path.basename(rsp_path_n)[:-4])
		fatload_list = []
		event_list = []

		cur_loadcase_ids = [id_n+cur_loadcase_start_zero for id_n in range(mode_ranges[0], mode_ranges[1]+1)]

		for begin_n, channel_n in zip(begin_ns, range(channel_ranges[0], channel_ranges[1]+1)):

			fatload_list.append(fatload_set(rsp_id, begin_n, cur_loadcase_id, channel_n))

		fatload_str = ''.join(fatload_list)

		event_list.append(event_set(event_id, event_name, fatload_list))

	event_str = ''.join(event_list)



	# 模板 xml替换生成新的 run xml
	file_str = file_read(tpl_path)
	for a, b in zip(['#ModelFile#', '#ResultFile#', '#DerivedLoadcase#', '#Channel#', '#FatigeEvents#'],
		[model_path.replace('\\','/'), result_path.replace('\\','/'), cfg_path.replace('\\','/'), tabfat_str, event_str]):
		file_str = file_str.replace(a, b)


	with open(run_path, 'w') as f:
		f.write(file_str)


	print('--end--')

