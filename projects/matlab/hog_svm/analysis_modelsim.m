% clc; clear all;
%% 先添加路径
file_dir = '../../hog_svm_fpga/05_modelsim/';
filename = [file_dir, 'yuv_result.txt'];
%% 加载运算结果
H = 600; W = 800;
x = load(filename);
%% 变形
x = x(1:H*W);
x = reshape(x', [W, H])';
imshow(uint8(x));