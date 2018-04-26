import matplotlib.pyplot as plt # plt 用于显示图片
import matplotlib.image as mpimg # mpimg 用于读取图片
import os
import numpy as np
import time
import struct
from PIL import Image
# 首先是各个姿势的word
# 生成mif文件
fp = open("../04_scripts/word_diplay.mif", "w")
fp.write("DEPTH=%d;\n"%(16384*8))
fp.write("WIDTH=%d;\n"%(1))
fp.write("ADDRESS_RADIX=DEC;\n")
fp.write("DATA_RADIX=DEC;\n")
fp.write("CONTENT\n")
fp.write("BEGIN\n")

#读取图像，支持 bmp、jpg、png、tiff 等常用格式
# 首先列出所有的文件夹
dirs = os.listdir("../15_word_jpg/")
dirs.remove("title.jpg")
for i in range(len(dirs)):
	filename = "../15_word_jpg/"+dirs[i]
	image = np.array(Image.open(filename))
	image_gray = ((image[:, :, 0]*0.257+image[:, :, 1]*0.504+image[:, :, 2]*0.098))+16
	image_gray = image_gray.astype(np.uint8)
	image_gray[image_gray<16] = 16
	image_gray[image_gray>235] = 235
	# 归一化
	image_gray = (image_gray<128)
	# 写入mif文件
	for m in range(image_gray.shape[0]):
		for n in range(image_gray.shape[1]):
			addr = m*image_gray.shape[1]+n + 16384*i
			fp.write("%d: %X;\n"%(addr, image_gray[m, n]))
	# 剩下的
	for k in range(addr+1, 16384*i+16384):
		fp.write("%d: %X;\n"%(k, 0))
			
# 结束
fp.write("END;\n")
fp.close()

# 然后是标题
fp = open("../04_scripts/title.mif", "w")
fp.write("DEPTH=%d;\n"%(16384*4))
fp.write("WIDTH=%d;\n"%(1))
fp.write("ADDRESS_RADIX=DEC;\n")
fp.write("DATA_RADIX=DEC;\n")
fp.write("CONTENT\n")
fp.write("BEGIN\n")

#读取图像，支持 bmp、jpg、png、tiff 等常用格式
# 首先列出所有的文件夹
dirs = os.listdir("../15_word_jpg/")
for i in range(len(dirs)):
	if dirs[i]=="title.jpg":
		filename = "../15_word_jpg/"+dirs[i]
		image = np.array(Image.open(filename))
		image_gray = ((image[:, :, 0]*0.257+image[:, :, 1]*0.504+image[:, :, 2]*0.098))+16
		image_gray = image_gray.astype(np.uint8)
		image_gray[image_gray<16] = 16
		image_gray[image_gray>235] = 235
		# 归一化
		image_gray = (image_gray<200)
		# 写入mif文件
		for m in range(image_gray.shape[0]):
			for n in range(image_gray.shape[1]):
				addr = m*image_gray.shape[1]+n
				fp.write("%d: %X;\n"%(addr, image_gray[m, n]))
		# 剩下的
		for k in range(addr+1, 16384*3+16384):
			fp.write("%d: %X;\n"%(k, 0))
			
# 结束
fp.write("END;\n")
fp.close()
