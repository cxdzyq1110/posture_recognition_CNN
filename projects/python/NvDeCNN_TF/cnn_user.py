# -*- coding:utf-8 -*-
#####################################
# import TensorFlow
import tensorflow as tf
####################################
class cnn_user:
	def	__init__(self, conf, epsilon, keep_prob_):
		self.W = []
		self.b = []
		self.type_ = []
		self.num_ = []
		self.kernel_size = []
		#self.num_.append(ch)
		with tf.name_scope('cnn_components'):
			for layer in range(0, len(conf)):
				print(conf[layer]) 
				# 卷积层
				with tf.name_scope('layer-%d'%(layer)):
					if conf[layer][0]=='I':
						self.num_.append(conf[layer][3]) # 输入通道数量
						self.type_.append('I')
						self.W.append([])
						self.b.append([])
						self.kernel_size.append([])
					elif conf[layer][0]=='C':
						r = conf[layer][1] 	# 卷积核的行
						c = conf[layer][2] 	# 卷积核的列
						m = self.num_[layer-1]# 上一层的图像个数
						n = conf[layer][3]	# 卷积核的个数
						# 构造出卷积核
						conv_kernel = tf.Variable(tf.truncated_normal([r, c, m, n], stddev=0.1))
						# add_to_collection()函数将新生成变量的L2正则化损失加入集合 losses
						tf.add_to_collection('losses', tf.contrib.layers.l2_regularizer(epsilon)(conv_kernel))
						# 构造卷积核的偏置
						conv_bias = tf.Variable(tf.truncated_normal([n]))
						# 然后统一赋值到W
						self.W.append(conv_kernel)
						self.b.append(conv_bias)
						self.type_.append('C')
						self.num_.append(n)
						self.kernel_size.append([r, c])
						#######
						## 为了可视化
						# 我们把权值归一化，张量的维度交换一下
						if layer==1:
							ck_min = tf.reduce_min(conv_kernel)
							ck_max = tf.reduce_max(conv_kernel)
							conv_kernel_0_1 = (conv_kernel-ck_min)/(ck_max-ck_min)
							conv_kernel_t = tf.transpose(conv_kernel_0_1, [3, 0, 1, 2])
							tf.summary.image("conv_kernel", conv_kernel_t, max_outputs=n)
					# 下采样层
					elif conf[layer][0]=='S':
						r = conf[layer][1] 	# 下采样的行
						c = conf[layer][2] 	# 下采样的列
						m = self.num_[layer-1]# 上一层的图像个数
						n = m				# 下采样的个数
						self.W.append([])
						self.b.append([])
						self.type_.append('S')
						self.num_.append(n)
						self.kernel_size.append([r, c])
					# 全连接层
					elif conf[layer][0]=='FC':
						m = conf[layer][1] 	# 输入向量长度
						n = conf[layer][2] 	# 输出向量长度
						# 链接权值
						fc_weight = tf.Variable(tf.truncated_normal([m, n], stddev=0.1))
						# add_to_collection()函数将新生成变量的L2正则化损失加入集合 losses
						tf.add_to_collection('losses', tf.contrib.layers.l2_regularizer(epsilon)(fc_weight))
						# 加入dropout
						fc_weight = tf.nn.dropout(fc_weight, keep_prob = keep_prob_)
						# 偏置
						fc_bias = tf.Variable(tf.truncated_normal([n]))
						# 然后统一赋值到W
						self.W.append(fc_weight)
						self.b.append(fc_bias)
						self.type_.append('FC')
						self.num_.append(n)
						self.kernel_size.append([])
					# 压平层
					elif conf[layer][0]=='STRIP':
						n = conf[layer][1] 	# 输出向量长度
						# 然后统一赋值到W
						self.W.append([])
						self.b.append([])
						self.type_.append('STRIP')
						self.num_.append(n)
						self.kernel_size.append([])
					#######
					print(self.num_)
		################
	##########
	# 前向推进
	def step(self, inputs):
		with tf.name_scope('cnn_forward'):
			self.x = inputs			
			for layer in range(0, len(self.W)):
				with tf.name_scope('layer-%d'%(layer)):
					# 如果是卷积层
					if self.type_[layer]=='C':
						layer_u = tf.nn.conv2d(self.x, self.W[layer], strides=[1, 1, 1, 1], padding='VALID') + self.b[layer]
						layer_x = tf.sigmoid(layer_u)
						self.x = layer_x
						## 为了可视化
						# 我们把权值归一化，张量的维度交换一下
						if layer==1:
							K = self.num_[layer]
							images_to_plot = self.x[0:1, :, :, 0:K]
							x_min = tf.reduce_min(images_to_plot)
							x_max = tf.reduce_max(images_to_plot)
							images_to_plot_0_to_1 = (images_to_plot-x_min)/(x_max-x_min)
							images_to_plot_0_to_1_t = tf.transpose(images_to_plot_0_to_1, [3, 1, 2, 0])
							tf.summary.image("images", images_to_plot_0_to_1_t, max_outputs=K)
					# 如果是pooling下采样层
					elif self.type_[layer]=='S':
						pool_size = [1, self.kernel_size[layer][1], self.kernel_size[layer][0], 1]
						layer_u = tf.nn.max_pool(self.x, ksize=pool_size, strides=pool_size, padding='VALID')
						self.x = layer_u
					# 如果是压平层
					elif self.type_[layer]=='STRIP':
						print(tf.shape(self.x), self.num_[layer])
						self.x = tf.transpose(self.x, [0, 3, 1, 2])
						all_con = tf.reshape(self.x, [-1, self.num_[layer]])
						print(tf.shape(all_con))
						self.x = all_con
					# 如果是全连接
					elif self.type_[layer]=='FC':
						all_con = tf.nn.sigmoid(tf.matmul(self.x, self.W[layer]) + self.b[layer])
						self.x = all_con
			#############
			return self.x
###############################