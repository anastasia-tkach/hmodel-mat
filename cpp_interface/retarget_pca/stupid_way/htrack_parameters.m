function [segments, dofs, triangles] = htrack_parameters(scaling_factor)

num_phalanges = 16;
[~, triangles] = get_initial_segment(1, 1, 1, 1);
Rx = @(alpha) [1, 0, 0, 0; 0, cos(alpha), -sin(alpha), 0; 0, sin(alpha), cos(alpha), 0; 0, 0, 0, 1];   

%% Scale Htrack
[phalanges, dofs] = hmodel_parameters();
segments = htrack_segments_parameters();

for i = 1:num_phalanges
    segments{i}.length = scaling_factor * segments{i}.length;
    segments{i}.radius1 = scaling_factor * segments{i}.radius1;
    segments{i}.radius2 = scaling_factor * segments{i}.radius2;
    segments{i}.local(1:3, 4) = scaling_factor * segments{i}.local(1:3, 4);
end

segments{17} = phalanges{17};
segments{18} = phalanges{18};
for i = 1:num_phalanges
    l = segments{i}.length;
    r1 = segments{i}.radius1;
    r2 = segments{i}.radius2;
    r = segments{i}.ratio;
    [Vertices, ~] = get_initial_segment(l, r1, r2, r);
    Vertices = transform(Vertices, Rx(pi/2)');  
    segments{i}.V = Vertices;  
end