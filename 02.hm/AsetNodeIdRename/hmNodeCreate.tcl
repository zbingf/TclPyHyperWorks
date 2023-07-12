

set file_path [file dirname [info script]]
set py_path  [format "%s/hmNodeCreate.py" $file_path]
set tcl_path [format "%s/__temp_create_node.tcl" $file_path]

puts "python-call running $py_path"
set result_py [exec python $py_path]
puts "python-call end"

if { $result_py == "True" } {
	puts "tcl-call running $tcl_path"
	set result_tcl [source $tcl_path]
	puts "tcl-call end"
}

# catch { file delete $tcl_path }

puts "------------hmNodeCreate run end------------"

