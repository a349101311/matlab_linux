function x = prox_l1(v, lambda)

s = sign(v);
v = abs(v);
x = max(0,v - lambda) .* s;
num = 0;
v_len = size(v(:),1);
x_flat = x(:);
for i = 1 : v_len
    if(x_flat(i) == 0)
        num = num + 1;
    end
end
%disp(num / v_len);
end