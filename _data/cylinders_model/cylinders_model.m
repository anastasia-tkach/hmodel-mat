function [mesh] = cylinders_model()

load Data;
load mu;
load stddev;

index = 234;
t = Data(index, 7:end);

t = t .* stddev;
t = t + mu;

Rx = @(alpha) [1, 0, 0, 0;
      0, cos(alpha), -sin(alpha), 0;
      0, sin(alpha), cos(alpha), 0;
      0, 0, 0, 1]; 
  
Ry = @(alpha)[cos(alpha), 0, sin(alpha), 0;
      0, 1, 0, 0;
      -sin(alpha), 0, cos(alpha), 0;
      0, 0, 0, 1];
  
Rz = @(alpha)[cos(alpha), -sin(alpha), 0, 0;
      sin(alpha), cos(alpha), 0, 0;
      0, 0, 1, 0;
      0, 0, 0, 1];

segments = segments_parameters();
theta = joints_parameters(t);

%% Apply deformation transform
for i = 1:length(segments)
    l = segments{i}.length;
    r1 = segments{i}.radius1;
    r2 = segments{i}.radius2;
    r = segments{i}.ratio;
    [Vertices, Triangles] = get_initial_segment(l, r1, r2, r);
    Vertices = transform(Vertices, Rx(pi/2)');  
    segments{i}.V = Vertices;  
end
segments = update_transform(segments, 1);

order = [2 1 3 4 6 5 7 8 10 9 11 12 14 13 15 16 18 17 19 20];
for i = order     
    segment = segments{theta{i}.segment_id};
    T = [];
    if (theta{i}.axis == 'X')
        R = Rx(theta{i}.value);
        T = segment.local * R;
    end
    if (theta{i}.axis == 'Z')
        R = Rz(theta{i}.value);
        T =  segment.local * R;
    end
    segments{theta{i}.segment_id}.local = T; 
    segments = update_transform(segments, theta{i}.segment_id);
end

for i = 1:length(segments) 
    segments{i}.global =  Ry(pi) * segments{i}.global; 
end

%% Create mesh
mesh.vertices = [];
mesh.triangles = [];
num_vertices = 0;

for i = 1:length(segments)    
    V = transform(segments{i}.V, segments{i}.global); 
    mesh.vertices = [mesh.vertices; V'];
    mesh.triangles = [mesh.triangles; Triangles + num_vertices];
    num_vertices = num_vertices + size(V, 2);
end



