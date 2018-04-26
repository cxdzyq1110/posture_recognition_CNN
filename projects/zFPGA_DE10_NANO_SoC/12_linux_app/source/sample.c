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
//////////////////////////////////////////////////////////////////////////////////
// 采样函数
void sample_task(int num)
{
    clock_t start, finish; double duration; 	// 计时用
    FILE *fp;   // 文件流操作
    // 下面就是读取加框加框的结果
    int final_bbox_reg[1][6];   // 必须先暂存下来，否则就会导致采集到的视频&光流数据尺寸不统一
    int i;
    for(i=0; i<6; i++){
        final_bbox_reg[0][i] = final_bbox[0][i];
    }
    // 计算时间
	start = clock();
	// 首先获取MT9D111正在写入的DDR区间基数
	mt9d111_block = (*(unsigned int *)h2f_lw_video_block_addr - 1)&0x03;
	void * video_addr = video_virtual_base + 0x00800000 * mt9d111_block;
	void * optical_addr = of_virtual_base + 0x00800000 * ((mt9d111_block-1)&0x03);
    // 设定文件名称
    char filename[128];
    // 首先是原始视频的记录
    sprintf(filename, "./%s/%s-%d-video.ima", filedir, time_stamp, num);
    //printf("writing into filename [%s]...\n", filename);
    // 
    int loop_count = final_bbox_reg[0][1];
    unsigned char ddr_content_buffer[4096]; // 1KB
    fp = fopen(filename, "wb");
    fwrite(&final_bbox_reg[0][2], 4, 1, fp);    // 先记录框的宽度
    fwrite(&final_bbox_reg[0][3], 4, 1, fp);    // 先记录框的高度
	while(loop_count < final_bbox_reg[0][3] + final_bbox_reg[0][1])
	{
        int addr = (800*loop_count + final_bbox_reg[0][0])<<2;
        int len = final_bbox_reg[0][2]<<2;
		memcpy(ddr_content_buffer, video_addr + addr, len);
		fwrite(ddr_content_buffer, 1, len, fp);
		// wait 100ms
		loop_count++;
	}
	fclose(fp);
    // sleep一会儿
    usleep(100*1000);
    // 然后是光流法计算的记录
    sprintf(filename, "./%s/%s-%d-optical.ima", filedir, time_stamp, num);
    //printf("writing into filename [%s]...\n", filename);
    // 
    loop_count = final_bbox_reg[0][1];
    //unsigned char ddr_content_buffer[4096]; // 1KB
    fp = fopen(filename, "wb");
    fwrite(&final_bbox_reg[0][2], 4, 1, fp);    // 先记录框的宽度
    fwrite(&final_bbox_reg[0][3], 4, 1, fp);    // 先记录框的高度
	while(loop_count < final_bbox_reg[0][3] + final_bbox_reg[0][1])
	{
        int addr = (800*loop_count + final_bbox_reg[0][0])<<2;
        int len = final_bbox_reg[0][2]<<2;
		memcpy(ddr_content_buffer, optical_addr + addr, len);
		fwrite(ddr_content_buffer, 1, len, fp);
		// wait 100ms
		loop_count++;
	}
	fclose(fp);
    
    // sleep一会儿
    usleep(100*1000);
    //
	finish = clock();
	duration = (double)(finish - start) / CLOCKS_PER_SEC; 
	//printf("video reading finished! total time: %f sec\n", duration);
}

// 读取最近一帧数据
void read_last_frame(void)
{
    clock_t start, finish; double duration; 	// 计时用
	// while 大循环——要测试一下HPS的满负荷运行会不会给FPGA那儿的DDR读写访问造成负担？
	FILE *fp = fopen("original_bits.ima", "wb");
	// 首先看看现在在写入那个区间
	mt9d111_block = (*(unsigned int *)h2f_lw_video_block_addr - 1)&0x03;
	video_result_addr = video_virtual_base + 0x00800000 * mt9d111_block;
	////printf("reading [%d]th block...\n", mt9d111_block);
	// 下面开始采集原始视频数据
	start = clock();
	int loop_count = 0;
	while(loop_count < 1024*8)
	{
		memcpy(test_f2s_read, video_result_addr + loop_count*(sizeof(test_f2s_read)), sizeof(test_f2s_read));
		fwrite(test_f2s_read, 1, sizeof(test_f2s_read), fp);
		// wait 100ms
		loop_count++;
	}
	finish = clock();
	duration = (double)(finish - start) / CLOCKS_PER_SEC; 
	fclose(fp);
	//printf("FPGA - DDR (read video ima file) access finished!\n");
	//printf("video reading finished! total time: %f sec\n", duration);
}