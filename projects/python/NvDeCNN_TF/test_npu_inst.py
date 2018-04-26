# -*- coding:utf-8 -*-
#####################################

import generate_cnn_layers as gen_cnn
import os
import subprocess
import numpy as np
from load_our_samples import *
import numpy as np
# 要产生NPU指令
SORC_BIAS = 0x38000000>>2    # 输入的数据
DIST_BIAS = 0x3C000000>>2    # 输出数据
PARA_BIAS = 0x28000000>>2    # 参数的偏移量
DATA_BIAS = 0x30000000>>2    # 中间运算数据缓存的偏移量
MAT_WIDTH = 0x00040000>>2    # 要保存一个256x256的矩阵，0.25 MB的空间足够了

#%%
##########################################
def generate_npu_inst(H):
    # 返回指令集
    inst_set = []
    # 卷积层中，偏移量直接进入IMM立即数运算，不必存入内存
    # 全连接中，偏移量作为向量运算，需要写入内存
    # 使用字典来记录 
    dict_para = dict()
    para_num = 0
    for layer in range(0, len(H)):
        if H[layer][0]=='I':
            output_num = H[layer][3]
        elif H[layer][0]=='C':
            # 先要遍历输入的变量
            for n in range(0, H[layer][3]):
                for m in range(0, output_num):
                    name = "conv-kernel-L%d-I%d-O%d"%(layer, m, n)
                    dict_para[name] = PARA_BIAS + para_num*MAT_WIDTH    # 每个参数有0.5MB的空间
                    para_num = para_num + 1
                
                # 然后是卷积的偏置量
                name = "conv-bias-L%d-O%d"%(layer, n)
                dict_para[name] = PARA_BIAS + para_num*MAT_WIDTH    # 每个参数有0.5MB的空间
                para_num = para_num + 1
                
            # 更新输出数量
            output_num = H[layer][3]
            
        elif H[layer][0]=='FC':
            # 首先是链接权值
            name = "fc-weight-L%d"%(layer)
            dict_para[name] = PARA_BIAS + para_num*MAT_WIDTH    # 每个参数有0.5MB的空间
            para_num = para_num + 1
            # 然后是连接偏置
            name = "fc-bias-L%d"%(layer)
            dict_para[name] = PARA_BIAS + para_num*MAT_WIDTH    # 每个参数有0.5MB的空间
            para_num = para_num + 1

    #print(hex(PARA_BIAS + para_num*MAT_WIDTH))
    # 构造NPU指令
    # 卷积核
    Km = 3; Kn = 3; Pm = 2; Pn = 2;
    # 用来累计DDR的读写次数
    DDR_READ = 0; DDR_WRITE = 0;
    # 存储NPU指令
    npu_inst = [0, 0, 0, 0]
    # 对于卷积层，l-层-m-输入-n-输出，参数所在的位置是 ()
    for layer in range(0, len(H)):
        if H[layer][0]=='I':
            print("layer %d: input"%(layer))
            # 然后初始化输入输出的内存空间偏移量 
            INP_BIAS = SORC_BIAS
            OUT_BIAS = DIST_BIAS
            # 初始化每一层的输入通道数量
            input_num = H[layer][3]
            input_size = [H[layer][1], H[layer][2]]
        # 卷积层
        elif H[layer][0]=='C':
            print("layer %d: convolution"%(layer))
            # 首先计算每个input_map和conv_kernel的卷积结果
            for n in range(0, H[layer][3]):
                # 计算每个输入和对应核的卷积，存储到数据缓存空间
                for m in range(0, input_num):
                    # 对于每个input_map进行计算
                    name = "conv-kernel-L%d-I%d-O%d"%(layer, m, n)
                    print("CONV, @%08X, @%08X, @%08X, M=%d, N=%d, Km=%d, Kn=%d"%(INP_BIAS+m*MAT_WIDTH, dict_para[name], DATA_BIAS+m*MAT_WIDTH, input_size[0], input_size[1], Km, Kn))
                    
                    # 翻译成指令
                    D1 = int((INP_BIAS+m*MAT_WIDTH))
                    D2 = int(dict_para[name])
                    D3 = int(DATA_BIAS+m*MAT_WIDTH)
                    M = int(input_size[0])
                    N = int(input_size[1])
                    npu_inst[0] = (7<<28)|(D1>>4)
                    npu_inst[1] = (D1<<28)|(D2>>4) 
                    npu_inst[2] = (D2<<28)|(D3>>4) 
                    npu_inst[3] = (D3<<28)|(M<<20)|(N<<12)|(Km<<6)|(Kn)
                    print("\tinst=%08X%08X%08X%08X"%(npu_inst[0]&0xFFFFFFFF, npu_inst[1]&0xFFFFFFFF, npu_inst[2]&0xFFFFFFFF, npu_inst[3]&0xFFFFFFFF))
                    inst_set.append(("%08X%08X%08X%08X"%(npu_inst[0]&0xFFFFFFFF, npu_inst[1]&0xFFFFFFFF, npu_inst[2]&0xFFFFFFFF, npu_inst[3]&0xFFFFFFFF)))
                    
                    # 累计DDR读写次数
                    DDR_READ = DDR_READ + input_size[0]*input_size[1] + Km*Kn
                    DDR_WRITE = DDR_WRITE + (input_size[0]-Km+1)*(input_size[1]-Kn+1)
                # 对于数据缓存空间中（m个）卷积结果进行累加，缓存
                for m in range(1, input_num):
                    print("ADD, @%08X, @%08X, @%08X, M=%d, N=%d"%(DATA_BIAS+0*MAT_WIDTH, DATA_BIAS+m*MAT_WIDTH, DATA_BIAS+0*MAT_WIDTH, (input_size[0]-Km+1), (input_size[1]-Kn+1)))
                    
                    # 翻译成指令
                    D1 = int(DATA_BIAS+0*MAT_WIDTH)
                    D2 = int(DATA_BIAS+m*MAT_WIDTH)
                    D3 = int(DATA_BIAS+0*MAT_WIDTH)
                    M = int(input_size[0]-Km+1)
                    N = int(input_size[1]-Kn+1)
                    npu_inst[0] = (0<<28)|(D1>>4)
                    npu_inst[1] = (D1<<28)|(D2>>4) 
                    npu_inst[2] = (D2<<28)|(D3>>4) 
                    npu_inst[3] = (D3<<28)|(M<<20)|(N<<12)
                    print("\tinst=%08X%08X%08X%08X"%(npu_inst[0]&0xFFFFFFFF, npu_inst[1]&0xFFFFFFFF, npu_inst[2]&0xFFFFFFFF, npu_inst[3]&0xFFFFFFFF))
                    inst_set.append(("%08X%08X%08X%08X"%(npu_inst[0]&0xFFFFFFFF, npu_inst[1]&0xFFFFFFFF, npu_inst[2]&0xFFFFFFFF, npu_inst[3]&0xFFFFFFFF)))
                    
                    # 累计DDR读写次数
                    DDR_READ = DDR_READ + (input_size[0]-Km+1)*(input_size[1]-Kn+1)*2
                    DDR_WRITE = DDR_WRITE + (input_size[0]-Km+1)*(input_size[1]-Kn+1)
                # 然后加上偏置
                name2 = "conv-bias-L%d-O%d"%(layer, n)
                print("ADDs, @%08X, @%08X, @%08X, M=%d, N=%d"%(DATA_BIAS+0*MAT_WIDTH, dict_para[name2], DATA_BIAS+0*MAT_WIDTH, (input_size[0]-Km+1), (input_size[1]-Kn+1)))
                
                # 翻译成指令
                D1 = int(DATA_BIAS+0*MAT_WIDTH)
                D2 = int(dict_para[name2])
                D3 = int(DATA_BIAS+0*MAT_WIDTH)
                M = int(input_size[0]-Km+1)
                N = int(input_size[1]-Kn+1)
                npu_inst[0] = (14<<28)|(D1>>4)
                npu_inst[1] = (D1<<28)|(D2>>4) 
                npu_inst[2] = (D2<<28)|(D3>>4) 
                npu_inst[3] = (D3<<28)|(M<<20)|(N<<12)
                print("\tinst=%08X%08X%08X%08X"%(npu_inst[0]&0xFFFFFFFF, npu_inst[1]&0xFFFFFFFF, npu_inst[2]&0xFFFFFFFF, npu_inst[3]&0xFFFFFFFF))
                inst_set.append(("%08X%08X%08X%08X"%(npu_inst[0]&0xFFFFFFFF, npu_inst[1]&0xFFFFFFFF, npu_inst[2]&0xFFFFFFFF, npu_inst[3]&0xFFFFFFFF)))
                
                # 累计DDR读写次数
                DDR_READ = DDR_READ + (input_size[0]-Km+1)*(input_size[1]-Kn+1) + 1
                DDR_WRITE = DDR_WRITE + (input_size[0]-Km+1)*(input_size[1]-Kn+1)
                # 然后是sigmoid非线性映射
                print("SIGM, @%08X, xx, @%08X, M=%d, N=%d"%(DATA_BIAS+0*MAT_WIDTH, OUT_BIAS+n*MAT_WIDTH, (input_size[0]-Km+1), (input_size[1]-Kn+1)))
                
                # 翻译成指令
                D1 = int(DATA_BIAS+0*MAT_WIDTH)
                D2 = int(0)
                D3 = int(OUT_BIAS+n*MAT_WIDTH)
                M = int(input_size[0]-Km+1)
                N = int(input_size[1]-Kn+1)
                npu_inst[0] = (9<<28)|(D1>>4)
                npu_inst[1] = (D1<<28)|(D2>>4) 
                npu_inst[2] = (D2<<28)|(D3>>4) 
                npu_inst[3] = (D3<<28)|(M<<20)|(N<<12)
                print("\tinst=%08X%08X%08X%08X"%(npu_inst[0]&0xFFFFFFFF, npu_inst[1]&0xFFFFFFFF, npu_inst[2]&0xFFFFFFFF, npu_inst[3]&0xFFFFFFFF))
                inst_set.append(("%08X%08X%08X%08X"%(npu_inst[0]&0xFFFFFFFF, npu_inst[1]&0xFFFFFFFF, npu_inst[2]&0xFFFFFFFF, npu_inst[3]&0xFFFFFFFF)))
                
                # 累计DDR读写次数
                DDR_READ = DDR_READ + (input_size[0]-Km+1)*(input_size[1]-Kn+1)
                DDR_WRITE = DDR_WRITE + (input_size[0]-Km+1)*(input_size[1]-Kn+1)
            # 最后交换一下INP_BIAS/OUT_BIAS两个输入/输出的地址
            TMP = OUT_BIAS
            OUT_BIAS = INP_BIAS
            INP_BIAS = TMP
            # 更新一下每一层的输入通道数量，以及输入图像的尺寸
            input_num = H[layer][3]
            input_size = [input_size[0]-Km+1, input_size[1]-Kn+1]
        # 池化层
        elif H[layer][0]=='S':
            print("layer %d: pooling"%(layer))
            # 使用POOL指令计算每个输入的pooling结果，缓存
            for m in range(0, input_num):
                # 对于每个input_map进行计算
                print("POOL, @%08X, MAX, @%08X, M=%d, N=%d, Pm=%d, Pn=%d"%(INP_BIAS+m*MAT_WIDTH, OUT_BIAS+m*MAT_WIDTH, input_size[0], input_size[1], Pm, Pn))
                
                # 翻译成指令
                D1 = int(INP_BIAS+m*MAT_WIDTH)
                D2 = int(1)
                D3 = int(OUT_BIAS+m*MAT_WIDTH)
                M = int(input_size[0])
                N = int(input_size[1])
                npu_inst[0] = (8<<28)|(D1>>4)
                npu_inst[1] = (D1<<28)|(D2>>4) 
                npu_inst[2] = (D2<<28)|(D3>>4) 
                npu_inst[3] = (D3<<28)|(M<<20)|(N<<12)|(Pm<<6)|Pn
                print("\tinst=%08X%08X%08X%08X"%(npu_inst[0]&0xFFFFFFFF, npu_inst[1]&0xFFFFFFFF, npu_inst[2]&0xFFFFFFFF, npu_inst[3]&0xFFFFFFFF))
                inst_set.append(("%08X%08X%08X%08X"%(npu_inst[0]&0xFFFFFFFF, npu_inst[1]&0xFFFFFFFF, npu_inst[2]&0xFFFFFFFF, npu_inst[3]&0xFFFFFFFF)))
                
                # 累计DDR读写次数
                DDR_READ = DDR_READ + (input_size[0])*(input_size[1])
                DDR_WRITE = DDR_WRITE + int(input_size[0]/Pm)*int(input_size[1]/Pn)
            # 最后交换一下INP_BIAS/OUT_BIAS两个输入/输出的地址
            TMP = OUT_BIAS
            OUT_BIAS = INP_BIAS
            INP_BIAS = TMP
            # 更新一下每一层的输入通道数量，以及输入图像的尺寸
            input_num = input_num
            input_size = [input_size[0]/Pm, input_size[1]/Pn]
        # 压平层
        elif H[layer][0]=='STRIP':
            print("layer %d: strip"%(layer))
            # 使用POOL指令计算每个输入的pooling结果，缓存
            for m in range(0, input_num):
                # 对于每个input_map进行计算
                space_for_each_img = int(H[layer][1]/input_num)     # 32-bit data format
                print("ADDi, @%08X, #%08X, @%08X, M=%d, N=%d"%(INP_BIAS+m*MAT_WIDTH, 0, OUT_BIAS+m*(space_for_each_img), input_size[0], input_size[1]))
                
                # 翻译成指令
                D1 = int(INP_BIAS+m*MAT_WIDTH)
                D2 = int(0)
                D3 = int(OUT_BIAS+m*(space_for_each_img))
                M = int(input_size[0])
                N = int(input_size[1])
                npu_inst[0] = (1<<28)|(D1>>4)
                npu_inst[1] = (D1<<28)|(D2>>4) 
                npu_inst[2] = (D2<<28)|(D3>>4) 
                npu_inst[3] = (D3<<28)|(M<<20)|(N<<12)
                print("\tinst=%08X%08X%08X%08X"%(npu_inst[0]&0xFFFFFFFF, npu_inst[1]&0xFFFFFFFF, npu_inst[2]&0xFFFFFFFF, npu_inst[3]&0xFFFFFFFF))
                inst_set.append(("%08X%08X%08X%08X"%(npu_inst[0]&0xFFFFFFFF, npu_inst[1]&0xFFFFFFFF, npu_inst[2]&0xFFFFFFFF, npu_inst[3]&0xFFFFFFFF)))
                
                # 累计DDR读写次数
                DDR_READ = DDR_READ + (input_size[0])*(input_size[1])
                DDR_WRITE = DDR_WRITE + (input_size[0])*(input_size[1])
            # 最后交换一下INP_BIAS/OUT_BIAS两个输入/输出的地址
            TMP = OUT_BIAS
            OUT_BIAS = INP_BIAS
            INP_BIAS = TMP
            # 更新一下每一层的输入通道数量
            input_num = 1
            input_size = [1, H[layer][1]]
        # 全连接层
        elif H[layer][0]=='FC':
            print("layer %d: fully_connection"%(layer))
            # 使用MULT矩阵乘法指令
            name = "fc-weight-L%d"%(layer)
            print("MULT, @%08X, @%08X, @%08X, M=%d, N=%d, P=%d"%(INP_BIAS, dict_para[name], DATA_BIAS, input_size[0], input_size[1], H[layer][2]))
            
            # 翻译成指令
            D1 = int(INP_BIAS)
            D2 = int(dict_para[name])
            D3 = int(DATA_BIAS)
            M = int(input_size[0])
            N = int(input_size[1])
            P = int(H[layer][2])
            npu_inst[0] = (4<<28)|(D1>>4)
            npu_inst[1] = (D1<<28)|(D2>>4) 
            npu_inst[2] = (D2<<28)|(D3>>4) 
            npu_inst[3] = (D3<<28)|(M<<20)|(N<<12)|(P<<4)
            print("\tinst=%08X%08X%08X%08X"%(npu_inst[0]&0xFFFFFFFF, npu_inst[1]&0xFFFFFFFF, npu_inst[2]&0xFFFFFFFF, npu_inst[3]&0xFFFFFFFF))
            inst_set.append(("%08X%08X%08X%08X"%(npu_inst[0]&0xFFFFFFFF, npu_inst[1]&0xFFFFFFFF, npu_inst[2]&0xFFFFFFFF, npu_inst[3]&0xFFFFFFFF)))
            
            # 累计DDR读写次数
            DDR_READ = DDR_READ + (input_size[0])*(input_size[1])*H[layer][2]
            DDR_WRITE = DDR_WRITE + input_size[0]*H[layer][2]
            # 矩阵乘法完成后，运算结果的尺寸变成了【input_size[0]xH[layer][2]】
            # 然后执行一下矩阵加法（加上连接偏置）
            name = "fc-bias-L%d"%(layer)
            print("ADD, @%08X, @%08X, @%08X, M=%d, N=%d"%(DATA_BIAS, dict_para[name], DATA_BIAS+MAT_WIDTH, input_size[0], H[layer][2]))
            
            # 翻译成指令
            D1 = int(DATA_BIAS)
            D2 = int(dict_para[name])
            D3 = int(DATA_BIAS+MAT_WIDTH)
            M = int(input_size[0])
            N = int(H[layer][2])
            npu_inst[0] = (0<<28)|(D1>>4)
            npu_inst[1] = (D1<<28)|(D2>>4) 
            npu_inst[2] = (D2<<28)|(D3>>4) 
            npu_inst[3] = (D3<<28)|(M<<20)|(N<<12)
            print("\tinst=%08X%08X%08X%08X"%(npu_inst[0]&0xFFFFFFFF, npu_inst[1]&0xFFFFFFFF, npu_inst[2]&0xFFFFFFFF, npu_inst[3]&0xFFFFFFFF))
            inst_set.append(("%08X%08X%08X%08X"%(npu_inst[0]&0xFFFFFFFF, npu_inst[1]&0xFFFFFFFF, npu_inst[2]&0xFFFFFFFF, npu_inst[3]&0xFFFFFFFF)))
            
            # 累计DDR读写次数
            DDR_READ = DDR_READ + (input_size[0])*H[layer][2]*2
            DDR_WRITE = DDR_WRITE + input_size[0]*H[layer][2]
            # 最后，使用sigmoid非线性映射
            print("SIGM, @%08X, xx, @%08X, M=%d, N=%d"%(DATA_BIAS+MAT_WIDTH, OUT_BIAS, input_size[0], H[layer][2]))
            
            # 翻译成指令
            D1 = int(DATA_BIAS+MAT_WIDTH)
            D2 = int(0)
            D3 = int(OUT_BIAS)
            M = int(input_size[0])
            N = int(H[layer][2])
            npu_inst[0] = (9<<28)|(D1>>4)
            npu_inst[1] = (D1<<28)|(D2>>4) 
            npu_inst[2] = (D2<<28)|(D3>>4) 
            npu_inst[3] = (D3<<28)|(M<<20)|(N<<12)
            print("\tinst=%08X%08X%08X%08X"%(npu_inst[0]&0xFFFFFFFF, npu_inst[1]&0xFFFFFFFF, npu_inst[2]&0xFFFFFFFF, npu_inst[3]&0xFFFFFFFF))
            inst_set.append(("%08X%08X%08X%08X"%(npu_inst[0]&0xFFFFFFFF, npu_inst[1]&0xFFFFFFFF, npu_inst[2]&0xFFFFFFFF, npu_inst[3]&0xFFFFFFFF)))
            
            # 累计DDR读写次数
            DDR_READ = DDR_READ + (input_size[0])*H[layer][2]
            DDR_WRITE = DDR_WRITE + input_size[0]*H[layer][2]
            # 最后交换一下INP_BIAS/OUT_BIAS两个输入/输出的地址
            TMP = OUT_BIAS
            OUT_BIAS = INP_BIAS
            INP_BIAS = TMP
            # 更新一下每一层的输入通道数量
            input_num = 1
            input_size = [1, H[layer][2]]
    #################
    # 最后评估一下整个系统的DDR读写负荷
    print("\n\nDDR-READ = %d, DDR_WRITE=%d, \nTOTAL-TIME[estimated in 50 MHz]=%f ms" %(DDR_READ, DDR_WRITE, (DDR_READ+DDR_WRITE)/50e6*1e3))

    return dict_para, inst_set

#########################################
#%% 生成比对测试文件
from scipy import signal
def generate_test_file(image, H, filename):
    fp = open(filename, "w")
    # 构造NPU指令
    # 卷积核
    Km = 3; Kn = 3; Pm = 2; Pn = 2;
    # 对于卷积层，l-层-m-输入-n-输出，参数所在的位置是 ()
    for layer in range(0, len(H)):
        if H[layer][0]=='I':
            # 初始化每一层的输入通道数量
            input_num = H[layer][3]
            input_size = [H[layer][1], H[layer][2]]
            # 输入图像
            input_img = [image[:, :, i] for i in range(0, H[layer][3])]
        # 卷积层
        elif H[layer][0]=='C':
            input_img_tmp = []
            # 首先计算每个input_map和conv_kernel的卷积结果
            for n in range(0, H[layer][3]):
                # 计算每个输入和对应核的卷积，存储到数据缓存空间
                conv_m_n = []
                for m in range(0, input_num):
                    # 对于每个input_map进行计算
                    name = "conv-kernel-L%d-I%d-O%d"%(layer, m, n)
                    kernel_m_n = np.loadtxt("./para/"+name+".csv", delimiter=",")
                    # print(kernel_m_n)
                    conv_res_m_n = signal.convolve2d(input_img[m], kernel_m_n, 'valid')
                    #print(conv_res_m_n.shape)
                    # 输出运算结果
                    fp.write("\n")
                    for i in range(conv_res_m_n.shape[0]):
                        for j in range(conv_res_m_n.shape[1]):
                            fp.write("%d\n"%(int(conv_res_m_n[i][j]*2**16)))
                    ##
                    conv_m_n.append(conv_res_m_n)
                    
                # 对于数据缓存空间中（m个）卷积结果进行累加，缓存
                # print(conv_m_n[0].shape)
                sum_conv_m_n = conv_m_n[0]
                for m in range(1, input_num):
                    sum_conv_m_n = sum_conv_m_n + conv_m_n[m]
                    # 输出运算结果
                    fp.write("\n")
                    for i in range(sum_conv_m_n.shape[0]):
                        for j in range(sum_conv_m_n.shape[1]):
                            fp.write("%d\n"%(int(sum_conv_m_n[i][j]*2**16)))
                    
                # 然后加上偏置
                name2 = "conv-bias-L%d-O%d"%(layer, n)
                bias_n = np.loadtxt("./para/"+name2+".csv", delimiter=",")
                sum_conv_m_n = sum_conv_m_n + bias_n
                # 输出运算结果
                fp.write("\n")
                for i in range(sum_conv_m_n.shape[0]):
                    for j in range(sum_conv_m_n.shape[1]):
                        fp.write("%d\n"%(int(sum_conv_m_n[i][j]*2**16)))
                
                # 然后是sigmoid非线性映射
                sigm_n = 1/(1+np.exp(-sum_conv_m_n))
                # 输出运算结果
                fp.write("\n")
                for i in range(sigm_n.shape[0]):
                    for j in range(sigm_n.shape[1]):
                        fp.write("%d\n"%(int(sigm_n[i][j]*2**16)))
                input_img_tmp.append(sigm_n)
            
            # 更新一下每一层的输入通道数量，以及输入图像的尺寸
            input_num = H[layer][3]
            input_size = [input_size[0]-Km+1, input_size[1]-Kn+1]
            # 输入图像
            input_img = input_img_tmp
            
        # 池化层
        elif H[layer][0]=='S':
            # 使用POOL指令计算每个输入的pooling结果，缓存
            input_img_tmp = []
            for m in range(0, input_num):
                # 对于每个input_map进行计算
                # print(input_img[m])
                pool_m = np.zeros((int(input_size[0]/2), int(input_size[1]/2)))
                for i in range(0, int(input_size[0]/2)):
                    for j in range(0, int(input_size[1]/2)):
                        pool_m[i, j] = np.max(input_img[m][2*i:2*i+2, 2*j:2*j+2])
                input_img_tmp.append(pool_m)
                
                # 输出运算结果
                fp.write("\n")
                for i in range(pool_m.shape[0]):
                    for j in range(pool_m.shape[1]):
                        fp.write("%d\n"%(int(pool_m[i][j]*2**16)))
            # 更新一下每一层的输入通道数量，以及输入图像的尺寸
            input_num = input_num
            input_size = [input_size[0]/Pm, input_size[1]/Pn]
            # 输入图像
            input_img = input_img_tmp
        # 压平层
        elif H[layer][0]=='STRIP':
            strip_tmp = np.zeros((input_num, int(H[layer][1]/input_num)))
            # 使用POOL指令计算每个输入的pooling结果，缓存
            for m in range(0, input_num):
                # 对于每个input_map进行计算
                strip_tmp[m] = input_img[m].reshape((int(H[layer][1]/input_num)))
            # 打印
            #print(strip_tmp)
            # 输出运算结果
            fp.write("\n")
            for i in range(strip_tmp.shape[0]):
                for j in range(strip_tmp.shape[1]):
                    fp.write("%d\n"%(int(strip_tmp[i][j]*2**16)))
            # 更新一下每一层的输入通道数量
            input_num = 1
            input_size = [1, H[layer][1]]
            input_img = strip_tmp.reshape((H[layer][1]))
        # 全连接层
        elif H[layer][0]=='FC':
            # 使用MULT矩阵乘法指令
            name = "fc-weight-L%d"%(layer)
            weight = np.loadtxt("./para/"+name+".csv", delimiter=",")
            input_img = np.dot(input_img, weight)
            
            # 输出运算结果
            fp.write("\n")
            for i in range(input_img.shape[0]):
                fp.write("%d\n"%(int(input_img[i]*2**16)))
                    
            # 矩阵乘法完成后，运算结果的尺寸变成了【input_size[0]xH[layer][2]】
            # 然后执行一下矩阵加法（加上连接偏置）
            name = "fc-bias-L%d"%(layer)
            bias = np.loadtxt("./para/"+name+".csv", delimiter=",")
            #print(input_img)
            input_img = input_img + bias
            #print(input_img)
            #print("---------")
            
            # 输出运算结果
            fp.write("\n")
            for i in range(input_img.shape[0]):
                fp.write("%d\n"%(int(input_img[i]*2**16)))
                
            # 最后，使用sigmoid非线性映射
            input_img = 1/(1+np.exp(-input_img))
            
            
            # 输出运算结果
            fp.write("\n")
            for i in range(input_img.shape[0]):
                fp.write("%d\n"%(int(input_img[i]*2**16)))
                
            # 更新一下每一层的输入通道数量
            input_num = 1
            input_size = [1, H[layer][2]]
    
    fp.close()
    
    return input_img

#########################################

# 测试用
if __name__ == '__main__':
    #%% 用H表征网络结构，P来表征参数，用D来表征数据
    H = gen_cnn.generate_cnn()
    
    para_dict, inst_set = generate_npu_inst(H)
    #print(inst_set)
    
    fp = open("./fpga/inst.list", "w")
    fp.write("@0\n")
    for inst in inst_set:
        fp.write("%s\n"%(inst))
    fp.write("%032X"%(0))
    fp.close()
    
    #%% 加载所有样本，并且生成所有的内存初始化文件
    sample_image, sample_label, sample_name = load_all_pr_samples("../../matlab/cnn_samples", size=[94, 94], rand="True")
    # 归一化
    sample_image[:, :, :, 0] = sample_image[:, :, :, 0]/256.0
    sample_image[:, :, :, 1] = sample_image[:, :, :, 1]/256.0
    sample_image[:, :, :, 2] = sample_image[:, :, :, 2]/256.0
    
    #%% 遍历所有的样本点
    SAMPLE_BIAS = 200
    TOTAL_NUM = 100
    true_cnt = 0
    for i in range(SAMPLE_BIAS+0, SAMPLE_BIAS+TOTAL_NUM): #sample_image.shape[0]):
        # 生成和verilog-NPU比对的测试文件
        image = sample_image[i, :, :, :]
        #print(image.shape)
        conv_out = generate_test_file(image, H, "./ver_compare/sp-%d-label-%d.txt"%(i, int(sample_label[i])))
        print(np.argmax(conv_out)==sample_label[i], np.argmax(conv_out), sample_label[i])
        true_cnt = true_cnt + (np.argmax(conv_out)==sample_label[i])
        # 创建一个内存初始化文件
        fp = open("./sim_source/sp-%d-label-%d.list"%(i, int(sample_label[i])), "w")
        fp_a = open("./sim_source/sp-%d-label-%d_da.list"%(i, int(sample_label[i])), "w")
        fp_b = open("./sim_source/sp-%d-label-%d_db.list"%(i, int(sample_label[i])), "w")
        fp_c = open("./sim_source/sp-%d-label-%d_dc.list"%(i, int(sample_label[i])), "w")
        fp_d = open("./sim_source/sp-%d-label-%d_dd.list"%(i, int(sample_label[i])), "w")
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
        for m in range(0, sample_image.shape[1]):
            for n in range(0, sample_image.shape[2]):
                DAT = int(sample_image[i][m][n][0]*2**16)
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
        for m in range(0, sample_image.shape[1]):
            for n in range(0, sample_image.shape[2]):
                DAT = int(sample_image[i][m][n][1]*2**16)
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
        for m in range(0, sample_image.shape[1]):
            for n in range(0, sample_image.shape[2]):
                DAT = int(sample_image[i][m][n][2]*2**16)
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
        for m in range(0, sample_image.shape[1]):
            for n in range(0, sample_image.shape[2]):
                DAT = int(sample_image[i][m][n][3]*2**16)
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
        filename_crlf = ".\sim_source\sp-%d-label-%d.list"%(i, int(sample_label[i]))
        subprocess.call(".\c_api\change_crlf.exe %s"%(filename_crlf))
        
    #############
    print("acc = %.2f"%(true_cnt*1.0/TOTAL_NUM))