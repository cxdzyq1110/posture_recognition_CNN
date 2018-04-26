#ifndef _NPU_
#define	_NPU_


// NPU inst
extern void send_npu_inst(char *op, char *para);	// OP指令名称 & 参数
extern void test_npu_inst(void);

extern float npu_time ;	// npu指令执行时间
extern uint32_t	npu_inst_buffer[4];

#endif