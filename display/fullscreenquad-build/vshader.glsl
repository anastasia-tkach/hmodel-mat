#version 330
in vec3 position;
out vec2 uv;

void main() {
    gl_Position = vec4(position, 1.0);
    uv = (vec2(position) + vec2(1,1))/2.0;   
}


