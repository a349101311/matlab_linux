function [PSNR] = eval_psnr(dd_hat,zz_hat, b, par,s_i)
%Dz = real(ifft2( reshape(sum(dd_hat.* zz_hat, 3), [par.size_x(1),par.size_x(2),size(b,3)]) ));
Dz = real(ifft2(sum(dd_hat.* zz_hat, 3)));
if size(par.psf_s,2) == 2   
    Dz = Dz(1 + par.psf_radius(1):size(Dz,1) - par.psf_radius(1),1 + par.psf_radius(2):size(Dz,2) - par.psf_radius(2),:); %% yf: correspond to circshift
else
    Dz = Dz(1 + par.psf_radius:end - par.psf_radius,1 + par.psf_radius:end - par.psf_radius,:); %% yf: correspond to circshift
end
% if par.gpu == 1
%     Dz = gather(Dz);
% end
% if par.precS == 1
%     Dz = double(Dz);
%     b = double(b);
% end
%PSNR0 = psnr(b, Dz); %%
clf
figure(3)
[PSNR,RMSE] = my_psnr(b,Dz);
subplot(1,2,1) , imshow(b);
subplot(1,2,2) , imshow(Dz);
title(sprintf('PSNR:%.2f',PSNR));
Frame = getframe(figure(3));
imwrite(Frame.cdata,['/home/zhangqi/newOCSC/matlab_linux/OCSC-master/compare/','/fruit/','/8/',int2str(s_i),'.jpg']);
end