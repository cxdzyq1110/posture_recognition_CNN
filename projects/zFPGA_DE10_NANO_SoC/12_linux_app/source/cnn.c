#include <stdio.h>
#include <dirent.h>
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

// 动作的名称
char * action[] = {"bending", "null", "waving", "squat", "standing", "walking"};
//
////////////////////////
//
void emit_all_npu_insts(void)
{
	clock_t 	start, finish; double duration; 	// 计时用
	uint32_t	npu_inst_buffer[4];
	char		stream[256];
	char		dat[9];
	FILE * fp = fopen("./inst.txt", "r");
	if(fp==NULL)
		printf("open inst.txt failed...\n");
	else
		printf("open inst.txt sucessfully...\n");
	//
	int i, j, k;
	// 首先是发送RESET信号
	npu_inst_buffer[0] = 0;
	npu_inst_buffer[1] = 0;
	npu_inst_buffer[2] = 0;
	npu_inst_buffer[3] = 1;
	memcpy(h2f_fpga_addr, npu_inst_buffer, 16);	// 似乎是这里发送之后，就出错了？
	//print_npu_inst();
	////printf("npu.inst stage ");
	printf("sending npu instructions...\n");
	usleep(20000);	// 10ms
	///////////////
	// 然后每读取一个指令就发送一次数据
	while(!feof(fp)){
		fgets(stream, sizeof(stream), fp);
		if(strlen(stream)>1){
			//printf("%s", stream);
			for(j=0; j<strlen(stream)-1; ){
				for(k=0; k<8; k++)
					dat[(j)%8] = stream[(j++)];

				dat[8] = 0x00;
				uint32_t dat_uint32;
				sscanf(dat, "%X", &dat_uint32);
				//printf("%08X", dat_uint32);
				npu_inst_buffer[j/8-1] = dat_uint32;
			}
			memcpy(h2f_fpga_addr, npu_inst_buffer, 16);
			//print_npu_inst();
			//
			//printf("\n-------------\n");
			usleep(10000);	// 10ms
		}
	}
	// 然后给出IDLE信号
	npu_inst_buffer[0] = 0;
	npu_inst_buffer[1] = 0;
	npu_inst_buffer[2] = 0;
	npu_inst_buffer[3] = 0;
	memcpy(h2f_fpga_addr, npu_inst_buffer, 16);
	//print_npu_inst();
	usleep(20000);	// 10ms
	/*
	// 最后给出START信号
	npu_inst_buffer[0] = 0;
	npu_inst_buffer[1] = 0;
	npu_inst_buffer[2] = 0;
	npu_inst_buffer[3] = 2;
	memcpy(h2f_fpga_addr, npu_inst_buffer, 16);
	//print_npu_inst();
	//
	emit_start_inst();
	//print_npu_inst();
	*/
	printf("npu insts emission finished...\n");
	//
	fclose(fp);
}

// 初始化CNN参数配置
void init_all_parameters(void)
{
	FILE * fp = fopen("./para.txt", "r");
	char str[128];
	int ADDR;
	unsigned int DATA;
	printf("setting CNN parameters...\n");
	while(!feof(fp))
	{
		fgets(str, sizeof(str), fp);
		if(strlen(str)>1)
		{
			// 判别，是否第一个char是@
			if(str[0]=='@'){
				sscanf(str, "@%X", &(ADDR));
			}
			// 否则就是数据
			else{
				sscanf(str, "%X", &DATA);
				//
				// CNN模型参数的存储地址，映射进入用户空间
				if((ADDR<<2) < CNN_IN_BASE){
					void *cnn_para_addr = cnn_para_virtual_base + (((ADDR<<2) - CNN_PARA_BASE)&CNN_PARA_MASK);
					*(unsigned int *)cnn_para_addr = DATA;	// 赋值
				}
				ADDR++;
			}
		}
	}
	
	printf("cnn parameters initiateion finished...\n");
	fclose(fp);
}


// 传输神经网络的输入
int cnn_run_input(void)
{
	// 首先看看现在在写入那个区间
	mt9d111_block = (*(unsigned int *)h2f_lw_video_block_addr - 1)&0x03;
	void * video_addr = video_virtual_base + 0x00800000 * mt9d111_block;
	void * of_addr = of_virtual_base + 0x00800000 * ((mt9d111_block-1)&0x03);
	
	// 要把内存中的数据缓存一下看看
	//FILE * fp = fopen("./data_under_test.txt", "w");
	// 首先获取现在的目标窗口
	int current_bbox[6];
	int i;
	int addr;
	for(i=0; i<6; i++){
		current_bbox[i] = final_bbox[0][i];
	}
	// 如果w/h都比较大
	if(current_bbox[2]<10 || current_bbox[3]<10)
		return 0;
	else{
		// 需要将CNN输入的94x94填满
		int row, col;
		int m, n;
		unsigned int rgb565;
		unsigned int of_val;
		for(m=0; m<CNN_INPUT_HEIGHT; m++){
			for(n=0; n<CNN_INPUT_WIDTH; n++){
				row = current_bbox[1] + m*1.0/CNN_INPUT_HEIGHT*current_bbox[3];
				col = current_bbox[0] + n*1.0/CNN_INPUT_WIDTH*current_bbox[2];
				//printf("row = %d, col = %d\n", row, col);
				// 计算出此时对应的原始图像的偏移地址
				addr = 4*(row*800 + col);
				
				// 首先是RGB565转灰度图
				// 加载RGB数据
				rgb565 = *(unsigned int *)(video_addr + addr);
				//printf("%08X\n", rgb565);
				// 计算灰度值
				int r = (rgb565>>11)&0x1F;
				int g = (rgb565>>5)&0x3F;
				int b = (rgb565>>0)&0x1F;
				int gray = ((r*66 + g*129 + b*25)/256.0) + 16;
				//printf("%d,", gray);
				gray = (gray<16)? 16 : (gray>235)? 235 : gray;
				gray *= 256;
				// 存储到CNN输入
				//printf(">> %08X\n", CNN_IN_BASE + 0*CNN_MAT_WIDTH + 4*(m*CNN_INPUT_WIDTH+n));
				*(unsigned int *)(cnn_in_virtual_base + 0*CNN_MAT_WIDTH + 4*(m*CNN_INPUT_WIDTH+n)) = gray;
				
				// 然后是光流法
				of_val = *(unsigned int *)(of_addr + addr);
				// 计算ux
				int ux = 1.0*(((of_val>>15)&0x7FFF)|(((of_val>>29)&0x01)<<15));
				int ux_32 = (ux>0x8000)? (ux-0x10000) : ux;
				ux_32 *= 256;
				/*
				// 存储到CNN的输入
				if(ux_32<0){
					printf("%08X\n", *(unsigned int *)&ux_32);
				}
				*/
				*(unsigned int *)(cnn_in_virtual_base + 1*CNN_MAT_WIDTH + 4*(m*CNN_INPUT_WIDTH+n)) = *(unsigned int *)(&ux_32);
				/*
				// 如果存在存储数据不正确的情况（实际上并不存在,负数都是正确存储的）
				if(((*(unsigned int *)(cnn_in_virtual_base + 1*CNN_MAT_WIDTH + 4*(m*CNN_INPUT_WIDTH+n)))&0x80000000)==0 && ux_32<0)
					printf("error: CNN input not correct!\n");
				*/
				// 然后是vy
				int vy = 1.0*(((of_val>>0)&0x7FFF)|(((of_val>>14)&0x01)<<15));
				int vy_32 = (vy>0x8000)? (vy-0x10000) : vy;
				vy_32 *= 256;
				// 存储到CNN的输入
				*(unsigned int *)(cnn_in_virtual_base + 2*CNN_MAT_WIDTH + 4*(m*CNN_INPUT_WIDTH+n)) = *(unsigned int *)(&vy_32);
				//printf("%d,", vy_32);
				//printf("%d == %08X\n", *(int *)(cnn_in_virtual_base + 2*CNN_MAT_WIDTH + 4*(m*CNN_INPUT_WIDTH+n)), *(unsigned int *)(cnn_in_virtual_base + 2*CNN_MAT_WIDTH + 4*(m*CNN_INPUT_WIDTH+n)));
				
				// 最后就是掩膜啦
				int mask = (of_val>>30)&0x01;
				// 存储到CNN的输入
				mask *= (256*256);
				*(unsigned int *)(cnn_in_virtual_base + 3*CNN_MAT_WIDTH + 4*(m*CNN_INPUT_WIDTH+n)) = mask;
				
				// 将数据缓存起来
				//fprintf(fp, "%d,%d,%d,%d\n", gray, ux_32, vy_32, mask);
			}
		}
	}
	
	//fclose(fp);

	return 1;
}

// 运行神经网络的判别
void cnn_run_judge(void)
{
	clock_t 		start, finish; double duration; 	// 计时用
	unsigned char 	cnn_inst_ready;
	float 			cnn_judge_result[6];
	// 将神经网络参数配置好
	//init_all_parameters();
	// 首先将神经网络的输入发送到CNN
	int tmp = cnn_run_input();
	if(tmp)
	{
		// 然后发送START指令
		emit_start_inst();
		// 然后等待CNN计算完毕
		start = clock();
		// 等待指令完成
		while(1){
			usleep(5*1000);	// 100ms -- sleep
			////printf(".");
			cnn_inst_ready = ((*(unsigned int *)h2f_lw_npu_addr) & 0x00000001);
			if(cnn_inst_ready)
				break;
		}
		// 然后要把CNN的运算结果输出来
		int cnn_result_int[6];
		int i;
		// 查找最大值
		float max_val = 0;
		int max_idx = 1;
		//printf("-------- * * * ------------\n");
		usleep(5*1000);	// 100ms -- sleep
		for(i=0; i<6; i++){
			cnn_result_int[i] = *(unsigned int *)(cnn_out_virtual_base + 4*i);
			cnn_judge_result[i] = cnn_result_int[i]/65536.0;
			//printf("[%s] ==> \t %.4f [%08X]\n", action[i], cnn_judge_result[i], cnn_result_int[i]);
			//
			if(cnn_judge_result[i]>max_val){
				max_val = cnn_judge_result[i];
				max_idx = i;
			}
		}
		printf("\naction: %s\n", action[max_idx + 1]);
		// 显示出来
		add_word_display(max_idx+1);
		//printf("--- --- ---\n");
		//
		npu_time = ((*(unsigned int *)h2f_lw_npu_addr)>>1)/CNN_NPU_CLK_FREQ;
		finish = clock();
		duration = (double)(finish - start) / CLOCKS_PER_SEC; 
		printf("npu_inst finished! total time: %f sec, npu-time = %f sec [%08X]\n", duration, npu_time, *(unsigned int *)h2f_lw_npu_addr);
	}
}
/////////////////////
// 2018-04-09: 增加一个测试CNN的接口（将训练集的数据发送过来，存储到DDR中，运行CNN是否识别正确）
void test_cnn_using_training(void)
{
	clock_t 		start, finish; double duration; 	// 计时用
	unsigned char 	cnn_inst_ready;
	float 			cnn_judge_result[6];
	//
	struct dirent    *ent  ;   //定义一个结构体 dirent的指针
	// 首先打开sim_source文件夹，遍历这里的文件
	DIR* dp = opendir("./sim_source");
	char str[128];	// 存储一行的数据
	int ADDR;	// 要写入DDR的地址
	unsigned int DATA;	// 要写入DDR的数据
	///////////////
	while((ent=readdir(dp))!=NULL) //读取pDir打开的目录，并赋值给ent, 同时判断是否目录为空，不为空则执行循环体
	{
		// 去掉"."和".."两个“文件”不要参与测试
		if(strcmp(ent->d_name, ".") && strcmp(ent->d_name, "..")){
			printf("--------\n%s\n", ent->d_name);
			// 在文件名中解算出测试文件样本对应的label
			char *p = ent->d_name;
			int i = 0;
			char label[2] = {0, 0};
			while(i<strlen(p)){
				if(p[i]=='.'){
					break;
				}
				else
					i++;
			}
			label[0] = p[i-1];
			// 转换
			int label_num = atoi(label);
			//printf("label = %d\n", label_num);
			// 然后打开文件
			char filename[128];
			strcpy(filename, "./sim_source/");
			strcat(filename, ent->d_name);
			FILE * fp = fopen(filename, "r");
			//init_all_parameters();
			// 将文件中的数据全部发送到DDR中去
			while(!feof(fp))
			{
				fgets(str, sizeof(str), fp);
				if(strlen(str)>1)
				{
					//printf("%d\n", strlen(str));
					// 判别，是否第一个char是@
					if(str[0]=='@'){
						sscanf(str, "@%X", &(ADDR));
						//printf(">> %08X\n", ADDR<<2);
					}
					// 否则就是数据
					else{
						sscanf(str, "%X", &DATA);
						//printf("%08X ==> %08X\n", ADDR<<2, DATA);
						// CNN模型参数的存储地址，映射进入用户空间
						/*
						if((ADDR<<2) < CNN_IN_BASE){
							void *cnn_para_addr = cnn_para_virtual_base + (((ADDR<<2) - CNN_PARA_BASE)&CNN_PARA_MASK);
							*(unsigned int *)cnn_para_addr = DATA;	// 赋值
						}
						// CNN网络输入的存储地址
						else 
						*/if((ADDR<<2) >= CNN_IN_BASE){
							void *cnn_in_addr = cnn_in_virtual_base + (((ADDR<<2) - CNN_IN_BASE)&CNN_IN_MASK);
							*(unsigned int *)cnn_in_addr = DATA;	// 赋值
						}
						ADDR++;
					}
				}
			}
			fclose(fp);
			//printf("list file data all sent into DDR...\n");
			// 启动CNN运算
			// 然后发送START指令
			emit_start_inst();
			// 然后等待CNN计算完毕
			start = clock();
			// 等待指令完成
			while(1){
				usleep(100*1000);	// 100ms -- sleep
				////printf(".");
				cnn_inst_ready = ((*(unsigned int *)h2f_lw_npu_addr) & 0x00000001);
				if(cnn_inst_ready)
					break;
			}
			// 然后要把CNN的运算结果输出来
			int cnn_result_int[6];
			//int i;
			printf("-------- * * * ------------\n");
			for(i=0; i<6; i++){
				cnn_result_int[i] = *(unsigned int *)(cnn_out_virtual_base + 4*i);
				cnn_judge_result[i] = cnn_result_int[i]/65536.0;
				printf("[%s] ==> \t %.4f [ %08X ]\n", action[i], cnn_judge_result[i], cnn_result_int[i]);
			}
			//printf("--- --- ---\n");
			//
			npu_time = ((*(unsigned int *)h2f_lw_npu_addr)>>1)/66.7e6;
			finish = clock();
			duration = (double)(finish - start) / CLOCKS_PER_SEC; 
			printf("\nnpu_inst finished! total time: %f sec, npu-time = %f sec [%08X]\n", duration, npu_time, *(unsigned int *)h2f_lw_npu_addr);
		}
	}
}
