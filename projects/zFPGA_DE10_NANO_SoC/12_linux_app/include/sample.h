#ifndef _SAMPLE_
#define _SAMPLE_

// 视频采集在DDR中的存储地址
extern void *video_result_addr;
// 用来缓存数据
extern uint8_t 	test_f2s_read[1024];
// 用于循环采样使用
extern int sample_time;    // 采样次数
// 记录采样的文件夹
extern char filedir[128];  //
// 时间戳
extern char time_stamp[128];
// 采样函数
extern void sample_task(int num);  // 输入量为采样次数（标记）
// 读取最近一帧数据
extern void read_last_frame(void);
#endif