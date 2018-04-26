# 需要有一个可以将采集到的数据发送到DDR中数据初始化文件，可以和python里面的结果进行比对
import generate_cnn_layers as gen_cnn
from load_our_samples import *
import numpy as np
import matplotlib.pyplot as plt
import test_npu_inst
import subprocess
#%% 加载采集到的【实时待检测数据】
x = np.loadtxt("./real-time-data/data_under_test.txt", delimiter=",")
H = 94; W = 94;

SORC_BIAS = 0x38000000>>2	# 输入的数据
DIST_BIAS = 0x3C000000>>2	# 输出数据
PARA_BIAS = 0x28000000>>2	# 参数的偏移量
DATA_BIAS = 0x30000000>>2	# 中间运算数据缓存的偏移量
MAT_WIDTH = 0x00040000>>2	# 要保存一个256x256的矩阵，0.5 MB的空间足够了
#%% 然后是把数据全部发送过去
filename = "./real-time-data/data_under_test.list"
fp = open(filename, "w")
for t in range(x.shape[1]):
	img = np.reshape(x[:, t], (H, W))
	img = (img+int(2**32))%int(2**32)
	fp.write("@%08X\n"%(MAT_WIDTH*t+SORC_BIAS))
	for i in range(H):
		for j in range(W):
			fp.write("%08X\n"%(int(img[i, j])))
			
fp.close()

#%% 然后要将CRLF转化
subprocess.call(".\c_api\change_crlf.exe %s"%(filename))

#%% 然后是modelsim仿真文件
# 生成待检测样本
image = np.zeros((H, W, 4), dtype=np.float)
for i in range(0, 4):
    image[:, :, i] = np.reshape(x[:, i], (H, W))
image = image / 65536.0
#%% 用H表征网络结构，P来表征参数，用D来表征数据
model = gen_cnn.generate_cnn()
conv_out = test_npu_inst.generate_test_file(image, model, "./ver_compare/data_under_test.tb.list")
para_dict, inst_set = test_npu_inst.generate_npu_inst(model)
# 创建一个内存初始化文件
fp = open("./sim_source/data_under_test.tb.list", "w")
fp_a = open("./sim_source/data_under_test_da.tb.list", "w")
fp_b = open("./sim_source/data_under_test_db.tb.list", "w")
fp_c = open("./sim_source/data_under_test_dc.tb.list", "w")
fp_d = open("./sim_source/data_under_test_dd.tb.list", "w")
# 首先将参数存储起来
for para in para_dict:
	# 参数所在的地址
	fp.write("@%08X\n"%(para_dict[para]))
	fp_a.write("@%08X\n"%(para_dict[para]))
	fp_b.write("@%08X\n"%(para_dict[para]))
	fp_c.write("@%08X\n"%(para_dict[para]))
	fp_d.write("@%08X\n"%(para_dict[para]))
	# 加载参数列表
	para_val = np.loadtxt("./para/"+para+".csv", delimiter=",")
	# print(para_val.shape, len(para_val.shape))
	# 如果参数是矩阵
	if len(para_val.shape)==2:
		for m in range(0, para_val.shape[0]):
			for n in range(0, para_val.shape[1]):
				DAT = int(para_val[m][n]*65536)
				fp.write("%08X\n"%(DAT&0xFFFFFFFF))
				fp_a.write("%03X\n"%((DAT>>24)&0x1FF))
				fp_b.write("%03X\n"%((DAT>>16)&0x1FF))
				fp_c.write("%03X\n"%((DAT>>8)&0x1FF))
				fp_d.write("%03X\n"%((DAT>>0)&0x1FF))
	# 如果参数是向量
	elif len(para_val.shape)==1:
		for m in range(0, para_val.shape[0]):
			DAT = int(para_val[m]*65536)
			fp.write("%08X\n"%(DAT&0xFFFFFFFF))
			fp_a.write("%03X\n"%((DAT>>24)&0x1FF))
			fp_b.write("%03X\n"%((DAT>>16)&0x1FF))
			fp_c.write("%03X\n"%((DAT>>8)&0x1FF))
			fp_d.write("%03X\n"%((DAT>>0)&0x1FF))
	# 如果参数是标量
	elif len(para_val.shape)==0:
		DAT = int(para_val*65536)
		fp.write("%08X\n"%(DAT&0xFFFFFFFF))
		fp_a.write("%03X\n"%((DAT>>24)&0x1FF))
		fp_b.write("%03X\n"%((DAT>>16)&0x1FF))
		fp_c.write("%03X\n"%((DAT>>8)&0x1FF))
		fp_d.write("%03X\n"%((DAT>>0)&0x1FF))
# 首先是原始的灰度图
fp.write("@%08X\n"%(SORC_BIAS+0*MAT_WIDTH))
fp_a.write("@%08X\n"%(SORC_BIAS+0*MAT_WIDTH))
fp_b.write("@%08X\n"%(SORC_BIAS+0*MAT_WIDTH))
fp_c.write("@%08X\n"%(SORC_BIAS+0*MAT_WIDTH))
fp_d.write("@%08X\n"%(SORC_BIAS+0*MAT_WIDTH))
for m in range(0, H):
	for n in range(0, W):
		DAT = int(image[m][n][0]*2**16)
		fp.write("%08X\n"%((DAT)&0xFFFFFFFF))
		fp_a.write("%03X\n"%((DAT>>24)&0x1FF))
		fp_b.write("%03X\n"%((DAT>>16)&0x1FF))
		fp_c.write("%03X\n"%((DAT>>8)&0x1FF))
		fp_d.write("%03X\n"%((DAT>>0)&0x1FF))
# 首先是原始的ux图
fp.write("@%08X\n"%(SORC_BIAS+1*MAT_WIDTH))
fp_a.write("@%08X\n"%(SORC_BIAS+1*MAT_WIDTH))
fp_b.write("@%08X\n"%(SORC_BIAS+1*MAT_WIDTH))
fp_c.write("@%08X\n"%(SORC_BIAS+1*MAT_WIDTH))
fp_d.write("@%08X\n"%(SORC_BIAS+1*MAT_WIDTH))
for m in range(0, H):
	for n in range(0, W):
		DAT = int(image[m][n][1]*2**16)
		fp.write("%08X\n"%((DAT)&0xFFFFFFFF))
		fp_a.write("%03X\n"%((DAT>>24)&0x1FF))
		fp_b.write("%03X\n"%((DAT>>16)&0x1FF))
		fp_c.write("%03X\n"%((DAT>>8)&0x1FF))
		fp_d.write("%03X\n"%((DAT>>0)&0x1FF))
# 首先是原始的vy图
fp.write("@%08X\n"%(SORC_BIAS+2*MAT_WIDTH))
fp_a.write("@%08X\n"%(SORC_BIAS+2*MAT_WIDTH))
fp_b.write("@%08X\n"%(SORC_BIAS+2*MAT_WIDTH))
fp_c.write("@%08X\n"%(SORC_BIAS+2*MAT_WIDTH))
fp_d.write("@%08X\n"%(SORC_BIAS+2*MAT_WIDTH))
for m in range(0, H):
	for n in range(0, W):
		DAT = int(image[m][n][2]*2**16)
		fp.write("%08X\n"%((DAT)&0xFFFFFFFF))
		fp_a.write("%03X\n"%((DAT>>24)&0x1FF))
		fp_b.write("%03X\n"%((DAT>>16)&0x1FF))
		fp_c.write("%03X\n"%((DAT>>8)&0x1FF))
		fp_d.write("%03X\n"%((DAT>>0)&0x1FF))
# 首先是原始的mask图
fp.write("@%08X\n"%(SORC_BIAS+3*MAT_WIDTH))
fp_a.write("@%08X\n"%(SORC_BIAS+3*MAT_WIDTH))
fp_b.write("@%08X\n"%(SORC_BIAS+3*MAT_WIDTH))
fp_c.write("@%08X\n"%(SORC_BIAS+3*MAT_WIDTH))
fp_d.write("@%08X\n"%(SORC_BIAS+3*MAT_WIDTH))
for m in range(0, H):
	for n in range(0, W):
		DAT = int(image[m][n][3]*2**16)
		fp.write("%08X\n"%((DAT)&0xFFFFFFFF))
		fp_a.write("%03X\n"%((DAT>>24)&0x1FF))
		fp_b.write("%03X\n"%((DAT>>16)&0x1FF))
		fp_c.write("%03X\n"%((DAT>>8)&0x1FF))
		fp_d.write("%03X\n"%((DAT>>0)&0x1FF))
# 然后关闭
fp.close()
fp_a.close()
fp_b.close()
fp_c.close()
fp_d.close()

# 然后将CRLF替换成LF
filename_crlf = ".\sim_source\data_under_test.tb.list"
subprocess.call(".\c_api\change_crlf.exe %s"%(filename_crlf))