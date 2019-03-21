function [d,d_hat,s,y,para]=updateD_ocsc(para,Ahis,Bhis,s,y,d_hat,s_i)
% admm: d,s, dual y (unscaled)
Rho_D = [];
if isempty(s)||isempty(y)
    if para.gpu==1
        if (para.precS ==1)
            s = zeros(para.size_k_full(1),para.size_k_full(2),para.K,'single','gpuArray');
        else
            s = zeros(para.size_k_full(1),para.size_k_full(2),para.K,'gpuArray'); 
        end
    else
        s = zeros(para.size_k_full(1),para.size_k_full(2),para.K);
        if (para.precS ==1)
           s=single(s);
        end
    end
    y=s;
end
s_hat = fft2(s);
y_hat = fft2(y);
%%
d_length = para.size_k_full(1)*para.size_k_full(2)*para.K;

for i_d = 1:para.max_it_d
    d_hat = solve_conv_term_D(s_hat,y_hat,Ahis,Bhis, para,para.rho_D);
    d = real(ifft2( d_hat ));
    sold =s;
    s = prox_ind( d + y/para.rho_D,para);
    s_hat = fft2(s);
    y = y + para.rho_D* (d - s);
    y_hat = fft2(y);
    % stopping criteria
    ABSTOL = 1e-4;
    RELTOL = 1e-4; 
    h.r_norm(i_d) = norm(d(:)-s(:));
    h.s_norm(i_d) = norm(-para.rho_D*(s(:)-sold(:)));      
    h.eps_pri(i_d)=sqrt(d_length)*ABSTOL+RELTOL*max(norm(d(:)),norm(s(:)));
    h.eps_dual(i_d)=sqrt(d_length)*ABSTOL+RELTOL*norm(y(:));
    if para.AutoRhod,
        if i_d ~= 1 && mod(i_d,para.AutoRhodPeriod) == 0,
            rsf = 1;
            if h.r_norm(i_d) > para.RhodRsdlRatio * h.s_norm(i_d), rsf = para.RhodScaling; end
            if h.s_norm(i_d) > para.RhodRsdlRatio * h.r_norm(i_d), rsf = 1 / para.RhodScaling; end
            para.rho_D = para.rho_D * rsf;
        end
    end
    r1 = h.r_norm(i_d) < h.eps_pri(i_d);
    s1 = h.s_norm(i_d) < h.eps_dual(i_d);
    Rho_D(i_d) = para.rho_D;
    %fprintf('r %3.3g s %3.3g rho_d %3.3g epri %3.3g edua %3.3g \n' , h.r_norm(i_d) , h.s_norm(i_d) , para.rho_D,h.eps_pri(i_d),h.eps_dual(i_d))
    if  r1 && s1
       break;
    end   
end
clf
x = 1 : i_d; 
Y = h.r_norm;
subplot(3,1,1) 
plot(x,Y)
title('rd')
xlabel('iterations')
ylabel('rd')
Y = h.s_norm;
subplot(3,1,2) 
plot(x,Y)
title('sd')
xlabel('iterations')
ylabel('sd')
Y = Rho_D;
subplot(3,1,3) 
plot(x,Y)
title('rho_D')
xlabel('iterations')
ylabel('rho_D')
Frame = getframe(figure(1));
imwrite(Frame.cdata,['/home/zhangqi/newOCSC/matlab_linux/OCSC-master/graph/','6/','graph_D',int2str(s_i),'.jpg']);
end
%%
function dd_hat = solve_conv_term_D(ss_hat, yy_hat, Ahi,Bhi, par,rho_D)
    sy = par.size_z(1); sx = par.size_z(2); k = par.size_z(3);
    left = Bhi+permute( reshape(rho_D * ss_hat-yy_hat, sx * sy, 1, k), [3,2,1] );
    clear Bhi ss_hat yy_hat
    if par.gpu==1
        x2 = pagefun(@mtimes,Ahi,left);
    else
%         for i = 1:size(Ahi,3)
%             x2(:,:,i) = Ahi(:,:,i)*left(:,:,i);
%         end
        x2 = MultiplyOfMatrix(Ahi,left);
    end
    clear Ahi
    dd_hat = reshape(permute(x2,[3,1,2]),sy,sx,[]);
end