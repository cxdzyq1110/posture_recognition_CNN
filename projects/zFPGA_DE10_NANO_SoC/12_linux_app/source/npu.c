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


/////////////////////////////////////
// 发射NPU指令
void send_npu_inst(char *op, char *para)
{
	unsigned char cnn_inst_ready;
	unsigned int para1, para2, para3, M, N, P;
    clock_t start, finish; double duration; 	// 计时用
	// 生成指令
	if(!strcmp(op, "ADD")){
		sscanf(para, "%X,%X,%X,%d,%d", &para1, &para2, &para3, &M, &N);
		npu_inst_buffer[0]=(0x0<<28)|(para1>>4);
		npu_inst_buffer[1]=(para1<<28)|(para2>>4);
		npu_inst_buffer[2]=(para2<<28)|(para3>>4);
		npu_inst_buffer[3]=(para3<<28)|(M<<20)|(N<<12);
	}
	else if(!strcmp(op, "ADDi")){
		sscanf(para, "%X,%d,%X,%d,%d", &para1, &para2, &para3, &M, &N);
		npu_inst_buffer[0]=(0x1<<28)|(para1>>4);
		npu_inst_buffer[1]=(para1<<28)|(para2>>4);
		npu_inst_buffer[2]=(para2<<28)|(para3>>4);
		npu_inst_buffer[3]=(para3<<28)|(M<<20)|(N<<12);
	}
	// 发送指令
	start = clock();
	memcpy(h2f_fpga_addr, npu_inst_buffer, 16);
	////printf("npu.inst stage ");
	usleep(10000);	// 10ms
	// 等待指令完成
	while(1){
		usleep(1000);	// 1ms
		////printf(".");
		cnn_inst_ready = ((*(unsigned int *)h2f_lw_npu_addr) & 0x00000001);
		if(cnn_inst_ready)
			break;
	}
	npu_time = ((*(unsigned int *)h2f_lw_npu_addr)>>1)/66.7e6;
	finish = clock();
	duration = (double)(finish - start) / CLOCKS_PER_SEC; 
	//printf("\nnpu_inst finished! total time: %f sec, npu-time = %f sec [%08X]\n", duration, npu_time, *(unsigned int *)h2f_lw_npu_addr);
}

// 测试NPU指令执行的正确性
void test_npu_inst(void)
{
	int para1, para2, para3;
    clock_t start, finish; double duration; 	// 计时用
	unsigned char OP = npu_inst_buffer[0]>>28;	// 首先是获取NPU指令名称
	unsigned int Dollar1 = (npu_inst_buffer[0]<<4)|(npu_inst_buffer[1]>>28);	// $1地址
	unsigned int Dollar2 = (npu_inst_buffer[1]<<4)|(npu_inst_buffer[2]>>28);	// $2地址
	unsigned int Dollar3 = (npu_inst_buffer[2]<<4)|(npu_inst_buffer[3]>>28);	// $3地址
	unsigned char M = (npu_inst_buffer[3]&0x0FFFFFFF)>>20;
	unsigned char N = (npu_inst_buffer[3]&0x000FFFFF)>>12;
	int IMM = *(int *)(&Dollar2);
	////printf("testing npu inst... $1(%08X), $2(%08X) ==> $3(%08X), M=%d, N=%d\n", Dollar1, Dollar2, Dollar3, M, N);
	// 映射进用户空间
	void *dollar1_virtual_base = mmap( NULL, 0x02000000, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, Dollar1<<2 );
	void *dollar3_virtual_base = mmap( NULL, 0x02000000, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, Dollar3<<2 );
	start = clock();
	////printf("go go go...\n");
	// 验证运算正确性
	int m, n;
	// 矩阵加法
	if(OP==0){
		void *dollar2_virtual_base = mmap( NULL, 0x02000000, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, Dollar2<<2 );
		for(m=0; m<M; m++){
			for(n=0; n<N; n++){
				para1 = (*(int *)(dollar1_virtual_base+4*(m*N+n)));
				para2 = (*(int *)(dollar2_virtual_base+4*(m*N+n)));
				para3 = (*(int *)(dollar3_virtual_base+4*(m*N+n)));
				if(para3 != (para1 + para2))
					printf("Addi Error : <%d, %d>, %d + %d ==> %d ( %d expected )\n", m, n, para1, para2, para3, (para1 + para2));
			}
		}
		munmap( dollar2_virtual_base, 0x02000000 );
	}
	// 立即数加法
	else if(OP==1){
		for(m=0; m<M; m++){
			for(n=0; n<N; n++){
				para1 = (*(int *)(dollar1_virtual_base+4*(m*N+n)));
				para3 = (*(int *)(dollar3_virtual_base+4*(m*N+n)));
				if(para3 != (para1 + IMM))
					printf("Addi Error : <%d, %d>, %d + %d ==> %d ( %d expected )\n", m, n, para1, IMM, para3, (para1 + IMM));
			}
		}
		////printf("Addi Example : <%d, %d>, %d + %d ==> %d ( %d expected )\n", m, n, para1, IMM, para3, (para1 + IMM));
	}
	// 释放掉映射了的空间
	munmap( dollar1_virtual_base, 0x02000000 );
	munmap( dollar3_virtual_base, 0x02000000 );
	finish = clock();
	duration = (double)(finish - start) / CLOCKS_PER_SEC; 
	//printf("testing npu inst finished... total time: %f sec\n", duration);
}