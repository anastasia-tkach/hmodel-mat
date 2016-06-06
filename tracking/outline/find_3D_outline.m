function [outline] = find_3D_outline(centers, outline)

for i = 1:length(outline)
    if isempty(outline{i})
        disp('empty');
        continue; 
    end
    if length(outline{i}.indices) == 2
        c1 = centers{outline{i}.indices(1)};
        c2 = centers{outline{i}.indices(2)};
        alpha = norm(outline{i}.t1 - outline{i}.start) / norm(outline{i}.t1 - outline{i}.t2);
        z_start = c1(3) * (1 - alpha) + c2(3) * alpha;
        alpha = norm(outline{i}.t1 - outline{i}.end) / norm(outline{i}.t1 - outline{i}.t2);
        z_end = c1(3) * (1 - alpha) + c2(3) * alpha;       
        outline{i}.start = [outline{i}.start; z_start];
        outline{i}.end = [outline{i}.end; z_end];
    else
        z_start = centers{outline{i}.indices(1)}(3);
        z_end = centers{outline{i}.indices(1)}(3);
        outline{i}.start = [outline{i}.start; z_start];
        outline{i}.end = [outline{i}.end; z_end];
    end   
end

print_outline(outline);

end

function print_outline(outline)
for i = 1:length(outline)
    disp(['outline[', num2str(i - 1), ']']);    
    disp(['   indices = ' num2str(outline{i}.indices - 1)]);
    disp(['   start = ' num2str(outline{i}.start')]);
    disp(['   end = ' num2str(outline{i}.end')]);
    disp(' ');
end
end