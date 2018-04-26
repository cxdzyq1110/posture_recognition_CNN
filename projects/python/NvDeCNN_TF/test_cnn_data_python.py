# -*- coding: utf-8 -*-
"""
Created on Mon Apr  9 21:19:29 2018

@author: xdche
"""
import generate_cnn_layers as gen_cnn
from load_our_samples import *
import numpy as np
import matplotlib.pyplot as plt
import test_npu_inst
#%% 加载采集到的【实时待检测数据】
x = np.loadtxt("./real-time-data/data_under_test.txt", delimiter=",")

H = 94; W = 94;
#%% 然后每一行变形
fig = plt.figure(figsize=(12,6))
plt.subplot(141)
plt.title("original video frame")
plt.imshow(np.reshape(x[:, 0], (H, W)), cmap='gray')
plt.subplot(142)
plt.title("L.K. opt-flow x-axis")
plt.imshow(np.reshape(x[:, 1], (H, W)), cmap='gray')
plt.subplot(143)
plt.title("L.K. opt-flow y-axis")
plt.imshow(np.reshape(x[:, 2], (H, W)), cmap='gray')
plt.subplot(144)
plt.title("L.K. opt-flow mask")
plt.imshow(np.reshape(x[:, 3], (H, W)), cmap='gray')
# 生成待检测样本
image = np.zeros((H, W, 4), dtype=np.float)
for i in range(0, 4):
    image[:, :, i] = np.reshape(x[:, i], (H, W))
image = image / 65536.0
#%% 然后带入CNN进行计算
# CNN网络结果
H = gen_cnn.generate_cnn()

output = test_npu_inst.generate_test_file(image, H, "null.txt")
'''
#%% 另外也要尝试一下其他的数据
sample_image, sample_label, sample_name = load_all_pr_samples("../../matlab/cnn_samples", size=[94, 94], rand="Flase", flip="True", cut="True")
# 归一化
sample_image[:, :, :, 0] = sample_image[:, :, :, 0]/256.0
sample_image[:, :, :, 1] = sample_image[:, :, :, 1]/256.0
sample_image[:, :, :, 2] = sample_image[:, :, :, 2]/256.0
#%%
k=289
print(sample_name)
print(sample_name[sample_label[k]])
fig = plt.figure(figsize=(12,6))
plt.subplot(141)
plt.title("original video frame")
plt.imshow(sample_image[k, :, :, 0], cmap='gray')
plt.subplot(142)
plt.title("L.K. opt-flow x-axis")
plt.imshow(sample_image[k, :, :, 1], cmap='gray')
plt.subplot(143)
plt.title("L.K. opt-flow y-axis")
plt.imshow(sample_image[k, :, :, 2], cmap='gray')
plt.subplot(144)
plt.title("L.K. opt-flow mask")
plt.imshow(sample_image[k, :, :, 3], cmap='gray')
#
output = test_npu_inst.generate_test_file(sample_image[k], H, "null.txt")
'''