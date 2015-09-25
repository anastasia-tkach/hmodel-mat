function examine_history(settings, history)
D = settings.D;
set_path;

%load('C:\Users\tkach\OneDrive\EPFL\Code\HandModel\rendering\history.mat');
close all;
last_iter = 1;
for iter = 1:length(history)
    if ~isempty(history{iter}), last_iter = iter; end
end
last_iter = last_iter - 1;
for iter = 1:last_iter
    if isempty(history{iter}) break; end;
    Energy = 0; Energy1 = 0; Energy2 = 0; Energy3 = 0;
    for p = 1:length(history{1}.poses)
        
        %% Energy 1
        if settings.energy1
            if iter == last_iter
                if D == 3
                    history{iter}.poses{p} = display_result_convtriangles(history{iter}.poses{p}, history{iter}.blocks, history{iter}.radii, true); drawnow
                else
                    display_result_2D(history{iter}.poses{p}, history{iter}.blocks, history{iter}.radii, true); drawnow;
                end
            end
            Energy1 = 0;
            for i = 1:length(history{iter}.poses{p}.points)
                if ~isempty(history{iter}.poses{p}.indices{i})
                    Energy1 = Energy1 + norm(history{iter}.poses{p}.points{i} - history{iter}.poses{p}.projections{i});
                end
            end
            %disp(['   Energy 1 = ', num2str(settings.w1 * Energy1)]);
        end
        
        %% Energy 2
        Energy2 = 0;
        blocks = history{iter}.blocks;
        if (p > 2)
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
                    Energy2 = Energy2 + abs(norm(history{iter}.poses{1}.centers{i} - history{iter}.poses{1}.centers{j}) ...
                        - norm(history{iter}.poses{p}.centers{i} - history{iter}.poses{p}.centers{j}));
                end
            end
            %disp(['            Energy 2 = ', num2str(settings.w2 * Energy2)]);
        end
        
        %% Energy 3
        if settings.energy3x ||  settings.energy3y || settings.energy3z
            %display_energy3_3D(history{iter}.poses{p}, history{iter}.blocks, history{iter}.radii, settings);
        end
        
        Energy3x = 0; Energy3y = 0; Energy3z = 0;
        if settings.energy3x
            Energy3x = history{iter}.poses{p}.f3x' * history{iter}.poses{p}.f3x;
        end
        if settings.energy3y
            Energy3y = history{iter}.poses{p}.f3y' * history{iter}.poses{p}.f3y;
        end
        if settings.energy3z
            Energy3z = history{iter}.poses{p}.f3z' * history{iter}.poses{p}.f3z;
        end
        %disp(['               Energy 3 = ', num2str(settings.w3 * Energy3x), ',            ', ...
        %num2str(settings.w3 * Energy3y), ',            ', num2str(settings.w3 * Energy3z)]);
    end
    
    %% Total energy
    Energy = history{iter}.energy;
    %Energy + settings.w1 * Energy1 + settings.w2 * Energy2 + settings.w3 * (Energy3x + Energy3y + Energy3z);
    disp(' '); disp(['ENERGY = ', num2str(Energy)]); %disp(' '); disp(' '); disp(' ');
    
end
