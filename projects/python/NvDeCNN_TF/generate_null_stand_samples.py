import matplotlib.pyplot as plt # plt 用于显示图片
import matplotlib.image as mpimg # mpimg 用于读取图片
import os
import numpy as np
import time
import struct
from PIL import Image

#####################################
def generate_fake_samples(file_dir, N, H, W, sample_name, random_flag):
	# 首先列出所有的文件夹
	dirs = os.listdir(file_dir)
	for t in range(0, N):
		#读取图像，支持 bmp、jpg、png、tiff 等常用格式
		filename = file_dir+"/"+dirs[t%len(dirs)]
		#print(filename)
		img = np.array(Image.open(filename))
		#img = mpimg.imread(filename)
		# 查看是不是要随机截取
		if random_flag==1:
			# 任意截取窗口
			sH = np.random.randint(img.shape[0]-H)
			sW = np.random.randint(img.shape[1]-W)
		else:
			# 正中央截取窗口
			sH = int(img.shape[0]/2 - H/2)
			sW = int(img.shape[1]/2 - W/2)
			
		img = img[sH:sH+H, sW:sW+W, 0:3]
		# 转化成rgb
		R = np.uint32(img[:, :, 0])
		G = np.uint32(img[:, :, 1])
		B = np.uint32(img[:, :, 2])
		# 然后变成RGB565
		data = np.uint32(((R>>3)<<11) | ((G>>2)<<5) | (B>>3))
		# 并且缓存起来
		fp = open("../../matlab/cnn_samples/"+sample_name+"/"+time_stamp+"-%d-video.ima"%(t), "wb")
		fp.write(struct.pack("<I", W))
		fp.write(struct.pack("<I", H))
		for i in range(data.shape[0]):
			for j in range(data.shape[1]):
				fp.write(struct.pack("<I", data[i, j]))
				
		fp.close()
		
		# 然后还要生成光流的信息
		ux = np.random.randn(H, W)*16
		vy = np.random.randn(H, W)*16
		vel = np.sqrt(ux*ux + vy*vy)
		# 掩膜也有
		mask = (vel > (np.mean(vel)*3))
		ux = np.uint32(ux)
		vy = np.uint32(vy)
		# 生成ima文件
		fp = open("../../matlab/cnn_samples/"+sample_name+"/"+time_stamp+"-%d-optical.ima"%(t), "wb")
		fp.write(struct.pack("<I", W))
		fp.write(struct.pack("<I", H))
		for i in range(H):
			for j in range(W):
				data_b = (1<<31)|(mask[i, j]<<30)|((ux[i, j]&0x7FFF)<<15)|((vy[i, j]&0x7FFF))
				fp.write(struct.pack("<I", data_b))
				
		fp.close()
############################################
# 测试用
if __name__ == '__main__':
	# 形成待检测窗口
	H = 128; W = 128;
	N = 500 	# 要生成的样本数量
	# 首先是null样本，我们从INRIA的neg样本中截取
	file_dir = "../../../ref_papers/inria/INRIAPerson/Test/neg"
	# 加载时间
	# 格式化成2016-03-20 11:45:39形式
	# time_stamp = (time.strftime("%Y-%m-%d-%H-%M-%S", time.localtime()) )
	time_stamp = "2018-04-12-16-33-01"
	# 然后遍历所有文件
	generate_fake_samples(file_dir, N, H, W, "null", 1)
	#%%
	'''
	# 然后是行人
	H = 96; W = 48;
	file_dir = "../../../ref_papers/inria/INRIAPerson/96X160H96/Train/pos"
	generate_fake_samples(file_dir, N, H, W, "standing", 0)
    '''