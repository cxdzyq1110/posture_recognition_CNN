#ifndef _OPTICAL_FLOW_
#define _OPTICAL_FLOW_



// 加载光流法mask的函数
extern void load_opt_flow_task(void);
// 光流法的外部框
extern int of_bbox[1][6]; // [0]=hcnt, [1]=vcnt, [2]=width, [3]=height, [4]=enable, [5]=score
// 线程间的互斥量
extern pthread_mutex_t mtx_of_bbox;    // 因为光流法计算出来的框需要同步

// 光流法结果
extern unsigned char of_mask[300][400];
// 光流计算结果在DDR中的内存地址
extern void *of_result_addr;

#endif