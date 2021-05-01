# Copyright (C) 2020  Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions 
# and other software and tools, and any partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License 
# Subscription Agreement, the Intel Quartus Prime License Agreement,
# the Intel FPGA IP License Agreement, or other applicable license
# agreement, including, without limitation, that your use is for
# the sole purpose of programming logic devices manufactured by
# Intel and sold by Intel or its authorized distributors.  Please
# refer to the applicable agreement for further details, at
# https://fpgasoftware.intel.com/eula.

# Quartus Prime: Generate Tcl File for Project
# File: Basic_Organ_Solution.tcl
# Generated on: Sat May 01 09:25:37 2021

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "Basic_Organ_Solution"]} {
		puts "Project Basic_Organ_Solution is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists Basic_Organ_Solution]} {
		project_open -revision Basic_Organ_Solution Basic_Organ_Solution
	} else {
		project_new -revision Basic_Organ_Solution Basic_Organ_Solution
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
    # import directory of the prokect setup scripts
    set project_setup [file dirname [info script]]

    # Set global assignments, collect source files
    source [file join $project_setup global_assignments.tcl]

    # Set pin assignments
    source [file join $project_setup pin_assignments.tcl]

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
