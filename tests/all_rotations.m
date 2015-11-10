euler_angles_123 = SpinCalc('DCMtoEA123', R, 1e-10, 0) / 180 * pi;
euler_angles_132 = SpinCalc('DCMtoEA132', R, 1e-10, 0) / 180 * pi;
euler_angles_213 = SpinCalc('DCMtoEA213', R, 1e-10, 0) / 180 * pi;
euler_angles_231 = SpinCalc('DCMtoEA231', R, 1e-10, 0) / 180 * pi;
euler_angles_312 = SpinCalc('DCMtoEA312', R, 1e-10, 0) / 180 * pi;
euler_angles_321 = SpinCalc('DCMtoEA321', R, 1e-10, 0) / 180 * pi;

theta = euler_angles_132;
R2 = Rx(theta(1)) * Rz(theta(2)) * Ry(theta(3));
R3 = Ry(theta(3))' *  Rz(theta(2))' * Rx(theta(1))';
%disp(R')
%disp(R2)
%indices = {[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]};
%for t = 1:length(indices)
%    tt = theta(indices{t});
%     R2 = Rx(tt(1)) * Ry(tt(2)) * Rz(tt(3))
%     R2 = Rx(tt(1)) * Rz(tt(2)) * Ry(tt(3))
%     R2 = Ry(tt(1)) * Rx(tt(2)) * Rz(tt(3))
%     R2 = Ry(tt(1)) * Rz(tt(2)) * Rx(tt(3))
%     R2 = Rz(tt(1)) * Rx(tt(2)) * Ry(tt(3))
%     R2 = Rz(tt(1)) * Ry(tt(2)) * Rx(tt(3))
% end
