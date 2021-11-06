

hwi GetSessionHandle sess;
sess GetClientManagerHandle mgr plot;
mgr GetBuildPlotsCtrlHandle build;
build SelectDataFile “D:/github/TclPyHyperWorks/hg2d/mrf_file/event_Altoonal_6.mrf” false;




# 数据导出
hwi GetSessionHandle sess;
sess GetClientManagerHandle pm Plot;
pm GetExportCtrlHandle ex
ex SetFormat “RPC”
ex SetFilename "D:/github/TclPyHyperWorks/hg2d/abf_file/export.rsp"
ex GetFilename
ex Export
hwi CloseStack


# 当前激活的name
# build GetActiveFilename

# 清空
# build ClearDataFileSet 