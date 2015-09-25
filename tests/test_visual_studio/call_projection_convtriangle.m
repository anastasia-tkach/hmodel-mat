N = 3;
clc;
p = rand(N, 1);
c1 = rand(N, 1);
c2 = rand(N, 1);
c3 = rand(N, 1);
r1 = rand(1, 1);
r2 = rand(1, 1);
r3 = rand(1, 1);
R = [r1, r2, r3];
R = sort(R, 'descend');
r1 = R(1); r2 = R(2); r3 = R(3);

index1 = 1;
index2 = 2;
index3 = 3;
[v1, v2, v3, u1, u2, u3] = tangent_points_function(c1, c2, c3, r1, r2, r3);
write_input_parameters_to_files(p, c1, c2, c3, r1, r2, r3, v1, v2, v3, u1, u2, u3, index1, index2, index3);
[index0, q0, s0, is_inside0] = projection_convtriangle(p, c1, c2, c3, r1, r2, r3, v1, v2, v3, u1, u2, u3, index1, index2, index3);

[index, q, s, is_inside] = projection_convtriangle_mex(p, c1, c2, c3, r1, r2, r3, v1, v2, v3, u1, u2, u3, index1, index2, index3);

disp([q0'; q']);
disp([s0'; s']);
disp([is_inside0, is_inside]);
disp([index0, index]);