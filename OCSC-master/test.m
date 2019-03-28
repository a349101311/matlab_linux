load(sprintf('datasets/%s/test/test_lcne.mat',data))
load(sprintf('result/%s/%d/record_K100_psf11.mat',data,train_number))
addpath('basic_tool'); 
addpath('OCSC');
addpath('3DMatrixMul');
K = [100];
psf_s=11;                                                                                                     
psf_radius = floor( psf_s/2 );
precS = 1;
use_gpu = 0;
padB = padarray(b, [psf_radius, psf_radius, 0], 0, 'both');
psnr = [4];

%%alt_min_online
b_hat = fft2(padB);
for s_i = 1 : 4
    temp_b = b(:,:,s_i);
    temp_b_hat = b_hat(:,:,s_i);
    %pre_process Z
    [stat_Z] = precompute_H_hat_Z(d_hat,PARA);
    %updateZ_ocsc
    objective = @(z_hat) objective_online(z_hat,d_hat, temp_b_hat,PARA );
    z = randn(PARA.size_z) * 10;
    t = zeros(PARA.size_z);
    t = single(t);
    z = single(z);
    u = t;
    z_hat = fft2(z);
    t_hat = t;
    u_hat = fft2(u);
    bhat_flat = reshape(temp_b_hat,1,[]);
    PRE = [];
    PRE.b = stat_Z.dhatT_flat.*bhat_flat;
    PRE.sc = 1./(PARA.rho_Z + stat_Z.dhatTdhat_flat');
    z_length = PARA.size_z(1) * PARA.size_z(2)*PARA.K;
    h.optval(1) = objective(z_hat);
    fprintf('start update Z \n--> Obj %3.3g \n',h.optval(1))
    for i_z = 1:PARA.max_it_z
        z_hat = solve_conv_term_Z(stat_Z.dhatT_flat,t_hat, u_hat, PARA,PARA.rho_Z,PRE);%%%%%
        z = real(ifft2( z_hat));
        
        told = t;
        t = prox_l1(z+u/PARA.rho_Z,PARA.lambda(2)/PARA.rho_Z);
        t_hat = fft2(t);
        u = u + PARA.rho_Z*(z-t);
        u_hat = fft2(u);
        h.optval(i_z + 1) = objective(z_hat);
        %stop criteria
        ABSTOL = 1e-3;
        RELTOL = 1e-3;
        h.r_norm(i_z) = norm(z(:)-t(:));
        h.s_norm(i_z) = norm(-PARA.rho_Z*(t(:)-told(:)));
        h.eps_pri(i_z)=sqrt(z_length)*ABSTOL+RELTOL*max(norm(z(:)),norm(t(:)));
        h.eps_dual(i_z)=sqrt(z_length)*ABSTOL+RELTOL*norm(u(:)); 
        fprintf('-->inner iter_Z %d, Obj %3.3g rho_z %3.3g rz %3.3g sz %3.3g epri %3.3g edua %3.3g\n', i_z, h.optval(i_z+1),PARA.rho_Z,h.r_norm(i_z),h.s_norm(i_z),h.eps_pri(i_z), h.eps_dual(i_z))
        r1 = h.r_norm(i_z) < h.eps_pri(i_z);
        s1 = h.s_norm(i_z) < h.eps_dual(i_z);
        if r1 && s1
            break;
        end
    end
    objZ = objective_online(z_hat,d_hat,temp_b_hat,PARA);
    %compute psnr
    Dz = real(ifft2(sum(d_hat.* z_hat, 3)));
    Dz = Dz(1 + PARA.psf_radius:end - PARA.psf_radius,1 + PARA.psf_radius:end - PARA.psf_radius,:);
    it = size(Dz,1);
    tmp = norm(temp_b(:) - Dz(:));
    p = 20 * log10(it/tmp);
    rmse = sqrt(1 / length(temp_b(:)) * (tmp^2));
    psnr(s_i) = p;
    fprintf('Z: no.img: %d, obj: %2.2f, psnr: %2.2f\n', s_i,objZ,p)
    figure(10)
    subplot(1,2,1) , imshow(temp_b);
    subplot(1,2,2) , imshow(Dz);
    title(sprintf('PSNR:%.2f',p));
    Frame = getframe(figure(10));
    path = sprintf('/home/zhangqi/newOCSC/matlab_linux/OCSC-master/testCompare/%s/%d/',data,train_number);
    if ~exist(path,'dir') == 1
        mkdir(path);
    end
    imwrite(Frame.cdata,[path,'compare',int2str(s_i),'.jpg']);
    
end  
savepath = sprintf('%s/psnr',path);
save(savepath,'psnr');
function zz_hat = solve_conv_term_Z( dhatT, tt_hat, uu_hat, par,rho_Z,pre)
sy = par.size_z(1); sx = par.size_z(2);
b = pre.b+permute(reshape(rho_Z*tt_hat - uu_hat,sy*sx,[]),[2,1]);
clear tt_hat uu_hat
sc = pre.sc.* sum(conj(dhatT).*b, 1);
sc = dhatT.*sc;
zz_hat = reshape(permute(1/rho_Z *(b-sc), [2,1]), par.size_z);
end
    
    
    
    
    