%% 比对verilog的行人检测是否正确

%% 从modelsim里面仿真出来的灰度图
file_dir = '../../hog_svm_fpga/05_modelsim/';
filename = [file_dir, 'yuv_result.txt'];
H = 600; W = 800;
fp = fopen(filename, 'r');
x = zeros(H*W, 1);
for n=1:H*W
    num_str = fgetl(fp);
    if(size(str2num(num_str), 1)>0)
        x(n, 1) = str2num(num_str);
    end
end
fclose(fp);
%%
x = imresize(reshape(x', [W, H])', [H, W]);
img_y = uint8(x);
R = 140; C = 80;
figure; hold on; title('check pedestrian detection < sim in verilog >');
imshow(img_y); axis on; xlim([0, W]); ylim([0, H]);
%% 然后获取verilog的检测结果
file_dir = '../../hog_svm_fpga/05_modelsim/';
filename = [file_dir, 'my_pd_result.txt'];
fp = fopen(filename, 'r');
while(~feof(fp))
    str = fgetl(fp);
    % 分割
    str_cut = regexp(str, '[==>]', 'split');
    if(size(str_cut, 2)~=7)
        break;
    else
        pos_str = str_cut{1, 4};
        pos_str_cut = regexp(pos_str, '[\[]', 'split');
        pos_str_cut = regexp(pos_str_cut{1, 2}, '[\]]', 'split');
        pos_str_cut = regexp(pos_str_cut{1, 1}, '[,]', 'split');
        pos_x = str2num(pos_str_cut{1,1}); pos_y = str2num(pos_str_cut{1,2});
        
        scale_str = str_cut{1, 1};
        scale_cut = regexp(scale_str, '[\/]', 'split');
        scale = str2num(scale_cut{1,2});
        
        prob_str = str_cut{1, 7};
        prob = str2num(prob_str);
        
        % 只看1/4的
        SCALE = 256;
        if scale==4 && prob>4*SCALE
            rectangle('Position', [pos_x, pos_y, 4*C, 4*R], 'EdgeColor','r', 'LineWidth',floor(prob/(4*SCALE)));
            text(pos_x, pos_y, [num2str(prob)]);
        elseif scale==2 && prob>32*SCALE
            rectangle('Position', [pos_x, pos_y, 2*C, 2*R], 'EdgeColor','r', 'LineWidth',floor(prob/(32*SCALE)));
            text(pos_x, pos_y, [num2str(prob)]);
        elseif scale==1 && prob>256*SCALE
            rectangle('Position', [pos_x, pos_y, 1*C, 1*R], 'EdgeColor','r', 'LineWidth',floor(prob/(256*SCALE)));
            text(pos_x, pos_y, [num2str(prob)]);
        end
    end
end