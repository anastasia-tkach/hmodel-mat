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
    if isempty(history{iter}), break; end;
    
    %% Total energy
    Energy = history{iter}.energy;
    disp(' '); disp(['ENERGY = ', num2str(Energy)]); %disp(' '); disp(' '); disp(' ');
    
    %% Energy 2
    if settings.energy2
        Energy2 = settings.w2 * history{iter}.f2' * history{iter}.f2;
        disp(['   Energy 2 = ', num2str(Energy2)]);
    end
    
    for p = 1:length(history{1}.poses)
        disp([' Pose ', num2str(p)]);
        
        if iter == last_iter
            if D == 3
                history{iter}.poses{p} = display_result_convtriangles(history{iter}.poses{p}, history{iter}.blocks, history{iter}.radii, false); drawnow
            else
                display_result_2D(history{iter}.poses{p}, history{iter}.blocks, history{iter}.radii, true); drawnow;
            end
        end
        
        %% Energy 1
        if settings.energy1
            Energy1 = settings.w1 * history{iter}.poses{p}.f1' * history{iter}.poses{p}.f1;
            disp(['   Energy 1 = ', num2str(Energy1)]);
        end
        
        %% Energy 3       
        if settings.energy3x, Energy3x = history{iter}.poses{p}.f3x' * history{iter}.poses{p}.f3x; disp(['   Energy 3x = ', num2str(Energy3x)]); end;
        if settings.energy3y, Energy3y = history{iter}.poses{p}.f3y' * history{iter}.poses{p}.f3y; disp(['   Energy 3y = ', num2str(Energy3y)]); end;
        if settings.energy3z, Energy3z = history{iter}.poses{p}.f3z' * history{iter}.poses{p}.f3z; disp(['   Energy 3z = ', num2str(Energy3z)]); end;
        
        %% Energy 4
        if settings.energy4
            Energy4 = settings.w4 * history{iter}.poses{p}.f4' * history{iter}.poses{p}.f4;
            disp(['   Energy 4 = ', num2str(Energy4)]);
        end
        
        %% Energy 5
        if settings.energy5
            Energy5 = settings.w5 * history{iter}.poses{p}.f5' * history{iter}.poses{p}.f5;
            disp(['   Energy 5 = ', num2str(Energy5)]);
        end
        
    end   

    
end
