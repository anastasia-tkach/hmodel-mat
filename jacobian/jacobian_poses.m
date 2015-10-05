function [f, J_ci, J_cj, J_ck, J_cl] = jacobian_poses(ci, cj, ck, cl)

f = @(ci, cj, ck, cl) (ci - cj)' * (ci - cj) - (ck - cl)' * (ck - cl);

J_ci = @(ci, cj, ck, cl) 2 *  ci' - 2 * cj';
J_cj = @(ci, cj, ck, cl) 2 *  cj' - 2 * ci';
J_ck = @(ci, cj, ck, cl) - 2 *  ck' + 2 * cl';
J_cl = @(ci, cj, ck, cl) - 2 * cl' + 2 * ck';

% f_ci = @(ci) f(ci, cj, ck, cl);
% f_cj = @(cj) f(ci, cj, ck, cl);
% f_ck = @(ck) f(ci, cj, ck, cl);
% f_cl = @(cl) f(ci, cj, ck, cl);
% disp([gradient(f_ci, ci); J_ci(ci, cj, ck, cl)]);
% disp([gradient(f_cj, cj); J_cj(ci, cj, ck, cl)]);
% disp([gradient(f_ck, ck); J_ck(ci, cj, ck, cl)]);
% disp([gradient(f_cl, cl); J_cl(ci, cj, ck, cl)]);

f = f(ci, cj, ck, cl);
J_ci = J_ci(ci, cj, ck, cl);
J_cj = J_cj(ci, cj, ck, cl);
J_ck = J_ck(ci, cj, ck, cl);
J_cl = J_cl(ci, cj, ck, cl);