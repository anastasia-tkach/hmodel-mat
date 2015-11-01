function [centers] = find_limited_positions(centers, index, rotations, edge_ids, restpose_edges, kinematic_chain)

if ~isempty(kinematic_chain{index}.parent_index)
    edge_id = edge_ids(kinematic_chain{index}.block_index);
    centers{index} = centers{kinematic_chain{index}.parent_index} + rotations{edge_id} * restpose_edges{edge_id};
end

for child_index = kinematic_chain{index}.children_indices
    centers = find_limited_positions(centers, child_index, rotations, edge_ids, restpose_edges, kinematic_chain);
end

