"""
    tkinter 应用
    基础模块
    v 1.0
"""
import tkinter as tk
import tkinter.filedialog
import tkinter.messagebox
import json
import re
import time

import logging
import os.path
PY_FILE_NAME = os.path.basename(__file__).replace('.py', '')
LOG_PATH = PY_FILE_NAME+'.log'
logger = logging.getLogger(PY_FILE_NAME)


# =======================================
# 子函数
list2str = lambda list1: ','.join([str(n) for n in list1])
str2list = lambda str1: [float(n) for n in str1.split(',')]
str2int = lambda str1: [int(n) for n in str1.split(',')]


# =======================================
# 基础模块
class TkUi:
    """
        调用tkinter
    """
    count = 0
    def __init__(self, title, frame=None):
        TkUi.count +=1 
        # 主界面
        if frame==None: 
            # print('frame call: None')
            if TkUi.count == 1 :        
                window = tk.Tk()
            else:
                window = tk.Toplevel()
            window.title(title)
            window.protocol('WM_DELETE_WINDOW', self.close_window)
        else:
            # print('frame call:', type(frame))
            window = frame

        self.window = window
        self.frames = {}
        self.entrys = {}
        self.vars = {}
        self.buttons = {}
        self.labels = {}
        self.scale = {}
        self.text = {}
        self.check = {}
        self.loc = 1
        self.sub_frames = {}

    def run(self):
        """
            运行 UI 界面
        """
        self.window.mainloop()
        # help(self.window.mainloop)

    def frame_loadpath(self, params, frame=None): # 读取导航及输入框
        """
            导入路径
            {
            'frame':'mnf_load',
            'var_name':'mnf_load',
            'path_name':'mnf file',
            'path_type':'.mnf',
            'button_name':'mnf load',
            'button_width':15,
            'entry_width':30,
            }
        """
        frame = self.create_frame(params['frame'], expand=tk.YES, fill=tk.X, frame=frame)

        def loadpath():
            path = tkinter.filedialog.askopenfilename(filetypes = ((params['path_name'],params['path_type']),))
            var.set(path)

        button = tk.Button(frame,text=params['button_name'],width=params['button_width'],command=loadpath)
        button.pack(side='left')

        var = tk.StringVar()
        var.set('')
        entry = tk.Entry(frame,width=params['entry_width'],show=None,textvariable=var)
        entry.pack(side='left',expand=tk.YES,fill=tk.X)

        self.vars[params['var_name']] = var
        self.buttons[params['var_name']] = button
        self.entrys[params['var_name']] = entry

        self.loc += 1

    def frame_loadpaths(self, params, frame=None): # 多文件加载
        """
            导入路径
            {
            'frame':'mnf_load',
            'var_name':'mnf_load',
            'path_name':'mnf file',
            'path_type':'.mnf',
            'button_name':'mnf load',
            'button_width':15,
            'entry_width':30,
            }
        """
        frame = self.create_frame(params['frame'], expand=tk.YES, fill=tk.X, frame=frame)

        def loadpath():
            path = tkinter.filedialog.askopenfilenames(filetypes = ((params['path_name'],params['path_type']),))
            var.set(','.join(path))

        button = tk.Button(frame,text=params['button_name'],width=params['button_width'],command=loadpath)
        button.pack(side='left')

        var = tk.StringVar()
        var.set('')
        entry = tk.Entry(frame,width=params['entry_width'],show=None,textvariable=var)
        entry.pack(side='left',expand=tk.YES,fill=tk.X)

        self.vars[params['var_name']] = var
        self.buttons[params['var_name']] = button
        self.entrys[params['var_name']] = entry

        self.loc += 1

    def frame_savepath(self, params, frame=None): # 保存导航及输入框
        """
            路径保存用
            {
            'frame':'h3d_save',
            'var_name':'h3d_save',
            'path_name':'mnf file',
            'path_type':'.h3d',
            'button_name':'h3d save',
            'button_width':15,
            'entry_width':30,
            }
        """
        frame = self.create_frame(params['frame'], expand=tk.YES, fill=tk.X, frame=frame)

        def savepath():
            path = tkinter.filedialog.asksaveasfilename(filetypes = ((params['path_name'],params['path_type']),))
            if len(path) < len(params['path_type'])+1 :
                path += params['path_type']
            if not path[-len(params['path_type']):] == params['path_type'] :
                path += params['path_type']
            if path == params['path_type']:
                path = ''
            var.set(path)

        button = tk.Button(frame,text=params['button_name'],width=params['button_width'],command=savepath)
        button.pack(side='left')

        var = tk.StringVar()
        var.set('')
        entry = tk.Entry(frame,width=params['entry_width'],show=None,textvariable=var)
        entry.pack(side='left',expand=tk.YES,fill=tk.X)

        self.vars[params['var_name']] = var
        self.buttons[params['var_name']] = button
        self.entrys[params['var_name']] = entry

        self.loc += 1

    def frame_button(self, params, frame=None): # 按钮框
        """
            按钮
            {
            'frame':'test',
            'button_name':'test',
            'button_width':15,
            'func':self.func1, # 回调函数
            }
        """
        frame = self.create_frame(params['frame'], expand=tk.YES, fill=tk.X, frame=frame)

        button = tk.Button(frame,text=params['button_name'],width=params['button_width'],
            command=params['func'])
        button.pack(side='left',expand=tk.YES,fill=tk.X)

        # if 'button' in params.keys():
        #   self.buttons[params['frame']] = button
        # else:
        #   self.buttons[params['frame']] = button
        

        if params['frame'] in self.buttons:
            if params['button_name'] in self.buttons[params['frame']]:
                assert False,'button重名'
            self.buttons[params['frame']][params['button_name']] = button
        else:
            self.buttons[params['frame']] = {params['button_name']:button}

        self.loc += 1

    def frame_entry(self, params, frame=None): # 注释及输入框
        """
            注释及输入
            params = {
                'frame':'qwer',
                'var_name':'qwer',
                'label_text':'adsf',
                'label_width':15,
                'entry_width':30,
            }
        """
        frame = self.create_frame(params['frame'], expand=tk.YES, fill=tk.X, frame=frame)

        label = tk.Label(frame,text=params['label_text'],width=params['label_width'])
        label.pack(side='left')

        var = tk.StringVar()
        var.set('')
        entry = tk.Entry(frame,width=params['entry_width'],show=None,textvariable=var)
        entry.pack(side='left',expand=tk.YES,fill=tk.X)
        
        self.vars[params['var_name']] = var
        self.entrys[params['var_name']] = entry

        return True

    def frame_label_only(self, params, frame=None): # 仅注释
        """
            注释及输入
            params = {
                'label_text':'adsf',
                'label_width':15,
            }
        """
        if 'frame' in params:
            frame = self.create_frame(params['frame'], expand=tk.YES, fill=tk.X, frame=frame)

        else:
            frame = tk.Frame(self.window)
            frame.pack(expand=tk.YES, fill=tk.BOTH)
            
        label = tk.Label(frame,text=params['label_text'],width=params['label_width'])
        label.pack(side='left',expand=tk.YES,fill=tk.X) #

        # self.labels[params['frame']] = label


        return True

    def frame_check_entry(self, params, frame=None):
        """
        params = {
            'frame':'check_entry',
            'check_text':'adsf',
            'check_var':'isVar',
            'entry_var':'var',
            'entry_width':30,
        }
        """
        frame = self.create_frame(params['frame'], expand=tk.YES, fill=tk.X, frame=frame)

        # 复选框
        var = tk.BooleanVar()
        check = tk.Checkbutton(frame,
            variable = var,
            text=params['check_text'],
            onvalue = True, offvalue = False)
        check.pack(side='left')

        self.check[params['check_var']] = check
        self.vars[params['check_var']] = var

        # entry框
        var = tk.StringVar()
        var.set('')
        entry = tk.Entry(frame,width=params['entry_width'],show=None,textvariable=var)
        entry.pack(side='left',expand=tk.YES,fill=tk.X)
        
        self.entrys[params['entry_var']] = entry
        self.vars[params['entry_var']] = var
        
        return True

    def frame_buttons_RWR(self, params, frame=None): # 运行，保存，读取按钮
        """
            运行、保存、读取
            {
                'frame':'rrw',
                'button_run_name':'a',
                'button_write_name':'b',
                'button_read_name':'c',
                'button_width':15,
                'func_run':self.func1,
            }
        """
        frame = tk.Frame(self.window)
        frame.pack(fill=tk.X) # expand=tk.YES,

        button_run = tk.Button(frame,text=params['button_run_name'],width=params['button_width'],command=params['func_run'])
        button_run.pack(side='left',expand=tk.YES,fill=tk.X)

        button_write = tk.Button(frame,text=params['button_write_name'],width=params['button_width'],command=self.write)
        button_write.pack(side='left',expand=tk.YES,fill=tk.X)

        button_read = tk.Button(frame,text=params['button_read_name'],width=params['button_width'],command=self.read)
        button_read.pack(side='left',expand=tk.YES,fill=tk.X)
        
        self.frames[params['frame']] = frame

        return True

    def frame_note(self): # 备注框，配合self.print
        """
            用于备注
        """
        frame = tk.Frame(self.window)
        frame.pack(fill=tk.X) # expand=tk.YES,
        var = tk.StringVar()
        var.set('')
        label = tk.Label(frame,show=None,textvariable=var) # ,width=params['entry_width']
        label.pack(side='left',expand=tk.YES,fill=tk.X) # ,expand=tk.YES

        self.note = [var, label]

        return True

    def frame_value_edit(self, params, frame=None): # 注释+输入+滚动框，变量变更
        """
            变量 编辑
            带 scale
            frame_value_edit2 = {
            'frame':'value_2',
            'var_name':'value_2',
            'label_text':'变量2', 
            'label_width':15,
            'entry_width':15,
            'scale_range':100, # 
            }
        """
        frame = self.create_frame(params['frame'], expand=tk.YES, fill=tk.X, frame=frame)

        # 开头备注
        label = tk.Label(frame,text=params['label_text'],width=params['label_width'])
        label.pack(side='left')
        
        # 数值栏
        var = tk.StringVar()
        var.set('')

        
        def entry_callback():
            var.set(var_entry.get())
        var_entry = tk.StringVar()
        var_entry.set(str(params['value']))
        entry = tk.Entry(frame,width=params['entry_width'],show=None,textvariable=var_entry,
            validate='focusout', # focusout
            validatecommand=entry_callback)
        entry.pack(side='left')


        def scale_callback(v): # 回调
            var.set( str(float(entry.get())*(1+float(v)/200)) )
            self.scale_run()

        # scale 
        scale = tk.Scale(frame, from_=-params['scale_range'], to=params['scale_range'], orient=tk.HORIZONTAL,
            length=200, showvalue=0, resolution=1, command=scale_callback)
        scale.pack(side='left')

        label2 = tk.Label(frame, width=params['entry_width'],textvariable=var)
        label2.pack(side='left')

        self.vars[params['var_name']] = var
        self.scale[params['var_name']] = scale

    def frame_text_lines(self, params, frame=None): # 多行文字输入框
        """
            多行输入
            params = {
            'frame':'text_1',
            'text_name':'text_1',
            'text_width':50,
            'text_height':15,
            }
        """
        frame = self.create_frame(params['frame'], expand=tk.YES, fill=tk.X, frame=frame)

        text = tk.Text(frame,
            width=params['text_width'],
            height=params['text_height'],bg='white')
        
        # text.insert("insert", "test")  # 插入
        text.pack(side='left', fill=tk.BOTH, expand=tk.YES)

        if 'isExpand' in params: # 是否扩展
            if params['isExpand']:
                text.pack(expand=tk.YES)
            else:
                text.pack(expand=tk.NO)
        else:
            text.pack(expand=tk.YES)


        self.text[params['text_name']] = text

    def frame_checkbutton(self, params, frame=None): # 单一复选框
        """
            复选框
            params = {
            'frame':'check_1',
            'var_name':'check_1',
            'check_text':'是否作图',
            }
        """
        frame = self.create_frame(params['frame'], expand=tk.YES, fill=tk.X, frame=frame)

        var_name = params['var_name']
        var = tk.BooleanVar()

        check = tk.Checkbutton(frame,
            variable = var,
            text=params['check_text'],
            onvalue = True, offvalue = False)
        check.pack(side='left')


        self.check[var_name] = check
        self.vars[var_name] = var

    def frame_checkbuttons(self, params, frame=None): # 多个复选框
        """
            复选框
        params = {
            'frame':'check_1',
            'vars':['isA','isB'],
            'check_texts':['是否A','是否B'],
        }
        """
        frame = self.create_frame(params['frame'], expand=tk.YES, fill=tk.X, frame=frame)

        for varname, check_text in zip(params['vars'], params['check_texts']):
            var = tk.BooleanVar()
            check = tk.Checkbutton(frame,
                variable = var,
                text=check_text,
                onvalue = True, offvalue = False)
            check.pack(side='left') # 

            self.check[varname] = check
            self.vars[varname] = var

    def frame_radiobuttons(self, params, frame=None): # 单选框
        """
            单选框
            params = {
            'frame':'loading_type',
            'var_name':'loading_type',
            'texts':['rsp读取方式', 'res读取方式', 'res输入,读取rsp'],
            }
            输出变量状态:  计数从1开始
        """
        frame = self.create_frame(params['frame'], expand=tk.YES, fill=tk.X, frame=frame)

        var = tk.IntVar()
        var.set(1)

        for num, text in enumerate(params['texts']):
            radio = tk.Radiobutton(frame, text=text, variable=var, value=num+1)
            radio.pack(side='left', expand=tk.YES, fill=tk.X)

        self.vars[params['var_name']] = var

    def get_text(self, name): # 多行文本数据读取
        """
            获取 text 多行文本
            name ： text的frame名称
        """
        return self.text[name].get(1.0,tk.END)

    def set_text(self, name, str1): # 多行文本框写入
        """
            写入 text 多行文本
            name ： text 的frame名称
            str1 ： 写入字符窜
        """
        self.text[name].delete(1.0,tk.END)
        self.text[name].insert('insert',str1)
        return True

    def get_vars(self): # 获取当前所有var变量
        
        var_names = list(self.vars.keys())
        params = {}
        for name in var_names:
            params[name] = self.strline_parse(self.vars[name].get())

        return params

    def get_texts(self): # 获取所有text的多行字符串数据
        
        var_names = list(self.text.keys())
        params = {}
        for name in var_names:
            params[name] = self.get_text(name)

        return params

    def get_vars_and_texts(self): # 所有 var及text数据导出
        # 注：var与text的key不能重名
        params = self.get_vars()
        params2 = self.get_texts()
        params.update(params2)
        return params

    def scale_run(self): # scale统一调用
        """
            用于scale 的统一调用
        """
        pass

    def write(self, isSubFrame=False):
        """
            写入 json
            用于保存数据
        """
        values = {}
        for key in self.sub_frames:
            values['SUBFRAMS_'+key] = self.sub_frames[key].write(isSubFrame=True) 

        for name in self.vars.keys():
            values[name] = self.vars[name].get()
        
        if len(self.text.keys()) > 0:
            for name in self.text.keys():
                values[name+'_TYPE_TEXT'] = self.get_text(name)

        if isSubFrame: return values # 子模块调用-提前返回需保存数据

        path = tkinter.filedialog.asksaveasfilename(filetypes = (('json','.json'),))
        if '.json' != path[-5:]:
            path += '.json'

        if '.json' != path:
            with open(path,"w") as f:
                json.dump(values,f)
            self.print('写入结束')
        else:
            self.print('未写入')
            pass

        return values

    def read(self, path=None, sub_values=None):
        """
            读取 json
            用于读取数据
        """
        if sub_values==None: # 读取

            if path == None:
                path = tkinter.filedialog.askopenfilename(filetypes = (('json','.json'),))

            if '.json' != path[-5:]:
                path += '.json'

            if '.json' != path : 
                """非空"""
                with open(path,"r") as f: # 文件读取
                    values = json.load(f)

                for name in values.keys():
                    if name[len('SUBFRAMS_'):] in self.sub_frames and 'SUBFRAMS_' in name: # 若有子模块, 则进行读取
                        self.sub_frames[name[len('SUBFRAMS_'):]].read(sub_values=values[name])
                        continue

                    if name not in self.vars.keys():
                        if '_TYPE_TEXT' in name:
                            # text 数据
                            self.set_text(name.split('_TYPE_TEXT')[0],values[name])
                            continue
                        else:
                            self.print('读取错误，变量: {} 不存在'.format(name))
                            # return False
                    try:
                        self.vars[name].set(values[name])
                    except:
                        pass

                self.print('读取结束')
            else:
                self.print('取消读取')

        else: # 子模块-读取

            for name in sub_values.keys():
                if name not in self.vars.keys():
                    if '_TYPE_TEXT' in name:
                        # text 数据
                        self.set_text(name.split('_TYPE_TEXT')[0],sub_values[name])
                        continue
                    else:
                        self.print('读取错误，变量: {} 不存在'.format(name))
                        # return False
                try:
                    self.vars[name].set(sub_values[name])
                except:
                    pass

        return True

    def print(self, str1): # 备注框写入
        """
            备注
            需提前调用 frame_note
        """
        self.note[0].set(str1)
        self.note[1].update()
        
        return True

    def create_frame(self, frame_name, expand=tk.YES, fill=tk.X, frame=None): # 根据frame名称返回frame对象
        """
            创建frame
                若frame已存在则直接返回frame对象
        """
        

        if frame_name in self.frames.keys():
            new_frame = self.frames[frame_name]
        else:
            if frame != None:
                new_frame  = tk.Frame(frame)
            else:
                new_frame = tk.Frame(self.window)
        
        new_frame.pack(expand=expand, fill=fill)
        self.frames[frame_name] = new_frame

        return new_frame

    def close_window(self):
        # 关闭时结束程序
        self.window.quit()
        self.window.destroy()
        return None

    @staticmethod
    def strline_parse(value): 
        """解析单行字符串数据"""
        def str_single_parse(str_value):
            """ 无空格单行字符串,非列表格式转化 """
            isFloat = lambda str1: re.match(r'\A\+?\-?\d+\.\d+\Z',str1)     # 是否为字符串
            isInt = lambda str1: re.match(r'\A\+?\-?\d+\Z',str1)            # 是否为整数
            isNone = lambda str1: str1.lower()=='none'
            isbool = lambda str1: str1.lower()=='false' or str1.lower()=='true'
            str2bool = lambda str1: True if str1.lower()=='true' else False
            if isFloat(str_value): 
                value = float(str_value)
                if value==int(value):
                    return int(value)
                else:
                    return value
            if isInt(str_value): return int(str_value)
            if isbool(str_value): return str2bool(str_value)
            if isNone(str_value): return None
            return str_value

        if type(value) != str: # 非字符串,返回
            return value

        str_value = re.sub(r'\s','',value).lower()  # 去空格

        if ',' in str_value:
            list1 = str_value.split(',')
            list2 = []
            for n in list1:
                list2.append(str_single_parse(n))
            return list2

        return str_single_parse(value)

    # 批量计算模块
    def frame_ui_runs(self, frame=None): # 批量计算模块
        """
            func 主运行函数
        """
        if frame!=None:
            new_frame = tk.LabelFrame(frame, text='批量读取运行(非必要)')
        else:
            new_frame = tk.LabelFrame(self.window, text='批量读取运行(非必要)')

        new_frame.pack()

        self.frame_loadpaths({
            'frame':'json_files', 'var_name':'json_files', 'path_name':'json files',
            'path_type':'.json', 'button_name':'json files',
            'button_width':15, 'entry_width':40,},
            frame=new_frame )

        self.frame_button({
            'frame':'cals',
            'button_name':'批量计算json',
            'button_width':30,
            'func':self.fun_ui_runs,},
            frame=new_frame )

        return new_frame

    def fun_ui_runs(self): # 批量运算
        # 批量读取json计算
        self.print('\n开始批量计算\n')
        params = self.get_vars_and_texts()
        if isinstance(params['json_files'], str): params['json_files'] = [params['json_files']]
        json_files = params['json_files']
        logger.info(f'批量计算json:\n{json_files}\n')
        
        for path in json_files:
            self.read(path)
            self.print(f'\n读取运行{path}\n')
            self.fun_run()
            self.print(f'\n{path}运行结束\n')

        self.print('\n批量计算完成\n')

    def fun_run(self): pass  # 主运行函数


class TkListBox(TkUi): # 列表扩展
    def __init__(self, title, frame=None):
        super().__init__(title, frame=frame)

        self.listbox = {}

    def listbox_del(self, name):

        lb = self.listbox[name]
        for n in range(lb.size()):
            lb.delete(0)

        return None

    def listbox_set(self, name, list1, isDel=True): # 设置列表

        lb = self.listbox[name]
        if isDel: self.listbox_del(name)
        for n, value in enumerate(list1):
            lb.insert(n, str(value))
        return None

    def listbox_get_select(self, name): # 获取所选
        lb = self.listbox[name]
        selections = lb.curselection()
        values = []
        for sel_loc in zip(selections):
            values.append(lb.get(sel_loc))

        return values

    def frame_listbox(self, params, frame=None):
        # 列表
        # params = {
        #   'frame': 'test1',
        #   'name': 'test1',
        #   'label_name': 't',
        #   'width': 5,
        #   'height': 20,
        #   'selections':'extended'
        # }

        if 'selections' not in params: params['selections'] = tk.EXTENDED

        frame = self.create_frame(params['frame'], expand=tk.YES, fill=tk.X, frame=frame)

        label = tk.Label(frame, text=params['label_name'])
        label.pack(side='top')

        sb = tk.Scrollbar(frame)
        lb = tk.Listbox(frame, selectmode=params['selections'], yscrollcommand=sb.set,
                width=params['width'], height=params['height'], exportselection=False)

        lb.pack(side=tk.LEFT, fill=tk.BOTH, expand=tk.YES)
        sb.pack(side=tk.LEFT, fill=tk.BOTH, expand=tk.NO)
        sb.config(command=lb.yview)

        self.listbox[params['name']] = lb

        return None


# =======================================
# 子UI模块

# 后处理读取参数模块
class ResultUi(TkUi):
    """
        AdmSim 主程序
    """
    def __init__(self, title, frame=None, loads=None, texts=None):
        super().__init__(title, frame=frame)

        if frame != None: logger.info('ResultUi-子模块调用')

        if loads == None:
            loads = ['res_path', 'reqs', 'comps', 'nrange', 'nchannel', 'label_text']
        loads = [n.lower() for n in loads]

        if texts == None:
            texts = {
                'res_path'   : '后处理文件',
                'reqs'       : 'reqs',
                'comps'      : 'comps',
                'nrange'     : '数据截取范围\n(起始,结束)',
                'nchannel'   : '通道截取\nNone或n1,n2,...',
                'label_text' : '备注: 计数起始值为0',
            }

        if 'res_path' in loads:
            self.frame_loadpath({
                'frame':'res_path','var_name':'res_path', 
                'path_name':'后处理文件', 'path_type':['*.drv','*.rsp','*.res','*.req', '*.csv'],
                'button_name':'后处理文件',
                'button_width':15, 'entry_width':30,
                })

        if 'res_paths' in loads:
            self.frame_loadpaths({
                'frame':'res_path','var_name':'res_path', 
                'path_name':'后处理文件', 'path_type':['*.drv','*.rsp','*.res','*.req', '*.csv'],
                'button_name':'后处理文件',
                'button_width':15, 'entry_width':30,
                })
            
        if 'reqs' in loads:
            self.frame_entry({
                'frame':'reqs', 'var_name':'reqs', 'label_text':texts['reqs'],
                'label_width':15, 'entry_width':30,
                })

        if 'comps' in loads:
            self.frame_entry({
                'frame':'comps', 'var_name':'comps', 'label_text':texts['comps'],
                'label_width':15, 'entry_width':30,
                })

        if 'nrange' in loads:
            self.frame_entry({
                'frame':'nrange', 'var_name':'nrange', 'label_text':texts['nrange'],
                'label_width':20, 'entry_width':30,
                })

        if 'nchannel' in loads:
            self.frame_entry({
                'frame':'nchannel', 'var_name':'nchannel', 'label_text':texts['nchannel'],
                'label_width':20, 'entry_width':30,
                })

        if 'label_text' in loads:
            self.frame_label_only({'label_text':texts['label_text'], 'label_width':30})


# 文档编辑
class TextEditUi(TkUi):

    def __init__(self, title, text_name, frame=None):
        super().__init__(title, frame=frame)

        self.TextUi = TextUi

        self.ui_data = {'title':title, 'text_name':text_name}

        self.frame_button({
            'frame':text_name,
            'button_name':title, 'button_width':15,
            'func':self.fun_values_cmd_set,
            })

        self.frame_text_lines({
            'frame':text_name,
            'text_name':text_name,
            'text_width':30, 'text_height':2,
            })


    def fun_values_cmd_set(self):

        text_name = self.ui_data['text_name']
        title = self.ui_data['title']

        text_data = self.get_text(text_name)
        obj1 = self.TextUi(title, text=text_data, label_text='Text')
        obj1.run()
        self.set_text(text_name, obj1.text_data)
        del obj1

        return None


# 变量编辑
class StrValuesEditUi(TextEditUi):

    def __init__(self, title, text_name, frame=None, loads=None, texts=None):
        super().__init__(title, text_name, frame=frame)

        if loads == None:
            loads = ['value', 'select', 'gain', 'label_text']
        loads = [n.lower() for n in loads]

        if texts == None:
            texts = {
                'value'   : '后处理文件',
                'select'       : 'reqs',
                'gain'      : 'comps',
                'label_text' : '备注: 计数起始值为0',
            }

        if 'value' in loads:
            self.frame_entry({
                'frame':'value', 'var_name':'value', 'label_text':texts['value'],
                'label_width':15, 'entry_width':30,
                })

        if 'select' in loads:
            self.frame_entry({
                'frame':'select', 'var_name':'select', 'label_text':texts['select'],
                'label_width':15, 'entry_width':30,
                })

        if 'gain' in loads:
            self.frame_entry({
                'frame':'gain', 'var_name':'gain', 'label_text':texts['gain'],
                'label_width':15, 'entry_width':30,
                })

        if 'label_text' in loads:
            self.frame_label_only({'label_text':texts['label_text'], 'label_width':30, 'frame':'label_only1'})

        # print(self.func_get_values())

    def func_get_values(self):

        ui_data = self.ui_data
        params = self.get_vars_and_texts()
        return params[ui_data['text_name']], params['value']


# adm仿真模块
class AdmSimUi(TkUi):

    def __init__(self, title, frame=None, loads=None, texts=None):
        super().__init__(title, frame=frame)

        label_frame = tk.LabelFrame(self.window, text=title)
        label_frame.pack()

        if loads == None:
            loads = ['adm_path', 'sim_type', 'drv_path', 'samplerate', 'simtime', 'adams_version', 'label', 'isLoad']
        loads = [n.lower() for n in loads]

        if texts == None:
            texts = {
                'adm_path'      : 'adm load',
                'drv_path'      : 'spline ID',
                'samplerate'    : '采样频率',
                'simtime'       : '仿真时长s',
                'label'         : '备注:计数起始位置为0',
            }

        if 'adm_path' in loads:
            self.frame_loadpath({
                'frame':'adm_path', 'var_name':'adm_path', 'path_name':'adm file',
                'path_type':'.adm', 'button_name':texts['adm_path'], 
                'button_width':10, 'entry_width':20,
                }, frame=label_frame)

        if 'sim_type' in loads:
            self.frame_radiobuttons({
                'frame':'sim_type',
                'var_name':'sim_type',
                'texts':['view', 'car四立柱ride', 'car整车Event'],
                }, frame=label_frame)

        if 'drv_path' in loads and 'isLoad'.lower() in loads:
            self.frame_check_entry({
                'frame':'drv_path', 'check_text':texts['drv_path'], 'check_var':'isLoad',
                'entry_var':'spline_id', 'entry_width':20,
                }, frame=label_frame)
        elif 'drv_path' in loads:
            # 无判断选项
            self.frame_entry({
                'frame':'drv_path', 'var_name':'spline_id', 'label_text':texts['drv_path'],
                'label_width':10, 'entry_width':20,
                }, frame=label_frame)

        if 'samplerate' in loads:
            self.frame_entry({
                'frame':'sim_set', 'var_name':'samplerate', 'label_text':texts['samplerate'],
                'label_width':10, 'entry_width':15,
                }, frame=label_frame)

        if 'simtime' in loads:
            self.frame_entry({
                'frame':'sim_set', 'var_name':'simtime', 'label_text':texts['simtime'],
                'label_width':10, 'entry_width':15,
                }, frame=label_frame)

        if 'adams_version' in loads:
            self.frame_radiobuttons({
                'frame':'adams_version',
                'var_name':'adams_version',
                'texts':['2017.2', '2019'],
                },frame=label_frame)
        
        if 'label' in loads:
            self.frame_label_only({'label_text':texts['label'], 'label_width':30, 
                'frame':'label_only1'}, frame=label_frame)

        self.cur_frame = label_frame


# =======================================
# 应用

# 文本UI
class TextUi(TkUi): 

    def __init__(self, title, text=None, label_text='Text'):
        
        super().__init__(title)

        self.frame_label_only({
            'label_text':label_text,'label_width':5,'frame':'titles'
            })

        self.frame_text_lines({
            'frame':'input',
            'text_name':'text',
            'text_width':80, 'text_height':30,
            })

        self.frame_button({
            'frame':'run',
            'button_name':'确定',
            'button_width':30,
            'func':self.fun_run,
            })

        if text != None:
            self.set_text('text', text)

        self.text_data = text

        #self.run()

    def fun_run(self):
        # 运行
        params = self.get_vars_and_texts()
        self.text_data = params['text']
        self.window.quit()
        self.window.destroy()


# 参数检索UI
class VarSearchUi(TkUi):
    """
        UI程序运行示例
        变量调整
        用于快速计算
        计算慢的不能用!!!
    """
    def __init__(self,title,n_var,names=None,values=None,fun_cal=None,var_cal=None,frame=None):
        """
            title 标题
            n_var 变量个数
            names 变量开头名称
            values 初始变量
            fun_cal 运算函数 格式如下
                fun_cal(var_cal,values)
                    首位为外部输入数据,次位为变量数据
            var_cal 外部数据输入
        """
        super().__init__(title,frame=frame)
        self.fun_cal = fun_cal
        self.var_cal = var_cal
        for n in range(n_var):
            if names==None:
                name = '变量_{}'.format(n)
            else:
                name = names[n]
            if values==None:
                value = ''
            else:
                value = values[n]
            frame_value_edit1 = {
                'frame':'value_{}'.format(n),
                'var_name':'value_{}'.format(n),
                'label_text':name,
                'label_width':15,
                'entry_width':15,
                'scale_range':200,
                'value':value,
            }
            self.frame_value_edit(frame_value_edit1)

        # 
        frame_buttons_RWR1 = {
            'frame':'rrw',
            'button_run_name':'run',
            'button_write_name':'write',
            'button_read_name':'read',
            'button_width':15,
            'func_run':self.fun_run,
        }

        self.frame_buttons_RWR(frame_buttons_RWR1)

        frame_button1 = {
            'frame':'reset',
            'button_name':'置零',
            'button_width':15,
            'func':self.fun_reset,
        }
        self.frame_button(frame_button1)

        self.frame_note()

        frame_text1 = {
            'frame':'text_1',
            'text_name':'text_1',
            'text_width':50,
            'text_height':15,
        }
        self.frame_text_lines(frame_text1)

        #self.run()

    def fun_run(self):
        """
            运行函数
        """
        keys = self.scale.keys()
        nlen = len(keys)
        values = [ float(self.vars['value_{}'.format(n)].get()) for n in range(len(keys))]
        # print(values)
        if self.fun_cal != None:
            str1 = self.fun_cal(self.var_cal,values)
            # self.print(str1)
            self.set_text('text_1',str1)
        # self.print(list2str([ round(obj.predict([values])[0],3) for obj in self.fun_cal]))
        return True

    def scale_run(self):
        """scale 全部调用"""
        self.fun_run()

    def fun_reset(self):
        """
            scale 置零
        """
        keys = self.scale.keys()
        for n in keys:
            self.scale[n].set(1)
        for n in keys:
            self.scale[n].set(0)


# =======================================
# 测试用

class TestUi(TkUi): 
    """
        UI程序运行示例
        测试用
    """
    def __init__(self,title):
        super().__init__(title)

        frame_loadpath1 = {
            'frame':'mnf_load',
            'var_name':'mnf_load',
            'path_name':'mnf file',
            'path_type':'.mnf',
            'button_name':'mnf load',
            'button_width':15,
            'entry_width':30,
        }

        frame_savepath1 = {
            'frame':'h3d_save',
            'var_name':'h3d_save',
            'path_name':'mnf file',
            'path_type':'.h3d',
            'button_name':'h3d save',
            'button_width':15,
            'entry_width':30,
        }

        frame_button1 = {
            'frame':'test',
            'button_name':'test',
            'button_width':15,
            'func':self.fun_run,
        }

        frame_entry1 = {
            'frame':'test2',
            'var_name':'test2',
            'label_text':'test2',
            'label_width':15,
            'entry_width':30,
        }
        
        frame_buttons_RWR1 = {
            'frame':'rrw',
            'button_run_name':'run',
            'button_write_name':'write',
            'button_read_name':'read',
            'button_width':15,
            'func_run':self.fun_run,
        }
        frame_value_edit1 = {
            'frame':'value_1',
            'var_name':'value_1',
            'label_text':'变量1',
            'label_width':15,
            'entry_width':15,
            'scale_range':100,
            'value':100,
        }
        frame_value_edit2 = {
            'frame':'value_2',
            'var_name':'value_2',
            'label_text':'变量2',
            'label_width':15,
            'entry_width':15,
            'scale_range':100,
            'value':100,
        }
        frame_check1 = {
            'frame':'check_1',
            'var_name':'check_1',
            'check_text':'是否作图',
        }
        frame_text_lines1 = {
            'frame':'text_1',
            'text_name':'text_1',
            'text_width':80,
            'text_height':20,
            }
        self.frame_loadpath(frame_loadpath1)
        self.frame_savepath(frame_savepath1)
        self.frame_button(frame_button1)
        self.frame_entry(frame_entry1)
        self.frame_buttons_RWR(frame_buttons_RWR1)
        
        self.frame_note()

        self.frame_value_edit(frame_value_edit1)
        self.frame_value_edit(frame_value_edit2)

        self.frame_checkbutton(frame_check1)
        
        self.frame_text_lines(frame_text_lines1)

        frame_checkbuttons1 = {
            'frame':'check_1',
            'vars':['isA','isB'],
            'check_texts':['是否A','是否B'],
        }
        self.frame_checkbuttons(frame_checkbuttons1)

        params = {
            'frame':'check_entry',
            'check_text':'adsf',
            'check_var':'isVar',
            'entry_var':'var',
            'entry_width':30,
        }
        self.frame_check_entry(params)

        params = {
            'frame':'loading_type',
            'var_name':'loading_type',
            'texts':['rsp读取方式', 'res读取方式', 'res输入,读取rsp'],
            }
        self.frame_radiobuttons(params)

        #self.run()

    def fun_run(self):
        # print('test\n\n')
        print(self.vars['mnf_load'].get())
        print(self.vars['h3d_save'].get())
        print(self.vars['test2'].get())
        # print(dir(self.vars['mnf_save']))
        # help(tk.Label)
        print(self.get_text('text_1'))
        # with open('temp.txt','w') as f:
        #   f.write(self.get_text('text_1'))
        self.print('\n计算结束\n')

    def scale_run(self):
        # self.fun_run()
        # print(10)
        pass


if __name__ == '__main__':
    pass
    
    # a = VarSearchUi('test',4,values=[11,21,13,43],fun_cal=None,var_cal=None).run()
    # # (title,n_var,names=None,values=None,fun_cal=None,var_cal=None)
    # b = TestUi('test')
    # print(TestUi.count)
    # TkUi.count = 0
    # c = TestUi('test2')
    # print(TkUi.count)
    # # ViewAdmSimUi('test')
    
    # TestUi('test')

    
    # obj1 = TextUi('adm变量编辑', text='test\ntest1', label_text='Text')
    # print(obj1.text_data)

    # TextEditUi('test','test').run()

    # StrValuesEditUi('title', 'values_cmd').run()
    AdmSimUi('test').run()
    print('end')
