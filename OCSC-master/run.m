clear
dbstop if error
addpath('basic_tool'); 
addpath('OCSC');
addpath('mtimesx');%**
addpath('3DMatrixMul');
%% set para
K = [100];
psf_s=11;                                                                                                     
psf_radius = floor( psf_s/2 );
precS = 1;
use_gpu = 0;
data = 'city_10';
%train_number = 1; % origin  noautorho all 1e-3
%train_number = 2; % Autorho all 1e-3 
%train_number = 3; %Autorho all 1e-3 L1 = 0.5
%train_number = 4; %Autorho all 1e-3 L1 = 0.1 
%train_number = 5; %bigger rho init L1 = 1
%train_number = 6;3 %Autorho rhoz = 2 rhod = 10 le-4 L1 = 1
%train_number = 7; %Autorho rho = gamma L1 = 0.1 1e-4
%train_number = 11; %origin no AutoRho all 1e-4
%train_number = 12; % AutoRho all 1e-4
%train_number = 20; % test SUREShrink
%train_number = 100; % rho = 500 1e-4
%train_number = 1000; % rho = gamma,1e-3,l1 = 0.1
%train_number = 10000; % rho_D = gamma,rho_Z = 0.01;le-3 L1 = 1
%train_number = 22; %AutorhoZ all 1e-3 L1 = 1
%train_number = 222; %AutorhoZ all Z1e-3 L1 = 1
%train_number = 23; %AutorhoD all 1e-3 L1 =1;
%train_number = 41 %AutoRhoZ all 1e-3 L1 = 0.1
%train_number = 42 %AutoRhoD all 1e-3 L1 = 0.1
%train_number = 43 % No Auto L1 = 0.1 ,rhoZ = 0.1
%train_number = 77; % autorhod z all 1e-4 L1 = 1 rels relr
%train_number = 777; % no autorhod z all 1e-4 L1 = 1 rels relr
%train_number = 7777; % autorhoz no autorhod all 1e-4 L1 = 1 rels relr
%train_number = 111; %origin le-3 L1 =1 reld relz
%train_stat_Z = [];
%train_number = 555; % L1 when L1 weight small , norm(z)  ABS REL TOL = 1e-4 ~ABS have auto
%train_number = 5555; % L1 when L1 weight = 1 , norm(z)  ABS REL TOL = 1e-4 ~ABS have auto
%train_number = 55555; % L1 when L1 weight = 1 , norm(z)  ABS REL TOL = 1e-4 ~ABS no auto
%train_number = 66; % SURE L1 init = 1 1e-4 autorho D Z
%train_number = 666; % SURE L1 init = 1 1e-5 autorho D Z
train_number = 12345; 
%% load datad3ata,train_number1
load (sprintf('datasets/%s/train/train_lcne.mat',data)) %%% 
padB = padarray(b, [psf_radius, psf_radius, 0], 0, 'both');
PARA= auto_para(K,psf_s,b,'no',1e-3,precS,use_gpu);
initPara = sprintf('rhoD:%.2f rhoZ:%.2f L1:%.2f rhoZRatio:%d rhoZScaling:%.2f rhoDRatio:%d rhoDScaling:%.2f max_it_z:%d max_it_d:%d',PARA.rho_D,PARA.rho_Z,PARA.lambda(2),PARA.RhoRsdlRatio,PARA.RhoScaling,PARA.RhodRsdlRatio,PARA.RhodScaling,PARA.max_it_z,PARA.max_it_d);
%% run
t1 = tic;
[ d,d_hat,psnr,PARA]  = alt_min_online(padB,PARA,[],b,train_number,data); 
tt = toc(t1);
%% save
repo_name = 'result';
repo_path = sprintf('%s/%s/%d',repo_name,data,train_number);
if exist(repo_path,'dir') == 0
    mkdir(repo_path);
end
save_name = sprintf('K%d_psf%d',K,psf_s);
save_me = sprintf('%s/record_%s.mat',repo_path,save_name);
save(save_me,'d_hat','d','tt','PARA','psnr','initPara');
fprintf('Done sparse coding learning! --> Time %2.2f sec.\n\n', tt)
%test