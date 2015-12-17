#pragma once

///--- Standard library IO
#include <iostream>
#include <cassert>

///--- On some OSs the exit flags are not defined
#ifndef EXIT_SUCCESS
#define EXIT_SUCCESS 0
#endif
#ifndef EXIT_FAILURE
#define EXIT_FAILURE 1
#endif

#include <GL/glew.h> 
#include <GL/glfw.h>

#include <Eigen/Dense>

#include <OpenGP/GL/EigenOpenGLSupport3.h>
#include "OpenGP/GL/shader_helpers.h"
#include <OpenGP/GL/glfw_helpers.h>
#include <OpenGP/Surface_mesh.h>

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>

using namespace opengp;
using namespace Eigen;
using namespace std;

int window_left = 0;
int window_bottom = 0;
int window_width = 1920;
int window_height = 1080;

GLuint vertex_array;
GLuint program_id;
GLuint memory_buffer;
GLuint texture_id;

struct Light {
	Vector3f Ia = Vector3f(1.0f, 1.0f, 1.0f);
	Vector3f Id = Vector3f(1.0f, 1.0f, 1.0f);
	Vector3f Is = Vector3f(1, 1, 1);

	Vector3f light_pos = Vector3f(0.0f, 0.0f, 0.01f);

	///--- Pass light properties to the shader
	void setup() {
		glUseProgram(program_id);
		GLuint light_pos_id = glGetUniformLocation(program_id, "light_pos"); //Given in camera space
		GLuint Ia_id = glGetUniformLocation(program_id, "Ia");
		GLuint Id_id = glGetUniformLocation(program_id, "Id");
		GLuint Is_id = glGetUniformLocation(program_id, "Is");
		glUniform3fv(light_pos_id, ONE, light_pos.data());
		glUniform3fv(Ia_id, ONE, Ia.data());
		glUniform3fv(Id_id, ONE, Id.data());
		glUniform3fv(Is_id, ONE, Is.data());
	}
};

struct Material {
	Vector3f ka = 0.5 * Vector3f(0.9176, 0.7412, 0.6157);
	Vector3f kd = 0.7 * Vector3f(0.9176, 0.7412, 0.6157);
	Vector3f ks = Vector3f(0, 0, 0);
	float p = 60.0f;

	///--- Pass material properties to the shaders
	void setup() {
		glUseProgram(program_id);
		GLuint ka_id = glGetUniformLocation(program_id, "ka");
		GLuint kd_id = glGetUniformLocation(program_id, "kd");
		GLuint ks_id = glGetUniformLocation(program_id, "ks");
		GLuint p_id = glGetUniformLocation(program_id, "p");
		glUniform3fv(ka_id, ONE, ka.data());
		glUniform3fv(kd_id, ONE, kd.data());
		glUniform3fv(ks_id, ONE, ks.data());
		glUniform1f(p_id, p);
	}
};

struct Canvas {

	void setup() {
		///--- Vertex one vertex Array
		glGenVertexArrays(1, &vertex_array);
		glBindVertexArray(vertex_array);

		///--- Vertex coordinates
		const GLfloat position[] = {
			/*V1*/ -1.0f, -1.0f, 0.0f,
			/*V2*/ +1.0f, -1.0f, 0.0f,
			/*V3*/ -1.0f, +1.0f, 0.0f,
			/*V4*/ +1.0f, +1.0f, 0.0f };

		///--- Buffer
		glGenBuffers(1, &memory_buffer);
		glBindBuffer(GL_ARRAY_BUFFER, memory_buffer);
		glBufferData(GL_ARRAY_BUFFER, sizeof(position), position, GL_STATIC_DRAW);

		///--- Attribute
		GLuint position_id = glGetAttribLocation(program_id, "position");
		glEnableVertexAttribArray(position_id);
		glVertexAttribPointer(position_id, 3, GL_FLOAT, DONT_NORMALIZE, ZERO_STRIDE, ZERO_BUFFER_OFFSET);

		/// Specify window bounds
		glUniform1f(glGetUniformLocation(program_id, "window_left"), window_left);
		glUniform1f(glGetUniformLocation(program_id, "window_bottom"), window_bottom);
		glUniform1f(glGetUniformLocation(program_id, "window_height"), window_height);
		glUniform1f(glGetUniformLocation(program_id, "window_width"), window_width);
	}
};

struct Texture {
	void setup() {
		///--- Texture coordinates
		const GLfloat vtexcoord[] = {
			/*V1*/ 0.0f, 0.0f,
			/*V2*/ 1.0f, 0.0f,
			/*V3*/ 0.0f, 1.0f,
			/*V4*/ 1.0f, 1.0f };

		///--- Buffer
		glGenBuffers(1, &memory_buffer);
		glBindBuffer(GL_ARRAY_BUFFER, memory_buffer);
		glBufferData(GL_ARRAY_BUFFER, sizeof(vtexcoord), vtexcoord, GL_STATIC_DRAW);

		///--- Attribute
		GLuint vtexcoord_id = glGetAttribLocation(program_id, "vtexcoord");
		glEnableVertexAttribArray(vtexcoord_id);
		glVertexAttribPointer(vtexcoord_id, 2, GL_FLOAT, DONT_NORMALIZE, ZERO_STRIDE, ZERO_BUFFER_OFFSET);

		///--- Load texture
		glGenTextures(1, &texture_id);
		glBindTexture(GL_TEXTURE_2D, texture_id);
		glfwLoadTexture2D("quad_texture.tga", 0);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

		///--- Texture uniforms
		GLuint tex_id = glGetUniformLocation(program_id, "tex");
		glUniform1i(tex_id, 0 /*GL_TEXTURE0*/);
	}
};

struct Camera {
	// fovy - specifies the field of view angle, in degrees, in the y direction.
	float fovy = 45.0f;
	// specifies the aspect ratio that determines the field of view in the x direction.The aspect ratio is the ratio of x(width) to y(height).
	float aspect = window_width / (float)window_height;
	// specifies the distance from the viewer to the near clipping plane(always positive).
	float zNear = 0.1f;
	// specifies the distance from the viewer to the far clipping plane(always positive).
	float zFar = 10.0f;
	Vector3f camera_center = Vector3f(0, 0, 10);
	Vector3f image_center = Vector3f(0, 0, 0);
	Vector3f camera_up = Vector3f(0, 1, 0);
	Vector3f world_up = Vector3f(0, 1, 0);

	float d = (camera_center - image_center).norm();
	int wheel_rotation = 0;
	bool left_button_pressed = false;
	bool right_button_pressed = false;
	Vector2f cursor_position = Vector2f(window_height / 2, window_width / 2);
	Vector2f euler_angles = Vector2f(-2.472, -0.789);
	Vector2f initial_euler_angles = Vector2f(-2.472, -0.789);
	float cursor_sensitivity = 0.003f;

	void process_mouse_movement(GLfloat cursor_x, GLfloat cursor_y) {
		if (left_button_pressed) {
			float delta_x = cursor_position[0] - cursor_x;
			float delta_y = cursor_y - cursor_position[1];
			float theta = initial_euler_angles[0] + cursor_sensitivity * delta_x;
			float phi = initial_euler_angles[1] + cursor_sensitivity * delta_y;

			Vector3f x = sin(theta) * sin(phi) * Vector3f::UnitX();
			Vector3f y = cos(phi) * Vector3f::UnitY();
			Vector3f z = cos(theta) * sin(phi) * Vector3f::UnitZ();

			camera_center = d * (x + y + z);
			euler_angles = Vector2f(theta, phi);
		}		
		else {
			cursor_position = Vector2f(cursor_x, cursor_y);
			initial_euler_angles = euler_angles;
		}		
	}

	void process_mouse_scroll(GLfloat rotation) {
		fovy += 2 * (rotation - wheel_rotation);
		wheel_rotation = rotation;
	}

	void process_mouse_button(int button) {
		if (button == 0) 
			left_button_pressed = !left_button_pressed;
		if (button == 1)
			right_button_pressed = !right_button_pressed;
	}

	void setup() {

		cout << euler_angles.transpose() << endl;

		Matrix4f projection = Eigen::perspective(fovy, aspect, zNear, zFar);
		Matrix4f view = Eigen::lookAt(camera_center, image_center, camera_up);
		Matrix4f model = Matrix4f::Identity();

		Matrix4f MVP = projection * view * model;
		Matrix4f invMVP = MVP.inverse();

		// test_project_unproject(projection, model, view);
		glUniform3fv(glGetUniformLocation(program_id, "camera_center"), 1, camera_center.data());
		glUniformMatrix4fv(glGetUniformLocation(program_id, "MVP"), 1, GL_FALSE, MVP.data());
		glUniformMatrix4fv(glGetUniformLocation(program_id, "invMVP"), 1, GL_FALSE, invMVP.data());

		glUniformMatrix4fv(glGetUniformLocation(program_id, "model"), ONE, DONT_TRANSPOSE, model.data());
		glUniformMatrix4fv(glGetUniformLocation(program_id, "view"), ONE, DONT_TRANSPOSE, view.data());
		glUniformMatrix4fv(glGetUniformLocation(program_id, "projection"), ONE, DONT_TRANSPOSE, projection.data());
	}
};

struct Model {
	int D = 3;
	string path = "C:\\Users\\tkach\\Desktop\\sphere3d-build\\Input\\";

	vector<double> parse_line(string line) {
		istringstream iss(line);
		vector<string> tokens;
		vector<double> numbers;
		copy(istream_iterator<string>(iss),
			istream_iterator<string>(),
			back_inserter(tokens));
		for (size_t i = 0; i < tokens.size(); i++) {
			numbers.push_back(std::stod(tokens[i]));
		}
		return numbers;
	}

	void get_input_matrix(string name, MatrixXd & input) {
		string line;
		ifstream inputfile(path + name + ".txt");
		bool first_line = true;
		if (inputfile.is_open()) {
			while (getline(inputfile, line)) {
				vector<double> numbers = parse_line(line);
				if (first_line) {
					input = MatrixXd::Zero(numbers[0], numbers[1]);
					first_line = false;
				}
				else {
					for (size_t k = 0; k < numbers.size(); k++) {
						int i = k % input.rows();
						int j = k / input.rows();
						input(i, j) = numbers[k];
					}
				}
			}
			inputfile.close();
		}
	}

	template <class T>
	vector<T> parse_centers(double * P, int N) {
		vector<T> centers;
		for (size_t i = 0; i < N; i++) {
			T center = T::Zero();
			for (size_t j = 0; j < D; j++) {
				center[j] = P[j * N + i];
			}
			centers.push_back(center);
		}
		return centers;
	}

	vector<float> parse_radii(double * P, int N) {
		vector<float> radii;
		for (size_t i = 0; i < N; i++) {					
			radii.push_back(P[i]);
		}
		return radii;
	}

	vector< vector<Vector3f>> parse_tangent_points(double * T, int N) {
		vector< vector<Vector3f>> tangents;
		vector<Vector3f> tangents_v1;
		vector<Vector3f> tangents_v2;
		vector<Vector3f> tangents_v3;
		vector<Vector3f> tangents_u1;
		vector<Vector3f> tangents_u2;
		vector<Vector3f> tangents_u3;
		for (size_t i = 0; i < N; i++) {
			Vector3f tangent = Vector3f::Zero();
			tangents_v1.push_back(tangent);
			tangents_v2.push_back(tangent);
			tangents_v3.push_back(tangent);
			tangents_u1.push_back(tangent);
			tangents_u2.push_back(tangent);
			tangents_u3.push_back(tangent);
			if (T[i] >= RAND_MAX) {				
				continue;
			}
			for (size_t j = 0; j < D; j++) {
				tangents_v1[i][j] = T[(j + 0) * N + i];
				tangents_v2[i][j] = T[(j + 3) * N + i];
				tangents_v3[i][j] = T[(j + 6) * N + i];
				tangents_u1[i][j] = T[(j + 9) * N + i];
				tangents_u2[i][j] = T[(j + 12) * N + i];
				tangents_u3[i][j] = T[(j + 15) * N + i];
			}
		}
		tangents.push_back(tangents_v1);
		tangents.push_back(tangents_v2);
		tangents.push_back(tangents_v3);
		tangents.push_back(tangents_u1);
		tangents.push_back(tangents_u2);
		tangents.push_back(tangents_u3);
		return tangents;
	}
	
	void setup() {

		MatrixXd B, T, C, R;
		get_input_matrix("B", B);
		get_input_matrix("T", T);
		get_input_matrix("C", C);
		get_input_matrix("R", R);

		double * B_pointer = B.data();
		double * T_pointer = T.data();
		
		vector<Vector3f> centers = parse_centers<Vector3f>(C.data(), C.rows());
		vector<float> radii = parse_radii(R.data(), R.rows());
		vector<Vector3i> blocks = parse_centers<Vector3i>(B.data(), B.rows());
		vector<vector<Vector3f>> tangents = parse_tangent_points(T_pointer, T.rows());
		vector<Vector3f> tangents_v1 = tangents[0];
		vector<Vector3f> tangents_v2 = tangents[1];
		vector<Vector3f> tangents_v3 = tangents[2];
		vector<Vector3f> tangents_u1 = tangents[3];
		vector<Vector3f> tangents_u2 = tangents[4];
		vector<Vector3f> tangents_u3 = tangents[5];
		
		glUniform1f(glGetUniformLocation(program_id, "num_blocks"), blocks.size());
		glUniform3fv(glGetUniformLocation(program_id, "centers"), centers.size(), (GLfloat *)centers.data());
		glUniform1fv(glGetUniformLocation(program_id, "radii"), radii.size(), (GLfloat *)radii.data());
		glUniform3iv(glGetUniformLocation(program_id, "blocks"), blocks.size(), (GLint *)blocks.data());
		glUniform3fv(glGetUniformLocation(program_id, "tangents_v1"), tangents_v1.size(), (GLfloat *)tangents_v1.data());
		glUniform3fv(glGetUniformLocation(program_id, "tangents_v2"), tangents_v2.size(), (GLfloat *)tangents_v2.data());
		glUniform3fv(glGetUniformLocation(program_id, "tangents_v3"), tangents_v3.size(), (GLfloat *)tangents_v3.data());
		glUniform3fv(glGetUniformLocation(program_id, "tangents_u1"), tangents_u1.size(), (GLfloat *)tangents_u1.data());
		glUniform3fv(glGetUniformLocation(program_id, "tangents_u2"), tangents_u2.size(), (GLfloat *)tangents_u2.data());
		glUniform3fv(glGetUniformLocation(program_id, "tangents_u3"), tangents_u3.size(), (GLfloat *)tangents_u3.data());


		//GLfloat *f = (GLfloat *)radii.data();
		//for (size_t i = 0; i < 2; ++i, f += 3) 
			//printf("Index %u value %f, %f, %f\n", i, f[0], f[1], f[2]);
	}

};

Material material;
Light light;
Canvas canvas;
Texture texture;
Camera camera;
Model model;

void test_project_unproject(Matrix4f projection, Matrix4f model, Matrix4f view) {

	/*glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(fovy, aspect, zNear, zFar);
	GLdouble gl_projection[16];
	glGetDoublev(GL_PROJECTION_MATRIX, gl_projection);

	glMatrixMode(GL_MODELVIEW); glLoadIdentity();
	gluLookAt(camera_center(0), camera_center(1), camera_center(2), image_center(0), image_center(1), image_center(2), camera_up(0), camera_up(1), camera_up(2));
	GLdouble gl_modelview[16];
	glGetDoublev(GL_MODELVIEW_MATRIX, gl_modelview);*/
	GLint gl_viewport[4];
	glGetIntegerv(GL_VIEWPORT, gl_viewport);

	/*vec3 X = vec3(1, 1, 1);
	float windowCoordinate[2] = {0.0f, 0.0f};
	glhProjectf(X(0), X(1), X(2), view.data(), projection.data(), viewport, windowCoordinate);
	cout << *windowCoordinate << ", " << *(windowCoordinate + 1) << endl;*/

	float winX = 512; float winY = 384; float winZ = 1;
	float objectCoordinate[3] = { 0.0f, 0.0f, 0.0f };

	GLdouble pos3D_x, pos3D_y, pos3D_z;
	GLdouble gl_projection[16];
	for (size_t i = 0; i < 16; i++) {
		gl_projection[i] = projection(i);
	}
	GLdouble gl_modelview[16];
	for (size_t i = 0; i < 16; i++) {
		gl_modelview[i] = view(i);
	}
	//glhUnProjectf(winX, winY, winZ, view.data(), projection.data(), gl_viewport, objectCoordinate);
	gluUnProject(winX, winY, winZ, gl_modelview, gl_projection, gl_viewport, &pos3D_x, &pos3D_y, &pos3D_z);
	cout << *(objectCoordinate) << ", " << *(objectCoordinate + 1) << ", " << *(objectCoordinate + 2) << endl;
	cout << pos3D_x << ", " << pos3D_y << ", " << pos3D_z << endl;
}

void init() {
	glClearColor(1, 1, 1, /*solid*/1.0); 
	glEnable(GL_DEPTH_TEST);
	program_id = opengp::load_shaders("vertex_shader.glsl", "fragment_shader.glsl");
	if (!program_id) exit(EXIT_FAILURE);
	glUseProgram(program_id);

	canvas.setup();
	model.setup();
	texture.setup();
	material.setup();
	light.setup();

	///--- to avoid the current object being polluted
	glBindVertexArray(0);
	glUseProgram(0);

}

void display() {
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glUseProgram(program_id);
	glBindVertexArray(vertex_array);
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, texture_id);

	camera.setup();	
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glBindVertexArray(0);
	glUseProgram(0);
}

void mouse_position_callback(int xpos, int ypos) {
	camera.process_mouse_movement(xpos, ypos);
}
void scroll_callback(int offset) {	
	cout << offset << endl;
	camera.process_mouse_scroll(offset);
}
void mouse_button_callback(int button, int) {
	camera.process_mouse_button(button);
}


int main(int, char**) {
	glfwInitWindowSize(window_width, window_height);
	glfwCreateWindow("Title");
	glfwDisplayFunc(display);

	glfwSetMousePosCallback(mouse_position_callback);
	glfwSetMouseButtonCallback(mouse_button_callback);	
	glfwSetMouseWheelCallback(scroll_callback);

	init();
	glfwMainLoop();
	return EXIT_SUCCESS;
}
