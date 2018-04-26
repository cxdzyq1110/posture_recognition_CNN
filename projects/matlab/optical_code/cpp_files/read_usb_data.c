#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>
#include "mex.h"
#include "matrix.h"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	mexPrintf("start modelsim sampled data file reading operation...\n");
	// 输入参数就是文件名称
	char *pr = (char *)mxArrayToString(prhs[0]);
	// 视频的像素情况
	int H = *(mxGetPr(prhs[1]));
	int W = *(mxGetPr(prhs[2]));
	mexPrintf("height = %d, width = %d\n", H, W);
	// 获取文件尺寸
	struct _stat info;
    _stat(pr, &info);
	int size = info.st_size;
	mexPrintf("file size = %d\n", size);
	// 遍历查看有多少行
	char buffer[1024];
	FILE *fp = fopen(pr, "r");
	int lines = 0;
	while(!feof(fp))
	{
		fgets(buffer, sizeof(buffer), fp);
		lines++;
	}
	fclose(fp);
	mexPrintf("total lines : %d...\n", lines);
	// 然后读出所有的数据
	int frameCnt = lines / (H * W);	// 总共的帧数
	// 创建3D数组
	mwSize dims[3] = {H, W, frameCnt};
	plhs[0] = mxCreateNumericArray(3, dims, mxINT32_CLASS, mxREAL);	// optical flow
	int *optical_flow_ux = (int *)mxGetPr(plhs[0]);
	plhs[1] = mxCreateNumericArray(3, dims, mxINT32_CLASS, mxREAL);	// optical flow
	int *optical_flow_vy = (int *)mxGetPr(plhs[1]);
	// 打开文件
	fp = fopen(pr, "r");
	int frame = 0;
	int ux, vy;
	int h, w;
	int pos;
	char num[128];
	int i, j;
	while(!feof(fp) && frame<frameCnt)
	{
		// 读一行
		memset(buffer, 0x00, sizeof(buffer));
		fgets(buffer, sizeof(buffer), fp);
		//mexPrintf("%s, %d", buffer, strcmp(buffer, "--- * * * ---\n"));
		//return ;
		// 查看是不是"--- * * * ---"
		if(!strcmp(buffer, "--- * * * ---\n"))
		{
			mexPrintf("frame %d ===> \n", frame);
			// 连续读取数据
			for(h=0; h<H; ++h){
				for(w=0; w<W; ++w){
					memset(buffer, 0x00, sizeof(buffer));
					fgets(buffer, sizeof(buffer), fp);
					// 并且解析ux/vy数值
					//sscanf(buffer, "%d, %d", &ux, &vy);
					memset(num, 0x00, sizeof(num));
					j = 0;
					for(i=0; i<strlen(buffer); ++i){
						if(buffer[i]!=' ' && buffer[i]!=',')
							num[j++] = buffer[i];
						else if(buffer[i]==',')
						{
							if(num[0]!='x')
								ux = atoi(num);
							else
								ux = 0;
							memset(num, 0x00, sizeof(num)); 
							j = 0;
						}
					}
					if(num[0]!='x')
						vy = atoi(num);
					else
						vy = 0;
					
					//
					//mexPrintf("bufer : %s  ==> ux = %d, vy = %d\n", buffer, ux, vy);
					// 写入到数组中
					//pos = h*(W*frameCnt) + w*frameCnt + frame;	// 计算像素点在整个数组中的位置
					pos = frame*(W*H) + w*H + h;	// 计算像素点在整个数组中的位置
					*(optical_flow_ux+pos) = ux;//frame+h*10;
					*(optical_flow_vy+pos) = vy;//frame+h*10;
					//mexPrintf("writen into array <h%d, w%d, f%d>\n", h, w, frame);
				}
			}
			frame++;	// 增加一帧
			
		}
		
	}
	fclose(fp);
	// 返回数据
	nlhs = 2;
	///////
	return;
}