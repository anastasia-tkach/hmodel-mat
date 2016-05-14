function [centers] = adjust_give_user(centers, user_name, names_map)

shift = centers{26};
for i = 1:length(centers)
    centers{i} = centers{i} - shift;
end

front = - [0; 0; 1];
back = [0; 0; 1];
to_thumb = [1; 0; 0];
to_pinky = - [1; 0; 0];

if strcmp(user_name, 'model')
    wrist_scaling = 0.7;
    centers{names_map('wrist_bottom_left')} = centers{names_map('wrist_top_left')} + wrist_scaling * (centers{names_map('wrist_bottom_left')} - centers{names_map('wrist_top_left')});
    centers{names_map('wrist_bottom_right')} = centers{names_map('wrist_top_right')} + wrist_scaling * (centers{names_map('wrist_bottom_right')} - centers{names_map('wrist_top_right')});
end

if strcmp(user_name, 'pei-i')
    wrist_scaling = 0.7;
    centers{names_map('wrist_bottom_right')} = centers{names_map('wrist_bottom_right')} + 5 * [0; 0; 1] + 2 * [0; 1; 0];
    
    centers{names_map('palm_thumb')} = centers{names_map('palm_thumb')} - 4 * [0; 1; 0];
    centers{names_map('palm_middle')} = centers{names_map('palm_middle')} + 4 * front;
    centers{names_map('palm_ring')} = centers{names_map('palm_ring')} + 2 * front;
    centers{names_map('palm_pinky')} = centers{names_map('palm_pinky')} + 2 * back;
    
    centers{names_map('middle_membrane')} = centers{names_map('middle_membrane')} + 2 * front;  
    
    centers{names_map('middle_base')} = centers{names_map('middle_base')} + 3 * front;
    centers{names_map('thumb_base')} = centers{names_map('thumb_base')} + 4 * to_pinky;
    
    centers{names_map('palm_left')} = centers{names_map('palm_left')} + 4 * to_thumb;
    centers{names_map('palm_back')} = centers{names_map('palm_back')} + 1.5 * back;
    
    centers{names_map('wrist_bottom_right')} = centers{names_map('wrist_bottom_right')} + 2 * front;
end

if strcmp(user_name, 'andrii')
    wrist_scaling = 0.7;
    centers{names_map('wrist_bottom_right')} = centers{names_map('wrist_bottom_right')} + 7 * [1; 0; 0];
    centers{names_map('wrist_bottom_left')} = centers{names_map('wrist_bottom_left')} + 7 * [1; 0; 0];
    centers{names_map('wrist_top_right')} = centers{names_map('wrist_top_right')} + 5 * [1; 0; 0];
    centers{names_map('wrist_top_left')} = centers{names_map('wrist_top_left')} + 7 * [1; 0; 0];    
    
    centers{names_map('palm_thumb')} = centers{names_map('palm_thumb')} + 2 * to_pinky;
    centers{names_map('palm_index')} = centers{names_map('palm_index')} + 2 * to_pinky;
    centers{names_map('palm_middle')} = centers{names_map('palm_middle')} + 3.5 * front;
    centers{names_map('palm_ring')} = centers{names_map('palm_ring')} + 3 * front;
    
    centers{names_map('index_base')} = centers{names_map('index_base')} + 4 * back;
    centers{names_map('ring_base')} = centers{names_map('ring_base')} + 3 * front;
    
    centers{names_map('index_membrane')} = centers{names_map('index_membrane')} + 3 * back; 
    centers{names_map('middle_membrane')} = centers{names_map('middle_membrane')} + 1 * front; 
    
    centers{names_map('palm_left')} = centers{names_map('palm_left')} + 8 * to_thumb + 4 * front;
    centers{names_map('palm_back')} = centers{names_map('palm_back')} + 2 * front;
end
if strcmp(user_name, 'thomas')
    centers{names_map('wrist_bottom_right')} = centers{names_map('wrist_bottom_right')} + 3 * [1; 0; 0] + 1 * front;
    centers{names_map('wrist_bottom_left')} = centers{names_map('wrist_bottom_left')} + 5 * [1; 0; 0];
    centers{names_map('wrist_top_right')} = centers{names_map('wrist_top_right')} + 3 * [1; 0; 0];
    centers{names_map('wrist_top_left')} = centers{names_map('wrist_top_left')} + 5 * [1; 0; 0] + 5 * [0; 1; 0];
    
    centers{names_map('palm_thumb')} = centers{names_map('palm_thumb')} + 3 * to_pinky;
    centers{names_map('palm_index')} = centers{names_map('palm_index')} + 4 * back + 1 * to_pinky;
    centers{names_map('palm_middle')} = centers{names_map('palm_middle')} + 7 * front;
    centers{names_map('palm_ring')} = centers{names_map('palm_ring')} + 6 * front;
    
    centers{names_map('palm_right')} = centers{names_map('palm_right')} + 2 * back;
    centers{names_map('palm_back')} = centers{names_map('palm_back')} + 1 * front;
    centers{names_map('palm_left')} = centers{names_map('palm_left')} + 7 * to_thumb;
    
    centers{names_map('index_base')} = centers{names_map('index_base')} + 2 * front;
    centers{names_map('middle_base')} = centers{names_map('middle_base')} + 3 * front;
    centers{names_map('ring_base')} = centers{names_map('ring_base')} + 2 * front;
    centers{names_map('thumb_base')} = centers{names_map('thumb_base')} + 2 * to_pinky;
    
    centers{names_map('index_membrane')} = centers{names_map('index_membrane')} + 1 * back;  
end