#ifndef _PLOT_
#define _PLOT_


// 绘图 & 加框
extern void plot_picture_and_bbox(void);

// 
#define	CAM_H_WIDTH	800
#define	CAM_V_WIDTH	600

#define VGA_SCALE	4
#define BBOX_WIDTH	5

// 然后是加上字幕
#define	bending		0
#define	null		1
#define	waving		2
#define	squat		3
#define	stand		4
#define	walking		5
extern void add_word_display(int action);
// 测试加上字幕
extern void test_word_display(void);

#endif