function [c] = adjust_membrane(centers, radii, names_map, membrane_name, base_name, bottom_name)

q = project_point_on_segment(centers{names_map(membrane_name)}, centers{names_map(base_name)}, centers{names_map(bottom_name)});
v = (centers{names_map(membrane_name)}  - q) / norm(centers{names_map(membrane_name)}  - q);
alpha = norm(centers{names_map(bottom_name)} - q) / norm(centers{names_map(bottom_name)} - centers{names_map(base_name)});
beta = norm(centers{names_map(base_name)} - q) / norm(centers{names_map(bottom_name)} - centers{names_map(base_name)});
r = alpha * radii{names_map(base_name)} + beta * radii{names_map(bottom_name)};
c = q + v * (r - radii{names_map(membrane_name)} + 0.01);