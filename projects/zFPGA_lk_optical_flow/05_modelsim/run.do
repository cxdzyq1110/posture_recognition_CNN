###########################################################
set QUARTUS_INSTALL_DIR "F:/altera/14.0/quartus"
# 定义顶层模块
set TOP_LEVEL_NAME "tb"

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
add wave "$TOP_LEVEL_NAME/MT9D*"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/MON*"
add wave "$TOP_LEVEL_NAME/top_inst/FRAME_PREV*"
add wave "$TOP_LEVEL_NAME/top_inst/FRAME_CURR*"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/cstate*"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/alt_fifo_16b_4096w_line_buf_inst/rd*"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/wrpix_cnt"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/RGB565_VSYNC"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/RGB565_HSYNC"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/RGB565_D"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/RGB565_DE"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/YUV422_VSYNC"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/YUV422_HSYNC"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/YUV422_D_curr"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/YUV422_D_prev"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/YUV422_DE"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/HSYNC"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/VSYNC"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/Ixyt"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/Ixm1yt"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/Ixym1t"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/Ixytm1"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/Ix"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/Iy"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/It"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/IxIyItEn"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/IxIx_sum"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/IxIy_sum"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/IyIy_sum"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/IxIt_sum"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/IyIt_sum"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/alt_lpm_divider_inst_u.denom"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/alt_lpm_divider_inst_u.numer"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/alt_lpm_divider_inst_v.denom"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/alt_lpm_divider_inst_v.numer"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/optical_u_0"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/optical_v_0"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/optical_uv_en"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/optical_u_9"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/optical_v_9"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/optical_uv"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/optical_threshold_judge"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/optical_rho"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/optical_phase"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/optical_rho_phase_en"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/DDR*"

# 观察SSRAM读写的负荷
add wave "$TOP_LEVEL_NAME/top_inst/mux_ddr_access_inst/cstate"
add wave "$TOP_LEVEL_NAME/top_inst/mux_ddr_access_inst/wport_addr_0_fifo_rdusedw"
add wave "$TOP_LEVEL_NAME/top_inst/mux_ddr_access_inst/rport_addr_1_fifo_rdusedw"
add wave "$TOP_LEVEL_NAME/top_inst/mux_ddr_access_inst/wport_addr_2_fifo_rdusedw"
add wave "$TOP_LEVEL_NAME/top_inst/mux_ddr_access_inst/rport_addr_3_fifo_rdusedw"
add wave "$TOP_LEVEL_NAME/top_inst/mux_ddr_access_inst/wport_addr_4_fifo_rdusedw"
add wave "$TOP_LEVEL_NAME/top_inst/mux_ddr_access_inst/rport_addr_5_fifo_rdusedw"

# 然后是SSRAM里面读取出来的数据进入FIFO后的数量计算
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/alt_fifo_16b_4096w_line_buf_inst/wrusedw"
add wave "$TOP_LEVEL_NAME/top_inst/OpticalFlowLK_inst/OPTICAL_SDRAM_INST/wrusedw"
add wave "$TOP_LEVEL_NAME/top_inst/MT9D111_SDRAM_INST/wrusedw"

radix decimal

run 500us