# -*- coding:utf-8 -*-
#####################################
import shutil 
import os
# import TensorFlow
import tensorflow as tf
import numpy as np
import generate_cnn_layers as gen_cnn


# import TensorFlow
import tensorflow as tf
# we use cnn，首先加载CNN模型
import cnn_user as cu
import generate_cnn_layers as gen_cnn
H = gen_cnn.generate_cnn()
# 添加正则化项，改善测试集性能
epsilon = 1e-3
eta = 0.5
keep_prob_ = tf.placeholder("float")
model = cu.cnn_user(H, epsilon, keep_prob_)
# training data for x_ & y_
# we use placeholder
x_ = tf.placeholder("float", shape=[None, H[0][1], H[0][2], H[0][3]])
y_ = tf.placeholder("float", shape=[None, H[-1][2]])
# 计算CNN的输出
cnn_out = model.step(x_)

with tf.name_scope('softmax'):
	y = tf.nn.softmax(cnn_out) # softmax输出
# get loss function
# loss = -tf.reduce_sum(y_*tf.log(y))
with tf.name_scope('loss_function'):
	loss = -tf.reduce_sum(y_*tf.log(y))
	#loss = tf.reduce_mean(tf.square(y - y_))
	tf.summary.scalar('loss', loss) # tensorflow >= 0.12
	
optimizer = tf.train.AdamOptimizer(1e-5)
train = optimizer.minimize(loss)

# merge all variables
merged = tf.summary.merge_all() # tensorflow >= 0.12

# initiation: {variables, session}
init = tf.initialize_all_variables()
sess = tf.Session()
sess.run(init)
#############
# 用来保存变量
saver = tf.train.Saver()

# 如果模型参数存在的话，就要载入
if os.path.exists("./model_params.ckpt.meta"):
	print("model exists, loading...")
	saver.restore(sess, "./model_params.ckpt")
	# 然后需要保存每一层的参数
	# 首先获取CNN里面的权值和偏置
	CNN_W = sess.run(model.W, feed_dict={keep_prob_: 1.0})
	CNN_b = sess.run(model.b, feed_dict={keep_prob_: 1.0})
	CNN_type = model.type_
	#print(CNN_W[0].shape, CNN_b)
	for layer in range(len(CNN_type)):
		#print(CNN_type[layer])
		if CNN_type[layer]=='C':
			print("convolution")
			print("layer %d:"%(layer))
			for n in range(0, CNN_W[layer].shape[3]):
				for m in range(0, CNN_W[layer].shape[2]):
					print("conv_kernel:%d->%d"%(m, n))
					print(CNN_W[layer][:,:,m,n])
					# 保存到csv文件中
					filename = "./para/conv-kernel-L%d-I%d-O%d.csv"%(layer, m, n)
					# tensorflow下面的卷机运算和一般的2d卷积不一样，这里一定要先将卷积核旋转180度保存
					kernel = np.flipud(np.fliplr(CNN_W[layer][:,:,m,n]))
					np.savetxt(filename, kernel, delimiter=",", fmt='%f')
					#np.savetxt(filename, CNN_W[layer][:,:,m,n], delimiter=",", fmt='%f')
					#
				print("bias-->%d:"%(n))
				print(CNN_b[layer].shape)
				print(CNN_b[layer][n])
				# 保存到csv文件中
				filename = "./para/conv-bias-L%d-O%d.csv"%(layer, n)
				np.savetxt(filename, [[CNN_b[layer][n]]], delimiter=",", fmt='%f')
				#
		# 然后是全连接层
		elif CNN_type[layer]=='FC':
			FC_W = CNN_W[layer]
			FC_b = CNN_b[layer]
			print("fully_connection")
			print("weight:")
			print(FC_W)
			# 保存到csv文件中
			filename = "./para/fc-weight-L%d.csv"%(layer)
			np.savetxt(filename, FC_W, delimiter=",", fmt='%f')
			#
			print("bias:")
			print(FC_b)
			# 保存到csv文件中
			filename = "./para/fc-bias-L%d.csv"%(layer)
			np.savetxt(filename, FC_b, delimiter=",", fmt='%f')
			#
	
else:
	print("no model exists, run CNN-training first...")