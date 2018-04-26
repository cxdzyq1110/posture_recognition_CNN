
// use wm8731 audio chip
//`define		USE_WM8731_CHIP
// 使用姿态芯片MPU6050
//`define		USE_MPU6050_CHIP
// 使用摄像头模块 OV7670
`define		USE_OV7670_CHIP
/////////////////////////////////
`define		I2C_SLV_ADDR_WIDTH	8
`define		I2C_REG_ADDR_WIDTH	8
`define		I2C_REG_DATA_WIDTH	8
`define		I2C_REG_ADDR_DATA	17	// 1-bit write/read + 8-bit addr + 8-bit data 
// 10 MHz / 10 /4 => 250 KHz
`define		I2C_SCK_FREQ_FACTR	10	
`define		I2C_CLK_BASE_COUNT	10

// 能够忍受的最大ACK未响应延时
`define		I2C_ACK_TOLR_DELAY	50

// 写入和读出
`define		I2C_WRITE_FLAG		0
`define		I2C_READ_FLAG		1

// 读写请求标志位
`define		I2C_WRITE_CMD		1'B0
`define		I2C_READ_CMD		1'B1