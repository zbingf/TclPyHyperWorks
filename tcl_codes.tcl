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


# 文件处理
# 删除
file delete $filename
# 复制
file copy $filename new.txt
# 重命名
file rename $file new.bmp
# 查找文件
set filename [glob *.png]

# 设置当前目录
cd $dict

# python 运行
set test [exec python $csv_paths]