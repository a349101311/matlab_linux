addpath('/home/zhangqi/newOCSC/matlab_linux/OCSC-master/basic_tool');
addpath('/home/zhangqi/newOCSC/matlab_linux/OCSC-master/3DMatrixMul');

K = [100];
psf_s=11;                                                                                                     
psf_radius = floor( psf_s/2 );
precS = 1;
use_gpu = 0;
data = 'city_10';
%% load data
load (sprintf('/home/zhangqi/newOCSC/matlab_linux/OCSC-master/datasets/%s/test/test_lcne.mat',data)) %%% 
padB = padarray(b, [psf_radius, psf_radius, 0], 0, 'both');
psnr = [4];
padB_hat = fft(padB);
for s_i = 1 : 4
    tmp_b = padB(:,:,s_i);
    tmp_b_hat = padB_hat(:,:,s_i);
    %precompute_H_hat_Z
    stat_Z = [];
    dhat_flat = reshape(d_hat,110 * 110,[]);
    stat_Z.dhatTdhat_flat = sum(conj(dhat_flat).*dhat_flat,2);
    stat_Z.dhatT_flat = conj(dhat_flat.');
   %update_Z_OCSC
    [z_si,z_hat_si] = updateZ_ocsc1(tmp_b_hat,PARA,d_hat,stat_Z);
    objZ = objective_online(z_hat_si,d_hat, tmp_b_hat,PARA);
    if strcmp( PARA.verbose, 'all')
       if (mod(s_i,1)==0)
            [ps] = eval_psnr(d_hat, z_hat_si,b(:,:,s_i),PARA,s_i); 
            psnr(s_i) = ps;
            fprintf('Z: no.img: %d, obj: %2.2f, psnr: %2.2f\n', s_i,objZ,ps)
        end 
    end
end
    