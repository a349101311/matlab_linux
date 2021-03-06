function [z,z_hat,para]=updateZ_ocsc(x_hat,para,d_hat,var,s_i,data,train_number)
%x_hat ͼ��  para ���� d_hat�˲�����ȫ)��Ԥ����õ��Ľ��
% admm: z, t, u (unscaled)
obj=[];
rZ = [];
sZ = [];
Rho_Z = [200];
objective = @(z_hat) objective_online(z_hat,d_hat, x_hat,para );
if para.gpu==1
    if (para.precS ==1)
        z = randn(para.size_z,'single','gpuArray'); %ִ������
        t = zeros(para.size_z,'single','gpuArray'); %ִ������ ���� ����������
    else
        z = randn(para.size_z,'gpuArray');
        t = zeros(para.size_z,'gpuArray'); 
    end
else
    z = randn(para.size_z) * 10;
    t = zeros(para.size_z);
    if (para.precS ==1)
       t=single(t);
       z = single(z);
    end
end
u = t;
z_hat = fft2(z);
t_hat =t;
u_hat = fft2(u);
%pre-stat for solve_conv_term_Z
xhat_flat = reshape(x_hat,1,[]);
PRE = [];
PRE.b = var.dhatT_flat.*xhat_flat;
z_length = para.size_z(1)*para.size_z(2)*para.K;
if strcmp(para.verbose, 'anner') || strcmp( para.verbose, 'all')
    h.optval(1) = objective(z_hat);
    fprintf('start update Z \n--> Obj %3.3g \n',h.optval(1))
end
i = 0;

for i_z = 1:para.max_it_z
    PRE.sc = 1./(para.rho_Z + var.dhatTdhat_flat'); %methoned rho 
    z_hat = solve_conv_term_Z(var.dhatT_flat,t_hat, u_hat, para,para.rho_Z,PRE);%%%%%
    z = real(ifft2( z_hat));
    told = t;
    t = prox_l1( z+u/para.rho_Z, para.lambda(2) / para.rho_Z);
    % modify SUREShrink
    %[t,para] = prox_l1_SUREShrink(z + u / para.rho_Z,para);
    t_hat = fft2(t);
    u = u+para.rho_Z*(z-t);
    u_hat = fft2(u);
    h.optval(i_z+1) = objective(z_hat);
    % stopping criteria 
    ABSTOL = 1e-3;
    RELTOL = 1e-3;
    %REL
%      h.r_norm(i_z) = norm(z(:)-t(:)) / max(norm(z(:)),norm(t(:)));
%      h.s_norm(i_z) = norm((t(:)-told(:))) / norm(u(:)); 
%      h.eps_pri(i_z)=sqrt(z_length) * ABSTOL / max(norm(z(:)),norm(t(:))) + RELTOL;
%      h.eps_dual(i_z)=sqrt(z_length) * ABSTOL / (para.rho_Z * norm(u(:))) + RELTOL;
    

    %ABS
     h.r_norm(i_z) = norm(z(:) - t(:));
     h.s_norm(i_z) = norm(-para.rho_Z * (t(:) - told(:)));
     h.eps_pri(i_z) = sqrt(z_length) * ABSTOL + RELTOL * max(norm(z(:)) , norm(t(:)));
     h.eps_dual(i_z) = sqrt(z_length) * ABSTOL + RELTOL * norm(u(:));
    if para.AutoRho,
        if i_z ~= 1 && mod(i_z,para.AutoRhoPeriod) == 0,
            rsf = 1;
            if h.r_norm(i_z) > para.RhoRsdlRatio * h.s_norm(i_z), rsf = para.RhoScaling; end
            if h.s_norm(i_z) > para.RhoRsdlRatio * h.r_norm(i_z), rsf = 1 / para.RhoScaling; end
            para.rho_Z = para.rho_Z * rsf;
        end
    end
    if strcmp(para.verbose, 'anner') || strcmp( para.verbose, 'all')        
        %fprintf('-->inner iter_Z %d, Obj %3.3g rho_z %3.3g rz %3.3g sz %3.3g epri %3.3g edua %3.3g beta %3.3g\n', i_z, h.optval(i_z+1),para.rho_Z,h.r_norm(i_z),h.s_norm(i_z),h.eps_pri(i_z), h.eps_dual(i_z) , para.lambda(2))
    end
    
    r1 = h.r_norm(i_z) < h.eps_pri(i_z);
    s1 = h.s_norm(i_z) < h.eps_dual(i_z);
    Rho_Z(i_z) = para.rho_Z;
    if (r1 && s1)
        break;
    end  
end  
clf
figure(1)
x = 1 : (i_z + 1); 
y = h.optval;
subplot(4,1,1) 
plot(x,y)
title('obj')
xlabel('iterations')
ylabel('obj value')
x = 1 : i_z; 
y = h.r_norm;
subplot(4,1,2) 
plot(x,y)
title('rz')
xlabel('iterations')
ylabel('rz')
y = h.s_norm;
subplot(4,1,3) 
plot(x,y)
title('sz')
xlabel('iterations')
ylabel('sz')
y = Rho_Z;
subplot(4,1,4) 
plot(x,y)
title('rho_Z')
xlabel('iterations')
ylabel('rho_Z')
Frame = getframe(figure(1));
path = sprintf('/home/zhangqi/newOCSC/matlab_linux/OCSC-master/graph/%s/%d/',data,train_number);
if exist(path,'dir')==0
    mkdir(path);
end
imwrite(Frame.cdata,[path,'graphZ',int2str(s_i),'.jpg']);
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function zz_hat = solve_conv_term_Z( dhatT, tt_hat, uu_hat, par,rho_Z,pre)
sy = par.size_z(1); sx = par.size_z(2);
b = pre.b+permute(reshape(rho_Z*tt_hat - uu_hat,sy*sx,[]),[2,1]);
clear tt_hat uu_hat
sc = pre.sc.* sum(conj(dhatT).*b, 1);
sc = dhatT.*sc;
zz_hat = reshape(permute(1/rho_Z *(b-sc), [2,1]), par.size_z);
end