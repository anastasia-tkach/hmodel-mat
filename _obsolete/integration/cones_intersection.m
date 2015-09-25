close all; clc; clear;

figure; hold on;

c1 = 0.02;
alpha = 0;
beta = 0;
shift = [0; 0; 0];
right_circular_cone('c', c1, alpha, beta, shift);

c2 = 0.006;
alpha = 0;
beta = pi/4;
shift = [0; -2; 0];
right_circular_cone('y', c2, alpha, beta, shift);

