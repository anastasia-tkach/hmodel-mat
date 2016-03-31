%% Load HModel
clc; close all; clear;
input_path = '_my_hand/final/';
semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);
load([semantics_path, 'fitting/blocks.mat'], 'blocks');
load([input_path, 'centers.mat'], 'centers');
load([input_path, 'radii.mat'], 'radii');
load([input_path, 'phalanges.mat'], 'phalanges');
load([input_path, 'dofs.mat'], 'dofs');

%% Load HTrack
num_thetas = 29;
num_phalanges = 16;
n = 20; m = 2; p = 6;

load Data;  Data = Data(:, p + 1:end);
% mu = mean(Data)';
% Data = bsxfun(@minus, Data, mu');  X = Data;
% Sigma = (X' * X) / size(X, 1); [U, S, V] = svd(Sigma); s = diag(S); s = diag(s(1:m));
% P = U(:, 1:m); Xp = P' * X';

scaling_factor = 0.811646;
[segments, joints, triangles] = htrack_parameters(scaling_factor);
for i = 1:length(phalanges)
    if i > num_phalanges, continue; end
    phalanges{i}.kinematic_chain = segments{i}.kinematic_chain;
end

%% Scale
scaling_factor =  0.7246;
for i = 1:length(centers)
    centers{i} = scaling_factor * centers{i};
    radii{i} = scaling_factor * radii{i};
end
for i = 1:num_phalanges
    phalanges{i}.local(1:3, 4) = scaling_factor * phalanges{i}.local(1:3, 4);
end

for i = 2:num_phalanges
    if isfield(phalanges{i}, 'rigid_names') &&  ~isempty(strfind(phalanges{i}.rigid_names{1}, 'top'))
        phalanges{i}.length = norm(centers{names_map(phalanges{i}.rigid_names{1})} - centers{names_map(phalanges{i}.name)});
    else
        child_id = phalanges{i}.children_ids(1);
        phalanges{i}.length = norm(phalanges{i}.global(1:3, 4) - phalanges{child_id}.global(1:3, 4));
    end
    phalanges{i}.length = phalanges{i}.length + randn;
end


%% Test with hmodel
%segments = htrack_move(theta, joints, phalanges);

