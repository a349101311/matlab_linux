function PARA = auto_para(K,psf_s,b,des,tol,precS,use_gpu)
%% Debug options
%%
PARA = [];
PARA.verbose = 'all'; % control whether to print
PARA.K=K;    
PARA.psf_s = psf_s; %11
PARA.psf_radius = floor( PARA.psf_s/2 );
PARA.tol = tol;
lambda_residual = 1.0; % fixed
lambda_l1 = 1;
%%
PARA.lambda = [lambda_residual, lambda_l1];
PARA.max_it = 100;
PARA.max_it_d = 200;
PARA.max_it_z = 200;
PARA.n =1;%��Ӧ���ǻҶ�ͼ����ͨ������˼
PARA.N = size(b,3); %ͼƬ����
PARA.size_x = [size(b,1) + 2*PARA.psf_radius, size(b,2) + 2*PARA.psf_radius,PARA.n]; %110*110*1  �����ͼƬ�Ĵ�С
PARA.size_z = [PARA.size_x(1), PARA.size_x(2), PARA.K,PARA.n]; %110*110*100*1
PARA.size_k = [2*PARA.psf_radius + 1, 2*PARA.psf_radius + 1,PARA.K]; %����˵Ĵ�С11*11*100
PARA.size_k_full = [PARA.size_x(1), PARA.size_x(2), PARA.K]; %����ľ���˴�С110*110*100
PARA.kernel_size = [PARA.psf_s, PARA.psf_s,PARA.K];
%% 
mul_heur = 50;%%%%%
gamma_heuristic = mul_heur* 1/max(b(:));
PARA.rho_D = 100;%Ϊʲô������ʼ��d��z�Ķ�ż����
PARA.rho_Z = 50;
%%
PARA.precS = precS;
PARA.gpu = use_gpu;
PARA.AutoRho = 1;
PARA.RhoRsdlRatio = 5;
PARA.RhoScaling = 1.5;
PARA.AutoRhoPeriod = 10;

PARA.AutoRhod = 1;
PARA.RhodRsdlRatio = 5;
PARA.RhodScaling = 1.5;
PARA.AutoRhodPeriod = 10;
end