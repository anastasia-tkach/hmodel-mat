close all;
num_thetas = 29;

path = 'C:\Developer\hmodel-cuda-build\data\sensor\hmodel_solutions.txt';
fileID = fopen(path, 'r');
Data = fscanf(fileID, '%f');
N = length(Data)/num_thetas;
Data = reshape(Data, num_thetas, N)';
%Data = Data(180:230, :);
L = length(Data);


for index = [1:6, 11, 15, 19, 23, 27]
    sequence = Data(:, index);
    initialization = [0; sequence(1:end - 1)];

    velocity = zeros(size(sequence));
    acceleration = zeros(size(sequence));
    error_before = zeros(size(sequence));
    error_now = zeros(size(sequence));
    alpha = 0.8;
    for i = 2:L
        velocity(i) = sequence(i) - sequence(i - 1);
    end
    prediction = initialization;
    for i = 4:length(sequence)       
       
        velocity = sequence(i - 1) - sequence(i - 2);
        if (velocity > pi || velocity < - pi)
            velocity = 0;
        end
        prediction(i) = sequence(i - 1) + 0.6 * velocity;
        
        f = 0.15;
        if (index > 3) 
            if abs(prediction(i) - sequence(i -1)) > f
                prediction(i) = sequence(i -1) + f * sign(prediction(i) - sequence(i -1));
            end
        end
        
        
        %% Compute error
        error_before(i) = abs(sequence(i) - initialization(i));
        error_now(i) = abs(sequence(i) - prediction(i));

    end
    
    figure; hold on;
    plot(sequence, 'lineWidth', 2);
    plot(prediction, 'lineWidth', 2);
    plot(initialization, 'lineWidth', 2);
   
    %for i = 1:L
    %   mypoint([i, sequence(i)], 'b');
    %   mypoint([i, prediction(i)], 'r');
    %   mypoint([i, initialization(i)], [1, 0.5, 0]);
    %end
    
    legend({'sequence', 'prediction', 'initialization'});
    title(['before = ' num2str(mean(error_before)), ', now = ', num2str(mean(error_now))])
    
    difference = 100 * (mean(error_before) - mean(error_now)) / mean(error_before);
    disp([num2str(index), ': ', num2str(difference)]);
    
    
end




