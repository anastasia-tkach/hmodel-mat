N = 3;
p = rand(N, 1);
v1 = rand(N, 1);
v2 = rand(N, 1);
v3 = rand(N, 1);
index1 = 1;
index2 = 2;
index3 = 3;
write_input_parameters_to_files(v1, v2, v3, p, index1, index2, index3);
[t0, index0] = closest_point_in_triangle(v1, v2, v3, p, index1, index2, index3);

[t, index] = closest_point_in_triangle_mex(v1, v2, v3, p, index1, index2, index3);

disp([t0 t]);
disp([index0' index]);
