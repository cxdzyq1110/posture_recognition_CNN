clc; clear all;
x = load('rgb.txt');
%%
IMG = zeros(600, 800, 3);

for ch=1:3
	IMG(:,:,ch) = reshape(x(:,ch)', [800,600])';
end
%%
imshow(uint8(IMG));
imwrite(uint8(IMG), './image/tt.png');
% %%
% file_dir = './image';
% % file_dir = '../picture/test_hog_svm';
% R = 140; C = 80;
% CellSize = [10, 10]; BlockSize = [2, 2]; NumBins = 9;
% NP = 2000; NN = 10000;
% sR = 100; sC = 60;
% dR = CellSize(1)*4; dC = CellSize(2)*4; tR = 600; tC = 800;
% load('../../matlab/mat_files/SVMModel.mat');
% run_detection(file_dir, SVMModel, 1, R, C, dR, dC, tR, tC, CellSize, BlockSize, NumBins);