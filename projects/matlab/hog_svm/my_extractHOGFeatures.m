function feature = my_extractHOGFeatures(picture, CellSize, BlockSize, BlockOverlap, NumBins)
    if(size(picture, 3)==3) 
        img_y = uint8(66.0*double(picture(:, :, 1))/256 + 129.0*double(picture(:, :, 2))/256 + 25.0*double(picture(:, :, 3))/256 + 16);
    else
        img_y = picture;
    end
    Iy = conv2([zeros(2, size(img_y, 2)); img_y], [1, 0, -1]', 'valid');
    Ix = conv2([zeros(size(img_y, 1), 2), img_y], [1, 0, -1], 'valid');
    Mxy = sqrt(Ix.^2+Iy.^2);
    Oxy = atan2(Ix, Iy); 
    Txy = Oxy/pi*2^31;
    Oxy(find(Oxy<0)) = Oxy(find(Oxy<0)) + pi; 
    Bxy = ceil(Oxy/pi*NumBins);
    % 然后构造Cell和Block
    MS_HOG = zeros(floor(size(picture, 1)/CellSize(1))*floor(size(picture, 2)/CellSize(2)), NumBins);
    MS_HSG = zeros(floor(size(picture, 1)/CellSize(1))*floor(size(picture, 2)/CellSize(2)), NumBins);
    MB_Cell = zeros(floor(size(picture, 1)/CellSize(1))*floor(size(picture, 2)/CellSize(2)), NumBins);
    for r=1:floor(size(picture, 1)/CellSize(1))
        for c=1:floor(size(picture, 2)/CellSize(2))
            Mxy_cell = Mxy(CellSize(1)*(r-1)+1:CellSize(1)*r, CellSize(2)*(c-1)+1:CellSize(2)*c);
            Bxy_cell = Bxy(CellSize(1)*(r-1)+1:CellSize(1)*r, CellSize(2)*(c-1)+1:CellSize(2)*c);
            for ch=1:NumBins
                MS_HOG(floor(size(picture, 2)/CellSize(2))*(r-1)+c, NumBins+1-ch) = sum(Mxy_cell(find(Bxy_cell==(ch))));
                MB_Cell(floor(size(picture, 2)/CellSize(2))*(r-1)+c, NumBins+1-ch) = MS_HOG(floor(size(picture, 2)/CellSize(2))*(r-1)+c, NumBins+1-ch);
            end
%             MS_HOG(floor(size(picture, 2)/CellSize(2))*(r-1)+c, :) = MS_HOG(floor(size(picture, 2)/CellSize(2))*(r-1)+c, :)/norm(MS_HOG(floor(size(picture, 2)/CellSize(2))*(r-1)+c, :));
            MS_HSG(floor(size(picture, 2)/CellSize(2))*(r-1)+c, :) = MS_HOG(floor(size(picture, 2)/CellSize(2))*(r-1)+c, :)>(sum(MS_HOG(floor(size(picture, 2)/CellSize(2))*(r-1)+c, :))/2^(floor(log2(NumBins))));
            
    %         for ch=1:9
    %             ori_x = 5+10*(c-1);
    %             ori_y = 5+10*(r-1);
    %             dx = 5*MS_HOG(80*(r-1)+c, ch)*cos((20*(9-ch)+10)/180*pi);
    %             dy = 5*MS_HOG(80*(r-1)+c, ch)*sin((20*(9-ch)+10)/180*pi);
    %             line([ori_x, ori_x+dx], [ori_y, (ori_y + dy)], 'Color','white', 'LineWidth', 1);
    %         end
        end
    end
    CellNum = [floor(size(picture, 1)/CellSize(1)), floor(size(picture, 2)/CellSize(2))];
    % 然后生成HSG-feature
    BlockStride = BlockSize - BlockOverlap;
    feature = zeros(floor((CellNum(1)-BlockSize(1)+1)/BlockStride(1))*...
                    floor((CellNum(2)-BlockSize(2)+1)/BlockStride(2))*...
                    BlockSize(1)*BlockSize(2)*NumBins, 1);
    for r=1:BlockStride(1):CellNum(1)-BlockSize(1)+1
        for c=1:BlockStride(2):CellNum(2)-BlockSize(2)+1
            for i=1:BlockSize(1)
                for j=1:BlockSize(2)
                    feature_idx = ((floor((CellNum(2)-BlockSize(2)+1)/BlockStride(2))*(r-1)+c-1)*BlockSize(1)*BlockSize(2) + (i-1)*BlockSize(2) + j-1)*NumBins+1;
                    cell_idx = CellNum(2)*(r-1+i-1)+c-1+j;
                    feature(feature_idx:feature_idx+NumBins-1) = MS_HSG(cell_idx, :);
                end
            end
                    
        end
    end
end