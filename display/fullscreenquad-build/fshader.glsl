#version 330

in vec2 uv;
// [0,1]
out vec3 color;
///--- Window dimension
uniform float window_h;
uniform float window_w;
uniform vec3 camera_position;

in vec4 gl_FragCoord;
out float gl_FragDepth;
in vec2 gl_PointCoord;
in int gl_PrimitiveID;

void main() {
    vec2 pixel = vec2(window_w, window_h) * uv;
    vec2 center = vec2(window_w/2,window_h/2);
    float r = window_h/2;
    if( length(pixel-center)<r )
		color = vec3(1, 1, 1);
    else
        color = vec3(0,0,0);
}