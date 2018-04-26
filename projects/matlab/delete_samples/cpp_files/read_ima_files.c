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
	char * pr = (char *)mxArrayToString(prhs[0]);
    // 输入的参数情况（video/optical）
    char * para = (char *)mxArrayToString(prhs[1]);
    // 打开文件
    FILE * fp = fopen(pr, "rb");
	// 视频的像素情况
	int H;
	int W;
    fread(&W, 4, 1, fp);
    fread(&H, 4, 1, fp);
	mexPrintf("%s\n", pr);
	mexPrintf("para = %s, height = %d, width = %d\n", para, H, W);
    int h = 0, w = 0, ch = 0;
    // 如果是读取原始图像
    if(!strcmp(para, "video")){
        // 创建3D数组
        mwSize dims[3] = {H, W, 3};
        plhs[0] = mxCreateNumericArray(3, dims, mxUINT8_CLASS, mxREAL);	// video
        unsigned char *video = (unsigned char *)mxGetPr(plhs[0]);
        while(!feof(fp)){
            // 读取4byte-->int
            unsigned char dat_byte[4];
            fread(&dat_byte, 1, 4, fp);
            unsigned short dat = (dat_byte[1]<<8)|dat_byte[0];
            unsigned char rgb[3];
            rgb[0] = ((dat>>0)&0x1F)<<3;
            rgb[1] = ((dat>>5)&0x3F)<<2;
            rgb[2] = ((dat>>11)&0x1F)<<3;
            for(ch=0; ch<3; ch++){
                int pos = ch*(H*W)+w*H+h;
                *(video+pos) = rgb[2-ch];
            }
            // 改变h/w
            h = (h+(w/(W-1)))%H;
            w = (w+1)%W;
        }
        // 返回数据 
        nlhs = 1;
    }
    // 否则如果是加载光流结果{
    if(!strcmp(para, "optical")){
        // 创建3D数组
        mwSize dims[2] = {H, W};
        plhs[0] = mxCreateNumericArray(2, dims, mxINT16_CLASS, mxREAL);	// optical/ux
        unsigned short *ux = (unsigned short *)mxGetPr(plhs[0]);
        plhs[1] = mxCreateNumericArray(2, dims, mxINT16_CLASS, mxREAL);	// optical/vy
        unsigned short *vy = (unsigned short *)mxGetPr(plhs[1]);
        plhs[2] = mxCreateNumericArray(2, dims, mxUINT8_CLASS, mxREAL);	// optical / mask
        unsigned char *mask = (unsigned char *)mxGetPr(plhs[2]);
        while(!feof(fp)){
            // 读取4byte-->int
            unsigned char dat_byte[4];
            fread(&dat_byte, 1, 4, fp);
            unsigned int dat = (dat_byte[3]<<24)|(dat_byte[2]<<16)|(dat_byte[1]<<8)|dat_byte[0];
            
            unsigned char m = (dat>>30)&0x01;   // mask
            dat = dat&0x3FFFFFFF;   // ux/vy
            unsigned short u = (dat>>15)|((dat>>29)<<15);
            unsigned short v = (dat&0x7FFF)|((dat&0x4000)<<1);
            
            int pos = w*H+h;
            *(ux+pos) = *(short *)&u;
            *(vy+pos) = *(short *)&v;
            *(mask+pos) = m;
            // 改变h/w
            h = (h+(w/(W-1)))%H;
            w = (w+1)%W;
        }
        // 返回数据 
        nlhs = 3;
    }
    // 关闭文件
	fclose(fp);
	///////
	return;
}