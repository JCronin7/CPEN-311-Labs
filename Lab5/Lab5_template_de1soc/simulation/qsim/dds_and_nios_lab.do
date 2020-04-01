onerror {exit -code 1}
vlib work
vlog -work work dds_and_nios_lab.vo
vlog -work work Waveform.vwf.vt
vsim -novopt -c -t 1ps -L cyclonev_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate_ver -L altera_lnsim_ver work.dds_and_nios_lab_vlg_vec_tst -voptargs="+acc"
vcd file -direction dds_and_nios_lab.msim.vcd
vcd add -internal dds_and_nios_lab_vlg_vec_tst/*
vcd add -internal dds_and_nios_lab_vlg_vec_tst/i1/*
run -all
quit -f
