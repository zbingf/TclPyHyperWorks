

import hmElemToNcodeGroup
import tkui

TkUi = tkui.TkUi


class ElemToNcodeGroupUI(TkUi):

    def __init__(self, title):
        super().__init__(title)
        str_label = '-'*40

        self.frame_loadpath({
            'frame':'fem_path', 'var_name':'fem_path', 'path_name':'fem file',
            'path_type':'.fem', 'button_name':'基础fem路径',
            'button_width':30, 'entry_width':40,
            })

        self.frame_savepath({
            'frame':'asc_path', 'var_name':'asc_path', 'path_name':'asc_path',
            'path_type':'.asc', 'button_name':'asc 路径\n[Ncode User Group]',
            'button_width':30, 'entry_width':40,
            })

        self.frame_entry({
            'frame':'set_id','var_name':'set_id','label_text':'计算目标set的ID【1位】',
            'label_width':30,'entry_width':30,
            })

        self.frame_entry({
            'frame':'fun_lambda','var_name':'fun_lambda','label_text':'prop2mat name\nlambda函数\n根据属性名称获取材料属性名称',
            'label_width':30,'entry_width':30,
            })

        self.frame_entry({
            'frame':'suffix','var_name':'suffix','label_text':'后缀suffix',
            'label_width':30,'entry_width':30,
            })

        self.frame_label_only({
            'label_text':'-------------\nset格式要求: $HMSETTYPE "regular";\n 需使用Hm Export导出fem!!!;\n关注输出数据是否完整;\n-------------',
            'label_width':15,
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

        self.vars['fun_lambda'].set("lambda propname: propname.split('_')[2]")
        self.vars['suffix'].set("_C")


    def fun_run(self):
        """
            运行按钮调用函数
            主程序
        """
        # 获取界面数据
        params = self.get_vars_and_texts()
        # print(params)
        fem_path = params['fem_path']
        asc_path = params['asc_path']
        set_id = str(params['set_id'])
        fun_lambda = params['fun_lambda']
        suffix = params['suffix']

        self.print('\n\n----开始计算----\n\n')

        cal_elem_num = hmElemToNcodeGroup.main_by_Setid(fem_path, asc_path, set_id,fun_lambda=fun_lambda,suffix=suffix)

        self.print('\n\n----计算结束----\n\n  辨识的elem单元数量: {}'.format(cal_elem_num))



        return True

if __name__=='__main__':

    ElemToNcodeGroupUI('HM 2021.1 SET转Ncode User Group').run()