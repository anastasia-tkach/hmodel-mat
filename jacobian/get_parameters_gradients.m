function [gradients] = get_parameters_gradients(index, attachments, D, mode)

gradients = cell(0, 1); %#ok<*AGROW>

%% Sphere
if length(index) == 1
    if strcmp(mode, 'fitting'), gradient.dr1 = zeros(1, D); end
    %% c1
    attachment = attachments{index(1)};
    if isempty(attachment)
        gradient.dc1 = eye(D, D);
        gradient.index = index(1);
        gradients{end + 1} = gradient;
    else
        for l = 1:length(attachment.indices)
            gradient.dc1 = attachment.weights(l) * eye(D, D);
            gradient.index = attachment.indices(l);
            gradients{end + 1} = gradient;
        end
    end
    %% r1
    if strcmp(mode, 'fitting'),
        gradient.dc1 = zeros(D, 1);  
        gradients{end + 1} = gradient; gradients{end}.dr1 = 1; gradients{end}.index = index(1);
    end
    
end

%% Convolution segment
if length(index) == 2
    if strcmp(mode, 'fitting'), gradient.dr1 = zeros(1, D); gradient.dr2 = zeros(1, D); end
    %% c1
    attachment = attachments{index(1)};
    if isempty(attachment)
        gradient.dc1 = eye(D, D); gradient.dc2 = zeros(D, D);
        gradient.index = index(1);
        gradients{end + 1} = gradient;
    else
        for l = 1:length(attachment.indices)
            gradient.dc1 = attachment.weights(l) * eye(D, D);
            gradient.dc2 = zeros(D, D);
            gradient.index = attachment.indices(l);
            gradients{end + 1} = gradient;
        end
    end
    %% c2
    attachment = attachments{index(2)};
    if isempty(attachment)
        gradient.dc1 = zeros(D, D); gradient.dc2 = eye(D, D);
        gradient.index = index(2);
        gradients{end + 1} = gradient;
    else
        for l = 1:length(attachment.indices)
            gradient.dc1 = zeros(D, D);
            gradient.dc2 = attachment.weights(l) * eye(D, D);
            gradient.index = attachment.indices(l);
            gradients{end + 1} = gradient;
        end
    end
    %% r1 and r2
    if strcmp(mode, 'fitting'),
        gradient.dc1 = zeros(D, 1); gradient.dc2 = zeros(D, 1); 
        gradient.dr1 = 0; gradient.dr2 = 0; 
        gradients{end + 1} = gradient; gradients{end}.dr1 = 1; gradients{end}.index = index(1);
        gradients{end + 1} = gradient; gradients{end}.dr2 = 1; gradients{end}.index = index(2);
    end
end

%% Convolution triangle
if length(index) == 3
    index = abs(index);
    if strcmp(mode, 'fitting'), gradient.dr1 = zeros(1, D); gradient.dr2 = zeros(1, D); gradient.dr3 = zeros(1, D); end
    %% c1
    attachment = attachments{index(1)};
    if isempty(attachment)
        gradient.dc1 = eye(D, D);
        gradient.dc2 = zeros(D, D); gradient.dc3 = zeros(D, D);
        gradient.index = index(1);
        gradients{end + 1} = gradient;
    else
        for l = 1:length(attachment.indices)
            gradient.dc1 = attachment.weights(l) * eye(D, D);
            gradient.dc2 = zeros(D, D); gradient.dc3 = zeros(D, D);
            gradient.index = attachment.indices(l);
            gradients{end + 1} = gradient;
        end
    end
    %% c2
    attachment = attachments{index(2)};
    if isempty(attachment)
        gradient.dc2 = eye(D, D);
        gradient.dc1 = zeros(D, D); gradient.dc3 = zeros(D, D);
        gradient.index = index(2);
        gradients{end + 1} = gradient;
    else
        for l = 1:length(attachment.indices)
            gradient.dc2 = attachment.weights(l) * eye(D, D);
            gradient.dc1 = zeros(D, D); gradient.dc3 = zeros(D, D);
            gradient.index = attachment.indices(l);
            gradients{end + 1} = gradient;
        end
    end
    %% c3
    attachment = attachments{index(3)};
    if isempty(attachment)
        gradient.dc3 = eye(D, D);
        gradient.dc1 = zeros(D, D); gradient.dc2 = zeros(D, D);
        gradient.index = index(3);
        gradients{end + 1} = gradient;
    else
        for l = 1:length(attachment.indices)
            gradient.dc3 = attachment.weights(l) * eye(D, D);
            gradient.dc1 = zeros(D, D); gradient.dc2 = zeros(D, D);
            gradient.index = attachment.indices(l);
            gradients{end + 1} = gradient;
        end
    end
    %% r1, r2 and r3
    if strcmp(mode, 'fitting'),
        gradient.dc1 = zeros(D, 1); gradient.dc2 = zeros(D, 1); gradient.dc3 = zeros(D, 1);
        gradient.dr1 = 0; gradient.dr2 = 0; gradient.dr3 = 0;
        gradients{end + 1} = gradient; gradients{end}.dr1 = 1; gradients{end}.index = index(1);
        gradients{end + 1} = gradient; gradients{end}.dr2 = 1; gradients{end}.index = index(2);
        gradients{end + 1} = gradient; gradients{end}.dr3 = 1; gradients{end}.index = index(3);
    end
end

