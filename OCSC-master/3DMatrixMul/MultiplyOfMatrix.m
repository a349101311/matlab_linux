function [C] = MultiplyOfMatrix(A,B)
%UNTITLED �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
dims = size(A,3);
C = zeros(size(A,1),size(B,2),dims);
for ii = 1 : dims
    C(:,:,ii) = A(:,:,ii) * B(:,:,ii);
end
end 

