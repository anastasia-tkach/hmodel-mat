function [segments] = initialize_ik_hmodel(centers, names_map)

D = 3; 
up = [0; 1; 0];

segments = hmodel_segments_parameters();

for i = 1:length(segments)
    segments{i}.local = eye(D + 1, D + 1);
    
    p = segments{i}.parent_id;
    c = segments{i}.children_ids;
    
    if isempty(p)
        segments{i}.local(1:D, D + 1) =  centers{names_map('palm_back')};
        segments{i}.global(1:D, D + 1) =  segments{i}.local(1:D, D + 1);
        continue;
    end
    
    if isempty(c)
        child_name = segments{i}.end_name;
    else
        child_name = segments{c}.name;
    end
    v = centers{names_map(child_name)} - centers{names_map(segments{i}.name)};
    if length(segments{i}.kinematic_chain) == 8
        R = vrrotvec2mat(vrrotvec(up, v));
        %if strcmp(segments{i}.name, 'HandThumb1')
           % R = find_svd_rotation(palm_frame, thumb_frame);
        %end
    elseif length(segments{i}.kinematic_chain) > 8
        u = centers{names_map(segments{i}.name)} - centers{names_map(segments{p}.name)};
        R = vrrotvec2mat(vrrotvec(u, v));
    end
    segments{i}.local(1:D, 1:D) = R;    
    segments{i}.global = segments{segments{i}.parent_id}.global * segments{i}.local;
    
    t = centers{names_map(segments{i}.name)} - centers{names_map(segments{p}.name)};
    T = segments{p}.global(1:D, 1:D)' * t;
    segments{i}.local(1:D, D + 1) =  T;
end

%% Update all transforms
segments = update_transform(segments, 1);

%% Compute length
for i = 1:length(segments)
    if isfield(segments{i}, 'end_name')    
        segments{i}.length = norm(centers{names_map(segments{i}.name)} - centers{names_map(segments{i}.end_name)});
    end
    if isfield(segments{i}, 'additional_name')    
        segments{i}.additional_length = norm(centers{names_map(segments{i}.name)} - centers{names_map(segments{i}.additional_name)});
    end
end

%% Initialize rigid centers
for i = 1:length(segments{1}.rigid_names)
    segments{1}.offsets{i} = centers{names_map(segments{1}.rigid_names{i})} -  centers{names_map(segments{1}.name)};
end