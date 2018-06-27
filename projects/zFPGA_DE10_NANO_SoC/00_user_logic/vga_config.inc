`define		VGA_H_BIAS			32'D80	// 横向的像素点偏移
`define		VGA_V_BIAS			32'D100	// 纵向的像素点偏移
`define		VGA_H_WIDTH			32'D480	// 横向的像素点宽度
`define		VGA_V_WIDTH			32'D340	// 纵向的像素点宽度
`define		VGA_H_LENG			32'D200	// 有效的水平长度
`define		VGA_V_LENG			32'D150	// 有效的垂直长度
`define		VGA_H_BORD			32'D20	// 横向的边框粗细
`define		VGA_V_BORD			32'D10	// 横向的边框粗细

`define		CAM_H_WIDTH			32'D800
`define		CAM_V_WIDTH			32'D600

/*
`define		MON_H_WIDTH			32'D800
`define		MON_V_WIDTH			32'D600
`define		MON_H_BIAS			32'D0
`define		MON_V_BIAS			32'D0
*/

`define		WORD_H_WIDTH		32'D180
`define		WORD_V_WIDTH		32'D50
`define		WORD_H_BIAS			(`VGA_H_BIAS + (`VGA_H_WIDTH>>1) + `VGA_H_BORD + 32'D10)
`define		WORD_V_BIAS			(`VGA_V_BIAS + (`VGA_V_WIDTH>>1) + `VGA_V_BORD + 32'D50)

`define		TITLE_H_WIDTH		32'D600
`define		TITLE_V_WIDTH		32'D35
`define		TITLE_H_BIAS		32'D20
`define		TITLE_V_BIAS		32'D10

/*
`define		ITU_H_WIDTH			32'D1728
`define		ITU_V_WIDTH			32'D625
*/

`define		RAM_READ_LATENCY	32'D3