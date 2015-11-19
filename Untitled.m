
clear;
p = [4; 4; 4; 4; 3; 3; 3; 2; 2; 1; 1; 1];
p = p / sum(p);

r = 0;
for i = 1:length(p)
    r = r + p (i) * log2(1/p(i));
end

a = 4 * 4 / 32 * log2(32/4);
b =  3 * 3 / 32 * log2(32/3);
c = 2 * 2/ 32 * log2(32/2);
d = 3 * 1/32 * log2(32);