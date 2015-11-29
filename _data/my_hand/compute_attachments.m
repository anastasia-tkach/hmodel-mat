load([data_path, 'names_map.mat']);
load([data_path, 'named_blocks.mat']);

centers_map = containers.Map();
radii_map = containers.Map();

for key = keys(names_map)
    key = key{1};
    c = centers(names_map(key)); c = c{1};
    r = radii(names_map(key)); r = r{1};
    centers_map(key) = c;
    radii_map(key) = r;
end

centers = {};
radii = {};
for key = keys(names_map)
    key = key{1};
    centers{names_map(key)} = centers_map(key);
    radii{names_map(key)} = radii_map(key);
end

%display_result_convtriangles(centers, [], [], blocks, radii, false);

%% Describe attachments
attachments_map = containers.Map();

attachments_map('pinky_membrane') = {'pinky_bottom', 'pinky_base'};
attachments_map('ring_membrane') = {'ring_bottom', 'ring_base'};
attachments_map('middle_membrane') = {'middle_bottom', 'middle_base'};
attachments_map('index_membrane') = {'index_bottom', 'index_base'};
attachments_map('thumb_membrane') = {'thumb_bottom', 'thumb_middle'};

attachments_map('palm_pinky') = {'pinky_bottom', 'pinky_base'};
attachments_map('palm_ring') = {'ring_bottom', 'ring_base'};
attachments_map('palm_middle') = {'middle_bottom', 'middle_base'};
attachments_map('palm_index') = {'index_bottom', 'index_base'};

attachments_map('wrist_bottom_left') = {'wrist_top_left', 'palm_back', 'wrist_top_right'};
attachments_map('wrist_bottom_right') = {'wrist_top_left', 'palm_back', 'wrist_top_right'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MAYBE REPLACE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

attachments_map('palm_fromt') = {'palm_right', 'palm_back', 'palm_ring'};
attachments_map('palm_attachment') = {'palm_right', 'palm_back', 'palm_ring'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MAYBE REPLACE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

attachments = cell(length(centers), 1);
for key = keys(names_map)
    key = key{1};
    index = names_map(key);
    if index == 28
        disp(' ')
    end
    if ~isKey(attachments_map, key), continue; end
    
    attachment_name = sort(attachments_map(key));
    for i = 1:length(named_blocks)
        block_name = sort(named_blocks{i});
        if length(attachment_name) ~= length(block_name), continue; end
        is_equal = true;
        for j = 1:length(attachment_name)
            if ~strcmp(attachment_name{j}, block_name{j}), is_equal = false; end
        end
        if is_equal == true
            attachments{index}.block_index = i;
            break;
        end
    end
end


%% Global frame indices
named_global_frame_block = {'palm_ring', 'palm_middle', 'palm_back'};

current_name = sort(named_global_frame_block);
for index = 1:length(named_blocks)
    block_name = sort(named_blocks{index});
    if length(current_name) ~= length(block_name), continue; end
    is_equal = true;
    for k = 1:length(current_name)
        if ~strcmp(current_name{k}, block_name{k}), is_equal = false; end
    end
    if is_equal == true
        global_frame_block = index;
        global_frame_indices = blocks{index};
        break;
    end
    
end

%% Describe parents

parents_map = containers.Map();

parents_map('pinky_top pinky_middle') = {'pinky_middle', 'pinky_bottom'};
parents_map('pinky_middle pinky_bottom') = {'pinky_bottom', 'pinky_base'};
parents_map('pinky_bottom pinky_base') = {'palm_right', 'palm_back', 'palm_ring'};

parents_map('ring_top ring_middle') = {'ring_middle', 'ring_bottom'};
parents_map('ring_middle ring_bottom') = {'ring_bottom', 'ring_base'};
parents_map('ring_bottom ring_base') = {'palm_right', 'palm_back', 'palm_ring'};

parents_map('middle_top middle_middle') = {'middle_middle', 'middle_bottom'};
parents_map('middle_middle middle_bottom') = {'middle_bottom', 'middle_base'};
parents_map('middle_bottom middle_base') = {'palm_right', 'palm_back', 'palm_ring'};

parents_map('index_top index_middle') = {'index_middle', 'index_bottom'};
parents_map('index_middle index_bottom') = {'index_bottom', 'index_base'};
parents_map('index_bottom index_base') = {'palm_right', 'palm_back', 'palm_ring'};

parents_map('thumb_top thumb_middle') = {'thumb_middle', 'thumb_bottom'};
parents_map('thumb_middle thumb_bottom') = {'thumb_bottom', 'thumb_base'};
parents_map('thumb_bottom thumb_base') = {'palm_right', 'palm_back', 'palm_ring'};

%% Index with numbers

parents = cell(length(blocks), 1);

for key = keys(parents_map)
    key = key{1};
    child_name = sort(strsplit(key));
    parent_name = sort(parents_map(key));
    
    for index = 1:length(named_blocks)
        block_name = sort(named_blocks{index});
        
        %% Find child block
        if length(child_name) == length(block_name)
            is_equal = true;
            for j = 1:length(child_name)
                if ~strcmp(child_name{j}, block_name{j})
                    is_equal = false;
                end
            end
            if is_equal, child_index = index; end
        end
        
        %% Find parent block
        if length(parent_name) == length(block_name)
            is_equal = true;
            for j = 1:length(parent_name)
                if ~strcmp(parent_name{j}, block_name{j})
                    is_equal = false;
                end
            end
            if is_equal, parent_index = index; end
        end
    end
    
    parents{child_index} = parent_index;
end

%% Describe solid blocks

named_solid_blocks = {};
named_solid_blocks{end + 1} = {{'wrist_top_left', 'wrist_bottom_left', 'wrist_top_right'}, ...
    {'wrist_bottom_left', 'wrist_top_right', 'wrist_bottom_right'}, ...
    {'wrist_top_left', 'wrist_top_right', 'palm_back'}, ...
    {'wrist_top_left', 'wrist_top_right', 'palm_attachment'}};
named_solid_blocks{end + 1} = {{'ring_membrane', 'middle_membrane', 'palm_ring'}, ...
    {'palm_ring', 'palm_middle', 'middle_membrane'}};
named_solid_blocks{end + 1} = {{'palm_middle', 'palm_thumb', 'palm_back'}, ...
    {'palm_thumb', 'thumb_base', 'palm_back'}, ...
    {'palm_right', 'palm_ring', 'palm_back'}, ...
    {'palm_ring', 'palm_middle', 'palm_back'}};

solid_blocks = cell(length(named_solid_blocks), 1);
solid_indicator = zeros(length(solid_blocks), 1);
for i = 1:length(named_solid_blocks)
    solid_blocks{i} = [];
    for j = 1:length(named_solid_blocks{i})
        current_name = sort(named_solid_blocks{i}{j});
        
        for index = 1:length(named_blocks)
            block_name = sort(named_blocks{index});
            if length(current_name) ~= length(block_name), continue; end
            is_equal = true;
            for k = 1:length(current_name)
                if ~strcmp(current_name{k}, block_name{k}), is_equal = false; end
            end
            if is_equal == true
                solid_blocks{i} = [solid_blocks{i}, index];
                solid_indicator(index) = 1;
                break;
            end
            
        end
        
    end
end

single_solid_blocks = {};
for i = 1:length(solid_indicator)
    if solid_indicator(i) == 0
        single_solid_blocks = [single_solid_blocks, {i}];
    end
end
solid_blocks = [single_solid_blocks'; solid_blocks];
%solid_blocks = [{1}; {2}; {3}; {4}; {5}; {6}; {7}; {8}; {9}; {10}; {11}; {12}; {13}; {14}; {15}; solid_blocks];
%solid_blocks = [];






