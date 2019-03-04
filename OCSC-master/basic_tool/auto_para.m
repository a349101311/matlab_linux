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
lambda_l1 = 1.0;
%%
PARA.lambda = [lambda_residual, lambda_l1];
PARA.max_it = 100;
PARA.max_it_d = 100;
PARA.max_it_z = 100;
PARA.n =1;%？应该是灰度图，单通道的意思
PARA.N = size(b,3); %图片数量
PARA.size_x = [size(b,1) + 2*PARA.psf_radius, size(b,2) + 2*PARA.psf_radius,PARA.n]; %110*110*1  填充后的图片的大小
PARA.size_z = [PARA.size_x(1), PARA.size_x(2), PARA.K,PARA.n]; %110*110*100*1
PARA.size_k = [2*PARA.psf_radius + 1, 2*PARA.psf_radius + 1,PARA.K]; %卷积核的大小11*11*100
PARA.size_k_full = [PARA.size_x(1), PARA.size_x(2), PARA.K]; %填充后的卷积核大小110*110*100
PARA.kernel_size = [PARA.psf_s, PARA.psf_s,PARA.K];
%% 
mul_heur = 50;%%%%%
gamma_heuristic = mul_heur* 1/max(b(:));
PARA.rho_D = gamma_heuristic;%为什么这样初始化d、z的对偶变量
PARA.rho_Z = gamma_heuristic;
%%
PARA.precS = precS;
PARA.gpu = use_gpu;
end