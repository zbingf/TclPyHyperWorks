# tcl codes

# 路径拼接
set path [file join test $csv_name]

# 列表
set csv_paths [list]
# 添加列表
lappend csv_paths $csv_path_n


# 自加
set i 0
set i [ expr $i+1 ]


# 文件处理 ---------------------------------------
# 删除
file delete $filename
# 复制
file copy $filename new.txt
# 重命名
file rename $file new.bmp
# 查找文件
set filename [glob *.png]

# 文件写入
set f_obj [open $file_path w]
puts $f_obj "asdf"
close $f_obj

# -----------------------------------------------

# 设置当前目录
cd $dict


# python 运行
set test [exec python $csv_paths]



eval "set datalist \"$pyResult\"" 



# -----------------------------------------------

# 字典
dict set point_target_dic $point_id "$loc1"
set value [dict get $point_target_dic $point_id]
