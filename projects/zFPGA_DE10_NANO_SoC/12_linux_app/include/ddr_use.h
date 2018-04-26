#ifndef _DDR_USE_
#define _DDR_USE_

// // 上方 512MB~544 MB属于相机拍摄的缓存 -- 8MB/frame
// | 512MB-520MB | 520MB-528MB | 528MB-536MB | 536MB-544MB |
#define	VIDEO_BASE	( 0x20000000 )
#define	VIDEO_SPAN	( 0x02000000 )
#define	VIDEO_MASK	( VIDEO_SPAN - 1 )
// 行人检测
#define PD_BASE		( 0x24000000 )
#define PD_SPAN		( 0x02000000 )
#define	PD_MASK		( PD_SPAN - 1 )


// 测试h2f/h2f_lw接口
#define H2F_BASE	( 0xc0000000 )
#define H2F_SPAN	( 0x40000000 )
#define H2F_MASK	( H2F_SPAN - 1 )
#define LW_H2F_BASE ( 0xff200000 )
#define LW_H2F_SPAN ( 0x00200000 )
#define LW_H2F_MASK ( LW_H2F_SPAN - 1 )

// 加框以后的视频
#define BBOX_BASE	( 0x26000000 )
#define BBOX_SPAN	( 0x02000000 )
#define	BBOX_MASK	( BBOX_SPAN - 1 )
// 光流法
#define OF_BASE		( 0x1E000000 )
#define OF_SPAN		( 0x02000000 )
#define	OF_MASK		( OF_SPAN - 1 )
// CNN参数
#define CNN_MAT_WIDTH	( 0x00040000 )
#define CNN_PARA_BASE	( 0x28000000 )
#define CNN_PARA_SPAN	( 0x08000000 )
#define	CNN_PARA_MASK	( CNN_PARA_SPAN - 1 )
// CNN输入
#define CNN_IN_BASE		( 0x38000000 )
#define CNN_IN_SPAN		( 0x04000000 )
#define	CNN_IN_MASK		( CNN_IN_SPAN - 1 )
// CNN输出
#define CNN_OUT_BASE	( 0x3C000000 )
#define CNN_OUT_SPAN	( 0x04000000 )
#define	CNN_OUT_MASK	( CNN_OUT_SPAN - 1 )

#endif
