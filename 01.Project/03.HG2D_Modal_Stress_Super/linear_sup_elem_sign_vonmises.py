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


# 叠加计算
def linear_superposition(element_data, rpc_data):
    # print('element_data')
    # print(element_data)
    # print('rpc_data')
    # print(len(rpc_data))
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


# 带方向米塞斯应力计算-2D
def get_sign_vonmises_2d(ls_element_data, nlen):
    # 
    # 数据长度 nlen

    sign_vonmises_data = {}

    face_types = ['Z1', 'Z2']
    for name in ls_element_data:
        sign_vonmises_data[name] = {}

        for face_type in face_types:
            list1 = []
            for n in range(nlen):
                xy = ls_element_data[name][('XY',face_type)][n]
                xx = ls_element_data[name][('XX',face_type)][n]
                yy = ls_element_data[name][('YY',face_type)][n]

                p1 = (xx+yy)/2 + ( ((xx-yy)/2)**2 + xy**2 )**0.5
                p3 = (xx+yy)/2 - ( ((xx-yy)/2)**2 + xy**2 )**0.5
                if abs(p1) < abs(p3):
                    p1, p3 = p3, p1
                p2 = 0

                vonmises = (((p1-p2)**2+(p2-p3)**2+(p3-p1)**2)/2)**0.5

                if p1 < 0:
                    vonmises = -vonmises

                list1.append(vonmises)

            sign_vonmises_data[name][face_type] = list1

    return sign_vonmises_data


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



# 主函数
def sign_vonmises_cal(file_path, modal_channels, rpc_path, rpc_channels, csv_path):

    name2 = os.path.basename(rpc_path)
    # csv_path  = file_path+f'.{name2}.result.csv'
    csv_path = csv_path[:-4]+f'_{name2}.csv'

    
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

    # 计算带方向的米塞斯应力
    sign_vonmises_data = get_sign_vonmises_2d(ls_element_data, nlen)

    n_name = len(sign_vonmises_data.keys())

    # csv_path[:-4]+f'_{rpc_samplerate:0.0f}Hz.csv'
    f = open(csv_path, 'w')
    for name in sign_vonmises_data:
        f.write(f'{name}_SignVonMises(Z1),{name}_SignVonMises(Z2),')
    f.write('\n')

    for loc in range(nlen):
        for loc_name, name in enumerate(sign_vonmises_data):
            value_z1, value_z2 = sign_vonmises_data[name]['Z1'][loc], sign_vonmises_data[name]['Z2'][loc]
            if loc_name == n_name-1:
                f.write(f'{value_z1},{value_z2}')
            else:
                f.write(f'{value_z1},{value_z2},')
        f.write('\n')
    f.close()

    change_csv_to_rsp(csv_path, rpc_samplerate)


class ElemSignVonmisesUi(TkUi):

    def __init__(self, title, frame=None):
        super().__init__(title, frame=frame)

        self.frame_label_only({
            'label_text':'-------------\nSignVonmises应力\n-------------',
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
        csv_path = params['csv_path']

        if isinstance(ms_files, str): ms_files = [ms_files]

        for ms_file in ms_files:
            sign_vonmises_cal(ms_file, modal_channels, rpc_path, rpc_channels, csv_path)

        # print(sign_vonmises_data)

        self.print('计算完成')



if __name__=='__main__':
    
    ElemSignVonmisesUi('ELEM-SignVonmisesUi').run()
