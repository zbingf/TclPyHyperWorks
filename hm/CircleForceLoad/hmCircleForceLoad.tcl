
# source "D:/github/TclPyHyperWorks/hm_v2/CircleForceLoad/hmCircleForceLoad.tcl"

# 路径定义
set script_dir [file dirname [info script]]
set p_script_dir [file dirname $script_dir]

set sub_dir $p_script_dir
if {$p_script_dir in $auto_path} {} else {
    lappend auto_path $p_script_dir   
} 

package require SubGeometry 1.0
package require SubHm 1.0
package require SubTk 1.0


proc create_circle_force_load {start_angle end_angle num value} {

    *createmarkpanel nodes 1
    set node_id [hm_getmark nodes 1]
    if {$node_id==""} { return; }
    set center_loc [get_loc_by_node $node_id]

    *createmarkpanel vectors 1
    set vector_id [hm_getmark vectors 1]
    if {$vector_id==""} { return; }
    set v_u [get_v_by_vector $vector_id]

    *createmarkpanel vectors 1 "surf_v"
    set vector_id [hm_getmark vectors 1]
    if {$vector_id==""} { return; }
    set surf_v [get_v_by_vector $vector_id]

    set v_v [v_multi_x $v_u $surf_v]

    set node_ids [create_circle_nodes_with_vector_start_end $v_v $v_u $center_loc 1 $num $start_angle $end_angle]
    set num_node [llength $node_ids]

    if {$num_node==1} {
        set single_angle [expr (double($end_angle - $start_angle)) / (double($num_node))]
    } else {
        set single_angle [expr (double($end_angle - $start_angle)) / (double($num_node)-1)]        
    }

    for { set i 0 } { $i < $num_node } { incr i 1 } {
        set cur_angle [expr $single_angle * $i + $start_angle]
        if {$cur_angle > [expr $end_angle + $single_angle*0.1]} {break}

        set cur_node_id [lindex $node_ids $i]
        set cur_loc [get_loc_by_node $cur_node_id]
        set cur_v [v_one [v_sub $cur_loc $center_loc]]
        set cur_force_values [v_multi_c $cur_v $value]

        puts "cur_angle:$cur_angle"
        puts "cur_force_values: $cur_force_values"


        *createentity loadcols name="force_$cur_angle\_deg"


        *createmark nodes 1 $node_id
        eval "*loadcreateonentity_curve nodes 1 1 1 $cur_force_values 0 0 $value 0 0 0 0 0"

        *createmark loadcols 1 "force_$cur_angle\_deg"
        set cur_loadcol_id [hm_getmark loadcols 1]    

        *loadstepscreate "load_force_$cur_angle\_deg" 1
        *createmark loadsteps 1 "load_force_$cur_angle\_deg"
        set cur_loadstep_id [hm_getmark loadsteps 1]
        
        *attributeupdatestring loadsteps $cur_loadstep_id 4060 1 1 0 "STATICS"
        *attributeupdateentity loadsteps $cur_loadstep_id 4147 1 1 0 loadcols $cur_loadcol_id
        *attributeupdateint loadsteps $cur_loadstep_id 4709 1 1 0 1

    }
}


# -----------------------------------------------
namespace eval ::hmCircleForceLoad {
    variable width 300
    variable height 200
    variable entry_width 16
    variable button_width 16
    variable recess
    variable file_dir [file dirname [info script]]

    variable start_angle 0
    variable end_angle 180
    variable num_load 3
    variable force_value 100
}


proc ::hmCircleForceLoad::fun_calc { args } {
    variable start_angle 
    variable end_angle 
    variable num_load 
    variable force_value

    create_circle_force_load $start_angle $end_angle $num_load $force_value
}


proc ::hmCircleForceLoad::fun_clear {args} \
{
    variable start_angle []
    variable end_angle []
    variable num_load []
    variable force_value []
}



::zbingf_UI::main_ui_start hmCircleForceLoad
::zbingf_UI::tk_entry hmCircleForceLoad "start_angle" 1 start_angle 
::zbingf_UI::tk_entry hmCircleForceLoad "end_angle" 2 end_angle 
::zbingf_UI::tk_entry hmCircleForceLoad "num_load" 3 num_load 
::zbingf_UI::tk_entry hmCircleForceLoad "force_value" 4 force_value 
::zbingf_UI::tk_button hmCircleForceLoad "clear" 5 fun_clear
::zbingf_UI::main_ui_end hmCircleForceLoad


