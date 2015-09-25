function [inside] = test_insideness(p, q, s)
inside = false;
if norm(p - s) < norm(q - s)
    inside = true;
end