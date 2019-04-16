function [x,para] = SUREShrink(v , para)

v_Sure = sort(abs(v(:)));
v_len = length(v_Sure);

SURE1 = inf;
v_Sure_squ = v_Sure.^2;
SSV_Sure = sum(v_Sure_squ);
tt = 0;
for i = 1 : round(v_len / 100) : v_len
    ts = v_Sure_squ(i);
    SSV_Sure = SSV_Sure - ts;
    SURE = v_len - 2 * i + (i * ts) + SSV_Sure;
    if(SURE <= 0 )
        break;
    end
    if(SURE < SURE1)
        SURE1 = SURE;
        tt = ts;
    end
    
end
x = v_Sure(ceil(v_len / 2));
beta = sqrt(tt) * x;

s = sign(v);
v = abs(v);
x = max(0,v - beta) .* s;
num = 0;
x_flat = x(:);
for i = 1 : v_len
    if(x_flat(i) == 0)
        num = num + 1;
    end
end
disp(num / v_len);

end

