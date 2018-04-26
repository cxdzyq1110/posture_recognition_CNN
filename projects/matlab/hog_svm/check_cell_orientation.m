A = imread('test.png');
img = imresize(A, [600, 800]);% 转成灰度图
img_y = uint8(66.0*double(img(:, :, 1))/256 + 129.0*double(img(:, :, 2))/256 + 25.0*double(img(:, :, 3))/256 + 16);
% clc; clear all;
%% matlab的HOG运算结果
CellSize = [10, 10]; BlockSize = [2, 2]; NumBins = 9;
[hog_feature, visual] = extractHOGFeatures(img, 'CellSize', CellSize, 'BlockSize', BlockSize, 'BlockOverlap', BlockSize-1, 'NumBins', NumBins);
my_hsg_feature = my_extractHOGFeatures(img, CellSize, BlockSize, BlockSize-1, NumBins);
% 改成HSG
hog_feature = hog_feature';
for t=1:floor(size(hog_feature, 1)/NumBins)
    hog_feature(NumBins*(t-1)+1:NumBins*t, 1) = sign(hog_feature(NumBins*(t-1)+1:NumBins*t, 1)-sum(hog_feature(NumBins*(t-1)+1:NumBins*t), 1)/(2^floor(log2(NumBins)))) / 2 + 1/2;
end
figure;  title('matlab cell hog');
imshow(img_y); hold on; plot(visual);
%%
figure;
MS_cell = load('../../hog_svm_fpga/05_modelsim/hog_svm_result.txt');
MS_HSG = MS_cell./repmat(sqrt(sum((MS_cell.^2)')'), 1, size(MS_cell, 2));%MS_cell>repmat(sum(MS_cell')'/8, 1, size(MS_cell, 2));
%%
imshow(img_y); hold on; axis on; xlabel('column'); ylabel('row'); title('my modelsim cell hog');
for r=1:60
    for c=1:80
        for ch=1:9
            ori_x = 5+10*(c-1);
            ori_y = 5+10*(r-1);
            dx = 5*MS_HSG(80*(r-1)+c, ch)*cos((20*(ch-1)+10)/180*pi);
            dy = 5*MS_HSG(80*(r-1)+c, ch)*sin((20*(ch-1)+10)/180*pi);
            line([ori_x, ori_x+dx], [ori_y, (ori_y + dy)], 'Color','white', 'LineWidth', 1);
        end
    end
end
%% 自己来统计cell里面的HOG
figure;
imshow(img_y); hold on; axis on; xlabel('column'); ylabel('row'); title('my matlab cell hog');
Iy = conv2([zeros(1, size(img_y, 2)); img_y], [1, -1]', 'valid');
Ix = conv2([zeros(size(img_y, 1), 1), img_y], [1, -1], 'valid');
Mxy = sqrt(Ix.^2+Iy.^2);
Oxy = atan2(Ix, Iy); 
Txy = Oxy/pi*2^31;
Oxy(find(Oxy<0)) = Oxy(find(Oxy<0)) + pi; 
Bxy = ceil(Oxy/pi*180/20);
%%
MS_HOG = zeros(4800, 9);
MB_Cell = zeros(4800, 9);
for r=1:60
    for c=1:80
        Mxy_cell = Mxy(10*(r-1)+1:10*r, 10*(c-1)+1:10*c);
        Bxy_cell = Bxy(10*(r-1)+1:10*r, 10*(c-1)+1:10*c);
        for ch=1:9
            MS_HOG(80*(r-1)+c, ch) = sum(Mxy_cell(find(Bxy_cell==ch)));
            MB_Cell(80*(r-1)+c, ch) = MS_HOG(80*(r-1)+c, ch);
        end
        MS_HOG(80*(r-1)+c, :) = MS_HOG(80*(r-1)+c, :)/norm(MS_HOG(80*(r-1)+c, :));
        for ch=1:9
            ori_x = 5+10*(c-1);
            ori_y = 5+10*(r-1);
            dx = 5*MS_HOG(80*(r-1)+c, ch)*cos((20*(ch-1)+10)/180*pi);
            dy = 5*MS_HOG(80*(r-1)+c, ch)*sin((20*(ch-1)+10)/180*pi);
            line([ori_x, ori_x+dx], [ori_y, (ori_y + dy)], 'Color','white', 'LineWidth', 1);
        end
    end
end