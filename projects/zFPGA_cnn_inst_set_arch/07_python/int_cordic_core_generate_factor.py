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

#########################
# 然后是处理exp计算的cordic核
# 循环产生系数
Kn = 1
fp = open("../04_scripts/exp_cordic_factor_Kn.mif", "w")
# 打印mif文件的开头
fp.write("DEPTH = %d;\n"%(ORDER))
fp.write("WIDTH = %d;\n"%(BW*2))
fp.write("ADDRESS_RADIX = HEX;\n")
fp.write("DATA_RADIX = HEX;\n")
fp.write("CONTENT\n")
fp.write("BEGIN\n")
for iter in range(0, ORDER):
	cosh_theta_n = 1.0/sqrt(1-0.25**(iter+1))
	theta_n = atanh(0.5**(iter+1))
	Kn = Kn*cosh_theta_n
	#print Kn, theta_n
	fp.write("%X : %08X%08X;\n"%(iter, floor(2**FRAC*Kn), floor(2**FRAC*theta_n)))

fp.write("END;\n")
fp.close()
##############
# 然后还要生成整数部分的exp(I)的数据值
fp = open("../04_scripts/exp_cordic_int_part.mif", "w")
# 打印mif文件的开头
fp.write("DEPTH = %d;\n"%(ORDER))
fp.write("WIDTH = %d;\n"%(BW))
fp.write("ADDRESS_RADIX = HEX;\n")
fp.write("DATA_RADIX = HEX;\n")
fp.write("CONTENT\n")
fp.write("BEGIN\n")
for iter in range(0, ORDER):
	Kn = exp(iter - ORDER/2.0)
	if Kn<(2**15):
		fp.write("%X : %08X;\n"%(iter, floor(2**FRAC*Kn)))
	else:
		Kn = 2**15
		fp.write("%X : %08X;\n"%(iter, floor(2**FRAC*Kn)))

fp.write("END;\n")
fp.close()