%% 加载仿真的数据
A = imread('test.png');
img = imresize(A, [600, 800]);% 转成灰度图

%% 设置训练的参数
R = 150; C = 70;
CellSize = [10, 10]; BlockSize = [2, 2]; NumBins = 9;
NP = 2000; NN = 2000;
sR = 100; sC = 60;
dR = CellSize(1); dC = CellSize(2);
%% 转成灰度图
img_y = uint8(0.257*img(:, :, 1) + 0.504*img(:, :, 2) + 0.098*img(:, :, 3) + 16);
figure; hold on; imshow(img_y); 
%% 将检测的HSG特征打印到文件中去
fp = fopen('hsg_feature.txt', 'w');
%% 滑动窗口
for i=1:dR:size(img_y, 1)-R+1
    for j=1:dC:size(img_y, 2)-C+1
        detect_img = img_y(i:i+R-1, j:j+C-1);
        hog_feature(:,1) = extractHOGFeatures(detect_img, 'CellSize', CellSize, 'BlockSize', BlockSize, 'BlockOverlap', BlockSize-1, 'NumBins', NumBins);
        % 改成HSG
        for t=1:floor(size(hog_feature, 1)/NumBins)
            hog_feature(NumBins*(t-1)+1:NumBins*t, 1) = sign(hog_feature(NumBins*(t-1)+1:NumBins*t, 1)-sum(hog_feature(NumBins*(t-1)+1:NumBins*t), 1)/(2^floor(log2(NumBins)))) / 2 + 1/2;
        end
        % 自己的
        my_hsg_feature = my_extractHOGFeatures(detect_img, CellSize, BlockSize, BlockSize-1, NumBins);
        % 输出到文本文件中
        for t=1:4:size(my_hsg_feature, 1)
            fprintf(fp, '%01X', uint8(my_hsg_feature(t)*8+my_hsg_feature(t+1)*4+my_hsg_feature(t+2)*2+my_hsg_feature(t+3)*1));
        end
        % SVM 预测
%                     [pred_label, pred_score] = predict(SVMModel, hog_feature');
%         [pred_label, pred_score] = predict(SVMModel, my_hsg_feature');
%         % 如果检测到行人，就要打框
%         if(pred_label==1 && pred_score(1)<0)
%             rectangle('Position', [j, i, C, R], 'EdgeColor','r', 'LineWidth',3);
%             % 然后给出score
%             text(j, i, [num2str(j), ',', num2str(i), ',', num2str(pred_score(1))]);
%         end
    end
end
%%
fclose(fp);