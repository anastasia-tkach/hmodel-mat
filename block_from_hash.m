function [block] = block_from_hash(w)

C = 50;
block = [];
negative = false;
if w < 0, 
    negative = true;
    w = abs(w);
end

while w > 0
    u = rem(w, C);
    w = (w - u) / C;
    block(end + 1) = u + 1;
    if negative, block(end) = -block(end); end
end