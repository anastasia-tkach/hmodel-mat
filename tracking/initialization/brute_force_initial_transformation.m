function [L_min] = brute_force_initial_transformation(centers, segments, joints, names_map, s1, s2, s3, j1, j2, j3, j4, name1, name2, name3)
D = 3;
b_data = centers{names_map(name1)};
c_data = centers{names_map(name2)};
d_data = centers{names_map(name3)};
mypoint(b_data, 'k');
mypoint(c_data, 'k');
mypoint(d_data, 'k');

up = [0; 1; 0];
min_distance = Inf;
for i = -0.8:0.04:0.8
    for j = -0.8:0.04:0.8
        for k = -0.8:0.04:0.8
            euler_angles = [i, j, k];
            L = eul2rotm(euler_angles);
            T = segments{s1}.local;
            T(1:D, 1:D) = L;
            G_c1 = segments{1}.global * T * makehgtform('axisrotate', joints{j1}.axis_vector, joints{j1}.value) *  makehgtform('axisrotate', joints{j2}.axis_vector, joints{j2}.value);
            G_c2 = G_c1 * segments{s2}.local * makehgtform('axisrotate', joints{j3}.axis_vector, joints{j3}.value);
            G_c3 = G_c2 * segments{s3}.local * makehgtform('axisrotate', joints{j4}.axis_vector, joints{j4}.value);
            
            b = G_c2(1:D, D + 1);
            c = G_c3(1:D, D + 1);
            d = c + G_c3(1:D, 1:D) * segments{s3}.length * up;
            
            %if norm(c - c_data) + norm(b - b_data) < min_distance
            if norm(c - c_data) + norm(b - b_data) + norm(d - d_data) < min_distance
                min_distance = norm(c - c_data) + norm(b - b_data);
                L_min = L;
            end
        end
    end
end

T = segments{s1}.local;
T(1:D, 1:D) = L_min;
G_c1 = segments{1}.global * T * makehgtform('axisrotate', joints{j1}.axis_vector, joints{j1}.value) *  makehgtform('axisrotate', joints{j2}.axis_vector, joints{j2}.value);
G_c2 = G_c1 * segments{s2}.local * makehgtform('axisrotate', joints{j3}.axis_vector, joints{j3}.value);
G_c3 = G_c2 * segments{s3}.local * makehgtform('axisrotate', joints{j4}.axis_vector, joints{j4}.value);

b = G_c2(1:D, D + 1);
c = G_c3(1:D, D + 1);
d = c + G_c3(1:D, 1:D) * segments{s3}.length * up;
mypoint(b, 'g');
mypoint(c, 'g');
mypoint(d, 'g');