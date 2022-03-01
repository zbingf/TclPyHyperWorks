# hvAutoRun.tcl


set file_dir [file dirname [info script]]
set target_tcl [format "%s/hvSumH3dDamage.tcl" $file_dir]
source $target_tcl
main_auto

hwc hwd window type=HyperMesh
*quit 1
# destroy .

set file_dir [file dirname [info script]]
set param_file [format "%s/__calc_end" $file_dir]
set FileChannelID [open $param_file w]
close $FileChannelID
