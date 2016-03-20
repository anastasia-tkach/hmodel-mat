function [phalanges] = htrack_move(theta, dofs, phalanges)
num_thetas = length(dofs);
num_phalanges = 4;

rotateX = zeros(num_thetas, 1);
rotateZ = zeros(num_thetas, 1);
rotateY = zeros(num_thetas, 1);
globals = zeros(num_thetas, 1);

for i = 1:num_thetas
    if (dofs{i}.phalange_id <= num_phalanges && dofs{i}.type == 0)
        if all(dofs{i}.axis == [1, 0, 0])
            rotateX(i) = theta(i);
        elseif all(dofs{i}.axis == [0, 1, 0])
            rotateY(i) = theta(i);
        else
            rotateZ(i) = theta(i);
        end          
    else
        globals(i) = theta(i);
    end
    
end
phalanges = transform_joints(globals, dofs, phalanges);
phalanges = transform_joints(rotateX, dofs, phalanges);
phalanges = transform_joints(rotateZ, dofs, phalanges);
phalanges = transform_joints(rotateY, dofs, phalanges);

end

function [phalanges] = transform_joints(theta, dofs, phalanges)
for i = 1:length(dofs)
    if (dofs{i}.phalange_id == -1), continue; end
    switch (dofs{i}.type)
        case 1
            phalanges = translate(dofs{i}.phalange_id, dofs{i}.axis * theta(i), phalanges);
        case 0
            phalanges = rotate(dofs{i}.phalange_id, dofs{i}.axis, theta(i), phalanges);
    end
end
end

function [phalanges] = update(id, phalanges)
if (phalanges{id}.parent_id >= 0)
    phalanges{id}.global = phalanges{phalanges{id}.parent_id}.global * phalanges{id}.local;
else
    phalanges{id}.global = phalanges{id}.local;
end
for i = 1 : length(phalanges{id}.children_ids)
    phalanges = update(phalanges{id}.children_ids(i), phalanges);
end
end

function [phalanges] = translate(id, t, phalanges)
phalanges{id}.local(1:3, 4) = phalanges{id}.local(1:3, 4) + t';
phalanges = update(id, phalanges);
end

function [phalanges] = rotate(id, axis, angle, phalanges)
phalanges{id}.local = phalanges{id}.local *  makehgtform('axisrotate', axis, angle);
phalanges = update(id, phalanges);
end

