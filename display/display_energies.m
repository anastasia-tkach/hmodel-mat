function [] = display_energies(history, mode)

switch mode
    case 'fitting'
        names = {'1', '2', '3', '4', '5', '6', '7'};
    case 'tracking'
        names = {'data-model', 'ARAP', 'collisions', 'joint-limits', 'silhouette', 'shape-existence'};
    case 'IK'
        names = {'data-model', 'joint-limits'};
end

E = zeros(length(history)-1, length(history{2}.energies));
for h = 2:length(history)
    for k = 1:length(history{h}.energies)
        E(h - 1, k) = history{h}.energies(k);
    end
end
figure; hold on; plot(2:length(history), E, 'lineWidth', 2);
legend(names);
