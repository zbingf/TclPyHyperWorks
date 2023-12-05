"""
    requests 、 components 辅助设置
"""
import os, time, re
import tkinter as tk
import pysnooper

import logging
import os.path
PY_FILE_NAME = os.path.basename(__file__).replace('.py', '')
LOG_PATH = PY_FILE_NAME+'.log'
logger = logging.getLogger(PY_FILE_NAME)


class ReqComTxt:

    def __init__(self,csv_path=None):

        if csv_path==None:
            self.csv_path = 'temp.csv'
        else:
            self.csv_path = csv_path

        self.param_dic = None
        self.sleep_time = 1
        self.str_start = """reqs-comps-数据生成
        component,fx,fy,fz,tx,ty,tz,
        request,req1,req2,req3,req4,req5,req6,req7
        次特征,front,front,,rear,rear,,front,
        """

        self.create_csv()

        params = self.reading()
        self.reqs = params['reqs']
        self.comps = params['comps']
        # print(self.reqs, self.comps)

    # @pysnooper.snoop()
    def create_csv(self):

        with open(self.csv_path, 'w') as f:
            f.write(self.str_start)
        os.popen(self.csv_path)
        # print('create_csv')

        return None

    # @pysnooper.snoop()
    def reading(self,sleep_time=None):
        if sleep_time==None:
            self.sleep_time = 1
        else:
            self.sleep_time = sleep_time

        while True:
            try:
                self.param_dic = self.csv_read()        
                os.remove(self.csv_path)
                # print(True)
                break
            except:
                time.sleep(self.sleep_time)
                # print(False)

        return self.param_dic

    # @pysnooper.snoop()
    def csv_read(self,strs=None):

        csv_path = self.csv_path
        with open(csv_path,'r') as f:
            lines = f.read()
        lines = lines.split('\n')

        comps = [ re.sub(r'\s','',value) for value in lines[1].split(',')[1:] if value]
        reqs = [ re.sub(r'\s','',value) for value in lines[2].split(',')[1:] if value]

        minors = [ re.sub(r'\s','',value) for value in lines[3].split(',')[1:] ]
        del minors[len(reqs):]
        new_minors = []
        for minor in minors:
            if minor:
                minor = '_'+minor
            new_minors.append(minor)

        new_reqs,new_comps = [],[]
        for loc,req in enumerate(reqs):
            temp_list_reqs = [req]*len(comps)
            new_reqs += temp_list_reqs
            temp_list_comps = [comp+new_minors[loc] for comp in comps]
            new_comps += temp_list_comps

        params = {}
        params['reqs'] = new_reqs
        params['comps'] = new_comps
        # print(params)

        return params

    def create_txt(self):
        str_reqs = ','.join(self.reqs)
        str_comps = ','.join(self.comps)
        str_title = ','.join([req+'.'+comp for req,comp in zip(self.reqs, self.comps)])

        return '-----requests-----\n'+str_reqs+\
            '\n\n-----components-----\n'+str_comps+\
            '\n\n-----title-----\n'+str_title+'\n\n'

import pyadams.ui.tkui as tkui
TkUi = tkui.TkUi

class ReqComTxtUi1(TkUi):
    def __init__(self, title, frame=None):
        super().__init__(title, frame=frame)
        str_label = '-'*50

        self.frame_text_lines({
            'frame':'strs',
            'text_name':'strs',
            'text_width':80, 'text_height':30,
            })

        obj = ReqComTxt(r'temp.csv')
        self.set_text('strs',obj.create_txt())
        #self.run()

class ReqComTxtUi(TkUi):

    def __init__(self, title, frame=None):
        
        super().__init__(title, frame=frame)

        self.frame_label_only({'label_text':'序号','label_width':5,'frame':'titles'})
        self.frame_label_only({'label_text':'request','label_width':40,'frame':'titles'})
        self.frame_label_only({'label_text':'minor','label_width':8,'frame':'titles'})
        self.frame_label_only({'label_text':'component','label_width':10,'frame':'titles'})
        self.frame_label_only({'label_text':'结果','label_width':40,'frame':'titles'})
        

        self.frame_text_lines({
            'frame':'input',
            'text_name':'nums',
            'text_width':5, 'text_height':30,
            'isExpand':True,
            })


        self.frame_text_lines({
            'frame':'input',
            'text_name':'reqs',
            'text_width':40, 'text_height':30,
            'isExpand':True,
            })

        self.frame_text_lines({
            'frame':'input',
            'text_name':'minors',
            'text_width':8, 'text_height':30,
            'isExpand':True,
            })
        
        self.frame_text_lines({
            'frame':'input',
            'text_name':'comps',
            'text_width':10, 'text_height':30,
            'isExpand':True,
            })

        self.frame_text_lines({
            'frame':'input',
            'text_name':'strs',
            'text_width':40, 'text_height':30,
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

        self.set_text('nums', '\n'.join([str(n) for n in range(1,100)]))
        self.set_text('reqs', '\n'.join(['test1','test2','test3']))
        self.set_text('minors', '\n'.join(['front','','rear']))
        self.set_text('comps', '\n'.join(['Fx','Fy','Fz','Tx','Ty','Tz']))

        for frame_key in self.frames:
            for obj in self.frames[frame_key].winfo_children():
                obj.pack(side=tk.LEFT, expand=tk.YES)

        self.frames['input'].pack(expand=tk.YES, fill=tk.BOTH)
        self.frames['titles'].pack(expand=tk.NO)
        self.frames['rrw'].pack(expand=tk.NO, fill=tk.Y)
        self.text['strs'].pack(expand=tk.NO, fill=tk.Y)
        self.text['minors'].pack(expand=tk.NO, fill=tk.Y)
        self.text['nums'].pack(expand=tk.NO, fill=tk.Y)

    
    def fun_run(self):
        params = self.get_vars_and_texts()

        reqs    = params['reqs']
        comps   = params['comps']
        minors  = params['minors']
        reqs = [req.replace(' ','') for req in reqs.split('\n') if req]
        comps = [comp.replace(' ','') for comp in comps.split('\n') if comp]
        minors = [minor.replace(' ','') for minor in minors.split('\n')]
        if len(minors) < len(reqs):
            for n in range(len(reqs)-len(minors)):
                minors.append('')

        # str_reqs = 

        new_minors = []
        for minor in minors:
            if minor:
                minor = '_'+minor
            new_minors.append(minor)

        new_reqs,new_comps = [],[]
        for loc,req in enumerate(reqs):
            temp_list_reqs = [req]*len(comps)
            new_reqs += temp_list_reqs
            temp_list_comps = [comp+new_minors[loc] for comp in comps]
            new_comps += temp_list_comps

        # print(reqs,comps,minors)
        # print(new_reqs, new_comps)

        self.reqs = new_reqs
        self.comps = new_comps
        strs = self.create_txt()
        self.set_text('strs', strs)

    def create_txt(self):
        str_reqs = ','.join(self.reqs)
        str_comps = ','.join(self.comps)
        str_title = ','.join([req+'.'+comp for req,comp in zip(self.reqs, self.comps)])

        return '-----requests-----\n'+str_reqs+\
            '\n\n-----components-----\n'+str_comps+\
            '\n\n-----title-----\n'+str_title+'\n\n'



if __name__ == '__main__':
    
    # ReqComTxtUi('ReqsComps')

    ReqComTxtUi('ReqsComps').run()
    
