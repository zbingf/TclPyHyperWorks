#
# if {![package vsatisfies [package provide Tcl] 8.5]} {return}


set script_dir [file dirname [info script]]

package ifneeded SubGeometry 1.0 [list source -encoding utf-8 [file join $script_dir SubGeometry.tcl]]
package ifneeded SubHm 1.0 [list source -encoding utf-8 [file join $script_dir SubHm.tcl]]
package ifneeded SubTk 1.0 [list source -encoding utf-8 [file join $script_dir SubTk.tcl]]


# # source main unitcell package
# package ifneeded UnitCell 1.0 [list source -encoding utf-8 [file join $dir UnitCell_cls.tcl]]

# package ifneeded MDS_ParaUC 1.0 [list source -encoding utf-8 [file join $dir MDS_ParaUC.tcl]]
