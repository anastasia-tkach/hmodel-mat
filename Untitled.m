D = 3;
close all;
i1 = [inf; inf; inf];
i2 = [inf; inf; inf];
while any(isinf(i1))
    v1 = rand(D, 1);
    v2 = rand(D, 1);
    v3 = rand(D, 1);
    
    u1 = rand(D, 1);
    u2 = rand(D, 1);
    u3 = rand(D, 1);
    
    [i1, i2] = intersect_trinagle_triangle(v1, v2, v3, u1, u2, u3);
    
end

%% Display

figure; hold on; axis off; axis equal;
myline(v1, v2, 'b');
myline(v1, v3, 'b');
myline(v3, v2, 'b');

myline(u1, u2, 'c');
myline(u1, u3, 'c');
myline(u3, u2, 'c');

mypoint(i1, 'm');
mypoint(i2, 'm');
myline(i1, i2, 'm');