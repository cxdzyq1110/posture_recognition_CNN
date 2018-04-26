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


// 仅仅是搬运一下视频
void fake_pd_windows_merge(void)
{
    clock_t start, finish; double duration; 	// 计时用
	// 首先获取MT9D111正在写入的DDR区间基数
	mt9d111_block = (*(unsigned int *)h2f_lw_video_block_addr - 1)&0x03;
	video_result_addr = video_virtual_base + 0x00800000 * mt9d111_block;
	// 然后将视频数据搬移到加框数据空间
	memcpy(bbox_virtual_base, video_result_addr, 0x00200000);	// 其实只要拷贝2MB就行啦
}

/////////////////////////////////////////////////
// 行人检测结果的窗口聚合
void pd_windows_merge(void)
{
    int loop_count;
    clock_t start, finish; double duration; 	// 计时用
	pd_result_addr = pd_virtual_base;
	////printf("reading pd result [0x%08X] ==> %08X hex\n", (unsigned int)pd_result_addr, *(unsigned int *)pd_result_addr);
	// 下面是加载可能是行人的框
	unsigned int pd_result_item;
	int loop_in;
	int pd_result_item_num = 0;
	int pd_result_scale, pd_result_score, pd_result_hcnt, pd_result_vcnt;
	// 只输出1/1和1/2和1/4检测的最大score的方框坐标
	int pd_result_yuki_position_s1[NUM_PD_PER_SCALE][2];
	int pd_result_yuki_score_s1[NUM_PD_PER_SCALE] = {0,};
	int pd_result_yuki_position_s2[NUM_PD_PER_SCALE][2];
	int pd_result_yuki_score_s2[NUM_PD_PER_SCALE] = {0,};
	int pd_result_yuki_position_s4[NUM_PD_PER_SCALE][2];
	int pd_result_yuki_score_s4[NUM_PD_PER_SCALE] = {0,};
	//
	// 遍历行人检测结果存储的内存空间
	void *pd_result_addr = pd_virtual_base + 4;
	// 开始计时
	start = clock();
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
	}while(pd_result_item!=0x00000000 && pd_result_item_num<20000);
	
	////printf("stop @ %08X\n", pd_result_item);
	
	//int pd_bbox[3*NUM_PD_PER_SCALE][6];	// [0]==>x, [1]==>y, [2]==>w, [3]==>h, [4]==>enable/disable, [5]==>score
	for(loop_count=0; loop_count<3*NUM_PD_PER_SCALE; loop_count++){
		pd_bbox[loop_count][4] = 0;
	}
	////////////////////////////////////////////////////////////////////////////////////////
	// 窗口聚合（使用非极大值抑制 NMS 算法）
	float IoU_thres = 0.1;
	////////////////////////////////////////////////////////////////////////////////////////
	// 1:1 scale
	for(loop_count=0; loop_count<NUM_PD_PER_SCALE; loop_count++){
		if(pd_result_yuki_score_s1[loop_count]>0)
		{
			/*
			//printf("bbox.scale = %d, bbox.score=%d, bbox.hcnt = %d, bbox.vcnt=%d\n", 
					1, pd_result_yuki_score_s1[loop_count],
					pd_result_yuki_position_s1[loop_count][1], pd_result_yuki_position_s1[loop_count][0]
			);
			*/
			// 把窗口聚合
			// 首先遍历寻找IoU>IoU_thres的待选窗口
			for(loop_in=0; loop_in<3*NUM_PD_PER_SCALE; loop_in++){
				if(!pd_bbox[loop_in][4]){
					// 添加一个窗口
					////printf("add [%d]th window, |x%d|y%d|w%d|h%d|\n", loop_in, pd_result_yuki_position_s1[loop_count][1], pd_result_yuki_position_s1[loop_count][0], 80, 140);
					pd_bbox[loop_in][4] = 1;
					pd_bbox[loop_in][5] = pd_result_yuki_score_s1[loop_count];
					pd_bbox[loop_in][0] = pd_result_yuki_position_s1[loop_count][1];
					pd_bbox[loop_in][1] = pd_result_yuki_position_s1[loop_count][0];
					pd_bbox[loop_in][2] = 80;
					pd_bbox[loop_in][3] = 140;
					break;
				}
				else{
					// 计算IoU
					int x1 = pd_bbox[loop_in][0];
					int y1 = pd_bbox[loop_in][1];
					int w1 = pd_bbox[loop_in][2];
					int h1 = pd_bbox[loop_in][3];
					int x2 = pd_result_yuki_position_s1[loop_count][1];
					int y2 = pd_result_yuki_position_s1[loop_count][0];
					int w2 = 80;
					int h2 = 140;
					float S1 = w1*h1;	// 面积1
					float S2 = w2*h2;	// 面积2
					// 计算交集
					float ISxl = (x1>x2)? x1 : x2;	// 挑选较大的（右）
					float ISxr = ((x1+w1)>(x2+w2))? (x2+w2) : (x1+w1);	// 挑选较小的（左）
					float ISyu = (y1>y2)? y1 : y2;	// 挑选较大的（下）
					float ISyd = ((y1+h1)>(y2+h2))? (y2+h2) : (y1+h1);	// 挑选较小的（上）
					//
					float SI;
					float SU;
					if((ISxl>ISxr)||(ISyu>ISyd))
						SI = 0;
					else
						SI = (ISxr-ISxl)*(ISyd-ISyu);
					//
					SU = S1+S2 - SI;
					float IoU = SI/SU;
					////printf("|x%d|y%d|w%d|h%d| -- |x%d|y%d|w%d|h%d| ==> SI=%.2f, SU = %.2f, IoU = %.2f\n", x1, y1, w1, h1, x2, y2, w2, h2, SI, SU, IoU);
					// 如果IoU>IoU_thres
					if(IoU>IoU_thres){
						// 比对score
						if(pd_bbox[loop_in][5]<pd_result_yuki_score_s1[loop_count]){
							// 替换这个窗口
							////printf("change [%d]th window, |x%d|y%d|w%d|h%d|s%d|\n", loop_in, pd_result_yuki_position_s1[loop_count][1], pd_result_yuki_position_s1[loop_count][0], 80, 140, pd_result_yuki_score_s1[loop_count]);
							pd_bbox[loop_in][4] = 1;
							pd_bbox[loop_in][5] = pd_result_yuki_score_s1[loop_count];
							pd_bbox[loop_in][0] = pd_result_yuki_position_s1[loop_count][1];
							pd_bbox[loop_in][1] = pd_result_yuki_position_s1[loop_count][0];
							pd_bbox[loop_in][2] = 80;
							pd_bbox[loop_in][3] = 140;
						}
						break;
					}
				}
			}
		}
	}
	// 1:2 scale
	for(loop_count=0; loop_count<NUM_PD_PER_SCALE; loop_count++){
		if(pd_result_yuki_score_s2[loop_count]>0)
		{
			/*
			//printf("bbox.scale = %d, bbox.score=%d, bbox.hcnt = %d, bbox.vcnt=%d\n", 
					2, pd_result_yuki_score_s2[loop_count],
					pd_result_yuki_position_s2[loop_count][1], pd_result_yuki_position_s2[loop_count][0]
			);
			*/
			// 把窗口聚合
			// 首先遍历寻找IoU>IoU_thres的待选窗口
			for(loop_in=0; loop_in<3*NUM_PD_PER_SCALE; loop_in++){
				if(!pd_bbox[loop_in][4]){
					// 添加一个窗口
					////printf("add [%d]th window, |x%d|y%d|w%d|h%d|\n", loop_in, pd_result_yuki_position_s2[loop_count][1], pd_result_yuki_position_s2[loop_count][0], 160, 280);
					pd_bbox[loop_in][4] = 1;
					pd_bbox[loop_in][5] = pd_result_yuki_score_s2[loop_count];
					pd_bbox[loop_in][0] = pd_result_yuki_position_s2[loop_count][1];
					pd_bbox[loop_in][1] = pd_result_yuki_position_s2[loop_count][0];
					pd_bbox[loop_in][2] = 160;
					pd_bbox[loop_in][3] = 280;
					break;
				}
				else{
					// 计算IoU
					int x1 = pd_bbox[loop_in][0];
					int y1 = pd_bbox[loop_in][1];
					int w1 = pd_bbox[loop_in][2];
					int h1 = pd_bbox[loop_in][3];
					int x2 = pd_result_yuki_position_s2[loop_count][1];
					int y2 = pd_result_yuki_position_s2[loop_count][0];
					int w2 = 160;
					int h2 = 280;
					float S1 = w1*h1;	// 面积1
					float S2 = w2*h2;	// 面积2
					// 计算交集
					float ISxl = (x1>x2)? x1 : x2;	// 挑选较大的（右）
					float ISxr = ((x1+w1)>(x2+w2))? (x2+w2) : (x1+w1);	// 挑选较小的（左）
					float ISyu = (y1>y2)? y1 : y2;	// 挑选较大的（下）
					float ISyd = ((y1+h1)>(y2+h2))? (y2+h2) : (y1+h1);	// 挑选较小的（上）
					//
					float SI;
					float SU;
					if((ISxl>ISxr)||(ISyu>ISyd))
						SI = 0;
					else
						SI = (ISxr-ISxl)*(ISyd-ISyu);
					//
					SU = S1+S2 - SI;
					float IoU = SI/SU;
					////printf("|x%d|y%d|w%d|h%d| -- |x%d|y%d|w%d|h%d| ==> SI=%.2f, SU = %.2f, IoU = %.2f\n", x1, y1, w1, h1, x2, y2, w2, h2, SI, SU, IoU);
					// 如果IoU>IoU_thres
					if(IoU>IoU_thres){
						// 比对score
						if(pd_bbox[loop_in][5]<pd_result_yuki_score_s2[loop_count]){
							// 替换这个窗口
							////printf("change [%d]th window, |x%d|y%d|w%d|h%d|s%d|\n", loop_in, pd_result_yuki_position_s2[loop_count][1], pd_result_yuki_position_s2[loop_count][0], 160, 280, pd_result_yuki_score_s2[loop_count]);
							pd_bbox[loop_in][4] = 1;
							pd_bbox[loop_in][5] = pd_result_yuki_score_s2[loop_count];
							pd_bbox[loop_in][0] = pd_result_yuki_position_s2[loop_count][1];
							pd_bbox[loop_in][1] = pd_result_yuki_position_s2[loop_count][0];
							pd_bbox[loop_in][2] = 160;
							pd_bbox[loop_in][3] = 280;
						}
						break;
					}
				}
			}
		}
	}
	// 1:4 scale
	for(loop_count=0; loop_count<NUM_PD_PER_SCALE; loop_count++){
		if(pd_result_yuki_score_s4[loop_count]>0)
		{
			/*
			//printf("bbox.scale = %d, bbox.score=%d, bbox.hcnt = %d, bbox.vcnt=%d\n", 
					4, pd_result_yuki_score_s4[loop_count],
					pd_result_yuki_position_s4[loop_count][1], pd_result_yuki_position_s4[loop_count][0]
			);
			*/
			// 把窗口聚合
			// 首先遍历寻找IoU>IoU_thres的待选窗口
			for(loop_in=0; loop_in<3*NUM_PD_PER_SCALE; loop_in++){
				if(!pd_bbox[loop_in][4]){
					// 添加一个窗口
					////printf("add [%d]th window, |x%d|y%d|w%d|h%d|\n", loop_in, pd_result_yuki_position_s4[loop_count][1], pd_result_yuki_position_s4[loop_count][0], 320, 560);
					pd_bbox[loop_in][4] = 1;
					pd_bbox[loop_in][5] = pd_result_yuki_score_s4[loop_count];
					pd_bbox[loop_in][0] = pd_result_yuki_position_s4[loop_count][1];
					pd_bbox[loop_in][1] = pd_result_yuki_position_s4[loop_count][0];
					pd_bbox[loop_in][2] = 320;
					pd_bbox[loop_in][3] = 560;
					break;
				}
				else{
					// 计算IoU
					int x1 = pd_bbox[loop_in][0];
					int y1 = pd_bbox[loop_in][1];
					int w1 = pd_bbox[loop_in][2];
					int h1 = pd_bbox[loop_in][3];
					int x2 = pd_result_yuki_position_s4[loop_count][1];
					int y2 = pd_result_yuki_position_s4[loop_count][0];
					int w2 = 320;
					int h2 = 560;
					float S1 = w1*h1;	// 面积1
					float S2 = w2*h2;	// 面积2
					// 计算交集
					float ISxl = (x1>x2)? x1 : x2;	// 挑选较大的（右）
					float ISxr = ((x1+w1)>(x2+w2))? (x2+w2) : (x1+w1);	// 挑选较小的（左）
					float ISyu = (y1>y2)? y1 : y2;	// 挑选较大的（下）
					float ISyd = ((y1+h1)>(y2+h2))? (y2+h2) : (y1+h1);	// 挑选较小的（上）
					//
					float SI;
					float SU;
					if((ISxl>ISxr)||(ISyu>ISyd))
						SI = 0;
					else
						SI = (ISxr-ISxl)*(ISyd-ISyu);
					//
					SU = S1+S2 - SI;
					float IoU = SI/SU;
					////printf("|x%d|y%d|w%d|h%d| -- |x%d|y%d|w%d|h%d| ==> SI=%.2f, SU = %.2f, IoU = %.2f\n", x1, y1, w1, h1, x2, y2, w2, h2, SI, SU, IoU);
					// 如果IoU>IoU_thres
					if(IoU>IoU_thres){
						// 比对score
						if(pd_bbox[loop_in][5]<pd_result_yuki_score_s4[loop_count]){
							// 替换这个窗口
							////printf("change [%d]th window, |x%d|y%d|w%d|h%d|s%d|\n", loop_in, pd_result_yuki_position_s4[loop_count][1], pd_result_yuki_position_s4[loop_count][0], 320, 560, pd_result_yuki_score_s4[loop_count]);
							pd_bbox[loop_in][4] = 1;
							pd_bbox[loop_in][5] = pd_result_yuki_score_s4[loop_count];
							pd_bbox[loop_in][0] = pd_result_yuki_position_s4[loop_count][1];
							pd_bbox[loop_in][1] = pd_result_yuki_position_s4[loop_count][0];
							pd_bbox[loop_in][2] = 320;
							pd_bbox[loop_in][3] = 560;
						}
						break;
					}
				}
			}
		}
	}
	finish = clock();
	duration = (double)(finish - start) / CLOCKS_PER_SEC; 
	printf("pedestrian detection result reading & NMS merging finished! total time: %f sec\n", duration);
	//
	//sleep(0.01);
}
