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

# 将三个子模块的PD检测结果输出进行观察
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/RGB565_HCnt*"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/RGB565_VCnt*"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/svm_judge_HCnt*"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/svm_judge_VCnt*"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/svm_judge_res*"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/cstate*"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/DDR*"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_200x150_inst/RGB565_*"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_200x150_inst/VSYNC"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_200x150_inst/HSYNC"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_200x150_inst/Mxy_Stat_Mean"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_200x150_inst/Mxy_Stat_Norm"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_200x150_inst/Mxy_Stat_Norm_En"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_200x150_inst/Mxy_Stat_Norm_Block_Feature"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_200x150_inst/Mxy_Stat_Norm_Block_Feature_En"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_200x150_inst/HSG_Feature_VCnt"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_200x150_inst/HSG_Feature_HCnt"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_200x150_inst/HSG_Feature_In_Window"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_200x150_inst/HSG_Feature_In_Window_En"
#add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_200x150_inst/line_buf_80pts_13lines_window_inst/taps*"
#add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/RGB565_D_1_1*"
#add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/RGB565_D_1_2*"
#add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/Ix"
#add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/Iy"
#add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/magnitude_xy"
#add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/orientation_xy"
#add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/mag_orient_xy_en"
#add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/__I*"
#add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/Mxy"
#add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/Bxy"
#add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/Bxy2"
#add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/debug_Bxy"
#add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/MBxyEn"
#add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/_I*"
#add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/svm_vut_scfifo_3528x16_inst/usedw"
#add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_400x300_inst/window_num"
#add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_200x150_inst/svm_vut_scfifo_q"
#add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_200x150_inst/svm_vut_scfifo_HSG"
#add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_200x150_inst/svm_judge_sum"

add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/RGB565*"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/VSYNC"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/HSYNC"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/DE"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/Ixyt"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/Ixm1yt"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/Ixym1t"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/Ix"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/Iy"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/IxIyItEn"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/magnitude_xy"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/orientation_xy"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/Mxy"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/Bxy"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/Bxy_DEC"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/MBxyEn"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/PixCnt"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/Mxy_C10*"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/LineCnt"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/Mxy_Stat_Mean"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/Mxy_Stat_Norm"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/Mxy_Stat_Norm_Prev"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/Mxy_Stat_Norm_En"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/Mxy_Stat_Norm_Block"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/Mxy_Stat_Norm_Block_Feature"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/Mxy_Stat_Norm_Block_Feature_En"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/Mxy_Stat_Norm_Block_Feature_Prev"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/HSG_Feature_In_Window_Shifter"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/svm_vut_scfifo_data"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/HSG_Feature_In_Window_En"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/svm*sum*"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/svm*_HSG_seg*"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/svm_parameter"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/svm_vut_scfifo_rdreq_shifter"
add wave "$TOP_LEVEL_NAME/top_inst/hog_svm_pd_rtl_inst/hog_svm_pd_800x600_inst/cstate*"



radix decimal

run 2000ns
#run -all