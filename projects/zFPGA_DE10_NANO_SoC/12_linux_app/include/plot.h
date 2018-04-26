#ifndef _PLOT_
#define _PLOT_


// 绘图 & 加框
extern void plot_picture_and_bbox(void);
// 加框的数据
extern unsigned int add_pd_box(unsigned int HCnt, unsigned int VCnt, unsigned int W, unsigned int H, unsigned S);	// 
extern unsigned int clear_pd_box(void);	// 

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