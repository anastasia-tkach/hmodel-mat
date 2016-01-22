function [special_centers] = get_special_spheres(names_map, named_special_centers)

special_centers = zeros(length(named_special_centers), 1);
for i = 1:length(named_special_centers)
    key = named_special_centers(i);
    special_centers(i) = names_map(key{1});
end