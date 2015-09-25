N = 5;
a = rand(5, 1);
b = rand(5, 1);
c = test_mex(a, b);
disp([c, a + b]);