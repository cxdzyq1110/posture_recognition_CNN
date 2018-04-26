#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <pthread.h>	// 多线程编程
#include <time.h>
#include "hwlib.h"
#include "socal/socal.h"
#include "socal/hps.h"
#include "socal/alt_gpio.h"

#include "../include/cnn.h"
#include "../include/ddr_use.h"
#include "../include/graphic.h"
#include "../include/hps_0.h"
#include "../include/hps_fpga_inf.h"
#include "../include/key_respond.h"
#include "../include/merge_bbox.h"
#include "../include/npu.h"
#include "../include/optical_flow.h"
#include "../include/pedestrian.h"
#include "../include/plot.h"
#include "../include/sample.h"

//
int init_all_interfaces(void)
{
	
	//printf("hello world from my linux app...\n");
	
	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		return( 1 );
	}
	
	// light weight h2f --> led
	lw_h2f_virtual_base = mmap( NULL, LW_H2F_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, LW_H2F_BASE );

	if( lw_h2f_virtual_base == MAP_FAILED ) {
		printf( "ERROR: lw_h2f mmap() failed...\n" );
		close( fd );
		return( 1 );
	}

	h2f_lw_led_addr = lw_h2f_virtual_base + ( ( unsigned long  )( LED_PIO_BASE ) & ( unsigned long)( LW_H2F_MASK ) );
	h2f_lw_sysid_addr = lw_h2f_virtual_base + ( ( unsigned long  )( SYSID_QSYS_0_BASE ) & ( unsigned long)( LW_H2F_MASK ) );
	h2f_lw_ram_addr = lw_h2f_virtual_base + ( ( unsigned long  )( H2F_LW_RAM_BASE ) & ( unsigned long)( LW_H2F_MASK ) );

	h2f_lw_fpga_addr = lw_h2f_virtual_base + ( ( unsigned long  )( AVALON_H2F_LW_BASE ) & ( unsigned long)( LW_H2F_MASK ) );
	h2f_lw_video_block_addr = lw_h2f_virtual_base + ( ( unsigned long  )( VIDEO_BLOCK_NUMBER_BASE ) & ( unsigned long)( LW_H2F_MASK ) );
	h2f_lw_bbox_frame_addr = lw_h2f_virtual_base + ( ( unsigned long  )( PD_BBOX_FRAME_BASE ) & ( unsigned long)( LW_H2F_MASK ) );
	h2f_lw_bbox_mask_addr = lw_h2f_virtual_base + ( ( unsigned long  )( PD_BBOX_H2F_LW_BASE ) & ( unsigned long)( LW_H2F_MASK ) );
	h2f_lw_npu_addr = lw_h2f_virtual_base + ( ( unsigned long  )( CNN_INST_INFO_BASE ) & ( unsigned long)( LW_H2F_MASK ) );
	
	// to fpga logic / cnn-inst
	h2f_virtual_base = mmap( NULL, H2F_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, H2F_BASE );
	if( h2f_virtual_base == MAP_FAILED ) {
		printf( "ERROR: h2f mmap() failed...\n" );
		close( fd );
		return( 1 );
	}
	h2f_ram_addr = h2f_virtual_base + ( ( unsigned long  )( H2F_RAM_BASE ) & ( unsigned long)( H2F_MASK ) );
	h2f_fpga_addr = h2f_virtual_base + ( ( unsigned long  )( AVALON_H2F_BASE ) & ( unsigned long)( H2F_MASK ) );
	
	// 	// f2s --> sdram // 存储的是视频数据
	video_virtual_base = mmap( NULL, VIDEO_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, VIDEO_BASE );
	
	if( video_virtual_base == MAP_FAILED ) {
		printf( "ERROR: video block mmap() failed...\n" );
		close( fd );
		return( 1 );
	}
	
	// 行人检测空间映射后的虚拟地址
	pd_virtual_base = mmap( NULL, PD_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, PD_BASE );
	
	if( pd_virtual_base == MAP_FAILED ) {
		printf( "ERROR: pedestrian detection mmap() failed...\n" );
		close( fd );
		return( 1 );
	}
	
	// CNN存储空间映射后的虚拟地址
	cnn_para_virtual_base = mmap( NULL, CNN_PARA_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, CNN_PARA_BASE );
	
	if( cnn_para_virtual_base == MAP_FAILED ) {
		printf( "ERROR: CNN parameter mmap() failed...\n" );
		close( fd );
		return( 1 );
	}
	
	// CNN输入的存储空间映射后的虚拟地址
	cnn_in_virtual_base = mmap( NULL, CNN_IN_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, CNN_IN_BASE );
	
	if( cnn_in_virtual_base == MAP_FAILED ) {
		printf( "ERROR: CNN input mmap() failed...\n" );
		close( fd );
		return( 1 );
	}
	
	// CNN输出的存储空间映射后的虚拟地址
	cnn_out_virtual_base = mmap( NULL, CNN_OUT_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, CNN_OUT_BASE );
	
	if( cnn_out_virtual_base == MAP_FAILED ) {
		printf( "ERROR: CNN output mmap() failed...\n" );
		close( fd );
		return( 1 );
	}
	// 光流计算结果存储空间映射后的虚拟地址
	of_virtual_base = mmap( NULL, OF_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, OF_BASE );
	
	if( of_virtual_base == MAP_FAILED ) {
		printf( "ERROR: optical flow mmap() failed...\n" );
		close( fd );
		return( 1 );
	}
	
	// 加框结果存储空间的映射
	bbox_virtual_base = mmap( NULL, BBOX_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, BBOX_BASE );
	
	if( bbox_virtual_base == MAP_FAILED ) {
		printf( "ERROR: adding bbox mmap() failed...\n" );
		close( fd );
		return( 1 );
	}
	
	return 0;
}




int close_all_interfaces(void)
{
	
	// clean up our memory mapping and exit
	
	if( munmap( lw_h2f_virtual_base, LW_H2F_SPAN ) != 0 ) {
		printf( "ERROR: lw-h2f munmap() failed...\n" );
		close( fd );
		return( 1 );
	}
	
	if( munmap( h2f_virtual_base, H2F_SPAN ) != 0 ) {
		printf( "ERROR: h2f munmap() failed...\n" );
		close( fd );
		return( 1 );
	}
	
	
	if( munmap( video_virtual_base, VIDEO_SPAN ) != 0 ) {
		printf( "ERROR: video munmap() failed...\n" );
		close( fd );
		return( 1 );
	}
	
	if( munmap( pd_virtual_base, PD_SPAN ) != 0 ) {
		printf( "ERROR: pd munmap() failed...\n" );
		close( fd );
		return( 1 );
	}
    
	if( munmap( of_virtual_base, OF_SPAN ) != 0 ) {
		printf( "ERROR: optical flow munmap() failed...\n" );
		close( fd );
		return( 1 );
	}
    
	if( munmap( bbox_virtual_base, BBOX_SPAN ) != 0 ) {
		printf( "ERROR: bbox munmap() failed...\n" );
		close( fd );
		return( 1 );
	}
    
	if( munmap( cnn_para_virtual_base, CNN_PARA_SPAN ) != 0 ) {
		printf( "ERROR: cnn parameter munmap() failed...\n" );
		close( fd );
		return( 1 );
	}
    
	if( munmap( cnn_in_virtual_base, CNN_IN_SPAN ) != 0 ) {
		printf( "ERROR: cnn input munmap() failed...\n" );
		close( fd );
		return( 1 );
	}
    
	if( munmap( cnn_out_virtual_base, CNN_OUT_SPAN ) != 0 ) {
		printf( "ERROR: cnn output munmap() failed...\n" );
		close( fd );
		return( 1 );
	}

	close( fd );
	
	return 0;
}