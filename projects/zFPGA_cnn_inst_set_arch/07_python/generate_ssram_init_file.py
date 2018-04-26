import math
import numpy as np
from scipy import signal
#%% 全自动的数据生成
M = 64; N = 128; 
AddImm = 1000;
MAT_M = 5; MAT_N = 3; MAT_P = 7;
fpda = open("./source_ssram_da.list", "w")
fpdb = open("./source_ssram_db.list", "w")
fpdc = open("./source_ssram_dc.list", "w")
fpdd = open("./source_ssram_dd.list", "w")

#%% 首先是原始的图像数据
Dollar1 = np.random.randint(5,20, size=(M,N))*2**16
fpda.write("@01000000\n")
fpdb.write("@01000000\n")
fpdc.write("@01000000\n")
fpdd.write("@01000000\n")
for i in range(0, M):
	for j in range(0, N):
		tmp_v = int(Dollar1[i, j])
		if tmp_v<0:
			tmp_v = tmp_v + 0xFFFFFFFF
		fpda.write("%03X\n"%((tmp_v >> 24)&0x1FF))
		fpdb.write("%03X\n"%((tmp_v >> 16)&0x1FF))
		fpdc.write("%03X\n"%((tmp_v >> 8)&0x1FF))
		fpdd.write("%03X\n"%((tmp_v >> 0)&0x1FF))
		
#%% 另一张图像的数据		
Dollar22 = np.random.randint(-15,-10, size=(M,N))*2**16
fpda.write("@02000000\n")
fpdb.write("@02000000\n")
fpdc.write("@02000000\n")
fpdd.write("@02000000\n")
for i in range(0, M):
	for j in range(0, N):
		tmp_v = int(Dollar22[i, j])
		if tmp_v<0:
			tmp_v = tmp_v + 0xFFFFFFFF
		fpda.write("%03X\n"%((tmp_v >> 24)&0x1FF))
		fpdb.write("%03X\n"%((tmp_v >> 16)&0x1FF))
		fpdc.write("%03X\n"%((tmp_v >> 8)&0x1FF))
		fpdd.write("%03X\n"%((tmp_v >> 0)&0x1FF))

#%% 然后是图像的加减乘
fp_add = open("./fp_add_test.txt", "w")
fp_addi = open("./fp_addi_test.txt", "w")
fp_sub = open("./fp_sub_test.txt", "w")
fp_dot = open("./fp_dot_test.txt", "w")
# 输出到文本
for i in range(0, len(Dollar1)):
	for j in range(0, len(Dollar1[0])):
		add_value = int((Dollar1[i, j]+Dollar22[i, j]))
		addi_value = int((Dollar1[i, j]+AddImm))
		sub_value = int((Dollar1[i, j]-Dollar22[i, j]))
		dot_value = int((Dollar1[i, j]/2**16*Dollar22[i, j]))
		fp_add.write("%d\n"%(add_value))
		fp_sub.write("%d\n"%(sub_value))
		fp_dot.write("%d\n"%(dot_value))
		fp_addi.write("%d\n"%(addi_value))
		
fp_add.close()
fp_addi.close()
fp_sub.close()
fp_dot.close()

#%% 矩阵转置变换
fp_tran = open("./fp_tran_test.txt", "w")
# 输出到文本
for j in range(0, len(Dollar1[0])):
	for i in range(0, len(Dollar1)):
		tran_value = int((Dollar1[i, j]))
		fp_tran.write("%d\n"%(tran_value))

fp_tran.close()

#%% 卷机运算卷积核
kernel = np.random.randint(-15,-10, size=(3,3))*2**16
fpda.write("@03000000\n")
fpdb.write("@03000000\n")
fpdc.write("@03000000\n")
fpdd.write("@03000000\n")
for i in range(0, len(kernel)):
	for j in range(0, len(kernel[0])):
		tmp_v = int(kernel[i, j])
		if tmp_v<0:
			tmp_v = tmp_v + 0xFFFFFFFF
		fpda.write("%03X\n"%((tmp_v >> 24)&0x1FF))
		fpdb.write("%03X\n"%((tmp_v >> 16)&0x1FF))
		fpdc.write("%03X\n"%((tmp_v >> 8)&0x1FF))
		fpdd.write("%03X\n"%((tmp_v >> 0)&0x1FF))
		
		
d1 = Dollar1
d2 = kernel

d1x = d1/2**16;
d2x = d2/2**16;

dcx = signal.convolve2d(d1x, d2x[0:3, 0:3], 'valid')

# 输出到文本
fp_conv = open("./fp_conv_test.txt", "w")
for i in range(0, len(dcx)):
	for j in range(0, len(dcx[0])):
		conv_value = int(2**16*dcx[i, j])
		fp_conv.write("%d\n"%(conv_value))

fp_conv.close()

#%% 然后是计算pooling
fp_pool = open("./fp_pool_test.txt", "w")
MODE = 1
dpx = np.zeros((M>>1, N>>1))
for i in range(0, M>>1):
	for j in range(0, N>>1):
		if MODE==0:
			dpx[i, j] = np.mean(d1x[2*i:2*i+2, 2*j:2*j+2])
		elif MODE==1:
			dpx[i, j] = np.max(d1x[2*i:2*i+2, 2*j:2*j+2])
			
		pool_value = int(2**16*dpx[i, j])
		fp_pool.write("%d\n"%(pool_value))

fp_pool.close()

#%% 然后是要验证MULT矩阵乘法指令
mat1 = np.random.randint(10,20, size=(MAT_M,MAT_N))
mat2 = np.random.randint(-20,-10, size=(MAT_N,MAT_P))
mat1_216 = 2**16*mat1
mat2_216 = 2**16*mat2
mat3 = np.dot(mat1, mat2)

fpda.write("@04000000\n")
fpdb.write("@04000000\n")
fpdc.write("@04000000\n")
fpdd.write("@04000000\n")
# 矩阵乘法的源数据
for i in range(0, len(mat1)):
	for j in range(0, len(mat1[0])):
		mult_value = int(2**16*mat1[i, j])
		fpda.write("%03X\n"%((mult_value >> 24)&0x1FF))
		fpdb.write("%03X\n"%((mult_value >> 16)&0x1FF))
		fpdc.write("%03X\n"%((mult_value >> 8)&0x1FF))
		fpdd.write("%03X\n"%((mult_value >> 0)&0x1FF))
		
fpda.write("@05000000\n")
fpdb.write("@05000000\n")
fpdc.write("@05000000\n")
fpdd.write("@05000000\n")
for i in range(0, len(mat2)):
	for j in range(0, len(mat2[0])):
		mult_value = int(2**16*mat2[i, j])
		fpda.write("%03X\n"%((mult_value >> 24)&0x1FF))
		fpdb.write("%03X\n"%((mult_value >> 16)&0x1FF))
		fpdc.write("%03X\n"%((mult_value >> 8)&0x1FF))
		fpdd.write("%03X\n"%((mult_value >> 0)&0x1FF))
		
		
# 输出到文本
fp_mult = open("./fp_mult_test.txt", "w")
for i in range(0, len(mat3)):
	for j in range(0, len(mat3[0])):
		mult_value = int(2**16*mat3[i, j])
		fp_mult.write("%d\n"%(mult_value))

fp_mult.close()
#%% 
######################
fp_tanh = open("./fp_tanh_test.txt", "w")
Dollar2 = -0x20000;
Dollar2_ini = -0x20000;
fpda.write("@06000000\n")
fpdb.write("@06000000\n")
fpdc.write("@06000000\n")
fpdd.write("@06000000\n")
for i in range(0, M):
	for j in range(0, N):
		fpda.write("%03X\n"%((Dollar2 >> 24)&0x1FF))
		fpdb.write("%03X\n"%((Dollar2 >> 16)&0x1FF))
		fpdc.write("%03X\n"%((Dollar2 >> 8)&0x1FF))
		fpdd.write("%03X\n"%((Dollar2 >> 0)&0x1FF))
		
		Dollar2 = Dollar2 + 32
		
		tanh_value = int(2**16*math.tanh(Dollar2/(2**16)))
			
		fp_tanh.write("%d\n"%(tanh_value))
		
fp_tanh.close()

#%% 矩阵±标量的运算
fp_adds = open("./fp_adds_test.txt", "w")
# 输出到文本
for i in range(0, len(Dollar1)):
	for j in range(0, len(Dollar1[0])):
		adds_value = int((Dollar1[i, j] + Dollar2_ini))
		fp_adds.write("%d\n"%(adds_value))

fp_adds.close()

#%% RGB565转灰度图函数变换
fp_gray = open("./fp_gray_test.txt", "w")
fpda.write("@07000000\n")
fpdb.write("@07000000\n")
fpdc.write("@07000000\n")
fpdd.write("@07000000\n")
red = np.random.randint(0,2**5, size=(M,N))
green = np.random.randint(0,2**6, size=(M,N))
blue = np.random.randint(0,2**5, size=(M,N))
rgb565 = red*2**11 + green*2**5 + blue
# 输出到文本
for i in range(0, len(rgb565)):
	for j in range(0, len(rgb565[0])):
		r = ((rgb565[i][j]>>11) & 0x1F) *8
		g = ((rgb565[i][j]>>5) & 0x3F) *4
		b = ((rgb565[i][j]>>0) & 0x1F) *8
		gray_value = int((r*66 + g*129 + b*25)/256) + 16
		if gray_value<16:
			gray_value = 16
		elif gray_value>235:
			gray_value = 235
		
		# 吸入文件中
		fpda.write("%03X\n"%((rgb565[i][j] >> 24)&0x1FF))
		fpdb.write("%03X\n"%((rgb565[i][j] >> 16)&0x1FF))
		fpdc.write("%03X\n"%((rgb565[i][j] >> 8)&0x1FF))
		fpdd.write("%03X\n"%((rgb565[i][j] >> 0)&0x1FF))
		fp_gray.write("%d\n"%(gray_value))

fp_gray.close()

#%% 关闭所有文件

fpda.close()
fpdb.close()
fpdc.close()
fpdd.close()