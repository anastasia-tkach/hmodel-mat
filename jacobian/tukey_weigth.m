function w = tukey_weigth(u, b)
    w = zeros(size(u, 1), 1);
    idx = find(u <= b);
    w(idx) = (ones(size(idx)) - (u(idx)./b).^2).^2;
end