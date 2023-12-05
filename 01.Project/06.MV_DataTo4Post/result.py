"""
    后处理文件
        + 解析
        + 处理

"""

# 标准库
import re, math, sys, os, struct, abc, copy, time
import logging, os.path
import pprint


# # 自建库
# from pyadams import datacal
# from pyadams.datacal import plot, tscal
# from pyadams.file import file_edit, office_docx


# ----------
logger = logging.getLogger('result')
logger.setLevel(logging.DEBUG)
is_debug = True


# ==============================
# 子函数
str_lower_strip = lambda str1: re.sub(r'\s','',str1).lower() # 去空格,小写化
# list2_change_rc = datacal.list2_change_rc
# value2str_list2 = datacal.value2str_list2
# cal_max         = tscal.cal_max
# cal_min         = tscal.cal_min
# cal_pdi         = tscal.cal_pdi
# cal_rms         = tscal.cal_rms
# cal_rainflow_pdi= tscal.cal_rainflow_pdi
# ==============================


# ==============================

class BaseResultFile(abc.ABC):
    """
        后处理数据读取
    """
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


class ResFile(BaseResultFile):
    """
        res 文件解析
    """
    def __init__(self, file_path, name=None): 
        super().__init__()
        self.file_path = file_path
        self.name      = name
        self.data_full = None

    def read_file(self, isReload=True): 
        # ==============================
        file_path = self.file_path
        # ==============================

        if not isReload:
            self._set_request_data()
            if is_debug: logger.warning(f'ResFile: {self.name} do not reload!!!')
            return None

        fileid = open(file_path,'r')
        data = []
        data_str = []
        n = 0
        while True:
            line=fileid.readline().lower()
            if '<stepmap' in line:
                n=1
            if r'</stepmap>' in line:
                data_str.append(line)
                n=0
                break
            if n==1:
                data_str.append(line)
        self.data_str=data_str
        while  True:
            line=fileid.readline().lower()
            if '<step' in line:
                data_n=[]
                while True:
                    line2=fileid.readline().lower()
                    if '</step>' in line2:
                        break
                    d1=line2.replace('\n','')
                    d2=d1.split(' ')
                    data_n.extend(d2)
                data.append(data_n)
            if '</analysis>' in line:
                break
            if not line : break
        fileid.close()

        self._requestId = self.data_title_parse(data_str)
        self.data_full  = data
        self._set_request_data()

        return None

    def get_samplerate(self, nlen=20, loc_start=5):

        # ==============================
        file_path = self.file_path
        # ==============================

        f = open(file_path, 'r')
        data = []
        while True:
            line = f.readline().lower()
            if r'</stepmap>' in line:
                break
        
        cur_loc = 0
        while True:
            line = f.readline().lower()
            data_n = []
            if '<step' in line:
                data_n=[]
                while True:
                    line2 = f.readline().lower()
                    if '</step>' in line2:
                        break
                    d1 = line2.replace('\n','')
                    d2 = d1.split(' ')
                    data_n.extend(d2)
                data.append(data_n)
            cur_loc += 1
            if nlen < cur_loc: # 完成计数，结束读取
                break
            if '</analysis>' in line:
                break
            if not line : break
        f.close()

        simTime = []
        for n in range(loc_start, len(data[:])):
            simTime.append(float(data[n][0]))

        samplerates = []
        for n in range(len(simTime)-1):
            delta = simTime[n+1] - simTime[n]
            samplerates.append(1.0 / delta)

        samplerate_mean = sum(samplerates) / len(samplerates)

        # ==============================
        self.samplerate = samplerate_mean
        # ==============================

        return samplerate_mean

    def _set_request_data(self): 
        
        # ==============================
        data        = self.data_full
        requestId   = self._requestId
        reqs        = self.reqs
        comps       = self.comps
        # ==============================

        dataId, dataOut, names = [], [], []
        isAllRead = True
        for n in range(0,len(reqs)):
            keyName = str_lower_strip(reqs[n])+'.'+str_lower_strip(comps[n])
            names.append(keyName)
            try:
                dataId.append(requestId[keyName])
            except:
                # if is_debug: logger.warning('reqs.comps error: {}\n'.format(keyName))
                if is_debug: logger.error(f'{key_name} not in requestId')
                isAllRead = False

        assert isAllRead , 'ResFile读取失败,未完全完成读取,终止'

        for n in dataId:
            n1=n-1
            temp=[]
            for n2 in range(len(data[:])): # 不考虑首位数据
                temp.append(float(data[n2][n1]))
            dataOut.append(temp)

        # ==============================
        self.data_original = dataOut
        # ==============================

        return None

    def read_file_faster(self): 

        # ==============================
        file_path = self.file_path
        reqs      = self.reqs
        comps     = self.comps
        # ==============================


        getlist = lambda data,list1: [data[n-1] for n in list1]

        fileid = open(file_path,'r')
        id_list, data, data_str, n = [], [], [], 0
        while True:
            line = fileid.readline().lower()
            if '<stepmap' in line:
                n=1
            if r'</stepmap>' in line:
                data_str.append(line)
                n=0
                break
            if n==1:
                data_str.append(line)

        requestId = self.data_title_parse(data_str) # 开头数据解析

        for req, comp in zip(self.reqs, self.comps):
            key_name = str_lower_strip(req)+'.'+str_lower_strip(comp)
            if key_name not in requestId:
                if is_debug: logger.error(f'{key_name} not in requestId')
            id_list.append(requestId[key_name])

        while True:
            line=fileid.readline().lower()
            if '<step' in line:
                data_n=[]
                while True:
                    line2=fileid.readline().lower()
                    if '</step>' in line2:
                        break
                    d1=line2.replace('\n','')
                    d2=d1.split(' ')
                    data_n.extend(d2)
                data.append(getlist(data_n, id_list))
            if '</analysis>' in line:
                break
        fileid.close()

        new_data = []
        for n in range(len(data[0])):
            new_line = []
            for line in data:
                new_line.append(float(line[n]))
            new_data.append(new_line)

        # ==============================
        self.data_original = new_data
        # ==============================

        return None

    def set_reqs_comps(self, reqs, comps): 

        titles = []
        for req, comp in zip(reqs, comps):
            titles.append(str(req)+'.'+str(comp))

        # ==============================
        self.reqs   = reqs
        self.comps  = comps
        self.titles = titles
        # ==============================

        return None

    @staticmethod
    def data_title_parse(data_str): 

        reg=r'^<entityname="(.*?)"(.*)entity="(\S*)"(.*)enttype="\S*"(.*)>'
        reg2=r'^<componentname="(.*?)".*id="(\d*)"(?:.*)/>'
        
        n=0
        requestId=dict()
        for line in data_str:
            line = str_lower_strip(line) #去所有空格并转为小写

            a=re.match(reg,line)
            b=re.match(reg2,line)
            if a:
                entityName=a.group(1)
                n = 1
            if b and (n==1):
                componentName=b.group(1)
                locId=b.group(2)
                requestId[entityName+'.'+componentName]=int(locId)
            if r'</entity>' in line: # 结束
                # print(line)
                n=0
                entityName=''

        return requestId


class ReqFile(BaseResultFile):
    """
        req 文件解析
    """
    def __init__(self, file_path, name=None):
        super().__init__()
        self.file_path = file_path
        self.name      = name
        self.data_full = None

    def read_file(self, isReload=True): 

        # ==============================
        file_path = self.file_path
        # ==============================
        
        if not isReload:
            self._set_request_data()
            if is_debug: logger.warning(f'ReqFile: {self.name} do not reload!!!')
            return None

        f = open(file_path,'r')
        # 开头解析
        title = []
        for n in range(3):
            title.append(f.readline())
        num,temp,gain = [line for line in title[2].split(' ') if line]
        num,gain = int(num),float(gain)

        # 索引解析
        n = 0
        loc_dic = {}
        num_dic = {}
        while True:
            line = f.readline()
            line2 = re.sub(r'\s','',line)
            if re.search(r'\D+',line2) == None:
                n += 1
                temp = [int(n) for n in re.split(r'\s',line) if n]
                num_dic[n] = temp
                loc_dic[temp[0]] = n
            else:
                continue
            if n == num:
                break
        # 数据解析
        ts,vs = [],[]
        is_start = False
        while True:
            line = f.readline()
            if not line:
                break
            temp = []
            temp = [float(n) for n in re.split(r'\s',line) if n]

            if len(temp) == 1:
                if is_start:
                    vs.append(v)
                    ts.append(temp[0])
                    v = []
                else:
                    is_start,v = True,[]
            else:
                v.extend(temp)

        f.close()

        # ==============================
        self.data_full = vs
        self.times = ts
        self.loc_dic = loc_dic
        self.num_dic = num_dic
        # ==============================
        self._set_request_data()

        return None

    def get_samplerate(self):
        # ==============================        
        list1 = self.times
        # ==============================
        nlen = len(list1)
        if nlen<10:
            cal_len = nlen
        else:
            cal_len = 10

        samplerate = 1 / (sum([list1[n+1]-list1[n] for n in range(cal_len-1)]) / (cal_len-1) )

        # ==============================
        self.samplerate = samplerate
        # ==============================
        return samplerate

    def _set_request_data(self): 
        # ==============================
        data_full = self.data_full
        loc_dic   = self.loc_dic
        nlocs     = self.nlocs
        nums      = self.nums
        # ==============================

        for n in range(len(nlocs)): # 将数据转化为
            # assert nlocs[n]==int(nlocs[n]), f'req数据读取，reqs中数据为非整数'
            # assert nums[n]==int(nums[n]), f'req数据读取，comps中数据为非整数'
            nlocs[n] = int(nlocs[n])
            nums[n] = int(nums[n])

        lines = [ [] for n in nlocs ]
        for line in data_full:
            for n in range(len(nlocs)):
                loc = nlocs[n]
                num = nums[n]
                new_loc = (loc_dic[loc]-1)*6
                lines[n].append(line[new_loc+num-1])
        
        names = [f'{loc}.{num}' for loc,num in zip(nlocs,nums)]

        # ==============================
        self.data_original = lines
        self.titles        = names
        # ==============================

        return None


    def set_reqs_comps(self, reqs, comps):

        titles = []
        for req, comp in zip(reqs, comps):
            titles.append(str(req)+'.'+str(comp))

        # ==============================
        self.nlocs  = reqs
        self.nums   = comps
        self.titles = titles
        # ==============================
        return None

class NumDataFile(BaseResultFile):
    """
        NumData 文件解析
    """
    def __init__(self, file_path, name=None): 
        super().__init__()
        self.file_path = file_path
        self.name      = name

    def read_file(self): 
        # ==============================
        file_path = self.file_path
        # ==============================

        file = open(file_path, 'r')
        data, titlelist = [], []
        isdata_start = False
        lines_temp = []
        while True:    
            line = file.readline()     #这里可以进行逻辑处理     file2.write('"'+line[:s]+'"'+",")  
            if not line: break  # 空
            isdata=True
            # num=0
            if re.match('\s*[ABCDE]+.*',line): # 标题注释
                # print(line)
                if '.' in line:
                    isdata_start = False
                    titlelist.append(line.replace('\n',''))
                else:
                    isdata_start = True
                continue

            value_strs = [float(value) for value in re.split('\s',line) if value]
            if value_strs:
                # 是数据段且非空数据行
                if isdata_start:
                    isdata_start = False
                    if lines_temp:
                        data.extend(list2_change_rc(lines_temp))
                        lines_temp = []
                    lines_temp = []
                lines_temp.append(value_strs)

        data.extend(list2_change_rc(lines_temp))

        file.close()

        titlelist = [title[4:] for title in titlelist]

        # ==============================
        self.data_original = data
        self.titles        = titlelist
        # ==============================

        return None

    def get_samplerate(self, nlen=None, loc_start=None): return self.samplerate

    def set_reqs_comps(self, reqs, comps): return None


class RpcFile(BaseResultFile):
    """
        rpc 文件解析
    """
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

    def get_samplerate(self, nlen=None, loc_start=None): return self.samplerate

    def set_reqs_comps(self, reqs, comps): return None

    def read_file_faster(self):
        self.read_file()

class CsvFile(BaseResultFile):
    """
        csv 文件解析
    """
    def __init__(self, file_path, name=None): 
        super().__init__()
        
        self.name          = name
        self.file_path     = file_path
        self.data_original = None
        self.times         = None
        self.titles        = None
        self.samplerate    = None


    def read_file(self): 

        # ==============================
        file_path = self.file_path
        # ==============================

        with open(file_path,'r') as f:
            filestr = f.read()
        
        list1 = []
        isTitle = True
        for loc, line in enumerate(filestr.split('\n')):
            
            if isTitle: # 开头读取
                titles = line.split(',')
                isTitle = False
                continue

            line = str_lower_strip(line)
            if line:
                line = [float(value) for value in line.split(',') if value]
                list1.append(line)

        new_list1 = []
        for n0 in range(len(list1[0])):
            line = []
            for n1 in range(len(list1)):
                line.append(list1[n1][n0])
            new_list1.append(line)

        # ==============================
        self.data_original = new_list1[1:]
        self.titles        = titles[1:]
        self.times         = new_list1[0]
        # ==============================

        return None

    def get_samplerate(self): 
        
        # ==============================
        list1 = self.times
        # ==============================

        nlen = len(list1)
        if nlen<10:
            cal_len = nlen
        else:
            cal_len = 10

        samplerate = 1 / (sum([list1[n+1]-list1[n] for n in range(cal_len-1)]) / (cal_len-1) )

        # ==============================
        self.samplerate = samplerate
        # ==============================

        return samplerate

    def set_reqs_comps(self, reqs, comps): return None


# ==============================
# ==============================

class DataModel:
    """
        后处理数据解析管理
    """
    model_names = []
    models      = {}

    def __init__(self, name):

        if name not in DataModel.model_names:
            DataModel.model_names.append(name)
            DataModel.models[name] = self
            self.names      = []
            self.objs       = {}
            self.file_types = {}
            self.others     = {}
        else:
            self.names      = DataModel.models[name].names
            self.objs       = DataModel.models[name].objs
            self.file_types = DataModel.models[name].file_types
            self.others     = DataModel.models[name].others
            if is_debug: logger.warning(f'DataModel["{name}"] is exists, using old data.')

    def __getitem__(self, k): return self.objs[k]

    def new_file(self, file_path, name):

        assert os.path.exists(file_path)
        # assert not name in self.objs
        if name in self.objs: 
            if is_debug: logger.warning(f'DataModel.new_file: {name} is exists, cover')

        # ==============================
        file_types = self.file_types
        # ==============================

        file_type = file_path[-4:].lower()
        if file_type == '.res':
            class_cal = ResFile
            file_types[name] = 'res'
        elif file_type == '.req':
            class_cal = ReqFile
            file_types[name] = 'req'
        elif file_type in ['.drv', '.rsp']:
            class_cal = RpcFile
            file_types[name] = 'rpc'
        elif file_type == '.csv':
            class_cal = CsvFile
            file_types[name] = 'csv'
        else:
            class_cal = NumDataFile
            file_types[name] = 'num'

        # if file_path == None: # 仅存放数据
        #     class_cal = DataOnly
        #     file_types[name] = None

        # ==============================
        self.objs[name] = class_cal(file_path, name)
        if name not in self.names:
            self.names.append(name)
        # ==============================

        return None

    def get_samplerate(self, name):

        return self.objs[name].get_samplerate()

    @staticmethod
    def remove(name):
        if name in DataModel.model_names:
            DataModel.model_names.remove(name)
            del DataModel.models[name]
        else:
            pass

        return True

    # def join_data(self, names):
    #     # 数拼接
    #     pass
    #     key = tuple(names)
    #     self.objs[key] = 


# ==============================
# ==============================

# ==============================
# 实时读取res文件数据
def get_res_paths(res_paths, reqs, comps, n_start=5, n_end=None, save_csv=False):
    """
        res_paths   list    多res路径

    """
    d_name = 'get_res_paths'
    dataobj = DataModel(d_name)

    event_names = []
    force_data_list = []
    samplerates = []
    if isinstance(n_start, int): n_start = [n_start]*len(res_paths)
    if n_end == None or isinstance(n_end, int): n_end = [n_end]*len(res_paths)

    assert len(n_start)==len(res_paths), 'len(n_start) != len(res_paths)'
    assert len(n_end)==len(res_paths), 'len(n_end) != len(res_paths)'

    for loc_start, loc_end, res_path in zip(n_start, n_end, res_paths):
        res_name = os.path.basename(res_path)[:-4]
        event_names.append(res_name)
        dataobj.new_file(res_path, res_name)
        dataobj[res_name].set_reqs_comps(reqs, comps)
        dataobj[res_name].read_file_faster()
        force_data = dataobj[res_name].get_data()
        force_data = [ line[loc_start:loc_end] for line in force_data ] # 起始位置截断
        force_data_list.append(force_data)
        # 频域计算
        samplerate_mean = dataobj[res_name].get_samplerate(nlen=20, loc_start=4)
        samplerates.append(round(samplerate_mean))

        if save_csv:
            dataobj[res_name].save_csv_data(res_path[:-4]+'.csv', force_data)

    # 退还
    DataModel.remove(d_name)

    return force_data_list, event_names, samplerates


