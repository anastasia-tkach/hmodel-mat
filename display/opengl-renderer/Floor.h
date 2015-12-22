#pragma once
#include <iostream>
#include <cassert>
#include <vector>

#include <GL/glew.h> 
#include <GL/glfw.h>

#include <Eigen/Dense>
typedef Eigen::Vector2f vec2;
typedef Eigen::Vector3f vec3;
typedef Eigen::Vector4f vec4;
typedef Eigen::Matrix4f mat4;
typedef Eigen::Matrix3f mat3;

#include <OpenGP/GL/EigenOpenGLSupport3.h>
#include "OpenGP/GL/shader_helpers.h"
#include <OpenGP/GL/glfw_helpers.h>
#include <OpenGP/Surface_mesh.h>

using namespace std;

class Floor {
public:
	GLuint _vao; ///< vertex array object
	GLuint _pid; ///< GLSL shader program ID 
	GLuint _vbo; ///< memory buffer

	void init(std::vector<vec3> points) {

		///--- Compile the shaders
		_pid = opengp::load_shaders("floor_vshader.glsl", "floor_fshader.glsl");
		if (!_pid) exit(EXIT_FAILURE);
		glUseProgram(_pid);

		///--- Vertex one vertex Array
		glGenVertexArrays(1, &_vao);
		glBindVertexArray(_vao);

		///--- Vertex coordinates
		//const GLfloat vpoint[] = { /*V1*/ -0.5, -0.5, 0, /*V2*/ 0.5, -0.5, 0, /*V3*/ -0.5, 0.5, 0, /*V4*/ 0.5, 0.5, 0 };

		///--- Buffer
		glGenBuffers(1, &_vbo);
		glBindBuffer(GL_ARRAY_BUFFER, _vbo);
		//glBufferData(GL_ARRAY_BUFFER, sizeof(vpoint), vpoint, GL_STATIC_DRAW);
		glBufferData(GL_ARRAY_BUFFER, sizeof(points[0]) * points.size() , (GLfloat *)points.data(), GL_STATIC_DRAW);
		
		///--- Attribute
		GLuint vpoint_id = glGetAttribLocation(_pid, "vpoint");
		glEnableVertexAttribArray(vpoint_id);
		glVertexAttribPointer(vpoint_id, 3, GL_FLOAT, DONT_NORMALIZE, ZERO_STRIDE, ZERO_BUFFER_OFFSET);

		///--- to avoid the current object being polluted
		glBindVertexArray(0);
		glUseProgram(0);
	}

	void draw(const mat4& MVP) {
		glUseProgram(_pid);
		glBindVertexArray(_vao);

		///--- Setup MVP
		GLuint MVP_id = glGetUniformLocation(_pid, "MVP");
		glUniformMatrix4fv(MVP_id, 1, GL_FALSE, MVP.data());

		///--- Draw
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glBindVertexArray(0);
		glUseProgram(0);
	}
};
