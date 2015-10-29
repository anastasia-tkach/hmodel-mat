function [gradients] = get_parameters_gradients(index, attachments, D)

gradients = cell(0, 1); %#ok<*AGROW>

%% Sphere
if length(index) == 1
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
end

%% Convolution segment
if length(index) == 2
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
end

%% Convolution triangle
if length(index) == 3
    index = abs(index);
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
end