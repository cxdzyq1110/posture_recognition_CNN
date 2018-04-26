# -*- coding: utf-8 -*-
"""
Created on Fri Apr  6 10:30:27 2018

@author: xdche
"""
import tensorflow as tf
# 比对scipy下面的convolve2d
from scipy import signal
import numpy as np

# 输入量
input = tf.Variable(tf.random_normal([2,2,2,4]))
# 卷积核
filter = tf.Variable(tf.random_normal([2,2,4,3]))
# 卷积后的偏置
bias = tf.Variable(tf.random_normal([3]))
# 运算的结果
op = tf.nn.conv2d(input, filter, strides=[1, 1, 1, 1], padding='VALID') + bias
# strip压平层
input_rearrange = tf.transpose(input, [0, 3, 1, 2])
strip = tf.reshape(input_rearrange, [-1, 2*2*4])

# 初始化数据
init = tf.initialize_all_variables()
with tf.Session() as sess:
    sess.run(init)
    
    # 首先获取输入量/卷积核的值
    input_val = input.eval()
    filter_val = filter.eval()
    bias_val = bias.eval()
    op_val = op.eval()
    strip_val = strip.eval()
    # 然后需要检验tf.nn.conv2d的计算过程
    sum_conv_m_n = 0
    # 对于每个batch都要运算
    # 首先验证convolution+bias
    for batch in range(0, input_val.shape[0]):
        #print("----- * * * ----\nbatch: %d"%(batch))
        for n in range(0, filter_val.shape[3]):
            sum_conv_m_n = 0    # 要把累加求和的步骤清零
            for m in range(0, filter_val.shape[2]):
                #print("--------\n%d-->%d"%(m, n))
                #print("A=")
                #print(input_val[batch, :, :, m]) # 第m个输入样本
                #print("B=")
                # 旋转卷积核180°，这里使用flipud(fliplr(A))来实现！
				# 注意这里一定要旋转180度，因为tensorflow下面的tf.nn.conv2d和一般的卷积实现不一样
				# reference : https://www.tensorflow.org/versions/r1.3/api_docs/python/tf/nn/conv2d
                kernel = filter_val[:, :, m, n]
                kernel = np.flipud(np.fliplr(kernel))
                #print(kernel)   # 第(m, n)个卷积核
                #print("in scipy.signal.convolve2d")
                test_res = signal.convolve2d(input_val[batch, :, :, m], kernel, 'valid')    # 卷积过程
                #print(test_res)
                sum_conv_m_n = sum_conv_m_n + test_res  # 累加
            
            sum_conv_m_n = sum_conv_m_n + bias_val[n]
			
            print("in convolve2d")
            print(sum_conv_m_n)
                
            print("in tensorflow")
            print(op_val[batch, :, :, n])
    # 然后验证reshape
    for batch in range(0, input_val.shape[0]):
        print("------- * * * ------------")
        print("in numpy")
        for n in range(0, input_val.shape[3]):
            print("n=", n)
            for h in range(input_val.shape[1]):
                print(input_val[batch, h, :, n])
        print("in tensorflow\n", strip_val[batch])
'''
IMG[batch, height, width, input_channel]
KERNEL[height, width, input_channel, output_channel]

tf.nn.conv2d(IMG, KERNEL) ==> sum_{input_channel}{convolve2d(IMG[batch, :, :, input_channel], KERNEL[:, :, input_channel, output_channel])}
'''