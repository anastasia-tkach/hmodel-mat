function [] = draw_triangle(a, b, c, color)

face_alpha = 1;
fill3([a(1); b(1); c(1)], [a(2); b(2); c(2)], [a(3); b(3); c(3)], color, 'EdgeColor','none', 'FaceAlpha', face_alpha);