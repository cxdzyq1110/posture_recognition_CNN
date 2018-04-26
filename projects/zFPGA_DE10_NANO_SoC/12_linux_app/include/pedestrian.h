#ifndef _PEDESTIAN_
#define _PEDESTIAN_


#define	NUM_PD_PER_SCALE	3

// 行人检测的框
extern int pd_bbox[100][6];
// 线程间的互斥量
extern pthread_mutex_t mtx_pd_bbox;    // 因为行人检测NMS计算出来的框需要同步

// 行人检测窗口聚合的代码实现
extern void pd_windows_merge(void);
extern void fake_pd_windows_merge(void);	// 仅仅是搬运一下视频

#endif