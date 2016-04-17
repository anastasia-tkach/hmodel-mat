function [] = write_cpp_model(path, centers, radii, blocks, phalanges)
D = 3;
I = zeros(length(phalanges), 4 * 4);
for i = 1:length(phalanges)
    I(i, :) = phalanges{i}.local(:)';
end
I = I';
num_centers = 38;
num_blocks = 30;
RAND_MAX = 32767;
R = zeros(1, num_centers);
C = zeros(D, num_centers);
B = RAND_MAX * ones(3, num_blocks);

for j = 1:num_centers
    R(j) =  radii{j};
    C(:, j) = centers{j};
end
for j = 1:num_blocks
    for k = 1:length(blocks{j})
        B(k, j) = blocks{j}(k) - 1;
    end
end
write_input_parameters_to_files(path, C, R, B, I);
