function [valid_update, poses, radii, change_indices] = apply_update(poses, blocks, radii, delta, D)

valid_update = false;
num_poses = length(poses);
num_centers = length(poses{1}.centers);
count = 0;
while (valid_update == false && count < 1)
    %% Update
    count = count + 1;
    [poses, new_radii] = update(poses, radii, delta, D);
    
    %% Verify blocks
    valid_update = true;
    change_indices = zeros(size(delta));
    
    %% Verify radii
    for o = 1:length(radii)
        if (new_radii{o} < 0)
            disp(['center ', num2str(o), ' - negative radius']);
            change_indices(D * num_poses * num_centers + o) = 1;
            valid_update = false;
        end
    end
    
    for p = 1:num_poses
        invalid_blocks = [];
        for b = 1:length(blocks)
            
            %% Verify tangent cone
            if length(blocks{b}) == 2
                c1 = poses{p}.new_centers{blocks{b}(1)};
                c2 = poses{p}.new_centers{blocks{b}(2)};
                r1 = new_radii{blocks{b}(1)};
                r2 = new_radii{blocks{b}(2)};
                
                [has_tangent_cone] = verify_tangent_cone(c1, c2, r1, r2);
                
                if (has_tangent_cone == false)
                    
                    disp(['pose ', num2str(p), ', block ', num2str(b), ' - no tangent cone']);
                    invalid_blocks = [invalid_blocks; b];                    
                    valid_update = false;
                    
                    shift = D * num_centers * (p - 1);
                    index_c1 = shift + D * blocks{b}(1) - D + 1:D * blocks{b}(1);
                    index_c2 = shift + D * blocks{b}(2) - D + 1:D * blocks{b}(2);
                    index_r1 = D * num_poses * num_centers + blocks{b}(1);
                    index_r2 = D * num_poses * num_centers + blocks{b}(2);
                    
                    change_indices(index_c1) = 1; change_indices(index_c2) = 1;
                    change_indices(index_r1) = 1; change_indices(index_r2) = 1;
                end
            end
            
            %% Verify tangent plane
            if length(blocks{b}) == 3
                c1 = poses{p}.new_centers{blocks{b}(1)};
                c2 = poses{p}.new_centers{blocks{b}(2)};
                c3 = poses{p}.new_centers{blocks{b}(3)};
                r1 = new_radii{blocks{b}(1)};
                r2 = new_radii{blocks{b}(2)};
                r3 = new_radii{blocks{b}(3)};
                
                has_tangent_plane1 = verify_tangent_plane(c1, c2, c3, r1, r2, r3);
                has_tangent_plane2 = verify_tangent_plane(c1, c3, c2, r1, r3, r2);
                has_tangent_plane3 = verify_tangent_plane(c2, c3, c1, r2, r3, r1);
                
                [has_tangent_cone1] = verify_tangent_cone(c1, c2, r1, r2);
                [has_tangent_cone2] = verify_tangent_cone(c2, c3, r2, r3);
                [has_tangent_cone3] = verify_tangent_cone(c1, c3, r1, r3);
                
                
                if has_tangent_plane1 == false || has_tangent_plane2 == false || has_tangent_plane3 == false || ...
                        has_tangent_cone1 == false || has_tangent_cone2 == false || has_tangent_cone3 == false
                    
                    if has_tangent_plane1 == false, disp(['pose ', num2str(p), ', block ', num2str(b), ' - no tangent plane for c1, c2, c3']); end
                    if has_tangent_plane2 == false, disp(['pose ', num2str(p), ', block ', num2str(b), ' - no tangent plane for c1, c3, c2']); end
                    if has_tangent_plane3 == false, disp(['pose ', num2str(p), ', block ', num2str(b), ' - no tangent plane for c2, c3, c1']); end
                    if has_tangent_cone1 == false, disp(['pose ', num2str(p), ', block ', num2str(b), ' - no tangent cone for c1, c2']); end
                    if has_tangent_cone2 == false, disp(['pose ', num2str(p), ', block ', num2str(b), ' - no tangent cone for c2, c3']); end
                    if has_tangent_cone3 == false, disp(['pose ', num2str(p), ', block ', num2str(b), ' - no tangent cone for c1, c3']); end
                    invalid_blocks = [invalid_blocks; b];      
                    
                    valid_update = false;
                    
                    shift = D * num_centers * (p - 1);
                    index_c1 = shift + D * blocks{b}(1) - D + 1:D * blocks{b}(1);
                    index_c2 = shift + D * blocks{b}(2) - D + 1:D * blocks{b}(2);
                    index_c3 = shift + D * blocks{b}(3) - D + 1:D * blocks{b}(3);
                    index_r1 = D * num_poses * num_centers + blocks{b}(1);
                    index_r2 = D * num_poses * num_centers + blocks{b}(2);
                    index_r3 = D * num_poses * num_centers + blocks{b}(3);
                    
                    change_indices(index_c1) = 1; change_indices(index_c2) = 1; change_indices(index_c3) = 1;
                    change_indices(index_r1) = 1; change_indices(index_r2) = 1; change_indices(index_r3) = 1;
                end
            end
        end
        %if ~isempty(invalid_blocks), display_hand_sketch(poses(p:p), new_radii, blocks, invalid_blocks); end
        
    end
    
    delta(change_indices == 1) = delta(change_indices == 1) * 0.7;
    
end


%% Copy valid updata

for p = 1:num_poses
    poses{p}.centers = poses{p}.new_centers;
    radii = new_radii;
end

end

function [poses, new_radii] = update(poses, radii, delta, D)
num_poses = length(poses);
num_centers = length(poses{1}.centers);
for p = 1:num_poses
    poses{p}.delta_c = delta(D * num_centers * (p - 1) + 1:D * num_centers * p);
    
    poses{p}.new_centers = cell(size(poses{p}.centers));
    for o = 1:num_centers
        poses{p}.new_centers{o} = poses{p}.centers{o} + poses{p}.delta_c(D * o - D + 1:D * o);
    end
end

new_radii = cell(size(radii));
if length(delta) == D * num_poses * num_centers, 
    new_radii = radii;
    return; 
end
for o = 1:num_centers
    new_radii{o} = radii{o} + delta(D * num_poses * num_centers + o);
end
end



