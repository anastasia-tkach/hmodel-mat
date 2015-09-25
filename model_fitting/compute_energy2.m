function [f2, J2] = compute_energy2(poses, blocks, num_centers, num_parameters, num_links)
D = 3;
f2 = zeros(num_links, 1);
J2 = zeros(num_links, num_parameters);
count = 1;
for k = 2:length(poses)
    for b = 1:length(blocks)
        if (length(blocks{b}) == 2)
            index1 = blocks{b}(1);
            index2 = blocks{b}(2);
        end
        if (length(blocks{b}) == 3)
            index1 = [blocks{b}(1), blocks{b}(1), blocks{b}(2)];
            index2 = [blocks{b}(2), blocks{b}(3), blocks{b}(3)];
        end
        for l = 1:length(index1)
            i = index1(l);
            j = index2(l);
            [fi, Ja, Jb, Jc, Jd] = energy2(poses{1}.centers{i}, poses{1}.centers{j}, poses{k}.centers{i}, poses{k}.centers{j});
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
