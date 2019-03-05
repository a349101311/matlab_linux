function [C] = MuitiplyOfMatrix(A,B)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
dims = size(A,3);
C = zeros(size(A,1),size(B,2),dims);
for ii = 1 : dims
    C(:,:,ii) = A(:,:,ii) * B(:,:,ii);
end
end 

