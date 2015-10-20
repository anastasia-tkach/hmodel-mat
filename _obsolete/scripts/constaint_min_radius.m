wr = 1000000;

if ...

%% Add constraints on r_min
new_radii = zeros(length(radii), 1);
for o = 1:length(radii)
    new_radii(o) = radii{o} + delta(D * num_centers * num_poses + o);
end
if ~isempty(find(new_radii < 0)) && (wr < 1e16)
    wr = wr * 2;
    disp(['    wr = ', num2str(wr)]);
    contraint_indices = find(new_radii < 0);
    for o = contraint_indices
        fr(D * num_centers * num_poses + o) = settings.r_min - radii{o};
        Jr(D * num_centers * num_poses + o, D * num_centers * num_poses + o) = 1;
    end
    if (wr > 1e16), continue; end
end

end