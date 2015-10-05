function [f2, J2] = compute_energy2(poses, blocks, num_centers, num_parameters, num_links, settings)
D = settings.D;
f2 = zeros(num_links, 1);
J2 = zeros(num_links, num_parameters);

switch settings.mode
    
   case 'fitting'        
        count = 1;
        for k = 2:length(poses)
            for b = 1:length(blocks)
                indices = nchoosek(blocks{b}, 2);
                index1 = indices(:, 1);
                index2 = indices(:, 2);
                for l = 1:length(index1)
                    i = index1(l);
                    j = index2(l);                    
                    [fi, Ja, Jb, Jc, Jd] = jacobian_poses(poses{1}.centers{i}, poses{1}.centers{j}, poses{k}.centers{i}, poses{k}.centers{j});
                    f2(count) = fi;
                    J2(count, D * (i - 1) + 1 : D * i) = Ja;
                    J2(count, D * (j - 1) + 1 : D * j) = Jb;
                    shift = (k - 1) * D * num_centers;
                    J2(count, shift + D * (i - 1) + 1 : shift + D * i) = Jc;
                    J2(count, shift + D * (j - 1) + 1 : shift + D * j) = Jd;
                    
                    count = count + 1;
                end
            end
        end
        
    case 'tracking'        
        count = 1;
        for b = 1:length(blocks)
            indices = nchoosek(blocks{b}, 2);
            index1 = indices(:, 1);
            index2 = indices(:, 2);
            for l = 1:length(index1)
                i = index1(l);
                j = index2(l);
                [fi, Ja, Jb] = jacobian_shape(poses{1}.centers{i}, poses{1}.centers{j}, poses{1}.invariants(count));
                f2(count) = fi;
                J2(count, D * (i - 1) + 1 : D * i) = Ja;
                J2(count, D * (j - 1) + 1 : D * j) = Jb;
                count = count + 1;
            end
        end
        
end


