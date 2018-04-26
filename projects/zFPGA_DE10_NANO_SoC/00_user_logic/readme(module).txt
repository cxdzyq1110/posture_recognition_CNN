整个系统实现了
1. FPGA计算LK光流
2. FPGA使用HOG特征+SVM分类实现行人检测
3. HPS将行人检测结果进行聚合，给出待检测窗口
4. FPGA调用指令集NPU，通过CNN实现姿势检测

DE10_NANO_SoC_GHRD.v	: 整个FPGA系统的top module
	|
	|
	+--------	jitter_killer.v : 按钮消抖（检测到下降沿后，延时在检测）
	|
	|
	+--------- 	mt9d111_config.v	: 摄像头MT9D111的配置模块，会调用I2C模块
	|				|
	|				+------	i2c_user_fsm.v : I2C接口的verilog代码（I2C主机）
	|
	|
	+---------	mt9d111_controller.v : 对摄像头MT9D111的数据报文进行解析
	|
	|
	+--------- 	adv7513_config.v	: HDMI芯片ADV7513的配置，会调用I2C模块
	|				|
	|				+------	i2c_user_fsm.v : I2C接口的verilog代码（I2C主机）
	|
	|
	+---------	adv7513_controller.v : 生成ADV7513--HDMI输出所需的信号
	|
	|
	+----------	video_process.v : 对MT9D111的数据进行缓存，同时读取DDR用于输出到HDMI
	|
	|
	+---------	hog_svm_pd_rtl.v	: 行人检测，内部调用800x600/400x300/200x150不同尺度的行人检测
	|				|
	|				+--	hog_svm_pd_800x600.v	： 800x600分辨率下的行人检测，用于检测小人
	|				|		|
	|				|		+--	RGB565_YUV422.v		RGB565和YUV422格式的转换，用于转换图像到灰度图像
	|				|		|
	|				|		+--	int_cordic_core.v ：计算向量模，计算像素梯度的大小
	|				|
	|				+--	hog_svm_pd_400x300.v	： 400x300分辨率下的行人检测，检测中等大小的人
	|				|
	|				+-	hog_svm_pd_200x150.v	： 200x150尺寸下的行人检测，检测大人
	|
	|
	+--------	OpticalFlowLK.v		: LK光流计算模型
	|					|
	|					+--	RGB565_YUV422.v		RGB565和YUV422格式的转换，用于转换图像到灰度图像
	|					|
	|					+--	int_cordic_core.v ：计算向量模，计算速度的大小
	|
	+----------	mux_ddr_access.v	:	用于将DDR控制器的单端口Avalon-MM扩展到多端口
	|									由于没有开启burst，所以传输效率上有损失
	|
	