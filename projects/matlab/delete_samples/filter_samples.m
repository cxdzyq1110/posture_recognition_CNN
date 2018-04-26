function varargout = filter_samples(varargin)
% FILTER_SAMPLES MATLAB code for filter_samples.fig
%      FILTER_SAMPLES, by itself, creates a new FILTER_SAMPLES or raises the existing
%      singleton*.
%
%      H = FILTER_SAMPLES returns the handle to a new FILTER_SAMPLES or the handle to
%      the existing singleton*.
%
%      FILTER_SAMPLES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FILTER_SAMPLES.M with the given input arguments.
%
%      FILTER_SAMPLES('Property','Value',...) creates a new FILTER_SAMPLES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before filter_samples_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to filter_samples_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help filter_samples

% Last Modified by GUIDE v2.5 15-Apr-2018 09:09:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @filter_samples_OpeningFcn, ...
                   'gui_OutputFcn',  @filter_samples_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before filter_samples is made visible.
function filter_samples_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to filter_samples (see VARARGIN)

% Choose default command line output for filter_samples
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes filter_samples wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = filter_samples_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    addpath('../cnn');
    global sample_path; % 样本文件夹
    global trash_path;  % 垃圾文件夹
    global sample_class; % 样本类别
    global sample_class_struct; % 样本类别文件夹目录
    global sample_class_dir_path; % 某个类别样本的文件夹目录
    global sample_class_dir_struct; % 记录某个类型的样本文件加目录
    global sample_class_size;   % 样本中类别的总量
    global sample_serial_number;    % 某个类别的某个样本序号
    global sample_serial_size;  % 某个类别的所有样本容量
    global sample_spec_path; % 某个类别的某个样本序号对应的样本镜像文件
    % 然后检查是不是有断点数据
    if(exist('last_state.mat')~=0)
        load('last_state.mat');
        % 显示样本名称
        set(handles.text8, 'String', sample_class_struct(sample_class, 1).name);
    else
        % 首先设置好样本/垃圾的文件夹
        sample_path = '../cnn_samples';
        trash_path = '../cnn_samples_backup';
        % 首先打开样本文件夹
        dir_list = dir(sample_path);
        dir_list = dir_list(3:size(dir_list, 1), :);
        sample_class_struct = dir_list;
        sample_class_size = size(dir_list, 1);
        % 选择第一个样本文件夹
        sample_class = 1;
        sample_class_dir_path = [sample_path, '/', dir_list(sample_class, 1).name];
        display(sample_class_dir_path);
        % 显示样本名称
        set(handles.text8, 'String', dir_list(sample_class, 1).name);
        % 加载第一个样本
        sample_serial_number = 1;
        file_list = dir(sample_class_dir_path);
        file_list = file_list(3:size(file_list, 1), :);
        sample_class_dir_struct = file_list;
        sample_serial_size = size(file_list, 1);
        sample_spec_path = [sample_class_dir_path, '/', file_list(sample_serial_number, 1).name];
    end
    % 打断文件名
    S = regexp(sample_spec_path, '-', 'split');
    S = regexp(S{1,size(S,2)}, '[.]', 'split');
    if(strcmp(S{1,1}, 'optical'))
        S = sample_spec_path(1:size(sample_spec_path, 2)-11);
        % 加载样本
        filename = [S, 'video.ima'];
        img = read_ima_files(filename, 'video');
        filename = [S, 'optical.ima'];
        [ux, vy, mask] = read_ima_files(filename, 'optical');
        % 绘制出来
        axes(handles.axes1); image(img);
        axes(handles.axes2); image(mask*255);
        axes(handles.axes3); image(ux);
        axes(handles.axes4); image(vy);
    end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % 全局变量
    global sample_path; % 样本文件夹
    global trash_path;  % 垃圾文件夹
    global sample_class; % 样本类别
    global sample_class_dir_path; % 某个类别样本的文件夹目录
    global sample_class_dir_struct; % 记录某个类型的样本文件加目录
    global sample_serial_number;    % 某个类别的某个样本序号
    global sample_serial_size;  % 某个类别的所有样本容量
    global sample_spec_path; % 某个类别的某个样本序号对应的样本镜像文件
    % 要循环遍历
    keep_flag = 1;
    while(keep_flag==1 && sample_serial_number<sample_serial_size)
        % 加载下一个样本
        sample_serial_number = 1+sample_serial_number;
        file_list = sample_class_dir_struct;
        % 检查一下文件的大小，如果太小（8Byte）就说明没有样本在里面
        if(file_list(sample_serial_number, 1).bytes<12)
            continue;
        end
        sample_spec_path = [sample_class_dir_path, '/', file_list(sample_serial_number, 1).name];
        % 打断文件名
        S = regexp(sample_spec_path, '-', 'split');
        S = regexp(S{1,size(S,2)}, '[.]', 'split');
        if(strcmp(S{1,1}, 'optical'))
            S = sample_spec_path(1:size(sample_spec_path, 2)-11);
            % 加载样本
            filename = [S, 'video.ima'];
            img = read_ima_files(filename, 'video');
            filename = [S, 'optical.ima'];
            [ux, vy, mask] = read_ima_files(filename, 'optical');
            % 绘制出来
            axes(handles.axes1); image(img);
            axes(handles.axes2); image(mask*255);
            axes(handles.axes3); image(ux);
            axes(handles.axes4); image(vy);
            keep_flag = 0;
        end
    end
    
    if(sample_serial_number>=sample_serial_size)
        display('samples of this class already read...');
        display('please load next class...');
    end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % 这个操作的目的是要移除没用的样本，
    % 原理就是复制到垃圾文件夹中
    % 并且将当前文件的图像和光流数据置为0,0尺寸即可
    % 全局变量
    global sample_path; % 样本文件夹
    global trash_path;  % 垃圾文件夹
    global sample_class; % 样本类别
    global sample_class_dir_path; % 某个类别样本的文件夹目录
    global sample_class_dir_struct; % 记录某个类型的样本文件加目录
    global sample_serial_number;    % 某个类别的某个样本序号
    global sample_serial_size;  % 某个类别的所有样本容量
    global sample_spec_path; % 某个类别的某个样本序号对应的样本镜像文件
    % 打断文件名
    S = regexp(sample_spec_path, '-', 'split');
    S = regexp(S{1,size(S,2)}, '[.]', 'split');
    if(strcmp(S{1,1}, 'optical'))
        S = sample_spec_path(1:size(sample_spec_path, 2)-11);
        % 加载样本
        src_filename = [S, 'video.ima'];
        dst_filename = regexprep(src_filename, sample_path, trash_path);
        movefile(src_filename, dst_filename);
        src_filename = [S, 'optical.ima'];
        dst_filename = regexprep(src_filename, sample_path, trash_path);
        movefile(src_filename, dst_filename);
    end
    


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global sample_path; % 样本文件夹
    global trash_path;  % 垃圾文件夹
    global sample_class; % 样本类别
    global sample_class_dir_path; % 某个类别样本的文件夹目录
    global sample_class_dir_struct; % 记录某个类型的样本文件加目录
    global sample_class_size;   % 样本中类别的总量
    global sample_serial_number;    % 某个类别的某个样本序号
    global sample_serial_size;  % 某个类别的所有样本容量
    global sample_spec_path; % 某个类别的某个样本序号对应的样本镜像文件
    % 这里是加载下一个样本类型
    if(sample_class>=sample_class_size)
        display('samples done...');
    else
        sample_class = sample_class + 1;
        % 首先打开样本文件夹
        dir_list = dir(sample_path);
        dir_list = dir_list(3:size(dir_list, 1), :);
        sample_class_dir_path = [sample_path, '/', dir_list(sample_class, 1).name];
        display(sample_class_dir_path);
        % 显示样本名称
        set(handles.text8, 'String', dir_list(sample_class, 1).name);
        % 加载第一个样本
        sample_serial_number = 1;
        file_list = dir(sample_class_dir_path);
        file_list = file_list(3:size(file_list, 1), :);
        sample_class_dir_struct = file_list;
        sample_serial_size = size(file_list, 1);
        sample_spec_path = [sample_class_dir_path, '/', file_list(sample_serial_number, 1).name];
        % 打断文件名
        S = regexp(sample_spec_path, '-', 'split');
        S = regexp(S{1,size(S,2)}, '[.]', 'split');
        if(strcmp(S{1,1}, 'optical'))
            S = sample_spec_path(1:size(sample_spec_path, 2)-11);
            % 加载样本
            filename = [S, 'video.ima'];
            img = read_ima_files(filename, 'video');
            filename = [S, 'optical.ima'];
            [ux, vy, mask] = read_ima_files(filename, 'optical');
            % 绘制出来
            axes(handles.axes1); image(img);
            axes(handles.axes2); image(mask*255);
            axes(handles.axes3); image(ux);
            axes(handles.axes4); image(vy);
        end
    end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global sample_path; % 样本文件夹
    global trash_path;  % 垃圾文件夹
    global sample_class; % 样本类别
    global sample_class_struct; % 样本类别文件夹目录
    global sample_class_dir_path; % 某个类别样本的文件夹目录
    global sample_class_dir_struct; % 记录某个类型的样本文件加目录
    global sample_class_size;   % 样本中类别的总量
    global sample_serial_number;    % 某个类别的某个样本序号
    global sample_serial_size;  % 某个类别的所有样本容量
    global sample_spec_path; % 某个类别的某个样本序号对应的样本镜像文件
    save('./last_state.mat', 'sample_path', 'trash_path', 'sample_class', 'sample_class_struct', ...
        'sample_class_dir_path', 'sample_class_dir_struct', 'sample_class_size', 'sample_serial_number',...
        'sample_serial_size', 'sample_spec_path');
    close(gcf);
