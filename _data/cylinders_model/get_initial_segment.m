function [Vertices, Triangles] = get_initial_segment(d, r1, r2, ratio)
u = 5;
v = 3;

a1 = r1;
b1 = r1 * ratio;
c1 = r1 * ratio;

a2 = r2;
b2 = r2 * ratio;
c2 = r2 * ratio;

Points = zeros(3, u, v);

for i = 1:u
    for j = 1:v
        theta = i*2*pi/u;        
        phi = j*pi/v/2;
        x = a2 * cos(theta)*sin(phi);
        y = b2 * sin(theta)*sin(phi);
        z = c2 * cos(phi);
        Points(1, i, j) = x;
        Points(2, i, j) = y;
        Points(3, i, j) = z + d;
    end
end

Top = repmat([0; 0; d + c2],  1, u);

Capsule = reshape(Points, 3, u*v); 
Capsule = [Top, Capsule];
Points = zeros(3, u, v);

for i = 1:u
    for j = 0:v - 1
        theta = i*2*pi/u;
        phi = pi/2 + j*pi/v/2;
        x = a1 * cos(theta)*sin(phi);
        y = b1 * sin(theta)*sin(phi);
        z = c1 * cos(phi);
        Points(1, i, j + 1) = x;
        Points(2, i, j + 1) = y;
        Points(3, i, j + 1) = z;
    end
end

Capsule = [Capsule, reshape(Points, 3, u*v) ]; 
Bottom = repmat([0; 0; - c1],  1, u);
Capsule = [Capsule, Bottom];
      
Triangles = [];
I = 1:(u*(v + 1)*2);
I = reshape(I, u, (v + 1)*2);
I = I';

I(I < u) = u;
I = I - u + 1;
I(I > 2*v*u + 2) = 2*u*v + 2;

for i = 2 : (v + 1)* 2
    for j = 1:u
        v1 = I(i, j);
        v2 = I(i - 1, j);
        j_plus = j + 1;
        if j == u
            j_plus = 1; 
        end
        v3 = I(i, j_plus);
        Triangles = [Triangles; [v1, v2, v3]];
        v4 = I(i - 1, j);
        v5 = I(i - 1, j_plus); 
        v6 = I(i, j_plus); 
        Triangles = [Triangles; [v4, v5, v6]];
    end
end

% Remove vertices added just for generating triangles
Capsule = Capsule(:, u:end - u + 1);     

 
Vertices = Capsule;

Vertices = [Vertices, [0; 0; 0], [0; 0; d]];



        
        
        