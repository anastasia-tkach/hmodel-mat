#version 330 core
uniform mat4 MVP;
in vec3 position;
out vec2 uv;

void main() {
	gl_Position = vec4(position, 1.0);
    //gl_Position = MVP * vec4(position, 1.0);
    //uv = vtexcoord;

    uv = (vec2(position) + vec2(1,1))/2.0; 
}


