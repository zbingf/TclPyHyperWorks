"""
    XY_data读取 及 数据处理
    线性叠加应力,求解SignVonmises
    
"""

import tk_ui
TkUi = tk_ui.TkUi

import rsp_read
RpcFile = rsp_read.RpcFile

import re
import os
import os.path
import copy

import shell_angle_x

import pprint

calc_shell_angle = shell_angle_x.calc_shell_angle
change_stress = shell_angle_x.change_stress
change_strain = shell_angle_x.change_strain
csv_elem_vs = shell_angle_x.csv_elem_vs


# 带方向米塞斯应力计算-2D
def get_vchange_xx_stress(ls_element_data, nlen, thetas):
    # 
    # 数据长度 nlen

    vchange_xx_data = {}
    vchange_xx_data_strain = {}

    face_types = ['Z1', 'Z2']
    for name in ls_element_data:

        theta = thetas[name[1:]]
        vchange_xx_data[name] = {}
        vchange_xx_data_strain[name] = {}

        for face_type in face_types:
            list1 = []
            list_strain = []
            for n in range(nlen):
                xy = ls_element_data[name][('XY',face_type)][n]
                xx = ls_element_data[name][('XX',face_type)][n]
                yy = ls_element_data[name][('YY',face_type)][n]

                new_xx = change_stress(xx, yy, xy, theta) #2.5/180*3.141592654
                new_xx_strain = change_strain(xx, yy, xy, theta, 210000, 0.3) 
                # print(xx, new_xx) 
                
                list1.append(new_xx)
                list_strain.append(new_xx_strain)

            vchange_xx_data[name][face_type] = list1
            vchange_xx_data_strain[name][face_type] = list_strain

    return vchange_xx_data, vchange_xx_data_strain


def xy_data_read(file_path):

    with open(file_path, 'r') as f:
        lines = [line for line in f.read().split('\n') if line]

    element_data = {}
    # loc = 1
    for line in lines:

        if "XYDATA" in line.upper():
            "XYDATA, XX(Z1)"
            obj1 = re.match('XYDATA\s*,\s*(\S+)\s*\((\S+)\).*', line)
            if obj1:
                groups = obj1.groups()
                data_type, surface = groups
                name = 'None'

            "XYDATA, E18748 - XX(Z1)"
            obj2 = re.match(r'XYDATA\s*,\s*(\S+)\s*-\s*(\S+)\s*\((\S+)\).*', line)
            if obj2:
                groups = obj2.groups()
                name, data_type, surface = groups

            if name not in element_data:
                element_data[name] = {}

            element_data[name][(data_type,surface)] = []
            continue

        if "ENDATA" in line.upper():
            continue

        value = float([value for value in line.split(' ') if value][-1])
        element_data[name][(data_type,surface)].append(value)

    return element_data


def get_target_modal_channel(element_data, channels):

    new_element_data = {}
    for name in element_data:
        new_element_data[name] = {}
        for key in element_data[name]:
            list1 = element_data[name][key]
            if channels[1] == None:
                end_modal = len(list1)
            else:
                end_modal = channels[1]+1

            new_element_data[name][key] = [list1[channel] for channel in range(channels[0],end_modal)]
    
    return new_element_data


def single_gauge(elem_id, topbottom, ori_str, angleoffset=0):

    single_gauge = '<StrainGauge AngleOffset="#angleoffset#" ID="Gauge_#elem_id#_#Z#" Location="#elem_id#" LocationType="ElementCentroid" Orientation="#ori_str#" ResultsFrom="OneSurface" ShellSurface="#topbottom#" Type="Single"/>'

    single_gauge = single_gauge.replace('#elem_id#', elem_id)
    if topbottom == "Top":
        single_gauge = single_gauge.replace('#Z#', 'Z2')
    else:
        single_gauge = single_gauge.replace('#Z#', 'Z1')

    single_gauge = single_gauge.replace('#topbottom#', topbottom)
    single_gauge = single_gauge.replace('#ori_str#', ori_str)
    single_gauge = single_gauge.replace('#angleoffset#', str(angleoffset))

    return single_gauge

def asg_xx_create(records, thetas_deg):
    # 根据数据创建XX方向的矢量测点
    list1 = []
    for elem_id in records:
        ori_str = ','.join([str(n) for n in records[elem_id]['V_x']['1']])
        angleoffset = thetas_deg[elem_id]
        line1 = single_gauge(elem_id, "Bottom", ori_str, 360-angleoffset)
        line2 = single_gauge(elem_id, "Top", ori_str, angleoffset)
        list1.append(line1)
        list1.append(line2)

    f = open('__xx.asg', 'w') 
    f.write('<Gauges>\n')
    for line in list1:
        f.write(line)
        f.write('\n')
    f.write('</Gauges>')

# 叠加计算
def linear_superposition(element_data, rpc_data):

    ls_element_data = {}
    nlen = len(rpc_data[0])
    for name in element_data:
        ls_element_data[name] = {}
        for key in element_data[name]:
            list1 = []
            for n_line in range(nlen): # 时域点位置
                value = 0
                for n_modal in range(len(rpc_data)):
                    value += element_data[name][key][n_modal]*rpc_data[n_modal][n_line]
                list1.append(value)

            ls_element_data[name][key] = list1

    return ls_element_data, nlen

def result_csv_write(csv_path, stress_data, nlen, isStress=True):

    # 数据写入
    n_name = len(stress_data.keys())
    f = open(csv_path, 'w')

    for n, name in enumerate(stress_data):
        if n == n_name-1:
            if isStress:
                f.write(f'{name}_VxxStress(Z1),{name}_VxxStress(Z2)')
            else:
                f.write(f'{name}_VxxStrain(Z1),{name}_VxxStrain(Z2)')
        else:
            if isStress:
                f.write(f'{name}_VxxStress(Z1),{name}_VxxStress(Z2),')
            else:
                f.write(f'{name}_VxxStrain(Z1),{name}_VxxStrain(Z2),')

    f.write('\n')
    
    for loc in range(nlen):
        # f.write( str(loc/rpc_samplerate) +',')
        for n, name in enumerate(stress_data):
            value_z1, value_z2 = stress_data[name]['Z1'][loc], stress_data[name]['Z2'][loc]
            if n == n_name-1:
                f.write(f'{value_z1},{value_z2}')
            else:
                f.write(f'{value_z1},{value_z2},')

        f.write('\n')
    f.close()



# 主函数
def vchange_xx_stress_cal(file_path, modal_channels, rpc_path, rpc_channels, v_path, fem_path, csv_path):

    name2 = os.path.basename(rpc_path)
    # csv_path  = file_path+f'.{name2}.result.csv'

    target_elem_ids, target_vs = csv_elem_vs(v_path)
    thetas, thetas_deg, records = calc_shell_angle(fem_path, target_elem_ids, target_vs)
    asg_xx_create(records, thetas_deg)
    # print(thetas_deg, records)
    # rsp数据
    rpc_obj = RpcFile(rpc_path, 'test')
    rpc_obj.read_file()
    rpc_obj.set_select_channels(rpc_channels)
    rpc_data = [copy.deepcopy(line) for line in rpc_obj.get_data()]
    rpc_samplerate = rpc_obj.get_samplerate()

    element_data = xy_data_read(file_path)

    # 模态通道选择
    if modal_channels != None:
        if isinstance(modal_channels[0], int):
            start_modal = modal_channels[0]
        else:
            start_modal = 0

        if isinstance(modal_channels[1], int):
            end_modal = modal_channels[1]
        else:
            end_modal = None

        modal_channels = [start_modal, end_modal]
        new_element_data = get_target_modal_channel(element_data, modal_channels)
    else:
        new_element_data = element_data

    # print(new_element_data)

    # 线性叠加 数据
    ls_element_data, nlen = linear_superposition(new_element_data, rpc_data)

    # 计算应力
    # print(thetas)
    stress_data, strain_data = get_vchange_xx_stress(ls_element_data, nlen, thetas)
    # stress_data = strain_data
    stress_path = csv_path[:-4]+'_stress.csv'
    strain_path = csv_path[:-4]+'_strain.csv'
    result_csv_write(stress_path, stress_data, nlen, isStress=True)
    result_csv_write(strain_path, strain_data, nlen, isStress=False)
    change_csv_to_rsp(stress_path, rpc_samplerate)
    change_csv_to_rsp(strain_path, rpc_samplerate)

    record_to_tcl(records, '__test.tcl')
    pprint.pprint(records)
    
    return None


def record_to_tcl(records, tcl_path):
    # record = {
    #         'V_x'： {'0':center, '1':v_one(B_startx)},
    #         'V_s': {'0':center, '1':v_one(P1_velem)},
    #         'V_t': {'0':center, '1':v_one(t_v)},
    #         'theta': -theta,
    #     }

    str_tcl = """
    hm_entityrecorder nodes on
        *createnode $loc1 0 0 0
    hm_entityrecorder nodes off
    set node_id [hm_entityrecorder nodes ids]
    *createmark nodes 1 $node_id

    *vectorcreate 1 $loc2 0

    """

    str_tcl2 = """
    *createmark elements 1 $elems
    *numbersmark elements 1 1
    """

    f = open(tcl_path, 'w')

    for num in records:
        record = records[num]
        for v in record:
            if 'V_' in v:
                s1 = str_tcl.replace('$loc1', 
                    ' '.join([str(n) for n in record[v]['0']])
                    )
                s2 = s1.replace('$loc2', 
                    ' '.join([str(n) for n in record[v]['1']])
                    )
                f.write(s2)
                f.write('\n')
    
    f.write(str_tcl2.replace('$elems', ' '.join(list(records.keys()))))

    f.close()
    return None


def change_csv_to_rsp(csv_path, samplerate):

    ATS_RSP = """<AsciiTranslateSetup>
       <Version>1</Version>
       <ConvertTo>1</ConvertTo>
       <CreateLogFile>0</CreateLogFile>
       <NumberOfHeaderLines>1</NumberOfHeaderLines>
       <NumberOfChannels>-1</NumberOfChannels>
       <LineNumberForChannelTitles>1</LineNumberForChannelTitles>
       <LineNumberForUnits>0</LineNumberForUnits>
       <TabSeparated>0</TabSeparated>
       <CommaSeparated>1</CommaSeparated>
       <SpaceSeparated>0</SpaceSeparated>
       <SemiColonSeparated>0</SemiColonSeparated>
       <FixedWidth>0</FixedWidth>
       <DecimalCharacter>1</DecimalCharacter>
       <IncludeExclude>0</IncludeExclude>
       <ColumnList></ColumnList>
       <HeaderToMetadata>0</HeaderToMetadata>
       <AutoDetectSampleRate>0</AutoDetectSampleRate>
       <SampleRate>#SampleRate#</SampleRate>
       <XaxisBase>0</XaxisBase>
       <XaxisTitle>Time</XaxisTitle>
       <XaxisUnits>Seconds</XaxisUnits>
       <OutputNamingMethod>2</OutputNamingMethod>
       <OutputTestName>temp</OutputTestName>
       <OutputNamingText></OutputNamingText>
       <OutputFormat>3</OutputFormat>
    </AsciiTranslateSetup>
    """

    ats_path = 'RSP_1V1.ats'
    with open(ats_path, 'w') as f:
        f.write(ATS_RSP.replace('#SampleRate#', str(samplerate)))
    ats_path = os.path.abspath(ats_path)

    str_cmd = 'asciitranslate.exe /inp="{}" /conv="TimeSeries" /SetupFile="{}" /prog=1'.format(csv_path, ats_path)

    with open('test.bat', 'w') as f:
        f.write(str_cmd)
    os.system('test.bat')
    
    os.remove('test.bat')
    os.remove(ats_path)

    return None


class ElemVxxStressUi(TkUi):

    def __init__(self, title, frame=None):
        super().__init__(title, frame=frame)

        self.frame_label_only({
            'label_text':'-------------\n指定应变方向应力\n-------------',
            'label_width':15,
            })

        self.frame_loadpaths({
            'frame':'ms_files', 'var_name':'ms_files', 'path_name':'modal stress XY-DATA',
            'path_type':'.*', 'button_name':'Modal Stress XY-DATA\n文件读取\nH3D应力结果',
            'button_width':30, 'entry_width':40,
            })


        self.frame_entry({
            'frame':'modal_channels', 'var_name':'modal_channels', 'label_text':'modal_channels\nRange[截断范围]\neg:7,None\nH3D起始0阶故直接填写阶数范围',
            'label_width':30, 'entry_width':40,
            })

        self.frame_loadpath({
            'frame':'rpc_path', 'var_name':'rpc_path', 'path_name':'rpc_path',
            'path_type':'.*', 'button_name':'rpc_path\n[模态坐标]',
            'button_width':30, 'entry_width':40,
            })

        self.frame_loadpath({
            'frame':'v_path', 'var_name':'v_path', 'path_name':'v_path',
            'path_type':'.*', 'button_name':'v_path\n[应变方向设置]',
            'button_width':30, 'entry_width':40,
            })

        self.frame_loadpath({
            'frame':'fem_path', 'var_name':'fem_path', 'path_name':'fem_path',
            'path_type':'.*', 'button_name':'fem_path\n[应变方向设置]\nfem文件路径',
            'button_width':30, 'entry_width':40,
            })

        self.frame_entry({
            'frame':'rpc_channels', 'var_name':'rpc_channels', 'label_text':'rpc_channels\neg: None or 7,8,9\n起始0位',
            'label_width':30, 'entry_width':30,
            })

        self.frame_savepath({
            'frame':'csv_path', 'var_name':'csv_path', 'path_name':'csv_path',
            'path_type':'.csv', 'button_name':'csv_path\n[输出结果]\n充当前缀',
            'button_width':30, 'entry_width':40,
            })

        self.frame_buttons_RWR({
            'frame' : 'rrw',
            'button_run_name' : '运行',
            'button_write_name' : '保存',
            'button_read_name' : '读取',
            'button_width' : 15,
            'func_run' : self.fun_run,
            })

        self.frame_note()

        self.vars['modal_channels'].set('None')
        self.vars['rpc_channels'].set('None')

    def fun_run(self):

        self.print('开始计算')
        params = self.get_vars_and_texts()

        ms_files = params['ms_files']
        rpc_path = params['rpc_path']
        modal_channels = params['modal_channels']
        rpc_channels   = params['rpc_channels']
        v_path = params['v_path']
        fem_path = params['fem_path']
        csv_path = params['csv_path']

        if isinstance(ms_files, str): ms_files = [ms_files]

        for ms_file in ms_files:
            vchange_xx_stress_cal(ms_file, modal_channels, rpc_path, rpc_channels, v_path, fem_path, csv_path)

        # print(stress_data)

        self.print('计算完成')




if __name__=='__main__':
    
    ElemVxxStressUi('ELEM-VxxStressUi').run()
