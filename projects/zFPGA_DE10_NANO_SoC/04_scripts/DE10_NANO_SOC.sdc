#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
create_clock -period "50.0 MHz" [get_ports FPGA_CLK1_50]
create_clock -period "50.0 MHz" [get_ports FPGA_CLK2_50]
create_clock -period "50.0 MHz" [get_ports FPGA_CLK3_50]

# for enhancing USB BlasterII to be reliable, 25MHz
create_clock -name {altera_reserved_tck} -period 40 {altera_reserved_tck}

# MT9D111
create_clock -name {MT9D111_PCLK} -period 25 {get_ports GPIO_0[6]}


#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty



#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]


set_input_delay -clock MT9D111_PCLK 	2		[get_ports GPIO_0[8]]
set_input_delay -clock MT9D111_PCLK 	2		[get_ports GPIO_0[9]]
set_input_delay -clock MT9D111_PCLK 	2		[get_ports GPIO_0[12]]
set_input_delay -clock MT9D111_PCLK 	2		[get_ports GPIO_0[13]]
set_input_delay -clock MT9D111_PCLK 	2		[get_ports GPIO_0[14]]
set_input_delay -clock MT9D111_PCLK 	2		[get_ports GPIO_0[15]]
set_input_delay -clock MT9D111_PCLK 	2		[get_ports GPIO_0[16]]
set_input_delay -clock MT9D111_PCLK 	2		[get_ports GPIO_0[17]]
set_input_delay -clock MT9D111_PCLK 	2		[get_ports GPIO_0[18]]
set_input_delay -clock MT9D111_PCLK 	2		[get_ports GPIO_0[19]]




#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -clock altera_reserved_tck 3 [get_ports altera_reserved_tdo]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from {get_ports KEY*} -to {*}
set_false_path -from {get_ports SW*} -to {*}
set_false_path -from {*} -to {get_ports LED*}
set_false_path -from {*} -through {HPS2FPGA_RESETN} -to {*}

set_false_path -from {soc_system:u0|soc_system_led_pio:led_pio|data_out*} -to {*}
set_false_path -from {video_process:video_process_inst|line_buffer_clear} -to {*}
set_false_path -from {video_process:video_process_inst|MT9D111_FrameFlag*} -to {*}
set_false_path -from {cnn_inst_executor:cnn_inst_executor_inst|cnn_inst_ready*} -to {*}
set_false_path -from {cnn_inst_executor:cnn_inst_executor_inst|cnn_inst_time*} -to {*}


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Load
#**************************************************************



