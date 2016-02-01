%% Generate a point
n0 = randi([1, settings.H], 1);
m0 = randi([1, settings.W], 1);
x = n0;
y = m0;
A = [(bounding_box.max_x - bounding_box.min_x) / (settings.W - 1), 0, bounding_box.min_x;
     0, (bounding_box.max_y - bounding_box.min_y) / (settings.H - 1), bounding_box.min_y;
     0, 0, 1];
d = A * [x; y; 1];

%% Find n and m
r  = d(1);
x = r - bounding_box.min_x;
x = x / (bounding_box.max_x - bounding_box.min_x);
x = x * (settings.W - 1);
n = x;

c = d(2);
y = c - bounding_box.min_y;
y = y / (bounding_box.max_y - bounding_box.min_y);
y = y * (settings.H - 1);
m = y;

[m0 m]
[n0 n]