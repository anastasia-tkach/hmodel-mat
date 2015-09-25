function [] = draw_conic_surfaces_analytically(c1, c2, r1, r2, color)

z = c1 + (c2 - c1) * r1 / (r1 - r2);
beta = asin((r1 - r2) /norm(c1 - c2));
r = r1 * cos(beta);

%% External conic surface

translation_vector = z;
cone_direction = (c1 - c2) / norm(c1 - c2);

eta1 = r1 * sin(beta);
s1 = c1 - eta1 * cone_direction;
eta2 = r2 * sin(beta);
s2 = c2 - eta2 * cone_direction;

h_top = norm(s2 - z);
h_bottom = norm(s1 - z);

draw_trimmed_cone(r, h_top, h_bottom, cone_direction, translation_vector, color);

%% Big internal conic surface
translation_vector = c1;
cone_direction = (c2 - c1) / norm(c1 - c2);
r = r1 * cos(beta);
h = r1 * sin(beta);

draw_cone(r, h, cone_direction, translation_vector, color);

%% Small internal conic surface
translation_vector = c2;
cone_direction = (c2 - c1) / norm(c1 - c2);
r = r2 * cos(beta);
h = r2 * sin(beta);

draw_cone(r, h, cone_direction, translation_vector, color);

