#ifndef _HPS_FPGA_INF_
#define	_HPS_FPGA_INF_


// 一些全局变量

extern void *h2f_lw_led_addr;		// led, ，通过h2f.lw接口写进去
extern void *h2f_lw_sysid_addr;	// system id，通过h2f.lw接口写进去
extern void *h2f_lw_ram_addr;		// ocram，通过h2f.lw接口写进去
extern void *h2f_lw_video_block_addr;		// mt9d111正在写入的区块，读取看看
extern void *h2f_lw_bbox_frame_addr;	// 加框以后的视频结果存储空间标记
extern void *h2f_lw_bbox_mask_addr;	// 用来存储加框的掩膜
extern void *h2f_lw_fpga_addr;		// fpga
extern void *h2f_lw_npu_addr;		// npu ready & time-count
extern void *h2f_ram_addr;
extern void *h2f_fpga_addr;

//

extern void *lw_h2f_virtual_base;	// lw.h2f接口的虚拟地址
extern void *h2f_virtual_base;		// h2f接口的虚拟地址
extern void *video_virtual_base;	// f2s接口（原始视频）映射的虚拟地址
extern void *pd_virtual_base;		// 行人检测空间映射后的虚拟地址
extern void *of_virtual_base;		// 光流计算结果存储空间映射后的虚拟地址
extern void *bbox_virtual_base;	// 加框以后的视频结果存储空间
extern void *bbox_memory_base;	// 加框以后的视频结果存储空间
extern void *cnn_para_virtual_base;	// CNN参数的存储空间
extern void *cnn_in_virtual_base;	// CNN输入的存储空间
extern void *cnn_out_virtual_base;	// CNN输出的存储空间


extern unsigned char mt9d111_block ;	// 查看现在摄像头的数据正在写入到DDR的哪一块内存区间 
extern unsigned char pd_bbox_frame;	// HPS正在写入的行人加框视频文件的内存块技术标记
//
extern void *pd_result_addr;
// 
extern int fd;

// 初始化所有的接口
extern int init_all_interfaces(void);
extern int close_all_interfaces(void);

#endif
