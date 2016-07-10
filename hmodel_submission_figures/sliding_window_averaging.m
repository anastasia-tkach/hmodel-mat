function [error] = sliding_window_averaging(error, half_window_size)

for i = 1 + half_window_size:length(error) - half_window_size
    error(i) = mean(error(i - half_window_size:i + half_window_size));
end
