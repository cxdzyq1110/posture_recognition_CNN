# -*- coding: utf-8 -*-
"""
Created on Tue Apr  3 09:10:05 2018

@author: xdche
"""

import numpy as np
import matplotlib.pyplot as plt
import time
import struct
from glob import glob
import sys
import os
import random

# 增加随机剪裁的可能
def load_one_pr_sample(path, size=[94, 94], cut='False'):
    # 加载一个样本，包括video&optical两种
    video_file = path+"video.ima"
    optical_file = path+"optical.ima"
    
    with open(video_file, "rb") as fp:
        a, b, c, d = struct.unpack('>BBBB',  fp.read(4))
        w = a + b*256 + c*4096 + d*65536
        a, b, c, d = struct.unpack('>BBBB',  fp.read(4))
        h = a + b*256 + c*4096 + d*65536
        #print(w, h)
        # 如果没有数据
        if w==0 or h==0:
            return 0, 0, []
        #
        data = np.fromfile(fp, dtype=np.uint32)
        #print(data)
        image_rgb565 = data.reshape((h, w))
        # 计算RGB888的图像
        image = np.zeros((h, w, 3), dtype=np.uint8)
        image[:, :, 0] = ((image_rgb565&0xFFFF)>>11)<<3
        image[:, :, 1] = ((image_rgb565&0x07E0)>>5)<<2
        image[:, :, 2] = ((image_rgb565&0x001F)>>0)<<3
        #plt.imshow(image)
        # 计算灰度图
        image_gray = ((image[:, :, 0]*0.257+image[:, :, 1]*0.504+image[:, :, 2]*0.098))+16
        image_gray = image_gray.astype(np.uint8)
        image_gray[image_gray<16] = 16
        image_gray[image_gray>235] = 235
        #print(image_gray)
        #plt.imshow(image_gray, cmap='gray')
    
    with open(optical_file, "rb") as fp:
        a, b, c, d = struct.unpack('>BBBB',  fp.read(4))
        w = a + b*256 + c*4096 + d*65536
        a, b, c, d = struct.unpack('>BBBB',  fp.read(4))
        h = a + b*256 + c*4096 + d*65536
        
        # 如果没有数据
        if w==0 or h==0:
            return 0, 0, []
        #
        data = np.fromfile(fp, dtype=np.uint32)
        # 变换尺寸
        optical = data.reshape((h, w))
        # 光流的mask
        mask = (optical>>30)&0x01
        optical = optical&0x3FFFFFFF   #ux/vy
        #
        u = 1.0*((optical>>15)|((optical>>29)<<15))
        v = 1.0*((optical&0x7FFF)|((optical&0x4000)<<1))
        #print(u, v)
        # 
        u[u>=0x8000] = u[u>=0x8000]-0x10000
        v[v>=0x8000] = v[v>=0x8000]-0x10000
        
    result = np.zeros((h, w, 4), dtype=np.float)
    result[:, :, 0] = image_gray*1.0
    result[:, :, 1] = u*1.0
    result[:, :, 2] = v*1.0
    result[:, :, 3] = mask*1.0
    
    # 如果需要进行随机剪裁，就在这里进行：采样起始点标注
    if cut=='True':
        dH = np.random.randint(int(h/6))
        dW = np.random.randint(int(w/6))
    else:
        dH = 0
        dW = 0
        
    # 抽样
    result_s = np.zeros((size[0], size[1], 4), dtype=np.float)
    row_number = (np.linspace(dH, h-dH, size[0], endpoint = False)).astype(np.uint32)
    col_number = (np.linspace(dW, w-dW, size[1], endpoint = False)).astype(np.uint32)
    for row in range(size[0]):
        result_s[row, :, 0] = result[row_number[row], col_number, 0]
        result_s[row, :, 1] = result[row_number[row], col_number, 1]
        result_s[row, :, 2] = result[row_number[row], col_number, 2]
        result_s[row, :, 3] = result[row_number[row], col_number, 3]
    
    
    return w, h, result_s

# 加载所有的样本
# 增加翻转/随机剪裁等【数据增强】手段
def load_all_pr_samples(path, size=[94, 94], rand='True', flip='False', cut='False'):
    sample_image = list()
    sample_label = list()
    # 首先列出所有的文件夹
    dirs = os.listdir(path)
    print(dirs)
    # 构造样本名称的list
    sample_name = list()
    for i in range(0, len(dirs)):
        sample_name.append(dirs[i])
    print(sample_name)
    # 然后遍历所有的文件夹（样本序号）
    for i in range(0, len(dirs)):
        print("going into %s"%(dirs[i]))
        path_sample = path+"/"+dirs[i]
        files = os.listdir(path_sample)
        #print(files)
        # 遍历所有的文件
        for filename in files:
            # 先将filename截断
            filename_cut = filename.split('.')
            type_cut = filename_cut[0].split('-')
            if "video" in type_cut:
                #print(filename)
                time_stamp = filename_cut[0].split("video")
                file_name = path_sample+"/"+time_stamp[0]
                # 首先是正常的原始数据加载
                w, h, A = load_one_pr_sample(file_name, size=size)
                if w>0 and h>0:
                    sample_image.append(A)
                    sample_label.append(i)
                # 然后是根据需要，是不是要进行对称翻转
                if flip=='True':
                    if w>0 and h>0:
                        B = A
                        B[:,:,0] = np.fliplr(B[:, :, 0])
                        B[:,:,1] = -np.fliplr(B[:,:,1])
                        B[:,:,2] = B[:,:,2]
                        B[:,:,3] = np.fliplr(B[:,:,3])
                        sample_image.append(B)
                        sample_label.append(i)
                # 然后是随机剪裁，这个需要进入到原始图像中去
                if cut=='True':
                    w, h, A = load_one_pr_sample(file_name, size=size, cut='True')
                    if w>0 and h>0:
                        sample_image.append(A)
                        sample_label.append(i)
                    # 然后是根据需要，是不是要进行对称翻转
                    if flip=='True':
                        if w>0 and h>0:
                            B = A
                            B[:,:,0] = np.fliplr(B[:, :, 0])
                            B[:,:,1] = -np.fliplr(B[:,:,1])
                            B[:,:,2] = B[:,:,2]
                            B[:,:,3] = np.fliplr(B[:,:,3])
                            sample_image.append(B)
                            sample_label.append(i)
    #随即打乱
    order = np.arange(len(sample_image)).tolist()
    if rand=='True':
        random.shuffle(order)
    
    sample_image = [sample_image[order[i]] for i in range(0, len(order))]
    sample_label = [sample_label[order[i]] for i in range(0, len(order))]
        
    return np.array(sample_image), np.array(sample_label), sample_name

# 测试用
if __name__ == '__main__':
    file_path = "../../matlab/cnn_samples/walking/2018-04-14-13-24-30-31-"
    #file_path = "../../matlab/cnn_samples/single_waving/2018-04-04-06-29-24-13-"
    print("--------- * * * -----------")
    w, h, A = load_one_pr_sample(file_path, size=[94, 94])
    fig = plt.figure(figsize=(12,6))
    plt.subplot(141)
    plt.title("original video frame")
    plt.imshow(A[:,:,0], cmap='gray')
    plt.subplot(142)
    plt.title("L.K. opt-flow x-axis")
    plt.imshow(A[:,:,1], cmap='gray')
    plt.subplot(143)
    plt.title("L.K. opt-flow y-axis")
    plt.imshow(A[:,:,2], cmap='gray')
    plt.subplot(144)
    plt.title("L.K. opt-flow mask")
    plt.imshow(A[:,:,3], cmap='gray')
    # 加上剪裁/对称
    print("--------- * * * -----------")
    w, h, A = load_one_pr_sample(file_path, size=[94, 94], cut='True')
    fig = plt.figure(figsize=(12,6))
    plt.subplot(141)
    plt.title("original video frame")
    plt.imshow(A[:,:,0], cmap='gray')
    plt.subplot(142)
    plt.title("L.K. opt-flow x-axis")
    plt.imshow(A[:,:,1], cmap='gray')
    plt.subplot(143)
    plt.title("L.K. opt-flow y-axis")
    plt.imshow(A[:,:,2], cmap='gray')
    plt.subplot(144)
    plt.title("L.K. opt-flow mask")
    plt.imshow(A[:,:,3], cmap='gray')
    # 遍历所有样本
    #sample_image, sample_label, sample_name = load_all_pr_samples("../../matlab/cnn_samples", size=[94, 94])