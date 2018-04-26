#ifndef _MERGE_BBOX_
#define	_MERGE_BBOX_


// 合并PD & LK的加框结果
extern void merge_bbox_task(void);
extern int final_bbox[1][6];
#define of_bbox_shifter_len 256
extern int of_bbox_shifter[of_bbox_shifter_len][6]; // 缓存过去检测到的光流法的框
extern int of_bbox_shifter_head;   // 指针头部
extern int of_bbox_shifter_sum[6];

extern int test_bbox[1][6];    // 待检测框


#endif