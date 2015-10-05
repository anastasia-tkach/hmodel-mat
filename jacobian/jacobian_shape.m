function [f, J_ci, J_cj] = jacobian_shape(ci, cj, d)

f = (ci - cj)' * (ci - cj) - d^2;

J_ci = 2 *  ci' - 2 * cj';
J_cj = 2 *  cj' - 2 * ci';

