clc; clear all;
%% 先添加路径
file_dir = '../video/';
% filename = [file_dir, 'weizmann/run/daria_run.avi'];
filename = [file_dir, 'smardorn/input.avi'];
%% 然后训练光流法
[frame, frameCnt, u, v] = my_optical_flow(filename);
%% 超过均值的都打成255
of_mask(find(of_mask>mean(of_mask(of_mask>0)))) = 255;
%% 汇总
total_mask = of_mask;
%% 对BGS的结果做膨胀
SE = strel('disk',3); 
% 保存到avi文件
obj_gray = VideoWriter([filename, '.avi']);   %所转换成的视频名称
open(obj_gray);
for t=1:frameCnt
    [m, n] = size(total_mask(:, :, t)); L = 1;
    % 再搞个滤波
    H=fspecial('gaussian', 5, 5);
    total_mask(:, :, t) = imfilter(total_mask(:, :, t),H,'replicate');  
    % 膨胀
    total_mask_exp(:, :, t) = imdilate(total_mask(:, :, t), SE);
    writeVideo(obj_gray, total_mask_exp(:, :, t));
end
close(obj_gray);
%% 训练完成
disp('training complete!');
%% 绘制
N = frameCnt;
figure('units','inches');  hold on;
pos = get(gcf,'pos'); 
set(gcf,'pos',[pos(1)-6 pos(2)-3 12 6]);
for frameCnt=1:N
	% View results
	subplot(1,2,1); hold on; title('原始视频'); imshow(frame(:, :, frameCnt),'InitialMagnification','fit');
	subplot(1,2,2); hold on; title('光流法效果'); imshow(of_mask(:, :, frameCnt),'InitialMagnification','fit');
    pause(0.1);
end


