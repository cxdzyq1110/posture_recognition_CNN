#ifndef _CNN_
#define	_CNN_



#define	CNN_INPUT_HEIGHT	94
#define	CNN_INPUT_WIDTH		94

extern void *cnn_para_virtual_base;	// CNN参数的存储空间
extern void *cnn_in_virtual_base;	// CNN输入的存储空间
extern void *cnn_out_virtual_base;	// CNN输出的存储空间

#define	CNN_NPU_CLK_FREQ	15e6
// NPU

// 发射所有的NPU指令
extern void emit_all_npu_insts(void);
//
//uint8_t h2f_fpga_addr[16];
#define	print_npu_inst()	for(i=0; i<4; i++)\
								printf("%08X", npu_inst_buffer[i]);\
							printf("\n")

// 要发射START指令							
#define emit_start_inst()	npu_inst_buffer[0] = 0;\
							npu_inst_buffer[1] = 0;\
							npu_inst_buffer[2] = 0;\
							npu_inst_buffer[3] = 2;\
							memcpy(h2f_fpga_addr, npu_inst_buffer, 16)
							
// 初始化CNN参数配置
extern void init_all_parameters(void);
// 运行神经网络的判别
extern void cnn_run_judge(void);
// 传输神经网络的输入
extern int cnn_run_input(void);

// 测试CNN的指令
extern void test_cnn_using_training(void);


#endif