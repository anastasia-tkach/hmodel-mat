function [centers] = pose_hand_model(theta, dofs, phalanges, centers, names_map, mean_centers)

for i = 1:length(phalanges), phalanges{i}.local = phalanges{i}.init_local; end
phalanges = htrack_move(theta, dofs, phalanges);
centers = update_centers(centers, phalanges, names_map);
for i = 1:length(centers), centers{i} = centers{i} - mean_centers; end