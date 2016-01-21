
% close all;
% D = 3;
% %% Generate data
% [centers, radii, blocks] = get_random_convtriangle();
% %[centers, radii, blocks] = get_random_convsegment(D);
% for i = 1:length(centers)
%     centers{i} = centers{i} + [0; 0; 1];
% end
% c1 = centers{1}; c2 = centers{2}; c3 = centers{3};
% r1 = radii{1}; r2 = radii{2}; r3 = radii{3};
% camera_center = [0; 0; 0];
% camera_ray = [0; 0; 1];
% p = rand(D, 1) + [0; 0; 1];

display_result(centers, [], [], blocks, radii, false, 0.5, 'small');

%% Convsegment 1
[t1, t2] = compute_last_visible_point(c1, c2, r1, r2, camera_ray, c1);
[t3, t4] = compute_last_visible_point(c1, c2, r1, r2, camera_ray, c2);
myline(t1, t3, 'b'); myline(t2, t4, 'b');
if norm(t1 - c3) < norm(t2 - c3)
    [t1, t2] = swap(t1, t2); 
    [t3, t4] = swap(t3, t4); 
end    
outline{1} = {t1; t3};

%% Convsegment 2
[t1, t2] = compute_last_visible_point(c1, c3, r1, r3, camera_ray, c1);
[t3, t4] = compute_last_visible_point(c1, c3, r1, r3, camera_ray, c3);
myline(t1, t3, 'b'); myline(t2, t4, 'b');
if norm(t1 - c2) < norm(t2 - c2)
    [t1, t2] = swap(t1, t2);
    [t3, t4] = swap(t3, t4); 
end    
outline{2} = {t1; t3};

%% Convsegment 3
[t1, t2] = compute_last_visible_point(c2, c3, r2, r3, camera_ray, c2);
[t3, t4] = compute_last_visible_point(c2, c3, r2, r3, camera_ray, c3);
myline(t1, t3, 'b'); myline(t2, t4, 'b');
if norm(t1 - c1) < norm(t2 - c1)
    [t1, t2] = swap(t1, t2); 
    [t3, t4] = swap(t3, t4); 
end    
outline{3} = {t1; t3};

%% Display

for i = 1:length(outline)
    myline(outline{i}{1}, outline{i}{2}, 'g');
end
view([180, -90]); camlight;

%% Compute outline



