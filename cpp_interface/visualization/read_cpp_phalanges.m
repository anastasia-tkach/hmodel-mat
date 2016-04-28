function [phalanges, dofs] = read_cpp_phalanges(path)

fileID = fopen([path, 'I.txt'], 'r');
I = fscanf(fileID, '%f');
I = I(2:end);
I = reshape(I, 16, length(I)/16)';
scaling_factor = 0.811646;
[phalanges, dofs] = hmodel_parameters();
for i = 1:size(I, 1)
    M = reshape(I(i, :), 4, 4)';
    phalanges{i}.init_local = M;
    phalanges{i}.init_local(1:3, 4) = scaling_factor * phalanges{i}.init_local(1:3, 4);
    phalanges{i}.local = phalanges{i}.init_local;
end
