function run_detection(file_dir, SVMModel, N, R, C, dR, dC, tR, tC, CellSize, BlockSize, NumBins, ReSizeStride)
    file_list = dir(file_dir);
    file_list = file_list(3:size(file_list, 1));
    file_list = file_list(randperm(size(file_list, 1)));
%     figure; hold on;
    for n=1:N
        img = imread([file_dir, '/', file_list(n, 1).name]);
        imwrite(img, 'test.png');
        % 转换大小
        if tR~=-1 && tC~=-1
            img = imresize(img, [tR, tC]);
        end
        % 然后写入到文件中
        img = double(img);
        fp = fopen('../picture/source_rgb565.list', 'w');
        fprintf(fp, '@%X\n', 2^21*(n-1));
        source = floor(floor(img(:,:,1)/8)*2^11 + floor(img(:,:,2)/4)*2^5 + floor(img(:,:,3)/8));
        for i=1:size(source, 1)
            for j=1:size(source, 2)
                fprintf(fp, '%04X\n', source(i,j));
            end
        end
        
        % 转成灰度图
        img_y = uint8(0.257*img(:, :, 1) + 0.504*img(:, :, 2) + 0.098*img(:, :, 3) + 16);
        % 划分成3个尺度进行检索
        for k=1:3
            figure; hold on; imshow(img_y); axis on;
            fp2 = fopen(['feature-', num2str(k), '.txt'], 'w');
            % 滑动窗口
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
                    % SVM 预测
%                     [pred_label, pred_score] = predict(SVMModel, hog_feature');
                    [pred_label, pred_score] = predict(SVMModel, my_hsg_feature');
                    % 保存feature
                    for it=1:4:size(my_hsg_feature, 1)
                        data = my_hsg_feature(it, 1)*8+my_hsg_feature(it+1, 1)*4+my_hsg_feature(it+2, 1)*2+my_hsg_feature(it+3, 1)*1;
%                         fprintf(fp2, dec2hex(data));
                        fprintf(fp2, '%X', uint8(data));
                    end
                    fprintf(fp2, ', %f\n', floor(pred_score(2)*64));
                    % 如果检测到行人，就要打框
                    if(pred_label==1 && pred_score(1)<-0.5)
                        rectangle('Position', [j, i, C, R], 'EdgeColor','r', 'LineWidth',3);
                        % 然后给出score
                        text(j, i, [num2str(j), ',', num2str(i), ',', num2str(pred_score(1))]);
                    end
                end
            end
            fclose(fp2);
            % 缩小一个尺度
            img_y = imresize(img_y, floor(size(img_y)/2));
            if(ReSizeStride)
                dR = floor(dR/2);
                dC = floor(dC/2);
            end
        end
    end
end