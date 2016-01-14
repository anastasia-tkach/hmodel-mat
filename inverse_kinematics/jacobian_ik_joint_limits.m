function [F, J] = jacobian_ik_joint_limits(joints)
epsilon = 1.192092896e-07;

J = zeros(length(joints), length(joints));
F = zeros(length(joints), 1);

for i = 1:length(joints)
    t = joints{i}.value;
    if t > joints{i}.max
        F(i) = joints{i}.max - t - epsilon;        
        J(i,i) = 1;
    end
    if(t < joints{i}.min)        
        F(i) = joints{i}.max - t + epsilon;
        J(i,i) = 1;        
    end    
end

