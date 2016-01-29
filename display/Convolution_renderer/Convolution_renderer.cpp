#include <iostream>
#include <vector>
#include <Eigen/Dense>
#include <GL/glew.h> 
#include <GL/glfw.h> 

#include <OpenGP/GL/EigenOpenGLSupport3.h>
#include <OpenGP/GL/glfw_helpers.h>

int window_left = 0;
int window_bottom = 0;
int window_width = 900;
int window_height = 900;

std::string path = "C:\\Users\\tkach\\OneDrive\\EPFL\\Code\\HModel\\display\\opengl-renderer-vs\\Input\\";

void get_input_matrix(std::string name, Eigen::MatrixXd & input) {
	FILE *fp = fopen((path + name + ".txt").c_str(), "r");
	int x, y;
	fscanf(fp, "%d%d", &x, &y);
	input = Eigen::MatrixXd::Zero(x, y);
	for (int j = 0; j < y; ++j) {
		for (int i = 0; i < x; ++i) {
			fscanf(fp, "%lf", &input(i, j));
		}
	}
	fclose(fp);
}

template <class T>
std::vector<T> parse_centers(double * P, int N) {
	std::vector<T> centers;
	for (size_t i = 0; i < N; i++) {
		T center = T::Zero();
		for (size_t j = 0; j < 3; j++) {
			center[j] = P[j * N + i];
		}
		centers.push_back(center);
	}
	return centers;
}

std::vector<float> parse_radii(double * P, int N) {
	std::vector<float> radii;
	for (size_t i = 0; i < N; i++) {
		radii.push_back(P[i]);
	}
	return radii;
}

std::vector< std::vector<Eigen::Vector3f>> parse_tangent_points(double * T, int N) {
	std::vector< std::vector<Eigen::Vector3f>> tangents;
	std::vector<Eigen::Vector3f> tangents_v1;
	std::vector<Eigen::Vector3f> tangents_v2;
	std::vector<Eigen::Vector3f> tangents_v3;
	std::vector<Eigen::Vector3f> tangents_u1;
	std::vector<Eigen::Vector3f> tangents_u2;
	std::vector<Eigen::Vector3f> tangents_u3;
	for (size_t i = 0; i < N; i++) {
		Eigen::Vector3f tangent = Eigen::Vector3f::Zero();
		tangents_v1.push_back(tangent);
		tangents_v2.push_back(tangent);
		tangents_v3.push_back(tangent);
		tangents_u1.push_back(tangent);
		tangents_u2.push_back(tangent);
		tangents_u3.push_back(tangent);
		if (T[i] >= RAND_MAX) {
			continue;
		}
		for (size_t j = 0; j < 3; j++) {
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



class Convolution_renderer {
	static const int ONE = 1;		

	struct Light {
		Eigen::Vector3f Ia = Eigen::Vector3f(1.0f, 1.0f, 1.0f);
		Eigen::Vector3f Id = Eigen::Vector3f(1.0f, 1.0f, 1.0f);
		Eigen::Vector3f Is = Eigen::Vector3f(1, 1, 1);
		Eigen::Vector3f light_pos = Eigen::Vector3f(0.0f, 0.0f, 0.01f);

		void setup(GLuint program_id) {
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
		Eigen::Vector3f ka = 0.5 * Eigen::Vector3f(0.9176, 0.7412, 0.6157);
		Eigen::Vector3f kd = 0.7 * Eigen::Vector3f(0.9176, 0.7412, 0.6157);
		Eigen::Vector3f ks = Eigen::Vector3f(0, 0, 0);
		float p = 60.0f;

		void setup(GLuint program_id) {
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

	struct Camera {

		float fovy = 45.0f;
		float aspect = window_width / (float)window_height;
		float zNear = 0.01f;
		float zFar = 20.0f;
		Eigen::Vector3f camera_center = Eigen::Vector3f(0, 0, -8);
		Eigen::Vector3f image_center = Eigen::Vector3f(0, 0, 0);
		Eigen::Vector3f camera_up = Eigen::Vector3f(0, 1, 0);
		Eigen::Vector3f world_up = Eigen::Vector3f(0, 1, 0);

		Eigen::Vector3f up = Eigen::Vector3f(0, 1, 0);
		Eigen::Vector3f direction = Eigen::Vector3f(0, 0, 1);

		Eigen::Matrix4f projection;
		Eigen::Matrix4f view;
		Eigen::Matrix4f model;
		Eigen::Matrix4f MVP;
		Eigen::Matrix4f invMVP;

		float d = (camera_center - image_center).norm();
		int wheel_rotation = 0;
		bool left_button_pressed = false;
		bool right_button_pressed = false;
		Eigen::Vector2f cursor_position = Eigen::Vector2f(window_height / 2, window_width / 2);
		Eigen::Vector2f euler_angles = Eigen::Vector2f(-6.411, -1.8);
		Eigen::Vector2f initial_euler_angles = Eigen::Vector2f(-6.411, -1.8);
		float cursor_sensitivity = 0.003f;

		void process_mouse_movement(GLfloat cursor_x, GLfloat cursor_y) {
			if (left_button_pressed) {
				float delta_x = cursor_position[0] - cursor_x;
				float delta_y = cursor_y - cursor_position[1];
				float theta = initial_euler_angles[0] + cursor_sensitivity * delta_x;
				float phi = initial_euler_angles[1] + cursor_sensitivity * delta_y;

				Eigen::Vector3f x = sin(theta) * sin(phi) * Eigen::Vector3f::UnitX();
				Eigen::Vector3f y = cos(phi) * Eigen::Vector3f::UnitY();
				Eigen::Vector3f z = cos(theta) * sin(phi) * Eigen::Vector3f::UnitZ();

				camera_center = d * (x + y + z);
				euler_angles = Eigen::Vector2f(theta, phi);
			}
			else {
				cursor_position = Eigen::Vector2f(cursor_x, cursor_y);
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

		void setup(GLuint program_id) {

			projection = Eigen::perspective(fovy, aspect, zNear, zFar);
			view = Eigen::lookAt(camera_center, image_center, camera_up);
			model = Eigen::Matrix4f::Identity();

			MVP = projection * view * model;
			invMVP = MVP.inverse();

			glUniform3fv(glGetUniformLocation(program_id, "camera_center"), 1, camera_center.data());
			glUniformMatrix4fv(glGetUniformLocation(program_id, "MVP"), 1, GL_FALSE, MVP.data());
			glUniformMatrix4fv(glGetUniformLocation(program_id, "invMVP"), 1, GL_FALSE, invMVP.data());

			glUniformMatrix4fv(glGetUniformLocation(program_id, "model"), ONE, false, model.data());
			glUniformMatrix4fv(glGetUniformLocation(program_id, "view"), ONE, false, view.data());
			glUniformMatrix4fv(glGetUniformLocation(program_id, "projection"), ONE, false, projection.data());
		}
	};

public: 

	Light light;
	Material material;
	Camera camera;

	GLuint vertex_array;
	GLuint program_id;
	GLuint memory_buffer;
	GLuint texture;
	std::string vertex_shader_name;
	std::string fragment_shader_name;
	std::vector<Eigen::Vector3f> points;

	void call_shader(int mode) {
		glUseProgram(program_id);
		glBindVertexArray(vertex_array);
		if (mode == GL_TRIANGLE_STRIP)
			camera.setup(program_id);
		else
			glUniformMatrix4fv(glGetUniformLocation(program_id, "MVP"), 1, GL_FALSE, camera.MVP.data());
		glDrawArrays(mode, 0, points.size());
		glBindVertexArray(0);
		glUseProgram(0);
	}

	void send_vertices_to_shader(std::string vertices_name) {

		glGenVertexArrays(1, &vertex_array);
		glBindVertexArray(vertex_array);

		glGenBuffers(1, &memory_buffer);
		glBindBuffer(GL_ARRAY_BUFFER, memory_buffer);
		glBufferData(GL_ARRAY_BUFFER, sizeof(points[0]) * points.size(), (GLfloat *)points.data(), GL_STATIC_DRAW);

		GLuint id = glGetAttribLocation(program_id, vertices_name.c_str());
		glEnableVertexAttribArray(id);
		glVertexAttribPointer(id, 3, GL_FLOAT, false, 0, 0);
	}

	void setup_canvas() {

		points = std::vector<Eigen::Vector3f>(4, Eigen::Vector3f::Zero());
		points[0] = Eigen::Vector3f(-1, -1, 0); points[1] = Eigen::Vector3f(1, -1, 0);
		points[2] = Eigen::Vector3f(-1, 1, 0); points[3] = Eigen::Vector3f(1, 1, 0);
		send_vertices_to_shader("position");

		/// Specify window bounds
		glUniform1f(glGetUniformLocation(program_id, "window_left"), window_left);
		glUniform1f(glGetUniformLocation(program_id, "window_bottom"), window_bottom);
		glUniform1f(glGetUniformLocation(program_id, "window_height"), window_height);
		glUniform1f(glGetUniformLocation(program_id, "window_width"), window_width);

	}

	void setup_texture() {
		///--- Texture
		const GLfloat vtexcoord[] = {0, 0, 1, 0, 0, 1, 1, 1 };
		glGenTextures(1, &texture);
		glBindTexture(GL_TEXTURE_2D, texture);
		

		glGenBuffers(1, &memory_buffer);
		glBindBuffer(GL_ARRAY_BUFFER, memory_buffer);
		glBufferData(GL_ARRAY_BUFFER, sizeof(vtexcoord), vtexcoord, GL_STATIC_DRAW);
		GLuint vtexcoord_id = glGetAttribLocation(program_id, "vtexcoord");
		glEnableVertexAttribArray(vtexcoord_id);
		glVertexAttribPointer(vtexcoord_id, 2, GL_FLOAT, false, 0, 0);

		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

		glfwLoadTexture2D("skin.tga", 0);
		//glUniform1i(glGetUniformLocation(program_id, "tex"), 0);
	}

	void load_model() {
		Eigen::MatrixXd B, T, C, R;
		get_input_matrix("B", B);
		get_input_matrix("T", T);
		get_input_matrix("C", C);
		get_input_matrix("R", R);

		std::vector<Eigen::Vector3f> centers = parse_centers<Eigen::Vector3f>(C.data(), C.rows());
		std::vector<float> radii = parse_radii(R.data(), R.rows());
		std::vector<Eigen::Vector3i> blocks = parse_centers<Eigen::Vector3i>(B.data(), B.rows());
		std::vector<std::vector<Eigen::Vector3f>> tangents = parse_tangent_points(T.data(), T.rows());
		std::vector<Eigen::Vector3f> tangents_v1 = tangents[0];
		std::vector<Eigen::Vector3f> tangents_v2 = tangents[1];
		std::vector<Eigen::Vector3f> tangents_v3 = tangents[2];
		std::vector<Eigen::Vector3f> tangents_u1 = tangents[3];
		std::vector<Eigen::Vector3f> tangents_u2 = tangents[4];
		std::vector<Eigen::Vector3f> tangents_u3 = tangents[5];

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
	}

	void init() {
		vertex_shader_name = "model_vshader.glsl";
		fragment_shader_name = "model_fshader.glsl";

		program_id = opengp::load_shaders(vertex_shader_name.c_str(), fragment_shader_name.c_str());
		if (!program_id) exit(EXIT_FAILURE);
		glUseProgram(program_id);

		setup_canvas();
		load_model();
		setup_texture();

		material.setup(program_id);
		light.setup(program_id);

		//glBindVertexArray(0);
		//glUseProgram(0);
	}

};

Convolution_renderer convolution_renderer;

void init() {
	glClearColor(1, 1, 1, 1);
	glEnable(GL_DEPTH_TEST);
	glPointSize(5);
	glLineWidth(2);
	convolution_renderer.init();
}

void display() {
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, convolution_renderer.texture);
	convolution_renderer.call_shader(GL_TRIANGLE_STRIP);
}

void mouse_position_callback(int xpos, int ypos) {
	convolution_renderer.camera.process_mouse_movement(xpos, ypos);
}
void scroll_callback(int offset) {
	convolution_renderer.camera.process_mouse_scroll(offset);
}
void mouse_button_callback(int button, int) {
	convolution_renderer.camera.process_mouse_button(button);
}

int main(int, char**) {
	opengp::glfwInitWindowSize(window_width, window_height);
	opengp::glfwCreateWindow("Title");
	opengp::glfwDisplayFunc(display);

	glfwSetMousePosCallback(mouse_position_callback);
	glfwSetMouseButtonCallback(mouse_button_callback);
	glfwSetMouseWheelCallback(scroll_callback);

	init();
	opengp::glfwMainLoop();
	return 0;
}

