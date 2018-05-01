###########################################################
set QUARTUS_INSTALL_DIR "F:/altera/14.0/quartus"
# 定义顶层模块
set TOP_LEVEL_NAME "tb_cnn"

# 包含qsys仿真目录
set QSYS_SIMDIR "../"
# 然后source 一下自己的仿真 模块
source ./msim_setup.tcl
file_copy
dev_com
###########################################################
# 下面的是要一直【更新】-->【运行】的！
user_com
# the "elab_debug" macro avoids optimizations which preserves signals so that they may be # added to the wave viewer
elab_debug

# 添加波形
#add wave "$TOP_LEVEL_NAME/fp*"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst*"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cstate"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/delay"

add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/cnn_inst*"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/OP*"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/Dollar*"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/M"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/N"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/P"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/Km"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/Kn"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/Pm"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/Pn"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/GPC*"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/cstate*"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/substate*"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/ddr_*"
#add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/vec_mac_*"
#add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/cnn_scfifo_256pts_Dollar*_rdusedw"
#add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/cnn_scfifo_256pts_Dollar3_rdempty*"
#add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/cnn_conv_kernel*"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/taps*"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/pixs*"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/cnn_conv_sum*"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/ddr_write_cnt"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/cnn_scfifo_256pts_Dollar3_wrreq"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/cnn_scfifo_256pts_Dollar3_data"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/cnn_ram_256pts_inst_*_wraddress"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/cnn_ram_256pts_inst_*_wren"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/cnn_ram_256pts_inst_*_data"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/cnn_ram_256pts_inst_*_rdaddress"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/cnn_ram_256pts_inst_*_q"

# exp计算
#add wave "$TOP_LEVEL_NAME/x_in_"
#add wave "$TOP_LEVEL_NAME/rho_exp"
#add wave "$TOP_LEVEL_NAME/rho_tanh"

# 观察SSRAM读写的负荷
add wave "$TOP_LEVEL_NAME/top_inst/mux_ddr_access_inst/cstate"
add wave "$TOP_LEVEL_NAME/top_inst/mux_ddr_access_inst/wport_addr_0_fifo_rdusedw"
add wave "$TOP_LEVEL_NAME/top_inst/mux_ddr_access_inst/rport_addr_1_fifo_rdusedw"
add wave "$TOP_LEVEL_NAME/top_inst/mux_ddr_access_inst/wport_addr_2_fifo_rdusedw"
add wave "$TOP_LEVEL_NAME/top_inst/mux_ddr_access_inst/rport_addr_3_fifo_rdusedw"
add wave "$TOP_LEVEL_NAME/top_inst/mux_ddr_access_inst/wport_addr_4_fifo_rdusedw"
add wave "$TOP_LEVEL_NAME/top_inst/mux_ddr_access_inst/rport_addr_5_fifo_rdusedw"

# 观察RGB变换
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/RGB*"
add wave "$TOP_LEVEL_NAME/top_inst/cnn_inst_executor_inst/cnn_inst_parser_inst/YUV*"

# 然后是SSRAM里面读取出来的数据进入FIFO后的数量计算
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/alt_fifo_16b_4096w_line_buf_inst/wrusedw"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/OPTICAL_SDRAM_INST/wrusedw"
add wave "$TOP_LEVEL_NAME/top_inst/MT9D111_SDRAM_INST/wrusedw"

radix hexadecimal

#run 500us
run -all