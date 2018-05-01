
# ----------------------------------------
# Auto-generated simulation script

# ----------------------------------------
# Initialize variables
if ![info exists SYSTEM_INSTANCE_NAME] { 
  set SYSTEM_INSTANCE_NAME ""
} elseif { ![ string match "" $SYSTEM_INSTANCE_NAME ] } { 
  set SYSTEM_INSTANCE_NAME "/$SYSTEM_INSTANCE_NAME"
}

if ![info exists TOP_LEVEL_NAME] { 
  set TOP_LEVEL_NAME "test_cordic"
}

if ![info exists QSYS_SIMDIR] { 
  set QSYS_SIMDIR "./../"
}

if ![info exists QUARTUS_INSTALL_DIR] { 
  set QUARTUS_INSTALL_DIR "C:/altera/13.0/quartus/"
}

# ----------------------------------------
# Initialize simulation properties - DO NOT MODIFY!
set ELAB_OPTIONS ""
set SIM_OPTIONS ""
if ![ string match "*-64 vsim*" [ vsim -version ] ] {
} else {
}

# Copy ROM/RAM files to simulation directory
alias file_copy {
  echo "\[exec\] file_copy"
  file copy -force $QSYS_SIMDIR/00_user_logic/vga_config.inc ./
}
# ----------------------------------------
# Create compilation libraries
proc ensure_lib { lib } { if ![file isdirectory $lib] { vlib $lib } }
ensure_lib          ./libraries/     
ensure_lib          ./libraries/work/
vmap       work     ./libraries/work/
vmap       work_lib ./libraries/work/
if ![ string match "*ModelSim ALTERA*" [ vsim -version ] ] {
  ensure_lib                       ./libraries/altera_ver/           
  vmap       altera_ver            ./libraries/altera_ver/           
  ensure_lib                       ./libraries/lpm_ver/              
  vmap       lpm_ver               ./libraries/lpm_ver/              
  ensure_lib                       ./libraries/sgate_ver/            
  vmap       sgate_ver             ./libraries/sgate_ver/            
  ensure_lib                       ./libraries/altera_mf_ver/        
  vmap       altera_mf_ver         ./libraries/altera_mf_ver/        
  ensure_lib                       ./libraries/altera_lnsim_ver/     
  vmap       altera_lnsim_ver      ./libraries/altera_lnsim_ver/           
}
# ----------------------------------------
# Compile device library files
alias dev_com {
  echo "\[exec\] dev_com"
  if ![ string match "*ModelSim ALTERA*" [ vsim -version ] ] {
    vlog -incr      "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v"                     -work altera_ver           
    vlog -incr      "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v"                              -work lpm_ver              
    vlog -incr      "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v"                                 -work sgate_ver            
    vlog -incr      "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v"                             -work altera_mf_ver        
    vlog -incr  -sv "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"                         -work altera_lnsim_ver          
  }
}

# --------------------------
# user files compile
alias user_com {      
vlog -incr  	   "../01_altera_ip/line_buf_20pts_9lines/line_buf_20pts_9lines.v"    
vlog -incr  	   "../01_altera_ip/line_buf_20pts_1lines/line_buf_20pts_1lines.v"    
vlog -incr  	   "../01_altera_ip/line_buf_20pts_13lines/line_buf_20pts_13lines.v"   
vlog -incr  	   "../01_altera_ip/line_buf_200pts_1line16/line_buf_200pts_1line16.v"  
vlog -incr  	   "../01_altera_ip/line_buf_200pts_2lines/line_buf_200pts_2lines.v"  
vlog -incr  	   "../01_altera_ip/line_buf_40pts_9lines/line_buf_40pts_9lines.v"    
vlog -incr  	   "../01_altera_ip/line_buf_40pts_1lines/line_buf_40pts_1lines.v"    
vlog -incr  	   "../01_altera_ip/line_buf_40pts_13lines/line_buf_40pts_13lines.v"   
vlog -incr  	   "../01_altera_ip/line_buf_400pts_1line16/line_buf_400pts_1line16.v"   
vlog -incr  	   "../01_altera_ip/line_buf_400pts_2lines/line_buf_400pts_2lines.v"   
vlog -incr  	   "../01_altera_ip/line_buf_80pts_9lines/line_buf_80pts_9lines.v"    
vlog -incr  	   "../01_altera_ip/line_buf_80pts_1lines/line_buf_80pts_1lines.v"    
vlog -incr  	   "../01_altera_ip/line_buf_80pts_13lines/line_buf_80pts_13lines.v"   
vlog -incr  	   "../01_altera_ip/line_buf_800pts_1line16/line_buf_800pts_1line16.v"   
vlog -incr  	   "../01_altera_ip/line_buf_800pts_2lines/line_buf_800pts_2lines.v"   
vlog -incr  	   "../01_altera_ip/svm_vut_scfifo_3528x16/svm_vut_scfifo_3528x16.v"    
vlog -incr  	   "../01_altera_ip/svm_model_rom_ip/svm_model_rom_ip.v"     
vlog -incr  	   "../01_altera_ip/svm_model_rom_ip_mlab/svm_model_rom_ip_mlab.v"     
vlog -incr  	   "../01_altera_ip/cordic_factor_Kn_rom_ip/cordic_factor_Kn_rom_ip.v"    
vlog -incr  	   "../01_altera_ip/pd_module_res_fifo_32x256/pd_module_res_fifo_32x256.v"    
vlog -incr  	   "../01_altera_ip/svm_vut_scfifo_1649x128/svm_vut_scfifo_1649x128.v"   
 
vlog -incr  	   "../01_altera_ip/alt_fifo_4b_4096w/alt_fifo_4b_4096w.v"    
vlog -incr  	   "../01_altera_ip/alt_fifo_32b_16w/alt_fifo_32b_16w.v"    
vlog -incr  	   "../01_altera_ip/alt_fifo_32b_64w/alt_fifo_32b_64w.v"    
vlog -incr  	   "../01_altera_ip/alt_fifo_64b_16w/alt_fifo_64b_16w.v"    
vlog -incr  	   "../01_altera_ip/alt_fifo_64b_64w/alt_fifo_64b_64w.v"    
          
#vlog -incr		   "../00_user_logic/hog_svm_pd_800x600_new.v"		  
vlog -incr		   "../00_user_logic/hog_svm_pd_800x600.v"		  
vlog -incr		   "../00_user_logic/hog_svm_pd_400x300.v"		  
vlog -incr		   "../00_user_logic/hog_svm_pd_200x150.v"		  
vlog -incr		   "../00_user_logic/hog_svm_pd_rtl.v"		  
vlog -incr		   "../00_user_logic/RGB565_YUV422.v"		  
vlog -incr		   "../00_user_logic/int_cordic_core.v"		             
vlog -incr  	   "../00_user_logic/mux_ddr_access.v"                 
vlog -incr  	   "../00_user_logic/ssram_controller.v"                 
vlog -incr  	   "../00_user_logic/mt9d111_controller.v"                 
vlog -incr  	   "../00_user_logic/mt9d111_sim.v"                      
vlog -incr  	   "../00_user_logic/top.v"                        
vlog -incr  	   "../00_user_logic/tb.v"                 
}
# --------------------

# ----------------------------------------
# Elaborate top level design
alias elab {
  echo "\[exec\] elab"
  eval vsim -t ps $ELAB_OPTIONS -L work -L work_lib -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver $TOP_LEVEL_NAME
}

# ----------------------------------------
# Elaborate the top level design with novopt option
alias elab_debug {
  echo "\[exec\] elab_debug"
  eval vsim -novopt -t ps $ELAB_OPTIONS -L work -L work_lib -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver $TOP_LEVEL_NAME
}

# ----------------------------------------
# Compile all the design files and elaborate the top level design
alias ld "
  dev_com
  com
  elab
"

# ----------------------------------------
# Compile all the design files and elaborate the top level design with -novopt
alias ld_debug "
  dev_com
  com
  elab_debug
"

