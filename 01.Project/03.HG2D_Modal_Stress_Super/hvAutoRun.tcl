# hvAutoRun.tcl


set file_dir [file dirname [info script]]
set target_tcl [format "%s/__temp.tcl" $file_dir]
source $target_tcl

hwc hwd window type=HyperMesh
*quit 1
# destroy .
