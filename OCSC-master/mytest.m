clear
dbstop if error
addpath('basic_tool'); 
addpath('OCSC');
addpath('mtimesx');%**
%% set para
K = [100];  %卷积核的个数
psf_s=11;   %卷积核大小                                                                                       
psf_radius = floor( psf_s/2 ); %填充半径
precS = 1; %是否为单精度数组
use_gpu = 1;%是否使用GPU
data = 'city_10';
data = 'fruit_10';
%% load data
load (sprintf('datasets/%s/train/train_lcne.mat',data)) %%% sprintf将格式化数据转成字符串
padB = padarray(b, [psf_radius, psf_radius, 0], 0, 'both'); %将数组四周填充半径个0
PARA= auto_para(K,psf_s,b,'no',1e-3,precS,use_gpu);
%% run
t1 = tic;
[ d,d_hat]  = alt_min_online(padB,PARA,[],b);
tt = toc(t1);