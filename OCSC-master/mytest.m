clear
dbstop if error
addpath('basic_tool'); 
addpath('OCSC');
addpath('mtimesx');%**
%% set para
K = [100];  %����˵ĸ���
psf_s=11;   %����˴�С                                                                                       
psf_radius = floor( psf_s/2 ); %���뾶
precS = 1; %�Ƿ�Ϊ����������
use_gpu = 1;%�Ƿ�ʹ��GPU
data = 'city_10';
data = 'fruit_10';
%% load data
load (sprintf('datasets/%s/train/train_lcne.mat',data)) %%% sprintf����ʽ������ת���ַ���
padB = padarray(b, [psf_radius, psf_radius, 0], 0, 'both'); %�������������뾶��0
PARA= auto_para(K,psf_s,b,'no',1e-3,precS,use_gpu);
%% run
t1 = tic;
[ d,d_hat]  = alt_min_online(padB,PARA,[],b);
tt = toc(t1);