# hyperview tcl代码

# 路径定义
set filepath [file dirname [info script]]
global filepath

# 句柄创建-single
proc pre_set_single { } {
    catch { 
        # hwISession 创建
        hwi GetSessionHandle sessObj }
    catch { 
        # hwIProject 创建
        sessObj GetProjectHandle proObj
    }
    catch { 
        # hwIPage 创建
        proObj GetPageHandle pagObj [proObj GetActivePage]
    }
    catch { 
        # hwIWindow 创建
        pagObj GetWindowHandle winObj [pagObj GetActiveWindow]
    }
    catch { 
        # 获取 Client , 当前为 polPost
        winObj GetClientHandle postObj
    }
    catch { 
        # polModel 创建
        postObj GetModelHandle modelObj [postObj GetActiveModel]
    }
    catch { 
        # polResultCtrl 创建
        modelObj GetResultCtrlHandle resultObj
    }
    catch { 
        # polContourCtrl 创建
        resultObj GetContourCtrlHandle contourObj
    }
    catch { 
        # polLegend 创建
        contourObj GetLegendHandle legendObj
    }
    catch {
        # 
        winObj GetViewControlHandle viewCtrObj
    }
}


# 释放句柄
proc release_obj {} {
    catch { sessObj ReleaseHandle }
    catch { proObj ReleaseHandle }
    catch { pagObj ReleaseHandle }
    catch { winObj ReleaseHandle }
    catch { postObj ReleaseHandle }
    catch { modelObj ReleaseHandle }
    catch { resultObj ReleaseHandle }
    catch { contourObj ReleaseHandle }
    catch { legendObj ReleaseHandle }
    catch { viewCtrObj ReleaseHandle }

    catch { elemObj ReleaseHandle }
    catch { qryObj ReleaseHandle }
}


# 获取当前 subcase ID
proc get_current_subcase_id { } {
    return [resultObj GetCurrentSubcase]
}


# 设置当前subcase
proc set_current_subcase {id_n} {
    # id_n : ID号输入
    resultObj SetCurrentSubcase $id_n
    return true
}


# 重画
proc post_draw {} {
    legendObj   SetType             dynamic
    contourObj  SetEnableState      true
    contourObj  SetDataType         Stress
    contourObj  SetDataComponent    vonMises
    postObj     SetDisplayOptions   "contour"   true
    postObj     SetDisplayOptions   "legend"    true
    postObj     Draw    
}


# 云图范围输出 csv
proc counter_elem_limit_out {limit_set csv_path} {
    # limit_set : 输出区间设置
    #   < 15  
    #   > 15
    # csv_path : csv存储路径

    set setid  [ modelObj  AddSelectionSet element ]
    modelObj GetSelectionSetHandle elemObj $setid 
    # poISelectionSet Add
    elemObj Add "contour $limit_set"
    modelObj GetQueryCtrlHandle qryObj 
    # poIQueryCtrl SetQuery
    # 指定输出内容
    qryObj SetQuery "element.id,contour.value,misc.sim"
    qryObj SetSelectionSet $setid
    qryObj WriteData $csv_path
    modelObj RemoveSelectionSet $setid 
    catch { elemObj ReleaseHandle }
    catch { qryObj ReleaseHandle }
}


# 主程序测试
proc main {} {

    # 当前路径
    global filepath
    set csv_paths [list]

    # ================================
    hwi OpenStack
    release_obj
    pre_set_single
    # set setid  [ modelObj  AddSelectionSet element ]
    # modelObj GetSelectionSetHandle elemObj $setid 
    # ================================
    set cur_sims [ resultObj GetSimulationList [get_current_subcase_id] ]
    set cur_subcases [resultObj GetSubcaseList]
    puts "Sims : $cur_sims"
    puts "Subcases : $cur_subcases"
    # return None
    # set num [llength $cur_subcases]
    # if {$num==1} {set cur_subcases [list $cur_subcases]}

    set i_sim 0
    set i_subcase 1 
    foreach id_subcase $cur_subcases {

        foreach sim_name $cur_sims {
            
            # ==================
            puts "sim_name: $sim_name ; cur_loc: $i_sim ; cur_subcase: $i_subcase ;"
            # 设置当前Simulation
            resultObj SetCurrentSimulation $i_sim
            # 设置视角
            # viewCtrObj SetViewMatrix "0.627365 -0.395400 0.670874 0.000000 -0.016645 0.854497 0.519190 0.000000 -0.778547 -0.336888 0.529500 0.000000 1003.278625 3526.162109 -3941.458496 1.000000"
            post_draw

            # ==================
            # postObj     Draw
            # 截图名称
            # sessObj CaptureScreen png test_$i_sim.png
            sessObj CaptureScreen png [file join $filepath "test_$i_sim.png"]
            # sessObj CaptureAnimation gif test_$i_sim.gif
            sessObj CaptureAnimation gif [file join $filepath "test_$i_sim.gif"]

            

            # ==================
            # 云图-csv导出
            # set csv_name "result_$i.csv"
            set csv_path [file join $filepath "result_$i_sim.csv"]
            counter_elem_limit_out "<100" $csv_path

            # ==================
            set i_sim [ expr $i_sim+1 ]
            lappend csv_paths $csv_path
        }
        set i_subcase [ expr $i_subcase+1 ]
    }

    # postObj CaptureImage asd.jpg

    # postObj CaptureImageByRegion MODELSONLY D:/temp_delet/temp/asd.jpg 4

    # modelObj GetSelectionSetHandle

    # postObj GetSectionHandle sectionObj
    # set ori_str [sectionObj GetOrientation]
    # puts ori_str
    # sectionObj SetOrientation 

    # ================================
    # postObj Clear

    # puts "=========="
    # puts [hwi ListAllHandles]
    # puts "=========="
    release_obj
    # puts [hwi ListAllHandles]
    # puts "=========="
    hwi CloseStack

    # ================================
    return $csv_paths
}

# cd "D:/github/TclPyHyperWorks/hv/hvCounterCsv"
set csv_paths [main]
puts $csv_paths

catch {
    release_obj
    hwi CloseStack
}
set test [exec python csv_read.py $csv_paths]
puts $test

# source D:/github/TclPyHyperWorks/hv/hvCounterCsv/hvCounterCsv.tcl


