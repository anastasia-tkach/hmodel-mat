#version 330 core
uniform mat4 MVP;
in vec3 position;
in vec3 point;
out vec2 uv;

/*out ivec2 point_final;

uniform float window_left;
uniform float window_bottom;
uniform float window_height;
uniform float window_width;*/

void main() {
	gl_Position = vec4(position, 1.0);
    //gl_Position = MVP * vec4(position, 1.0);
    //uv = vtexcoord;

    uv = (vec2(position) + vec2(1,1))/2.0; 

	/*vec4 point_gl =  MVP * vec4(point, 1.0);
    vec3 point_clip = vec3(point_gl[0], point_gl[1], point_gl[2]) / point_gl[3];
	int n = 0; int f = 1; 
	float ox = window_left + window_width/2;
	float oy = window_bottom + window_height/2;
	
    float xd = point_clip[0];
    float yd = point_clip[1];
    float zd = point_clip[2];
	vec3 point_window = vec3(0, 0, 0);
    point_window[0] = xd * window_width / 2 + ox;
    point_window[1] = yd * window_height / 2 + oy;
    point_window[2] = zd * (f - n) / 2 + (n + f) / 2;

	int i1 = int(point_window[0]);
	int i2 = int(point_window[1]);
    point_final = ivec2(i1, i2);*/
}


