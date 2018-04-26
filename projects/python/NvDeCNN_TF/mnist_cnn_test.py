# -*- coding:utf-8 -*-
#####################################
# remove logs
logs_dir = "logs"
# delete directory & files inside
import shutil 
import os
# 指定GPU
os.environ["CUDA_VISIBLE_DEVICES"] = "0"
# 创建/移除logs文件夹
if os.path.exists(logs_dir):
	shutil.rmtree(logs_dir)

# 区分是训练，还是测试
'''
'''
import sys
if sys.argv[1]=='train':
	train_mode = 1
elif sys.argv[1]=='test':
	train_mode = 0
#train_mode = 1


# import TensorFlow
import tensorflow as tf
# we use cnn，首先加载CNN模型
import cnn_user as cu
import generate_cnn_layers as gen_cnn
H = gen_cnn.generate_cnn()
# 添加正则化项，改善测试集性能
epsilon = 1e-2
eta = 0.5
keep_prob_ = tf.placeholder("float")
model = cu.cnn_user(H, epsilon, keep_prob_)

# 加载图像数据&标签数据
from load_our_samples import *
import numpy as np

if train_mode==1:
	sample_image, sample_label, sample_name = load_all_pr_samples("../../matlab/cnn_samples", size=[94, 94], rand="True", flip="True", cut="True")
	# 归一化
	sample_image[:, :, :, 0] = sample_image[:, :, :, 0]/256.0
	sample_image[:, :, :, 1] = sample_image[:, :, :, 1]/256.0
	sample_image[:, :, :, 2] = sample_image[:, :, :, 2]/256.0
	# 编码方式
	OneHot = [[j==i for j in range(0, H[-1][2])] for i in range(0, H[-1][2])]
	OneHot = (np.array(OneHot))*1.0
	sample_label_one_hot = np.array([OneHot[sample_label[i]] for i in range(0, len(sample_label))])

	# 然后设置一下训练集和测试集
	test_set_ratio = 0.1
	train_image = sample_image[0:int(sample_image.shape[0]*(1-test_set_ratio)), :, :, :]
	train_label_one_hot = sample_label_one_hot[0:int(sample_image.shape[0]*(1-test_set_ratio)), :]
	train_label = sample_label[0:int(sample_image.shape[0]*(1-test_set_ratio))]
	test_image = sample_image[int(sample_image.shape[0]*(1-test_set_ratio)):int(sample_image.shape[0]), :, :, :]
	test_label_one_hot = sample_label_one_hot[int(sample_image.shape[0]*(1-test_set_ratio)):int(sample_image.shape[0]), :]
	test_label = sample_label[int(sample_image.shape[0]*(1-test_set_ratio)):int(sample_image.shape[0])]

else:
	# 原始数据测试
	total_image, total_label, total_name = load_all_pr_samples("../../matlab/cnn_samples", size=[94, 94], rand="True")
	# 归一化
	total_image[:, :, :, 0] = total_image[:, :, :, 0]/256.0
	total_image[:, :, :, 1] = total_image[:, :, :, 1]/256.0
	total_image[:, :, :, 2] = total_image[:, :, :, 2]/256.0
	# 编码方式
	OneHot = [[j==i for j in range(0, H[-1][2])] for i in range(0, H[-1][2])]
	OneHot = (np.array(OneHot))*1.0
	total_label_one_hot = np.array([OneHot[total_label[i]] for i in range(0, len(total_label))])


# training data for x_ & y_
# we use placeholder
x_ = tf.placeholder("float", shape=[None, H[0][1], H[0][2], H[0][3]])
y_ = tf.placeholder("float", shape=[None, H[-1][2]])
# 计算CNN的输出
cnn_out = model.step(x_)
with tf.name_scope('softmax'):
	y = tf.nn.softmax(cnn_out)
	
# get mse_loss function
# mse_loss = -tf.reduce_sum(y_*tf.log(y))
with tf.name_scope('loss_function'):
	mse_loss = -tf.reduce_sum(y_*tf.log(y))
	#mse_loss = tf.reduce_mean(tf.square(y - y_))
	tf.summary.scalar('mse_loss', mse_loss) # tensorflow >= 0.12
	# # 将均方误差损失函数加入损失集合
	tf.add_to_collection('losses', mse_loss)
	# get_collection()返回一个列表，这个列表是所有这个集合中的元素，在本样例中这些元素就是损失函数的不同部分，将他们加起来就是最终的损失函数
	loss = tf.add_n(tf.get_collection('losses'))
	
optimizer = tf.train.AdamOptimizer(1e-2)
#optimizer = tf.train.GradientDescentOptimizer(0.01)
train = optimizer.minimize(loss)

# merge all variables
merged = tf.summary.merge_all() # tensorflow >= 0.12

# initiation: {variables, session}
init = tf.initialize_all_variables()
#sess = tf.Session()
sess_config = tf.ConfigProto() 
sess_config.gpu_options.per_process_gpu_memory_fraction = 0.80 
sess_config.gpu_options.allow_growth = True # 允许自增长
#sess_config.log_device_placement=True # 允许打印gpu使用日志
sess = tf.Session(config=sess_config) 
sess.run(init)
#############
# 用来保存变量
saver = tf.train.Saver()
# plot
writer = tf.summary.FileWriter(logs_dir+"/", sess.graph) # tensorflow >=0.12

# accuracy estimation，评估正确率
correct_prediction = tf.equal(tf.argmax(y,1), tf.argmax(y_,1))
accuracy = tf.reduce_mean(tf.cast(correct_prediction, "float"))

# 如果模型参数存在的话，就要载入
if os.path.exists("./model_params.ckpt.meta"):
	print("model exists, loading...")
	saver.restore(sess, "./model_params.ckpt")
	
# 训练/推理
# true training process
L = 1000; C = 50; BatchSize = 480;
for step in range(0, L):
	# 如果在训练模式
	if train_mode==1:
		batch = []
		indice = [i%train_image.shape[0] for i in range((step*BatchSize), (step*BatchSize)+BatchSize)]
		image_x = np.array([train_image[indice[i], :, :, :] for i in range(0, len(indice))])
		label_y = np.array([OneHot[train_label[indice[i]]] for i in range(0, len(indice))])
		label_val_y = np.array([train_label[indice[i]] for i in range(0, len(indice))])
		batch.append(image_x)
		batch.append(label_y)
		###################################
		for c in range(0, C):
			sess.run(train, feed_dict={x_: batch[0], y_: batch[1], keep_prob_: eta})
		if step % (L/1000) == 0:
			#print(batch[0].shape, batch[1].shape)
			mse_loss_val = sess.run(mse_loss, feed_dict={x_: batch[0], y_: batch[1], keep_prob_: 1.0})
			print("\n[%.2f%%] --> %f"%(step/(L/100), mse_loss_val))
			# 首先是训练集中的测试
			acc = sess.run(accuracy, feed_dict={x_: batch[0], y_: batch[1], keep_prob_: 1.0})
			print("acc_in_train = %.2f"%(acc))
			
			# 统计各个样本的正确性
			correct = sess.run(correct_prediction, feed_dict={x_: batch[0], y_: batch[1], keep_prob_: 1.0})
			# 还应该统计TP/FP数据
			y_val = sess.run(y, feed_dict={x_: batch[0], y_: batch[1], keep_prob_: 1.0})
			y_label = np.argmax(y_val, axis=1)
			#print(y_label)
			for s in range(0, len(sample_name)):
				tp = (y_label[label_val_y==s]==s)	# true positive
				tn = (y_label[label_val_y!=s]!=s)	# true negative
				fp = (y_label[label_val_y!=s]==s)	# false positive
				fn = (y_label[label_val_y==s]!=s)	# false negative
				# 样本名称
				if sample_name[s]=="single_waving":
					label_name = "waving"
				else:
					label_name = sample_name[s]
				print("[%s] ==> \ttp_rate = %.2f, fp_rate = %.2f, precision = %.2f, recall = %.2f"
						%(label_name, 		np.sum(tp)*1.0/(np.sum(tp)+np.sum(fn) + 0.0001),
											np.sum(fp)*1.0/(np.sum(fp)+np.sum(tn) + 0.0001),
											np.sum(tp)*1.0/(np.sum(tp)+np.sum(fp) + 0.0001),
											np.sum(tp)*1.0/(np.sum(tp)+np.sum(fn) + 0.0001)))
			# do update data in plotting
			rs = sess.run(merged, feed_dict={x_: batch[0], y_: batch[1], keep_prob_: 1.0})
			writer.add_summary(rs, step)
			
			# 然后是测试集
			acc = sess.run(accuracy, feed_dict={x_: test_image, y_: test_label_one_hot, keep_prob_: 1.0})
			print("----\nacc_in_test = %.2f"%(acc))
			
			# 统计各个样本的正确性
			correct = sess.run(correct_prediction, feed_dict={x_: test_image, y_: test_label_one_hot, keep_prob_: 1.0})
			# 还应该统计TP/FP数据
			y_val = sess.run(y, feed_dict={x_: test_image, y_: test_label_one_hot, keep_prob_: 1.0})
			y_label = np.argmax(y_val, axis=1)
			#print(y_label)
			for s in range(0, len(sample_name)):
				tp = (y_label[test_label==s]==s)	# true positive
				tn = (y_label[test_label!=s]!=s)	# true negative
				fp = (y_label[test_label!=s]==s)	# false positive
				fn = (y_label[test_label==s]!=s)	# false negative
				# 样本名称
				if sample_name[s]=="single_waving":
					label_name = "waving"
				else:
					label_name = sample_name[s]
				print("[%s] ==> \ttp_rate = %.2f, fp_rate = %.2f, precision = %.2f, recall = %.2f"
						%(label_name, 		np.sum(tp)*1.0/(np.sum(tp)+np.sum(fn) + 0.0001),
											np.sum(fp)*1.0/(np.sum(fp)+np.sum(tn) + 0.0001),
											np.sum(tp)*1.0/(np.sum(tp)+np.sum(fp) + 0.0001),
											np.sum(tp)*1.0/(np.sum(tp)+np.sum(fn) + 0.0001)))
			
			# 定期保存模型参数
			saver.save(sess, "./model_params.ckpt")
			
	# 否则是在测试模式
	elif train_mode==0:
		batch = []
		indice = [i%total_image.shape[0] for i in range((step*BatchSize), (step*BatchSize)+BatchSize)]
		image_x = np.array([total_image[indice[i], :, :, :] for i in range(0, len(indice))])
		label_y = np.array([OneHot[total_label[indice[i]]] for i in range(0, len(indice))])
		label_val_y = np.array([total_label[indice[i]] for i in range(0, len(indice))])
		batch.append(image_x)
		batch.append(label_y)
		#################################################
		if step % (L/100) == 0:
			mse_loss_val = sess.run(mse_loss, feed_dict={x_: batch[0], y_: batch[1], keep_prob_: 1.0})
			print("\n[%.2f%%] --> %f"%(step/(L/100), mse_loss_val))
			# 首先是训练集中的测试
			acc = sess.run(accuracy, feed_dict={x_: batch[0], y_: batch[1], keep_prob_: 1.0})
			print("acc_in_train = %.2f"%(acc))
			
			# 统计各个样本的正确性
			correct = sess.run(correct_prediction, feed_dict={x_: batch[0], y_: batch[1], keep_prob_: 1.0})
			# 还应该统计TP/FP数据
			y_val = sess.run(y, feed_dict={x_: batch[0], y_: batch[1], keep_prob_: 1.0})
			y_label = np.argmax(y_val, axis=1)
			#print(y_label)
			for s in range(0, len(total_name)):
				tp = (y_label[label_val_y==s]==s)	# true positive
				tn = (y_label[label_val_y!=s]!=s)	# true negative
				fp = (y_label[label_val_y!=s]==s)	# false positive
				fn = (y_label[label_val_y==s]!=s)	# false negative
				# 样本名称
				if total_name[s]=="single_waving":
					label_name = "waving"
				else:
					label_name = total_name[s]
				print("[%s] ==> \ttp_rate = %.2f, fp_rate = %.2f, precision = %.2f, recall = %.2f"
						%(label_name, 		np.sum(tp)*1.0/(np.sum(tp)+np.sum(fn) + 0.0001),
											np.sum(fp)*1.0/(np.sum(fp)+np.sum(tn) + 0.0001),
											np.sum(tp)*1.0/(np.sum(tp)+np.sum(fp) + 0.0001),
											np.sum(tp)*1.0/(np.sum(tp)+np.sum(fn) + 0.0001)))
			# do update data in plotting
			rs = sess.run(merged, feed_dict={x_: batch[0], y_: batch[1], keep_prob_: 1.0})
			writer.add_summary(rs, step)
