function [mesh] = generate_segment_mesh(c1, c2, r1, r2)

sphere1 = generate_sphere_mesh(c1', r1);
sphere2 = generate_sphere_mesh(c2', r2);

sphere1 = remove_interior_vertices(sphere1, c1, c2, r1, r2);
sphere2 = remove_interior_vertices(sphere2, c2, c1, r1, r2);
cylinder = generate_cylinder_mesh(r1, r2, c1, c2);

mesh.vertices = [sphere1.vertices; cylinder.vertices; sphere2.vertices];

cylinder.triangles = cylinder.triangles + size(sphere1.vertices, 1);
sphere2.triangles = sphere2.triangles + size(sphere1.vertices, 1) + size(cylinder.vertices, 1);

mesh.triangles = [sphere1.triangles; cylinder.triangles; sphere2.triangles];




