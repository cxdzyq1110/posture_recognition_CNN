#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <time.h>
#include "hwlib.h"
#include "socal/socal.h"
#include "socal/hps.h"
#include "socal/alt_gpio.h"
#include "hps_0.h"

#define	F2H_BASE	( 0x08000000 )
#define	F2H_SPAN	( 0x10000000 )
#define	F2H_MASK	( F2H_SPAN - 1 )

// // 上方 512MB~544 MB属于相机拍摄的缓存 -- 8MB/frame
	// | 512MB-520MB | 520MB-528MB | 528MB-536MB | 536MB-544MB |
	// 512 MB --> 0x20000000 / 1016MB --> 0x3f800000
#define	F2S_BASE	( 0x20000000 )
#define	F2S_SPAN	( 0x20000000 )
#define	F2S_MASK	( F2S_SPAN - 1 )

// 测试h2f/h2f_lw接口
#define H2F_BASE	( 0xc0000000 )
#define H2F_SPAN	( 0x40000000 )
#define H2F_MASK	( H2F_SPAN - 1 )
#define LW_H2F_BASE ( 0xff200000 )
#define LW_H2F_SPAN ( 0x00200000 )
#define LW_H2F_MASK ( LW_H2F_SPAN - 1 )

// 行人检测
#define PD_BASE		( 0x24000000 )
#define PD_SPAN		( 0x02000000 )
#define	PD_MASK		( PD_SPAN - 1 )

uint8_t 	test_h2f_read[1024];
uint8_t 	test_f2s_read[1024];
int main() {

	void *lw_h2f_virtual_base;
	void *h2f_virtual_base;
	void *f2h_virtual_base;
	void *f2s_virtual_base;
	void *pd_virtual_base;
	int fd;
	int loop_count;
	int led_direction;
	int led_mask;
	void *h2f_lw_led_addr;
	void *h2f_lw_sysid_addr;
	void *h2f_lw_fpga_addr;
	void *h2f_lw_ram_addr;
	void *h2f_fpga_addr;
	void *h2f_ram_addr;
	void *f2h_sdram_addr;
	void *f2s_sdram_addr;
	void *pd_result_addr;
	
	int i;
	clock_t start, finish; double duration; 	// 计时用

	printf("hello world\n");
	// map the address space for the LED registers into user space so we can interact with them.
	// we'll actually map in the entire CSR span of the HPS since we want to access various registers within that span

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

	// to fpga logic
	h2f_virtual_base = mmap( NULL, H2F_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, H2F_BASE );
	if( h2f_virtual_base == MAP_FAILED ) {
		printf( "ERROR: h2f mmap() failed...\n" );
		close( fd );
		return( 1 );
	}
	h2f_lw_fpga_addr = lw_h2f_virtual_base + ( ( unsigned long  )( AVALON_H2F_LW_BASE ) & ( unsigned long)( LW_H2F_MASK ) );
	h2f_fpga_addr = h2f_virtual_base + ( ( unsigned long  )( AVALON_H2F_BASE ) & ( unsigned long)( H2F_MASK ) );
	h2f_ram_addr = h2f_virtual_base + ( ( unsigned long  )( H2F_RAM_BASE ) & ( unsigned long)( H2F_MASK ) );
	
	// f2h --> sdram
	f2h_virtual_base = mmap( NULL, F2H_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, F2H_BASE );
	f2h_sdram_addr = f2h_virtual_base + ( ( unsigned long  )( 0 ) & ( unsigned long)( F2H_MASK ) );
	
	unsigned int BIAS = 0;
	//printf("please input video BIAS [hex] <00000000 ~ 1f800000>: ");
	//scanf("%X", &BIAS);
	printf("starting my soc-fpga application...\n");
	// f22 --> sdram
	f2s_virtual_base = mmap( NULL, F2S_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, F2S_BASE );
	f2s_sdram_addr = f2s_virtual_base + ( ( unsigned long  )( BIAS ) & ( unsigned long)( F2S_MASK ) );
	
	pd_virtual_base = mmap( NULL, PD_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, PD_BASE );
	pd_result_addr = pd_virtual_base + 4;	// 跳过0x1C00_0000那个0x0000_0000固定条目
	
	
	// while 大循环——要测试一下HPS的满负荷运行会不会给FPGA那儿的DDR读写访问造成负担？
	while(1){
		// 先看看systemid在说
		printf("system id : %08X    --[@%08X]\n", *(uint32_t *)h2f_lw_sysid_addr, h2f_lw_sysid_addr);
		
		// 首先，让FPGA对DDR的访问启动
		*(uint32_t *)h2f_lw_led_addr = 0xFFFFFFFF;	// 全亮
		// 延时一会儿
		usleep( 100*1000 );
		printf("FPGA - DDR access enabled!\n");
		//
		/*
		*/
		FILE *fp = fopen("original_bits.ima", "wb");
		loop_count = 0;
		while(loop_count < 1024*8)
		{
			memcpy(test_f2s_read, f2s_sdram_addr + loop_count*(sizeof(test_f2s_read)), sizeof(test_f2s_read));
			fwrite(test_f2s_read, 1, sizeof(test_f2s_read), fp);
			// wait 100ms
			usleep(10);
			loop_count++;
		}
		fclose(fp);
		printf("FPGA - DDR (read video ima file) access finished!\n");
		
		//
		printf("reading HOG+SVM pedestrian detection...\n");
		printf("[0x1C00.0000] --> %08X\n", *(unsigned int *)pd_virtual_base);
		
		int times = 1;
		while((times--))
		{
			printf("------------ * * * ---------------\n");
			start = clock();
			unsigned int pd_result_item;
			int pd_result_item_num = 0;
			int pd_result_scale, pd_result_score, pd_result_hcnt, pd_result_vcnt;
			// 只输出1/1和1/2和1/4检测的最大score的方框坐标
		#define	NUM_PD_PER_SCALE	2
			int pd_result_yuki_position_s1[NUM_PD_PER_SCALE][2];
			int pd_result_yuki_score_s1[NUM_PD_PER_SCALE] = {0,};
			int pd_result_yuki_position_s2[NUM_PD_PER_SCALE][2];
			int pd_result_yuki_score_s2[NUM_PD_PER_SCALE] = {0,};
			int pd_result_yuki_position_s4[NUM_PD_PER_SCALE][2];
			int pd_result_yuki_score_s4[NUM_PD_PER_SCALE] = {0,};
			do{
				/*
				pd_result_item = ((*(unsigned char *)(pd_result_addr))<<0)
								| ((*(unsigned char *)(pd_result_addr+1))<<8)
								| ((*(unsigned char *)(pd_result_addr+2))<<16)
								| ((*(unsigned char *)(pd_result_addr+3))<<24);
				*/
				pd_result_item = *(unsigned int *)pd_result_addr;
				pd_result_scale = (pd_result_item&0xC0000000)>>30;
				pd_result_score = (pd_result_item&0x3FF00000)>>20;
				pd_result_hcnt = (pd_result_item&0x000FFC00)>>10;
				pd_result_vcnt = (pd_result_item&0x000003FF)>>0;
				pd_result_addr += 4;
				pd_result_item_num += 1;
				// 记录最大的score对应的坐标
				// 注意，是要选取前 NUM_PD_PER_SCALE 个可能的bbox
				if(pd_result_scale==1 && (pd_result_hcnt<720) && (pd_result_vcnt<460)){
					for(loop_count=0; loop_count<NUM_PD_PER_SCALE; loop_count++){
						if(pd_result_score>pd_result_yuki_score_s1[loop_count]){
							pd_result_yuki_score_s1[loop_count] = pd_result_score;
							pd_result_yuki_position_s1[loop_count][1] = pd_result_hcnt;
							pd_result_yuki_position_s1[loop_count][0] = pd_result_vcnt;
							break;
						}
					}
				}
				else if(pd_result_scale==2 && (pd_result_hcnt<640) && (pd_result_vcnt<220)){
					for(loop_count=0; loop_count<NUM_PD_PER_SCALE; loop_count++){
						if(pd_result_score>pd_result_yuki_score_s2[loop_count]){
							pd_result_yuki_score_s2[loop_count] = pd_result_score;
							pd_result_yuki_position_s2[loop_count][1] = pd_result_hcnt;
							pd_result_yuki_position_s2[loop_count][0] = pd_result_vcnt;
							break;
						}
					}
				}
				else if(pd_result_scale==3 && (pd_result_hcnt<480) && (pd_result_vcnt<40)){
					for(loop_count=0; loop_count<NUM_PD_PER_SCALE; loop_count++){
						if(pd_result_score>pd_result_yuki_score_s4[loop_count]){
							pd_result_yuki_score_s4[loop_count] = pd_result_score;
							pd_result_yuki_position_s4[loop_count][1] = pd_result_hcnt;
							pd_result_yuki_position_s4[loop_count][0] = pd_result_vcnt;
							break;
						}
					}
				}
			}while(pd_result_item&0xC0000000);
			
			printf("stop @ %08X\n", pd_result_item);
			
			// 1:1 scale
			for(loop_count=0; loop_count<NUM_PD_PER_SCALE; loop_count++){
				if(pd_result_yuki_score_s1[loop_count]>0)
					printf("bbox.scale = %d, bbox.score=%d, bbox.hcnt = %d, bbox.vcnt=%d\n", 
							1, pd_result_yuki_score_s1[loop_count],
							pd_result_yuki_position_s1[loop_count][1], pd_result_yuki_position_s1[loop_count][0]
					);
			}
			// 1:2 scale
			for(loop_count=0; loop_count<NUM_PD_PER_SCALE; loop_count++){
				if(pd_result_yuki_score_s2[loop_count]>0)
					printf("bbox.scale = %d, bbox.score=%d, bbox.hcnt = %d, bbox.vcnt=%d\n", 
							2, pd_result_yuki_score_s2[loop_count],
							pd_result_yuki_position_s2[loop_count][1], pd_result_yuki_position_s2[loop_count][0]
					);
			}
			// 1:4 scale
			for(loop_count=0; loop_count<NUM_PD_PER_SCALE; loop_count++){
				if(pd_result_yuki_score_s4[loop_count]>0)
					printf("bbox.scale = %d, bbox.score=%d, bbox.hcnt = %d, bbox.vcnt=%d\n", 
							4, pd_result_yuki_score_s4[loop_count],
							pd_result_yuki_position_s4[loop_count][1], pd_result_yuki_position_s4[loop_count][0]
					);
			}
			finish = clock();
			duration = (double)(finish - start) / CLOCKS_PER_SEC; 
			printf("pedestrian detection result reading finished!\ntotal time: %f sec\n", duration);
			//
			sleep(0.01);
		}
		
		int loop_in;
		// 测试ram写入
		printf("------------ * * * ---------------\n");
		printf("testing h2f -- ram interface started [@%08X]...\n", h2f_ram_addr);
		start = clock();
		/*
		for(loop_count==0; loop_count<10; loop_count++){
			for(loop_in=0; loop_in<1024; loop_in++){
				*(unsigned int *)h2f_ram_addr = 
				*(unsigned int *)(f2s_sdram_addr);
				h2f_ram_addr += 4;
				f2s_sdram_addr += 4;
			}
			h2f_ram_addr = h2f_ram_addr - 1024*4;
		}
		*/
		finish = clock();
		duration = (double)(finish - start) / CLOCKS_PER_SEC; 
		printf("testing h2f -- ram interface finished!\ntotal time: %f sec\n", duration);
		// 测试h2f/h2f_lw接口
		printf("------------ * * * ---------------\n");
		printf("testing h2f interface started [@%08X]...\n", h2f_fpga_addr);
		start = clock();
		/*
		for(loop_count==0; loop_count<1024; loop_count++){
			for(loop_in=0; loop_in<1024; loop_in++){
				*(unsigned int *)h2f_fpga_addr = 
				*(unsigned int *)(f2s_sdram_addr);
				h2f_fpga_addr += 4;
				f2s_sdram_addr += 4;
			}
		}*/
		/*
		*/
		for(loop_count==0; loop_count<5; loop_count++){
			//*(unsigned int *)h2f_fpga_addr = *(unsigned int *)(f2s_sdram_addr + loop_count*4*8);
			memcpy(h2f_fpga_addr, f2s_sdram_addr, 1024*4);
			h2f_fpga_addr = h2f_fpga_addr + 1024*4;
			f2s_sdram_addr = f2s_sdram_addr + 1024*4;
		}
		/*
		for(loop_count==0; loop_count<1000; loop_count++){
			memcpy(h2f_fpga_addr, f2s_sdram_addr, 1000*4);
			f2s_sdram_addr = f2s_sdram_addr + 1000*4;
			h2f_fpga_addr = h2f_fpga_addr + 1000*4;
		}
		*/
		finish = clock();
		duration = (double)(finish - start) / CLOCKS_PER_SEC; 
		printf("testing h2f interface finished!\ntotal time: %f sec\n", duration);
		
		//sleep(3);
		// 测试h2f/h2f_lw接口
		printf("------------ * * * ---------------\n");
		printf("testing h2f.lw interface started [@%08X]...\n", h2f_lw_fpga_addr);
		start = clock();
		for(loop_count==0; loop_count<1000; loop_count++){
			*(unsigned int *)h2f_lw_fpga_addr = loop_count + 1;
			h2f_lw_fpga_addr = h2f_lw_fpga_addr + 4;
		}
		finish = clock();
		duration = (double)(finish - start) / CLOCKS_PER_SEC; 
		printf("testing h2f.lw interface finished!\ntotal time: %f sec\n", duration);
		
	}
	
	//////////////////////
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
	
	
	if( munmap( f2h_virtual_base, F2H_SPAN ) != 0 ) {
		printf( "ERROR: f2h munmap() failed...\n" );
		close( fd );
		return( 1 );
	}
	
	
	if( munmap( f2s_virtual_base, F2S_SPAN ) != 0 ) {
		printf( "ERROR: f2s munmap() failed...\n" );
		close( fd );
		return( 1 );
	}
	
	if( munmap( pd_virtual_base, PD_SPAN ) != 0 ) {
		printf( "ERROR: pd munmap() failed...\n" );
		close( fd );
		return( 1 );
	}

	close( fd );

	return( 0 );
}
