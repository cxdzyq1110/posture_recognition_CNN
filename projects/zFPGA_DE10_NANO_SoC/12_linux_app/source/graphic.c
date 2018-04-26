#include "../include/graphic.h"
//////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////
// 计算两个框的重叠面积
int InterSect(int x1, int y1, int w1, int h1, int x2, int y2, int w2, int h2)
{
    // 计算交集
    int ISxl = (x1>x2)? x1 : x2;	// 挑选较大的（右）
    int ISxr = ((x1+w1)>(x2+w2))? (x2+w2) : (x1+w1);	// 挑选较小的（左）
    int ISyu = (y1>y2)? y1 : y2;	// 挑选较大的（下）
    int ISyd = ((y1+h1)>(y2+h2))? (y2+h2) : (y1+h1);	// 挑选较小的（上）
    //
    int SI;
    if((ISxl>ISxr)||(ISyu>ISyd))
        SI = 0;
    else
        SI = (ISxr-ISxl)*(ISyd-ISyu);
    //
    return SI;
}
