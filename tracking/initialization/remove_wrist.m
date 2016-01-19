function [blocks, named_blocks, names_map] = remove_wrist(semantics_path)

num_wrist_blocks = 3;
load([semantics_path, 'fitting/blocks.mat']);
load([semantics_path, 'fitting/names_map.mat']);
load([semantics_path, 'fitting/named_blocks.mat']);

blocks(end - num_wrist_blocks + 1:end) = [];
named_blocks(end - num_wrist_blocks + 1:end) = [];
wrist_blocks_names = {'wrist_top_left', 'wrist_top_right', 'wrist_bottom_left', 'wrist_bottom_right'};
remove(names_map, wrist_blocks_names);

% save([semantics_path, 'tracking/blocks.mat'], 'blocks');
% save([semantics_path, 'tracking/names_map.mat'], 'names_map');
% save([semantics_path, 'tracking/named_blocks.mat'], 'named_blocks');