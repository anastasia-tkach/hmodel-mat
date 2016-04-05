function [] = a()

%% init & params
t = (-50 : 0.2 : 100)';
y = sin(t) + 0.5 * sin(t + pi / 3);
sigma = 0.2;
n_lags = 12;
hidden_layer_size = 15;
%% create net
net = fitnet(hidden_layer_size);
%% train
noise = sigma * randn(size(t));
y_train = y + noise;
out = circshift(y_train, -1);
out(end) = nan;
in = lagged_input1(y_train, n_lags);
net = train(net, in', out');
%% test
noise = sigma * randn(size(t)); % new noise
y_test = y + noise;
in_test = lagged_input1(y_test, n_lags);
out_test = net(in_test')';
y_test_predicted = circshift(out_test, 1); % sync with actual value
y_test_predicted(1) = nan;
%% plot
figure, 
plot(t, [y, y_test, y_test_predicted], 'linewidth', 2); 
grid minor; legend('orig', 'noised', 'predicted')


end

function in = lagged_input1(in, n_lags)
    for k = 2 : n_lags
        in = cat(2, in, circshift(in(:, end), 1));
        in(1, k) = nan;
    end
end