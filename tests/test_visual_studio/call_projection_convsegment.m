N = 3;
p = 10 * rand(N, 1);
c1 = rand(N, 1);
c2 = rand(N, 1);
r1 = rand(1, 1);
r2 = rand(1, 1);
index1 = 1;
index2 = 2;
%write_input_parameters_to_files(p, c1, c2, r1, r2, index1, index2);
[index0, q0, s0, is_inside0] = projection_convsegment(p, c1, c2, r1, r2, index1, index2);

[index, q, s, is_inside] = projection_convsegment_mex(p, c1, c2, r1, r2, index1, index2);

disp([q0 q]);
disp([s0 s]);
disp([is_inside0 is_inside]);
disp([index0 index]);