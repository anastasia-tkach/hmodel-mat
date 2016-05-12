
clc; clear; %close all;
semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);
front = - [0; 0; 1];
back = [0; 0; 1];
to_thumb = [1; 0; 0];
to_pinky = - [1; 0; 0];

user_name = 'pei-i';
input_path = ['C:/Developer/data/models/', user_name, '/'];
[centers, radii, blocks, theta, phalanges, mean_centers] = read_cpp_model(input_path);

%%  Andrii
if strcmp(user_name, 'andrii')
    wrist_scaling = 0.7;
    centers{names_map('wrist_bottom_right')} = centers{names_map('wrist_bottom_right')} + 7 * [1; 0; 0];%  - 4 * [0; 1; 0];
    centers{names_map('wrist_bottom_left')} = centers{names_map('wrist_bottom_left')} + 7 * [1; 0; 0];
    centers{names_map('wrist_top_right')} = centers{names_map('wrist_top_right')} + 5 * [1; 0; 0];
    centers{names_map('wrist_top_left')} = centers{names_map('wrist_top_left')} + 7 * [1; 0; 0];
    
    centers{names_map('palm_thumb')} = centers{names_map('palm_thumb')} + 2 * to_pinky;
    centers{names_map('palm_index')} = centers{names_map('palm_index')} + 2 * to_pinky;
    centers{names_map('palm_middle')} = centers{names_map('palm_middle')} + 3.5 * front;
    centers{names_map('palm_ring')} = centers{names_map('palm_ring')} + 4 * front;
    
    centers{names_map('index_base')} = centers{names_map('index_base')} + 4 * back;
    centers{names_map('ring_base')} = centers{names_map('ring_base')} + 3 * front;
    centers{names_map('ring_bottom')} = centers{names_map('ring_bottom')} + 7 * [0; 1; 0];
    centers{names_map('ring_middle')} = centers{names_map('ring_middle')} + 4 * [0; 1; 0];
    centers{names_map('pinky_bottom')} = centers{names_map('pinky_bottom')} + 3 * [0; 1; 0];
    
    centers{names_map('index_membrane')} = centers{names_map('index_membrane')} + 5 * back;
    centers{names_map('middle_membrane')} = centers{names_map('middle_membrane')} + 0 * front;
    centers{names_map('ring_membrane')} = centers{names_map('ring_membrane')} + 2 * front;
    centers{names_map('pinky_membrane')} = centers{names_map('pinky_membrane')} + 4 * to_pinky;
    
    centers{names_map('palm_left')} = centers{names_map('palm_left')} + 8 * to_thumb + 4 * front;
    centers{names_map('palm_back')} = centers{names_map('palm_back')} + 2 * front;
    
    radii{names_map('thumb_middle')} =  1.1 * radii{names_map('thumb_middle')};
end

%% Thomas
if strcmp(user_name, 'thomas')
    centers{names_map('wrist_bottom_right')} = centers{names_map('wrist_bottom_right')} + 3 * [1; 0; 0] + 1 * front;
    centers{names_map('wrist_bottom_left')} = centers{names_map('wrist_bottom_left')} + 5 * [1; 0; 0];
    centers{names_map('wrist_top_right')} = centers{names_map('wrist_top_right')} + 3 * [1; 0; 0] + 10 * [0; 1; 0];
    centers{names_map('wrist_top_left')} = centers{names_map('wrist_top_left')} + 5 * [1; 0; 0] + 15 * [0; 1; 0];
    
    centers{names_map('palm_thumb')} = centers{names_map('palm_thumb')} + 3 * to_pinky;
    centers{names_map('palm_index')} = centers{names_map('palm_index')} + 4 * back + 1 * to_pinky;
    centers{names_map('palm_middle')} = centers{names_map('palm_middle')} + 7 * front;
    centers{names_map('palm_ring')} = centers{names_map('palm_ring')} + 6 * front + 5 * to_thumb;
    
    centers{names_map('palm_right')} = centers{names_map('palm_right')} + 2 * back;
    centers{names_map('palm_back')} = centers{names_map('palm_back')} + 1 * front;
    centers{names_map('palm_left')} = centers{names_map('palm_left')} + 7 * to_thumb;
    
    centers{names_map('thumb_base')} = centers{names_map('thumb_base')} + 2 * to_pinky;
    centers{names_map('index_base')} = centers{names_map('index_base')} + 1 * front;
    centers{names_map('middle_base')} = centers{names_map('middle_base')} + 2 * front;
    centers{names_map('ring_base')} = centers{names_map('ring_base')} + 2 * front;
    centers{names_map('ring_bottom')} = centers{names_map('ring_bottom')} + 10 * [0; 1; 0];
    centers{names_map('pinky_bottom')} = centers{names_map('pinky_bottom')} + 7 * [0; 1; 0];
    
    centers{names_map('index_membrane')} = centers{names_map('index_membrane')} + 1 * back;
    centers{names_map('ring_membrane')} = centers{names_map('ring_membrane')} + 1 * front;
end

%% Pei - i
if strcmp(user_name, 'pei-i')
    wrist_scaling = 1.0;
    centers{names_map('wrist_bottom_left')} = centers{names_map('wrist_top_left')} + wrist_scaling * (centers{names_map('wrist_bottom_left')} - centers{names_map('wrist_top_left')});
    centers{names_map('wrist_bottom_right')} = centers{names_map('wrist_top_right')} + wrist_scaling * (centers{names_map('wrist_bottom_right')} - centers{names_map('wrist_top_right')});
    
    centers{names_map('wrist_bottom_right')} = centers{names_map('wrist_bottom_right')} + 5 * [0; 0; 1] + 2 * [0; 1; 0];
    
    centers{names_map('palm_thumb')} = centers{names_map('palm_thumb')} - 4 * [0; 1; 0];
    centers{names_map('palm_middle')} = centers{names_map('palm_middle')} + 4 * front;
    centers{names_map('palm_ring')} = centers{names_map('palm_ring')} + 2 * front;
    centers{names_map('palm_pinky')} = centers{names_map('palm_pinky')} + 2 * back + 3 * to_thumb;
    
    centers{names_map('index_membrane')} = centers{names_map('index_membrane')} + 1 * back + 3 * to_pinky;
    centers{names_map('middle_membrane')} = centers{names_map('middle_membrane')} + 2 * front;
    centers{names_map('pinky_membrane')} = centers{names_map('pinky_membrane')} + 1 * front + 3 * to_thumb;
    
    centers{names_map('middle_base')} = centers{names_map('middle_base')} + 3 * front;
    centers{names_map('thumb_base')} = centers{names_map('thumb_base')} + 4 * to_pinky;
    centers{names_map('ring_bottom')} = centers{names_map('ring_bottom')} + 10 * [0; 1; 0];
    centers{names_map('ring_middle')} = centers{names_map('ring_middle')} + 8 * [0; 1; 0];
    centers{names_map('ring_top')} = centers{names_map('ring_top')} + 8 * [0; 1; 0];
    centers{names_map('pinky_bottom')} = centers{names_map('pinky_bottom')} + 2 * [0; 1; 0];
    
    centers{names_map('palm_left')} = centers{names_map('palm_left')} + 4 * to_thumb;
    centers{names_map('palm_back')} = centers{names_map('palm_back')} + 1.5 * back;
    
    centers{names_map('wrist_bottom_right')} = centers{names_map('wrist_bottom_right')} + 2 * front;
    
    centers{names_map('thumb_bottom')} = centers{names_map('thumb_base')} + 0.9 * (centers{names_map('thumb_bottom')} - centers{names_map('thumb_base')});
    
    centers{names_map('thumb_top')} = centers{names_map('thumb_middle')} + 0.8 * (centers{names_map('thumb_top')} - centers{names_map('thumb_middle')});
    centers{names_map('thumb_middle')} = centers{names_map('thumb_bottom')} + 0.9 * (centers{names_map('thumb_middle')} - centers{names_map('thumb_bottom')});
    centers{names_map('thumb_bottom')} = centers{names_map('thumb_base')} + 0.9 * (centers{names_map('thumb_bottom')} - centers{names_map('thumb_base')});
    centers{names_map('thumb_fold')} = centers{names_map('thumb_bottom')} + 0.01 * rand;
    
    radii{names_map('middle_top')} =  0.93 * radii{names_map('middle_top')};
    radii{names_map('ring_middle')} =  1.07 * radii{names_map('ring_middle')};
    radii{names_map('thumb_bottom')} =  1.11 * radii{names_map('thumb_bottom')};
    
    radii{names_map('wrist_bottom_left')} = 1.12 * radii{names_map('wrist_bottom_left')};
    radii{names_map('wrist_bottom_right')} = 1.12 * radii{names_map('wrist_bottom_right')};
end

%% Compute transformations
[phalanges, dofs] = get_phalanges_from_centers(centers, phalanges, names_map);
num_thetas = 29;
phalanges = htrack_move(zeros(num_thetas, 1), dofs, phalanges);
phalanges = initialize_offsets(centers, phalanges, names_map);
%phalanges = htrack_move(zeros(num_thetas, 1), dofs, phalanges);
centers = update_centers(centers, phalanges, names_map);

xlimit = [-195.11, 185.43];
ylimit = [-60, 150];
zlimit = [-86.933, 50.376];

display_result(centers, [], [], blocks, radii, false, 1, 'big');
view([-180, -90]);
%xlim(xlimit); ylim(ylimit); zlim(zlimit);
camlight;

write_cpp_model(['C:/Developer/data/models/', user_name, '_new/'], centers, radii, blocks, phalanges);