N = frameCnt;
figure('units','inches');  hold on;
pos = get(gcf,'pos'); 
set(gcf,'pos',[pos(1)-6 pos(2)-3 12 6]);


t = 10;
% View results
% subplot(1,2,1); hold on; title('原始视频'); imshow(frame(:, :, t));
% subplot(1,2,2); hold on; title('BGS效果'); imshow(total_mask(:, :, t));
% subplot(1,2,2); hold on; title('GMM-BGS效果'); imshow(gmm_mask(:, :, t));
% subplot(1,2,2); hold on; title('光流法-BGS效果'); imshow(of_mask(:, :, t));
% subplot(1,2,2); hold on; title('ViBe-BGS效果'); imshow(vibe_mask(:, :, t));
% subplot(1,2,2); hold on; title('帧差-BGS效果'); imshow(fd_mask(:, :, t));

% weight = [0.3; 0.4; 0.3];
% vibe_fd_mask = uint8(255*round(weight(1)*im2double(gmm_mask) + weight(2)*im2double(vibe_mask) + weight(3)*im2double(fd_mask)));
% subplot(1,2,2); hold on; title('改进型帧差-GMM-ViBe效果'); imshow(vibe_fd_mask(:, :, t));
SE = strel('disk',1); 
subplot(1,5,1); hold on; title('原始视频'); imshow(frame(:, :, t),'InitialMagnification','fit');
% 单个BGS的效果
subplot(1,5,2); hold on; title('GMM-BGS效果'); imshow(imdilate(gmm_mask(:, :, t), SE),'InitialMagnification','fit');
subplot(1,5,3); hold on; title('ViBe-BGS效果'); imshow(imdilate(vibe_mask(:, :, t), SE),'InitialMagnification','fit');
subplot(1,5,4); hold on; title('帧差-BGS效果'); imshow(imdilate(fd_mask(:, :, t), SE),'InitialMagnification','fit');
subplot(1,5,5); hold on; title('光流法-BGS效果'); imshow(imdilate(of_mask(:, :, t), SE),'InitialMagnification','fit');
