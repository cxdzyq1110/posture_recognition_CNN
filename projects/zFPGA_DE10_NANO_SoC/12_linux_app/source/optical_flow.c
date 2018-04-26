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


// 加载光流法mask的函数
void load_opt_flow_task(void)
{
    int i, j;
    int addr;
    clock_t start, finish; double duration; 	// 计时用
	start = clock();
    ////printf("starting reading of-mask...\n");
	// 首先看看现在在写入那个区间
	mt9d111_block = (*(unsigned int *)h2f_lw_video_block_addr - 1)&0x03;
	of_result_addr = of_virtual_base + 0x00800000 * ((mt9d111_block-1)&0x03);
    // 计算光流mask的中心位置
    int sx = 0, sy = 0;
    int cn = 0;
    for(i=0; i<300; i++){
        for(j=0; j<400; j++){
            addr = 4*((2*i*800)+2*j);
            of_mask[i][j] = ((*(unsigned int *)(of_result_addr+addr))>>30) & 0x01;
            if(of_mask[i][j]==1){
                sx += j; sy += i; cn++;
            }
        }
    }
    // 清除光流法的框
    of_bbox[0][4] = 0; // disable
    // 生成中心位置
    if(cn>0){
        int cx = sx/cn; int cy = sy/cn;
        // 统计中心位置周围是否有较多的of_mask
        //int scale = 1;  // 70x40 in 300x400
        float scale_x, scale_y;
        for(scale_y=4.0; scale_y>0.5; scale_y=scale_y-0.1)
        {
            scale_x = scale_y;
            //for(scale_x=scale_y; scale_x>0.5; scale_x=scale_x-0.4)
            //{
                int xmin = (cx-20*scale_x)<0 ? 0 : cx-20*scale_x;
                int xmax = (cx+20*scale_x)>399-10 ? 399-10 : cx+20*scale_x;
                int ymin = (cy-35*scale_y)<0 ? 0 : cy-35*scale_y;
                int ymax = (cy+35*scale_y)>299-10 ? 299-10 : cy+35*scale_y;
                int sn = 0;
                for(i=ymin; i<ymax; i++){
                    for(j=xmin; j<xmax; j++){
                        sn += of_mask[i][j];
                    }
                }
                // 
                if(sn>(200*scale_x*scale_y)){
                    //printf("<scale_x=%.2f, scale_y=%.2f> of_mask_center = %d, %d\n", scale_x, scale_y, cy, cx);
                    of_bbox[0][4] = 1; 
                    of_bbox[0][0] = xmin*2; 
                    of_bbox[0][1] = ymin*2; 
                    of_bbox[0][2] = (xmax-xmin)*2; 
                    of_bbox[0][3] = (ymax-ymin)*2; 
                    of_bbox[0][5] = 256;
                    break;
                }
            //}
        }
    }
	finish = clock();
	duration = (double)(finish - start) / CLOCKS_PER_SEC; 
	printf("of_mask-loading finished! total time: %f sec\n", duration);
}
