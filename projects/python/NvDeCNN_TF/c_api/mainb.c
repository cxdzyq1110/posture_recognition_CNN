#include <stdio.h>
#include <string.h>
#include <time.h>
typedef	unsigned int uint32_t;
typedef	unsigned char uint8_t;

// 动作的名称
char * action[] = {"bending", "null", "waving", "squat", "standing", "walking"};
// 发射所有的NPU指令
void emit_all_npu_insts(void);
//
uint8_t h2f_fpga_addr[16];
#define	print_npu_inst()	for(i=0; i<16; i++)\
								printf("%02X", h2f_fpga_addr[i]);\
							printf("\n")

// 要发射START指令							
#define emit_start_inst()	npu_inst_buffer[0] = 0;\
							npu_inst_buffer[1] = 0;\
							npu_inst_buffer[2] = 0;\
							npu_inst_buffer[3] = 2;\
							memcpy(h2f_fpga_addr, npu_inst_buffer, 16)
							
// 初始化参数配置
void init_all_parameters(void);
//
void emit_all_npu_insts(void)
{
	clock_t 	start, finish; double duration; 	// 计时用
	uint32_t	npu_inst_buffer[4];
	char		stream[256];
	char		dat[9];
	FILE * fp = fopen("./inst.txt", "r");
	//
	int i, j, k;
	// 首先是发送RESET信号
	npu_inst_buffer[0] = 0;
	npu_inst_buffer[1] = 0;
	npu_inst_buffer[2] = 0;
	npu_inst_buffer[3] = 1;
	memcpy(h2f_fpga_addr, npu_inst_buffer, 16);
	print_npu_inst();
	////printf("npu.inst stage ");
	//usleep(10000);	// 10ms
	///////////////
	// 然后每读取一个指令就发送一次数据
	while(!feof(fp)){
		fgets(stream, sizeof(stream), fp);
		if(strlen(stream)>0){
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
		}
	}
	// 然后给出IDLE信号
	npu_inst_buffer[0] = 0;
	npu_inst_buffer[1] = 0;
	npu_inst_buffer[2] = 0;
	npu_inst_buffer[3] = 0;
	memcpy(h2f_fpga_addr, npu_inst_buffer, 16);
	print_npu_inst();
	/*
	// 最后给出START信号
	npu_inst_buffer[0] = 0;
	npu_inst_buffer[1] = 0;
	npu_inst_buffer[2] = 0;
	npu_inst_buffer[3] = 2;
	memcpy(h2f_fpga_addr, npu_inst_buffer, 16);
	print_npu_inst();
	//
	emit_start_inst();
	print_npu_inst();
	*/

	//
	fclose(fp);
}

// 初始化参数配置
void init_all_parameters(void)
{
	FILE * fp = fopen("./para.txt", "r");
	char str[128];
	int ADDR;
	unsigned int DATA;
	while(!feof(fp))
	{
		fgets(str, sizeof(str), fp);
		if(strlen(str)>0)
		{
			// 判别，是否第一个char是@
			if(str[0]=='@'){
				sscanf(str, "@%X", &(ADDR));
			}
			// 否则就是数据
			else{
				sscanf(str, "%X", &DATA);
				//printf("%08X ==> %08X\n", ADDR<<2, DATA);
				ADDR++;
			}
		}
	}
	
	fclose(fp);
}

/*
*/
int main(void){
	emit_all_npu_insts();
	init_all_parameters();
	// 开辟一块内存
	void * space = malloc(100);
	// 将-1存储进去
	*(unsigned int *)space = -5;
	printf("%08X\n", *(unsigned int *)space);
	//
	free(space);
	
	int i;
	for(i=0; i<6; i++){
		printf("%s\n", action[i]);
	}
	return 0;
}
