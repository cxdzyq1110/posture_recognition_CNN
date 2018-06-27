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

/////////////////////////////
// 绘图&加框处理
void plot_picture_and_bbox(void)
{
    int loop_in; int loop_count;
    clock_t start, finish; double duration; 	// 计时用
    // 下面就是形成加框的结果
	start = clock();
	// 首先获取MT9D111正在写入的DDR区间基数
	mt9d111_block = (*(unsigned int *)h2f_lw_video_block_addr - 1)&0x03;
	video_result_addr = video_virtual_base + 0x00800000 * mt9d111_block;
	// 然后将视频数据搬移到加框数据空间
	// 先告诉FPGA正在写入的块
	bbox_memory_base = bbox_virtual_base + pd_bbox_frame * 0x00800000;	// 8MB/frame
	//memcpy(bbox_memory_base, video_result_addr, 0x00200000);	// 其实只要拷贝2MB就行啦
    // 其实只要1/4的图像就可以了
    int i, j; int addr;
    for(i=0; i<CAM_V_WIDTH; i=i+VGA_SCALE){
        for(j=0; j<CAM_H_WIDTH; j=j+VGA_SCALE){
            addr = CAM_H_WIDTH*i + j;
            *(unsigned int *)(bbox_memory_base+addr*4) = *(unsigned int *)(video_result_addr+addr*4);
        }
    }
	int SCALE = 16;
    /*
    */
	// 遍历NMS后的窗口
	for(loop_count=0; loop_count<3*NUM_PD_PER_SCALE; loop_count++){
		if(pd_bbox[loop_count][4]==0)
			break;
		else{
			// 只有和待检测窗口IoU比较大的几个才行
			// 计算交集面积
			int IS = InterSect(pd_bbox[loop_count][0], pd_bbox[loop_count][1], pd_bbox[loop_count][2], pd_bbox[loop_count][3],
								test_bbox[0][0], test_bbox[0][1], test_bbox[0][2], test_bbox[0][3]);
			int TS = test_bbox[0][2]*test_bbox[0][3]+1;
			float IoT = IS*1.0/TS;
			if(IoT<0.1)
				continue;
			//printf("IS=%d, T=%d, IoT=%.2f\n", IS, TS, IoT);
			//
			unsigned bias_addr = 0;
			// 上下两个横线
			for(loop_in=0; loop_in<(pd_bbox[loop_count][5]/SCALE); loop_in++){
				bias_addr = (CAM_H_WIDTH*(pd_bbox[loop_count][1]+loop_in)+pd_bbox[loop_count][0])<<2;
                for(j=0; j<pd_bbox[loop_count][2]; j++)
                    *(unsigned int *)(bbox_memory_base+bias_addr+4*j) = 0x0000f800;
				//memset(bbox_memory_base+bias_addr, 0x00, (pd_bbox[loop_count][2]<<2));
				bias_addr = (CAM_H_WIDTH*(pd_bbox[loop_count][1]+loop_in+pd_bbox[loop_count][3])+pd_bbox[loop_count][0])<<2;
				//memset(bbox_memory_base+bias_addr, 0x00, (pd_bbox[loop_count][2]<<2));
                for(j=0; j<pd_bbox[loop_count][2]; j++)
                    *(unsigned int *)(bbox_memory_base+bias_addr+4*j) = 0x0000f800;
			}
			// 然后是左右的竖线
			for(loop_in=0; loop_in<(pd_bbox[loop_count][3]+pd_bbox[loop_count][5]/SCALE); loop_in++){
				bias_addr = (CAM_H_WIDTH*(pd_bbox[loop_count][1]+loop_in)+pd_bbox[loop_count][0])<<2;
				//memset(bbox_memory_base+bias_addr, 0x00, ((pd_bbox[loop_count][5]/SCALE)<<2));
                for(j=0; j<(pd_bbox[loop_count][5]/SCALE); j++)
                    *(unsigned int *)(bbox_memory_base+bias_addr+4*j) = 0x0000f800;
				bias_addr = (CAM_H_WIDTH*(pd_bbox[loop_count][1]+loop_in)+pd_bbox[loop_count][0]+pd_bbox[loop_count][2])<<2;
				//memset(bbox_memory_base+bias_addr, 0x00, ((pd_bbox[loop_count][5]/SCALE)<<2));
                for(j=0; j<(pd_bbox[loop_count][5]/SCALE); j++)
                    *(unsigned int *)(bbox_memory_base+bias_addr+4*j) = 0x0000f800;
			}
		}
	}
    // 然后还有光流法计算出来的框
    for(loop_count=0; loop_count<1; loop_count++)
    {
        if(of_bbox[loop_count][4]==1)
        {
            unsigned bias_addr = 0;
            // 上下两个横线
            for(loop_in=0; loop_in<(of_bbox[loop_count][5]/SCALE); loop_in++){
                bias_addr = (CAM_H_WIDTH*(of_bbox[loop_count][1]+loop_in)+of_bbox[loop_count][0])<<2;
                for(j=0; j<of_bbox[loop_count][2]; j++)
                    *(unsigned int *)(bbox_memory_base+bias_addr+4*j) = 0x0000001F;
                //memset(bbox_memory_base+bias_addr, 0x00, (of_bbox[loop_count][2]<<2));
                bias_addr = (CAM_H_WIDTH*(of_bbox[loop_count][1]+loop_in+of_bbox[loop_count][3])+of_bbox[loop_count][0])<<2;
                //memset(bbox_memory_base+bias_addr, 0x00, (of_bbox[loop_count][2]<<2));
                for(j=0; j<of_bbox[loop_count][2]; j++)
                    *(unsigned int *)(bbox_memory_base+bias_addr+4*j) = 0x0000001F;
            }
            // 然后是左右的竖线
            for(loop_in=0; loop_in<(of_bbox[loop_count][3]+of_bbox[loop_count][5]/SCALE); loop_in++){
                bias_addr = (CAM_H_WIDTH*(of_bbox[loop_count][1]+loop_in)+of_bbox[loop_count][0])<<2;
                //memset(bbox_memory_base+bias_addr, 0x00, ((of_bbox[loop_count][5]/SCALE)<<2));
                for(j=0; j<(of_bbox[loop_count][5]/SCALE); j++)
                    *(unsigned int *)(bbox_memory_base+bias_addr+4*j) = 0x0000001F;
                bias_addr = (CAM_H_WIDTH*(of_bbox[loop_count][1]+loop_in)+of_bbox[loop_count][0]+of_bbox[loop_count][2])<<2;
                //memset(bbox_memory_base+bias_addr, 0x00, ((of_bbox[loop_count][5]/SCALE)<<2));
                for(j=0; j<(of_bbox[loop_count][5]/SCALE); j++)
                    *(unsigned int *)(bbox_memory_base+bias_addr+4*j) = 0x0000001F;
            }
        }
    }
    // 待检测框
    for(loop_count=0; loop_count<1; loop_count++)
    {
        if(test_bbox[loop_count][4]==1)
        {
            unsigned bias_addr = 0;
            // 上下两个横线
            for(loop_in=0; loop_in<(test_bbox[loop_count][5]/SCALE); loop_in++){
                bias_addr = (CAM_H_WIDTH*(test_bbox[loop_count][1]+loop_in)+test_bbox[loop_count][0])<<2;
                for(j=0; j<test_bbox[loop_count][2]; j++)
                    *(unsigned int *)(bbox_memory_base+bias_addr+4*j) = 0x000007FF;
                //memset(bbox_memory_base+bias_addr, 0x00, (test_bbox[loop_count][2]<<2));
                bias_addr = (CAM_H_WIDTH*(test_bbox[loop_count][1]+loop_in+test_bbox[loop_count][3])+test_bbox[loop_count][0])<<2;
                //memset(bbox_memory_base+bias_addr, 0x00, (test_bbox[loop_count][2]<<2));
                for(j=0; j<test_bbox[loop_count][2]; j++)
                    *(unsigned int *)(bbox_memory_base+bias_addr+4*j) = 0x000007FF;
            }
            // 然后是左右的竖线
            for(loop_in=0; loop_in<(test_bbox[loop_count][3]+test_bbox[loop_count][5]/SCALE); loop_in++){
                bias_addr = (CAM_H_WIDTH*(test_bbox[loop_count][1]+loop_in)+test_bbox[loop_count][0])<<2;
                //memset(bbox_memory_base+bias_addr, 0x00, ((test_bbox[loop_count][5]/SCALE)<<2));
                for(j=0; j<(test_bbox[loop_count][5]/SCALE); j++)
                    *(unsigned int *)(bbox_memory_base+bias_addr+4*j) = 0x000007FF;
                bias_addr = (CAM_H_WIDTH*(test_bbox[loop_count][1]+loop_in)+test_bbox[loop_count][0]+test_bbox[loop_count][2])<<2;
                //memset(bbox_memory_base+bias_addr, 0x00, ((test_bbox[loop_count][5]/SCALE)<<2));
                for(j=0; j<(test_bbox[loop_count][5]/SCALE); j++)
                    *(unsigned int *)(bbox_memory_base+bias_addr+4*j) = 0x000007FF;
            }
        }
    }
    // 最后是总的框
    for(loop_count=0; loop_count<1; loop_count++)
    {
        if(final_bbox[loop_count][4]==1)
        {
            unsigned bias_addr = 0;
            // 上下两个横线
            for(loop_in=0; loop_in<(final_bbox[loop_count][5]/SCALE); loop_in++){
                bias_addr = (CAM_H_WIDTH*(final_bbox[loop_count][1]+loop_in)+final_bbox[loop_count][0])<<2;
                for(j=0; j<final_bbox[loop_count][2]; j++)
                    *(unsigned int *)(bbox_memory_base+bias_addr+4*j) = 0x000007E0;
                //memset(bbox_memory_base+bias_addr, 0x00, (final_bbox[loop_count][2]<<2));
                bias_addr = (CAM_H_WIDTH*(final_bbox[loop_count][1]+loop_in+final_bbox[loop_count][3])+final_bbox[loop_count][0])<<2;
                //memset(bbox_memory_base+bias_addr, 0x00, (final_bbox[loop_count][2]<<2));
                for(j=0; j<final_bbox[loop_count][2]; j++)
                    *(unsigned int *)(bbox_memory_base+bias_addr+4*j) = 0x000007E0;
            }
            // 然后是左右的竖线
            for(loop_in=0; loop_in<(final_bbox[loop_count][3]+final_bbox[loop_count][5]/SCALE); loop_in++){
                bias_addr = (CAM_H_WIDTH*(final_bbox[loop_count][1]+loop_in)+final_bbox[loop_count][0])<<2;
                //memset(bbox_memory_base+bias_addr, 0x00, ((final_bbox[loop_count][5]/SCALE)<<2));
                for(j=0; j<(final_bbox[loop_count][5]/SCALE); j++)
                    *(unsigned int *)(bbox_memory_base+bias_addr+4*j) = 0x000007E0;
                bias_addr = (CAM_H_WIDTH*(final_bbox[loop_count][1]+loop_in)+final_bbox[loop_count][0]+final_bbox[loop_count][2])<<2;
                //memset(bbox_memory_base+bias_addr, 0x00, ((final_bbox[loop_count][5]/SCALE)<<2));
                for(j=0; j<(final_bbox[loop_count][5]/SCALE); j++)
                    *(unsigned int *)(bbox_memory_base+bias_addr+4*j) = 0x000007E0;
            }
        }
    }
	// 调换正在写入的内存块
	pd_bbox_frame = 1-pd_bbox_frame;
    *(unsigned char *)h2f_lw_bbox_frame_addr = pd_bbox_frame;
	//
	finish = clock();
	duration = (double)(finish - start) / CLOCKS_PER_SEC; 
	//printf("bbox-adding result reading finished! total time: %f sec\n", duration);
}

/////////////////////////////////////////////////////

/////////////////
// 加上字幕
void add_word_display(int action)
{
	*(uint32_t *)h2f_lw_led_addr = 0xFFFFFFF0 | action;	// 全亮
	usleep(1000);
}

// 测试加上字幕
void test_word_display(void)
{
	int i;
	for(i=0; i<6; i++){
		add_word_display(i);
		usleep(2000*1000);
	}
}