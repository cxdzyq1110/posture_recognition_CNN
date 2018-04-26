#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include "hwlib.h"
#include "socal/socal.h"
#include "socal/hps.h"
#include "socal/alt_gpio.h"
#include "hps_0.h"

#define LW_H2F_BASE ( 0xff200000 )
#define LW_H2F_SPAN ( 0x00200000 )
#define LW_H2F_MASK ( LW_H2F_SPAN - 1 )

#define	F2H_BASE	( 0x08000000 )
#define	F2H_SPAN	( 0x10000000 )
#define	F2H_MASK	( F2H_SPAN - 1 )

// // 上方 512MB~544 MB属于相机拍摄的缓存 -- 8MB/frame
	// | 512MB-520MB | 520MB-528MB | 528MB-536MB | 536MB-544MB |
	// 512 MB --> 0x20000000 / 1016MB --> 0x3f800000
#define	F2S_BASE	( 0x20000000 )
#define	F2S_SPAN	( 0x20000000 )
#define	F2S_MASK	( F2S_SPAN - 1 )

uint8_t 	test_h2f_read[1024];
uint8_t 	test_f2s_read[1024];
int main() {

	void *lw_h2f_virtual_base;
	void *f2h_virtual_base;
	void *f2s_virtual_base;
	int fd;
	int loop_count;
	int led_direction;
	int led_mask;
	void *h2f_lw_led_addr;
	void *h2f_lw_sysid_addr;
	void *f2h_sdram_addr;
	void *f2s_sdram_addr;
	
	int i;

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
	
	// 先看看systemid在说
	printf("system id : %08X\n", *(uint32_t *)h2f_lw_sysid_addr);
	
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
	printf("FPGA - DDR (read video ima file) access enabled!\n");
	printf("starting lighting!\n");
	
	// toggle the LEDs a bit
	loop_count = 0;
	led_mask = 0x01;
	led_direction = 0; // 0: left to right direction
	while( loop_count < 60 ) {
		
		// control led
		*(uint32_t *)h2f_lw_led_addr = led_mask | 0x40; 	// FPGA需要正常工作的

		// wait 100ms
		usleep( 100*1000 );
		
		// update led mask
		if (led_direction == 0){
			led_mask <<= 1;
			if (led_mask == (0x01 << (LED_PIO_DATA_WIDTH-2)))
				 led_direction = 1;
		}else{
			led_mask >>= 1;
			if (led_mask == 0x01){ 
				led_direction = 0;
				loop_count++;
			}
		}
		
	} // while
	

	// clean up our memory mapping and exit
	
	if( munmap( lw_h2f_virtual_base, LW_H2F_SPAN ) != 0 ) {
		printf( "ERROR: lw-h2f munmap() failed...\n" );
		close( fd );
		return( 1 );
	}
	
	
	if( munmap( f2h_virtual_base, F2H_SPAN ) != 0 ) {
		printf( "ERROR: h2f munmap() failed...\n" );
		close( fd );
		return( 1 );
	}

	close( fd );

	return( 0 );
}
