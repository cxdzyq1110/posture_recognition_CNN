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
#include "../include/hps_0.h"

////
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

///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
// NPU指令，128-bit
float npu_time ;	// npu指令执行时间
uint32_t	npu_inst_buffer[4];
// 一些全局变量
void *lw_h2f_virtual_base;	// lw.h2f接口的虚拟地址
void *h2f_virtual_base;		// h2f接口的虚拟地址
void *video_virtual_base;	// f2s接口（原始视频）映射的虚拟地址
void *pd_virtual_base;		// 行人检测空间映射后的虚拟地址
void *of_virtual_base;		// 光流计算结果存储空间映射后的虚拟地址
void *bbox_virtual_base;	// 加框以后的视频结果存储空间
void *bbox_memory_base;	// 加框以后的视频结果存储空间
void *cnn_para_virtual_base;	// CNN参数的存储空间
void *cnn_in_virtual_base;	// CNN输入的存储空间
void *cnn_out_virtual_base;	// CNN输出的存储空间
int fd;
//int loop_count;
int led_direction;
int led_mask;
void *h2f_lw_led_addr;		// led, ，通过h2f.lw接口写进去
void *h2f_lw_sysid_addr;	// system id，通过h2f.lw接口写进去
void *h2f_lw_ram_addr;		// ocram，通过h2f.lw接口写进去
void *h2f_lw_video_block_addr;		// mt9d111正在写入的区块，读取看看
void *h2f_lw_bbox_frame_addr;	// 加框以后的视频结果存储空间标记
void *h2f_lw_bbox_mask_addr;	// 用来存储加框的掩膜
void *h2f_lw_fpga_addr;		// fpga
void *h2f_lw_npu_addr;		// npu ready & time-count
void *h2f_ram_addr;
void *h2f_fpga_addr;

unsigned char mt9d111_block ;	// 查看现在摄像头的数据正在写入到DDR的哪一块内存区间 
unsigned char pd_bbox_frame;	// HPS正在写入的行人加框视频文件的内存块技术标记
	
void *pd_result_addr;
void *video_result_addr;
void *of_result_addr;	

// 行人检测的框
int pd_bbox[100][6];

// 合并PD & LK的加框结果
int final_bbox[1][6];
int of_bbox_shifter[of_bbox_shifter_len][6]; // 缓存过去检测到的光流法的框
int of_bbox_shifter_head;   // 指针头部
int of_bbox_shifter_sum[6];

int test_bbox[1][6];    // 待检测框

// 线程结束运行的标志
int thread_exit_falg;


// 光流法结果
unsigned char of_mask[300][400];
// 光流法的外部框
int of_bbox[1][6]; // [0]=hcnt, [1]=vcnt, [2]=width, [3]=height, [4]=enable, [5]=score

// 用于循环采样使用
int sample_time;    // 采样次数
// 记录采样的文件夹
char filedir[128];  //
int mode;   // 运行的模式，0-->正常模式 / 1-->采样模式 / 2-->没有CNN的运行模式
// 用来缓存数据
uint8_t 	test_f2s_read[1024];
// 时间戳
char time_stamp[128];

///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
// 线程1，用来进行行人检测结果的NMS
void * thread_pd_bbox(void *);
// 线程2，用来检测按钮
void * check_keyboard(void *);
// 线程3，用来调度NPU
void * npu_inst_transfer(void *);
// 线程4，用来加载光流法
void * load_opt_flow_task_thread(void *);
// 线程5，用来绘图&加框处理
void * plot_thread(void *);
// 线程6，用来合并行人检测&光流加框的结果
void * merge_bbox_thread(void *);
// 线程7，采样
void * sample_bbox_thread(void *);
// 线程8，判别
void * cnn_judge_thread(void *);
// 线程8，判别一次
void * cnn_judge_once_thread(void *);

// 主函数
int main(int argc,char *argv[]) {
	//
    int i;
    system("clear");
    //
	if(init_all_interfaces())
		return 0;
	// 首先，让FPGA对DDR的访问启动
	*(uint32_t *)h2f_lw_led_addr = 0xFFFFFFFF;	// 全亮
	// 测试加上字幕
	add_word_display(1);
	// 初始化配置
	pd_bbox_frame = 0;	// 首先写入的是#0内存块
    sample_time = 0;
    for(i=0; i<6; i++){
        of_bbox_shifter_sum[i] = 0;
    }
    
    of_bbox_shifter_head = 0;   // 清除光流法的框的缓存空间
	// 延时一会儿
	usleep( 100*1000 );
	
	// 存储好NPU指令
	emit_all_npu_insts();	// 2018-04-09: 一旦运行这个函数，HPS就会奔溃？	
	// 存储好CNN的参数
	init_all_parameters();
	
	// 定义线程的 id 变量，多个变量使用数组
#define NUM_THREADS 10
    pthread_t tids[NUM_THREADS];
	
	// 首先测试一下最近一帧数据的读取结果
	read_last_frame();
    
    // 然后需要根据带入参数的值，确定需要调用的模式（running/sampling，即运行/采样）
    // 如果执行了 ./my_first_hps-fpga r  ，那么就是正常的运行模式
    if(argc==2 && !strcmp(argv[1], "r"))
    {
        printf("running mode...\n");
        mode = 0;   // 正常运行模式
        //return 1;
    }
	else if(argc==2 && !strcmp(argv[1], "tr"))
	{
		printf("running only once...\n");
		mode = 8;
	}
    // 如果执行了 ./my_first_hps-fpga rnc  ，那么就是没有CNN的运行模式（在CNN训练前，前期检查）
    else if(argc==2 && !strcmp(argv[1], "rnc"))
    {
        printf("running-without-CNN mode...\n");
        mode = 2;   // 没有CNN的运行模式
        //return 1;
    }
    // 如果执行了 ./my_first_hps-fpga rnc  ，那么就是没有CNN的运行模式（在CNN训练前，前期检查）
    else if(argc==2 && !strcmp(argv[1], "testcnn"))
    {
        printf("testing-CNN mode...\n");
        mode = 3;   // 测试CNN的模式
        //return 1;
    }
    // 如果执行了 ./my_first_hps-fpga s dir num  ，那么就是采样模式，会采集num次数，全部保存在dir文件夹中，加上时间戳标记
    else if(argc==4 && !strcmp(argv[1], "s"))
    {
        sample_time = atoi(argv[3]);
        strcpy(filedir, argv[2]);
        printf("sampling mode, dir = %s, times=%d...\n", filedir, sample_time);
        if(opendir(filedir)==NULL){
            printf("dir not exists, create one...\n");
            mkdir(filedir, S_IRWXU);
        }
        else{
            printf("dir already exists...\n");
        }
        mode = 1;   // 采样模式
        //return 1;        
    }
    // 否则就是无效指令，直接退出
    else{        
        printf("unvalid mode...\n");
        mode = 0;   // 正常运行模式
        return 0;
    }
	
    // 有CNN的运行模式
    if(mode==0)
    {
        // 首先清除线程结束的flag
        thread_exit_falg = 0;
        // 创建行人检测的线程
        pthread_create(&tids[0], NULL, thread_pd_bbox, NULL);
        // 创建按钮检测的线程
        pthread_create(&tids[1], NULL, check_keyboard, NULL);
        // 创建NPU调度的线程
        //pthread_create(&tids[2], NULL, npu_inst_transfer, NULL);
        // 创建加载光流法mask的线程
        pthread_create(&tids[3], NULL, load_opt_flow_task_thread, NULL);
        // 合并框线的线程
        pthread_create(&tids[4], NULL, merge_bbox_thread, NULL);
        // 创建绘图与显示的线程
        pthread_create(&tids[5], NULL, plot_thread, NULL);
        // 创建CNN判别的线程
        pthread_create(&tids[6], NULL, cnn_judge_thread, NULL);
        
        // 等待线程终止
        while(!thread_exit_falg)
            usleep(1000*1000);	// 
        
    }
    
    // 没有CNN的运行模式
    else if(mode==2)
    {
        // 首先清除线程结束的flag
        thread_exit_falg = 0;
        // 创建行人检测的线程
        pthread_create(&tids[0], NULL, thread_pd_bbox, NULL);
        // 创建按钮检测的线程
        pthread_create(&tids[1], NULL, check_keyboard, NULL);
        // 创建NPU调度的线程
        //pthread_create(&tids[2], NULL, npu_inst_transfer, NULL);
        // 创建加载光流法mask的线程
        pthread_create(&tids[3], NULL, load_opt_flow_task_thread, NULL);
        // 合并框线的线程
        pthread_create(&tids[4], NULL, merge_bbox_thread, NULL);
        // 创建绘图与显示的线程
        pthread_create(&tids[5], NULL, plot_thread, NULL);
        
        // 等待线程终止
        while(!thread_exit_falg)
            usleep(1000*1000);	// 
        
    }
    
    // 采样模式
	else if(mode==1){
        // 获取时间戳
        time_t tt; 
        time(&tt);  
        struct tm *t;  
        t = localtime(&tt); 
        ////printf("localtime %4d%02d%02d %02d:%02d:%02d\n", t->tm_year + 1900, t->tm_mon + 1, t->tm_mday, t->tm_hour, t->tm_min, t->tm_sec);
        sprintf(time_stamp, "%4d-%02d-%02d-%02d-%02d-%02d", t->tm_year + 1900, t->tm_mon + 1, t->tm_mday, t->tm_hour, t->tm_min, t->tm_sec);
        ////printf("%s\n", time_stamp);
        
        
        // 首先清除线程结束的flag
        thread_exit_falg = 0;
        // 创建行人检测的线程
        pthread_create(&tids[0], NULL, thread_pd_bbox, NULL);
        // 创建按钮检测的线程
        pthread_create(&tids[1], NULL, check_keyboard, NULL);
        // 创建NPU调度的线程
        //pthread_create(&tids[2], NULL, npu_inst_transfer, NULL);
        // 创建加载光流法mask的线程
        pthread_create(&tids[3], NULL, load_opt_flow_task_thread, NULL);
        // 合并框线的线程
        pthread_create(&tids[4], NULL, merge_bbox_thread, NULL);
        // 采样的线程
        pthread_create(&tids[5], NULL, sample_bbox_thread, NULL);
        // 创建绘图与显示的线程
        pthread_create(&tids[6], NULL, plot_thread, NULL);
        
        // 等待线程终止
        while(!thread_exit_falg)
            usleep(1000*1000);	// 
    }
	
	// 还要增加一个用来检测CNN运行正确与否的程序（在训练集中）
	// 在python生成的sim_source文件夹中，有相应的CNN参数 & 原始数据的list文件
	// 这些文件的命名依照[sp-xx-label-yy.list]的规则，能够很方便的进行CNN硬件化验证
	else if(mode==3){
		printf("testing our CNN module...\n");
		test_cnn_using_training();
	}
	
	// 测试是不是线程的问题？
	else if(mode==8){
		// 首先清除线程结束的flag
        thread_exit_falg = 0;
        // 创建行人检测的线程
        pthread_create(&tids[0], NULL, thread_pd_bbox, NULL);
        // 创建按钮检测的线程
        pthread_create(&tids[1], NULL, check_keyboard, NULL);
        // 创建NPU调度的线程
        //pthread_create(&tids[2], NULL, npu_inst_transfer, NULL);
        // 创建加载光流法mask的线程
        pthread_create(&tids[3], NULL, load_opt_flow_task_thread, NULL);
        // 合并框线的线程
        pthread_create(&tids[4], NULL, merge_bbox_thread, NULL);
        // 创建绘图与显示的线程
        pthread_create(&tids[5], NULL, plot_thread, NULL);
        // 创建CNN判别的线程
        pthread_create(&tids[6], NULL, cnn_judge_once_thread, NULL);
        
        // 等待线程终止
        while(!thread_exit_falg)
            usleep(1000*1000);	// 
	}
	
	//////////////////////
    // 关闭所有的接口
	if(close_all_interfaces())
		return 0;
	
	return( 0 );
}

//////////////////////////
///////////////
// 线程1，用来进行行人检测结果的NMS和加框处理
void * thread_pd_bbox(void * para)
{
	printf("thread_pd_bbox\n");
	while(!thread_exit_falg)
	{
		////printf("------ * * * --------\n");
		pd_windows_merge();
		//fake_pd_windows_merge();
		usleep(50000);	// 10ms延时
	}
}

// 线程2，用来检测按钮
void * check_keyboard(void * para)
{
	printf("check_keyboard\n");
	while(!thread_exit_falg)
	{
		if(mygetch() == 0x1B)
			thread_exit_falg = 1;
		usleep(200000);	// 100ms延时
	}
}

// 线程3，NPU指令控制
void * npu_inst_transfer(void * para)
{
	printf("npu_inst_transfer\n");
	while(!thread_exit_falg)
	{
		//printf("------ * * * --------\n");
		// 发射NPU指令
		send_npu_inst("ADDi", "0c000000,-189,0e000000,64,128");
		//test_npu_inst();
		usleep(10000);	// 10ms延时
	}
}

// 线程4， 加载光流法mask的函数
void * load_opt_flow_task_thread(void * para)
{
	printf("load_opt_flow_task_thread\n");
    while(!thread_exit_falg)
	{
		//printf("------ * * * --------\n");
        load_opt_flow_task();
		usleep(50000);	// 10ms延时
	}
}

// 线程5，用来绘图&加框处理
void * plot_thread(void * para)
{
	printf("plot_thread\n");
    while(!thread_exit_falg)
	{
		//printf("------ * * * --------\n");
        plot_picture_and_bbox();
		usleep(20000);	// 10ms延时
	}
}

// 线程6，合并
void * merge_bbox_thread(void * para)
{
	printf("merge_bbox_thread\n");
    while(!thread_exit_falg)
	{
		//printf("------ * * * --------\n");
        merge_bbox_task();
		usleep(10*1000);	// 10ms延时
	}
}

// 线程7，采样
void * sample_bbox_thread(void * para)
{
	printf("sample_bbox_thread\n");
    while(!thread_exit_falg && (sample_time--))
	{
		//printf("------ * * * --------\n");
        printf("sample %dth...\n", sample_time);
        sample_task(sample_time);
		usleep(50000);	// 10ms延时
	}
    thread_exit_falg = 1;
}

// 线程8，判别
void * cnn_judge_thread(void * para)
{
	printf("cnn_judge_thread\n");
	while(!thread_exit_falg)
	{
		//printf("------ * * * --------\n");
        cnn_run_judge();
		usleep(5000);	// 500ms延时
	}
}
// 线程8，判别一次
void * cnn_judge_once_thread(void * para)
{
	printf("cnn_judge_thread\n");
	usleep(5000*1000);	// 500ms延时
	//printf("------ * * * --------\n");
	cnn_run_judge();
	usleep(10000);	// 500ms延时
}
//////////////////////////////////////////////////////////////////////////////////
