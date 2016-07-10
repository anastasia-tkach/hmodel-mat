function [F,J] = myfun(x)

n = 10;
k = 1:n;
F = 2 + 2*k-exp(k*x(1))-exp(k*x(2));
F = F';
J = zeros(n, 2);
J(k,1) = -k.*exp(k*x(1));
J(k,2) = -k.*exp(k*x(2));

