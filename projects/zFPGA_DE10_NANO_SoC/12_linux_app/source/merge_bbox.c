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


/////////////////////////////////
// 合并PD & LK的加框结果
void merge_bbox_task(void)
{
    clock_t start, finish; double duration; 	// 计时用
    start = clock();
    int i, j;
    int cx, cy;
    // 首先考察光流法是否检测出行人框
    // 并且初始化最后的框的属性
    int Bx_min, Bx_max, By_min, By_max;
    if(of_bbox[0][4])
    {
        // 如果有光流，那么就要取光流区域中心和上一次跟踪结果中心
        cx = ((of_bbox[0][0] + of_bbox[0][2]/2) + (final_bbox[0][0] + final_bbox[0][2]/2))/2;
        cy = ((of_bbox[0][1] + of_bbox[0][3]/2) + (final_bbox[0][1] + final_bbox[0][3]/2))/2;
        //
        Bx_min = of_bbox[0][0];
        Bx_max = of_bbox[0][0] + of_bbox[0][2];
        By_min = of_bbox[0][1];
        By_max = of_bbox[0][1] + of_bbox[0][3];
    }
    // 否则就是使用上一次检测到的结果
    else{
        // 如果没有有光流，那么直接用上一次跟踪结果的中心
        cx = final_bbox[0][0] + final_bbox[0][2]/2;
        cy = final_bbox[0][1] + final_bbox[0][3]/2;
        //
        Bx_min = final_bbox[0][0];
        Bx_max = final_bbox[0][0] + final_bbox[0][2];
        By_min = final_bbox[0][1];
        By_max = final_bbox[0][1] + final_bbox[0][3];
    }
    
    // 然后需要考察[cx, cy]周围是否有HOG+SVM行人检测框，用来进行扩充
    // 首先生成待检测区域
    int Tx_min = (cx-of_bbox_shifter_sum[2]/2/of_bbox_shifter_len)<0 ? 0 : cx-of_bbox_shifter_sum[2]/2/of_bbox_shifter_len;
    int Tx_max = (cx+of_bbox_shifter_sum[2]/2/of_bbox_shifter_len)>(CAM_H_WIDTH-2*BBOX_WIDTH) ? (CAM_H_WIDTH-2*BBOX_WIDTH) : cx+of_bbox_shifter_sum[2]/2/of_bbox_shifter_len;
    int Ty_min = (cy-of_bbox_shifter_sum[3]/2/of_bbox_shifter_len)<0 ? 0 : cy-of_bbox_shifter_sum[3]/2/of_bbox_shifter_len;
    int Ty_max = (cy+of_bbox_shifter_sum[3]/2/of_bbox_shifter_len)>(CAM_V_WIDTH-2*BBOX_WIDTH) ? (CAM_V_WIDTH-2*BBOX_WIDTH) : cy+of_bbox_shifter_sum[3]/2/of_bbox_shifter_len;
    //
    test_bbox[0][0] = Tx_min;
    test_bbox[0][1] = Ty_min;
    test_bbox[0][2] = Tx_max - Tx_min;
    test_bbox[0][3] = Ty_max - Ty_min;
    test_bbox[0][4] = 1;
    test_bbox[0][5] = 256;
    // 然后遍历HOG+SVM的行人检测+NMS非极大值抑制后的打框结果
    int idx = 0;
    while(pd_bbox[idx][4]){
        // 只看有效的打框
        // 计算框的中心，
        int pd_bbox_cx = pd_bbox[idx][0] + pd_bbox[idx][2]/2;
        int pd_bbox_cy = pd_bbox[idx][1] + pd_bbox[idx][3]/2;
        // 计算PD框和待检测框的重叠面积
        int SI = InterSect(pd_bbox[idx][0], pd_bbox[idx][1], pd_bbox[idx][2], pd_bbox[idx][3],
                            Tx_min, Ty_min, Tx_max-Tx_min, Ty_max-Ty_min
                            );
        // 计算重叠面积占据PD框的多少百分比
        float InterSectRatio = SI * 1.0 / (pd_bbox[idx][2]*pd_bbox[idx][3]);
        // 如果中心落在待检测区域
        //if((pd_bbox_cx>Tx_min && pd_bbox_cx<Tx_max) && (pd_bbox_cy>Ty_min && pd_bbox_cy<Ty_max)){
        if(InterSectRatio > 0.8){
            // 那么这个中心位置是值得借鉴的
            // 也就是说要扩充光流框
            Bx_min = pd_bbox[idx][0]<Bx_min? pd_bbox[idx][0] : Bx_min;
            Bx_max = (pd_bbox[idx][0] + pd_bbox[idx][2])>Bx_max? (pd_bbox[idx][0] + pd_bbox[idx][2]) : Bx_max;
            By_min = pd_bbox[idx][1]<By_min? pd_bbox[idx][1] : By_min;
            By_max = (pd_bbox[idx][1] + pd_bbox[idx][3])>By_max? (pd_bbox[idx][1] + pd_bbox[idx][3]) : By_max;
        }
        idx++;
        if(idx>50)
            break;
    }
    ///////////////
    // 最后合并框
    final_bbox[0][0] = Bx_min;
    final_bbox[0][1] = By_min;
    final_bbox[0][2] = Bx_max - Bx_min;
    final_bbox[0][3] = By_max - By_min;
    final_bbox[0][4] = 1;
    final_bbox[0][5] = 160;
    // 记录一段时间里面，行人的尺寸，要进行光滑处理！
    of_bbox_shifter_sum[2] -= of_bbox_shifter[of_bbox_shifter_head][2];
    of_bbox_shifter_sum[3] -= of_bbox_shifter[of_bbox_shifter_head][3];
    of_bbox_shifter[of_bbox_shifter_head][2] = final_bbox[0][2];
    of_bbox_shifter[of_bbox_shifter_head][3] = final_bbox[0][3];
    of_bbox_shifter_sum[2] += of_bbox_shifter[of_bbox_shifter_head][2];
    of_bbox_shifter_sum[3] += of_bbox_shifter[of_bbox_shifter_head][3];
    of_bbox_shifter_head = (of_bbox_shifter_head+1)%of_bbox_shifter_len;
	//
	finish = clock();
	duration = (double)(finish - start) / CLOCKS_PER_SEC; 
	printf("bbox-merge finished! total time: %f sec ==> x%d, y%d, w%d, h%d\n", duration, final_bbox[0][0], final_bbox[0][1], final_bbox[0][2], final_bbox[0][3]);
}

