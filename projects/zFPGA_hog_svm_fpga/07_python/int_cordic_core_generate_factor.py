# -*- coding:utf-8 -*-
#####################################
from math import *
#####################################
import os, sys
# 设定bit width位宽
BW = int(sys.argv[1])
# 设定小数位宽
FRAC = int(sys.argv[2])
# 设定展开阶数
ORDER = 256
###########################
# 首先处理生成模计算的cordic核
# 循环产生系数
Kn = 1
fp = open("../04_scripts/cordic_factor_Kn.mif", "w")
# 打印mif文件的开头
fp.write("DEPTH = %d;\n"%(ORDER))
fp.write("WIDTH = %d;\n"%(BW*2))
fp.write("ADDRESS_RADIX = HEX;\n")
fp.write("DATA_RADIX = HEX;\n")
fp.write("CONTENT\n")
fp.write("BEGIN\n")
for iter in range(0, ORDER):
	cos_theta_n = 1.0/sqrt(1+0.25**iter)
	theta_n = atan(0.5**iter)
	Kn = Kn*cos_theta_n
	fp.write("%X : %08X%08X;\n"%(iter, floor(2**(BW-1)*Kn), floor(2**(BW-1)*theta_n/pi)))

fp.write("END;\n")
fp.close()

#########################
