function [frame, frameCnt, hfg_mask] = train_of(filename, NoiseThreshold)
	%% 然后读取视频
	hsrc = vision.VideoFileReader(filename, ...
									'ImageColorSpace', 'RGB', ...
									'VideoOutputDataType', 'uint8');
    %% 光流法
     opticFlow = opticalFlowLK('NoiseThreshold',NoiseThreshold);
	%% 这里是视频处理的部分
	frameCnt = 1;
	while ~isDone(hsrc)
		% Read frame
        curr = step(hsrc);         % 原始帧?
        frame(:, :, frameCnt) = curr(:, :, 1);
        % 
        if frameCnt>1
            frame_2=im2double(frame(:, :, frameCnt));
            flow = estimateFlow(opticFlow,frame_2);
            opFlow = sqrt(flow.Vx.^2 + flow.Vy.^2);
            hfg_mask(:, :, frameCnt) = uint8(floor(opFlow/max(opFlow(:))*255));
        end
        prev = curr;
        % 递进
        frameCnt = frameCnt + 1;
	end
	frameCnt = frameCnt-1;
	
	%% 删除部件
	release(hsrc);

end