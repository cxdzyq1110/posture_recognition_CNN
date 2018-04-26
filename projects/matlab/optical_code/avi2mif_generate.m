clc; clear all;
%% 先添加路径
file_dir = '../video/';
filename = [file_dir, 'yibu/input.mp4'];
%% 打开文件
readerobj = VideoReader(filename);
PixelCnt = readerobj.FrameRate * readerobj.Duration*readerobj.Height*readerobj.Width;
fp = fopen('../video/source_rgb565.list', 'w');
for frame=1:20
    fprintf(fp, '@%X\n', 2^21*(frame-1));
    pic = double(read(readerobj, frame));
    source = floor(floor(pic(:,:,1)/8)*2^11 + floor(pic(:,:,2)/4)*2^5 + floor(pic(:,:,3)/8));
    for i=1:size(source, 1)
        for j=1:size(source, 2)
            fprintf(fp, '%04X\n', source(i,j));
        end
    end
end
fclose(fp);