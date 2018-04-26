function check_picture_pedestrian(image, SVMModel, R, C, dR, dC, CellSize, BlockSize, NumBins)
    
% 滑动窗口
    for i=1:dR:size(image, 1)-R+1
        for j=1:dC:size(image, 2)-C+1
            detect_img = image(i:i+R-1, j:j+C-1);
            % 自己的
            my_hsg_feature = my_extractHOGFeatures(detect_img, CellSize, BlockSize, BlockSize-1, NumBins);
            % SVM 预测
            [pred_label, pred_score] = predict(SVMModel, my_hsg_feature');
            % 如果检测到行人，就要打框
            if(pred_label==1 && pred_score(1)<-1)
                rectangle('Position', [j, i, C, R], 'EdgeColor','r', 'LineWidth',3);
                % 然后给出score
                text(j, i, [num2str(j), ',', num2str(i), ',', num2str(pred_score(1))]);
            end
        end
    end
end