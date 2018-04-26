%% 用来生成modelsim仿真用的图片list文件
file_dir = '../../../ref_papers/inria/INRIAPerson/Test/pos'; % 图片所在的文件夹
%% 获取文件列表
file_list = dir(file_dir);
file_list = file_list(3:size(file_list, 1));
file_list = file_list(randperm(size(file_list, 1)));
%% 加载图像文件
img = imread([file_dir, '/', file_list(1, 1).name]);
img = imresize(img, [600, 800]); % 转换图像尺寸
fp = fopen('../picture/source_rgb565.list', 'w');
% 然后写入到文件中
img = double(img);
fp = fopen('../picture/source_rgb565.list', 'w');
fprintf(fp, '@%X\n', 0);
source = floor(floor(img(:,:,1)/8)*2^11 + floor(img(:,:,2)/4)*2^5 + floor(img(:,:,3)/8));
for i=1:size(source, 1)
    for j=1:size(source, 2)
        fprintf(fp, '%04X\n', source(i,j));
    end
end