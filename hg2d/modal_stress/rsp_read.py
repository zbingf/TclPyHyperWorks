import re, math, sys, os, struct, abc, copy, time
import logging, os.path



class ReusltData(abc.ABC):

    def __init__(self): 
        self.name            = None
        self.file_path       = None
        self.data_original   = None
        self.select_channels = None
        self.line_ranges     = None
        self.titles          = None
        self.samplerate      = None
        self.data_func       = None

    @abc.abstractmethod
    def read_file(self): pass  # 读取文件

    @abc.abstractmethod
    def get_samplerate(self): return self.samplerate # 采样频率获取

    def get_data(self): # 获取数据

        # ==============================
        select_channels = self.select_channels
        line_ranges     = self.line_ranges
        data_original   = self.data_original
        data_func       = self.data_func
        # ==============================
        new_data = []
        if line_ranges==None: line_ranges = [None, None]
        if select_channels==None: select_channels = list(range(len(data_original)))

        assert isinstance(line_ranges, list)
        assert isinstance(select_channels, list)

        # for n, line in enumerate(data_original):
        #     if n in select_channels:
        #         new_data.append(line[line_ranges[0] : line_ranges[1]])

        for n in select_channels: # 通道截取
            assert n<len(data_original), 'channels selected is error' # 通道截取错误
            new_data.append(data_original[n][ line_ranges[0] : line_ranges[1] ])

        # ==============================
        self.line_ranges    = line_ranges
        # self.data_original  = data_original
        # ==============================
        if data_func != None: # 函数编辑
            new_data = copy.deepcopy(new_data)
            new_data = data_func(new_data)

        return new_data

    def set_data_func(self, func=None): self.data_func = func

    def set_select_channels(self, list1d): # 通道截取
        self.select_channels = list1d
        return None

    def set_line_ranges(self, list1d): # 数据截取区间
        self.line_ranges = list1d
        return None

    def get_select_channels(self, list1d): return self.select_channels

    def get_line_ranges(self): return self.line_ranges

    def get_titles(self): 
        # ==============================
        select_channels = self.select_channels
        titles = self.titles
        # ==============================
        if select_channels == None:
            return titles
        else:
            return [titles[n] for n in select_channels]

    def save_csv_data(self, file_path, data=None):  # 数据转存位CsvFile
        """ 数据保存到csv文件中"""

        # ==============================
        if data == None:
            data   = copy.copy(self.get_data())
        else:
            data   = copy.copy(data)

        titles     = copy.copy(self.get_titles())
        samplerate = self.get_samplerate()
        # ==============================

        time_line = [ n / samplerate for n in range(len(data[0])) ]
        data.insert(0, time_line)
        titles.insert(0, 'time(s)')

        f = open(file_path, 'w')
        f.write(','.join(titles) + '\n')
        for row in range(len(data[0])):
            for col in range(len(data)):
                f.write(str(data[col][row]) + ',')
            f.write('\n')

        f.close()

        return None



class RpcFile(ReusltData):

    def __init__(self, file_path, name=None): 
        super().__init__()
        self.file_path = file_path
        self.name      = name
        self.title_dic = None

    def read_file(self): 
        # ==============================
        file_path = self.file_path
        # ==============================

        file_path = os.path.abspath(file_path)
        # 判定文件是否存在
        if not(os.path.isfile(file_path)): 
            print('RPC File " %s " Not Found' %file_path)
            return
        
        # 读取开头数据
        file   = open(file_path,'rb')
        r = file.read(512)

        num =  len(r)//128
        dic    = {}
        for i in range(num):
            s = i*128
            e = s + 32
            key = r[s:e]
            key = key.replace(b'\x00',b'').decode()
            if key != '' : 
                v = e+96
                value = r[e:v]
                value = value.replace(b'\x00',b'').decode()
                dic[key] = value

        numHeader = int(dic['NUM_HEADER_BLOCKS'])

        r = file.read(512*(numHeader-1))
        num = len(r)//128 
        for i in range(num):
            s = i*128
            e = s + 32
            key = r[s:e]
            key = key.replace(b'\x00',b'').decode()
            if key != '' : 
                v = e+96
                value = r[e:v]
                value = value.replace(b'\x00',b'').decode()
                dic[key] = value

        # 开头数据解析
        # print(dic)
        # 通道数
        n_channel = int(dic['CHANNELS']) 
        # 通道名称
        name_channels = [ dic['DESC.CHAN_{}'.format(n+1)] for n in range(n_channel)]
        # print(name_channels)
        # SCALE 系数
        scales = [ float(dic['SCALE.CHAN_{}'.format(n+1)]) for n in range(n_channel)]
        # print(scales)
        # frame数
        n_frame = int(dic['FRAMES'])
        frame = int(dic['PTS_PER_FRAME'])
        n_half_frame = int(dic['HALF_FRAMES'])
        n_frame += n_half_frame
        # print(n_half_frame)
        # group
        group = int(dic['PTS_PER_GROUP'])
        n_group = max(1, int(frame*n_frame//group))
        # print(frame*n_frame,group,n_group)
        if frame*n_frame > n_group*group:
            n_group +=1

        # 数据段读取并解析
        data_list = [ [] for n in range(n_channel) ]

        for n_g in range(n_group):
            for num in range(n_channel):
                cal_n = group
                if n_g == n_group-1:
                    # 最后一段数据读取 , 并不一定完整解析
                    if frame*n_frame < group*n_group:
                        cal_n = frame*n_frame - group*(n_group-1)

                r = file.read(group*2)
                data_raw = struct.unpack('h'*int(group),r)
                for n,temp1 in zip(data_raw,range(cal_n)):
                    data_list[num].append(n*scales[num])

        # data_list 各同道数据

        # 关闭文档
        file.close()

        # ==============================
        self.data_original = data_list
        self.title_dic     = dic
        self.titles        = name_channels
        self.samplerate    = 1 / float(dic['DELTA_T'])
        # ==============================

        return None

    def get_samplerate(self): return self.samplerate

    def set_reqs_comps(self, reqs, comps): return None



def test_RspFile():




    file_path = r'event_Altoonal_6_out.rsp'

    rpc_obj = RpcFile(file_path, 'test')

    rpc_obj.read_file()
    rpc_obj.set_select_channels([0,1,2])
    rpc_obj.set_line_ranges([2,10])

    data = rpc_obj.get_data()
    titles = rpc_obj.get_titles()
    samplerate = rpc_obj.get_samplerate()
    # print(data)
    # print(titles)
    # print(samplerate)

    print(data)
    print(titles)

    return None


if __name__ == '__main__':
	test_RspFile()