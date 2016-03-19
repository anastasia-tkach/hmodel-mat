path = 'C:\Developer\hmodel-cuda-build\data\';
fileID = fopen([path, '_M1.txt'], 'r');
M = fscanf(fileID, '%f');
num = max(M);
J1 = zeros(num, 29);
I1 = zeros(num, 1);
M = reshape(M, 30, length(M)/30);
for i = 1:size(M, 2);    
    n = M(1, i);
    if n < 0
        continue;
    end
    J1(n, :) = M(2:end, i);
    I1(n) = 1;
end

fileID = fopen([path, '_M2.txt'], 'r');
M = fscanf(fileID, '%f');
num = max(M);
J2 = zeros(num, 29);
I2 = zeros(num, 1);
M = reshape(M, 30, length(M)/30);
for i = 1:size(M, 2);    
    n = M(1, i);
    if n < 0
        continue;
    end    
    J2(n, :) = M(2:end, i);
    I2(n) = 1;
end

Ij = find(sum(J1 ~= J2, 2))
J1(I1 == 0, :) = [];

J2(I1 == 0, :) = [];