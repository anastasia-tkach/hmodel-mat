#include <iostream>
#include <Eigen/Dense>
#include <string>
#include <iostream>
#include <fstream>
#include <sstream>
#include <algorithm>
#include <iterator>
#include <vector>
#include <iomanip> 
#include <math.h>
#include <limits>

using namespace Eigen;
using namespace std;


const int D = 3;
string path = "C:\\Users\\tkach\\OneDrive\\EPFL\\Code\\HandModel\\_cpp\\Input\\";

struct six {
	Vector3d v1;
	Vector3d v2;
	Vector3d v3;
	Vector3d u1;
	Vector3d u2;
	Vector3d u3;
};

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
			/*for (size_t i = 0; i < input.rows(); i++) {
			for (size_t j = 0; j < input.cols(); j++) {
			input(i, j) = numbers[i * input.cols() + j];
			}
			}
			}*/
		}
		inputfile.close();
	}
}

void get_input_3d_vector(string name, Vector3d & input) {
	string line;
	ifstream inputfile(path + name + ".txt");
	bool first_line = true;
	if (inputfile.is_open()) {
		while (getline(inputfile, line)) {
			if (first_line) {
				input = Vector3d();
				first_line = false;
			}
			else {
				vector<double> numbers = parse_line(line);
				for (size_t i = 0; i < D; i++) {
					input(i) = numbers[i];
				}
			}
		}
		inputfile.close();
	}
}

template <class T>
void get_input_scalar(string name, T & input) {
	string line;
	ifstream inputfile(path + name + ".txt");
	bool first_line = true;
	if (inputfile.is_open()) {
		while (getline(inputfile, line)) {
			if (first_line) {
				first_line = false;
			}
			else {
				vector<double> numbers = parse_line(line);
				input = (T)numbers[0];
			}
		}
		inputfile.close();
	}
}

template <typename T> int sign(T val) {
	return (T(0) < val) - (val < T(0));
}

template <class T>
vector<vector<T>> parse_blocks(double * B, int N) {
	vector<vector<T>> blocks;
	for (size_t i = 0; i < N; i++) {
		vector<T> block;
		for (size_t j = 0; j < D; j++) {
			if (B[j * N + i] < RAND_MAX) {
				block.push_back((T)B[j * N + i]);
			}
		}
		blocks.push_back(block);
	}
	return blocks;
}

vector<Vector3d> parse_points(double * P, int N) {
	vector<Vector3d> centers;
	for (size_t i = 0; i < N; i++) {
		Vector3d center = Vector3d::Zero();
		for (size_t j = 0; j < D; j++) {
			center[j] = P[j * N + i];
		}
		centers.push_back(center);
	}
	return centers;
}

vector<six>  parse_tangent_points(double * T, int N) {
	vector<six> tangent_points;
	for (size_t i = 0; i < N; i++) {
		six tangent_point;
		if (T[i] >= RAND_MAX) {
			tangent_points.push_back(tangent_point);
			continue;
		}
		tangent_point.v1 = Vector3d::Zero();
		tangent_point.v2 = Vector3d::Zero();
		tangent_point.v3 = Vector3d::Zero();
		tangent_point.u1 = Vector3d::Zero();
		tangent_point.u2 = Vector3d::Zero();
		tangent_point.u3 = Vector3d::Zero();
		for (size_t j = 0; j < D; j++) {
			tangent_point.v1[j] = T[(j + 0) * N + i];
			tangent_point.v2[j] = T[(j + 3) * N + i];
			tangent_point.v3[j] = T[(j + 6) * N + i];
			tangent_point.u1[j] = T[(j + 9) * N + i];
			tangent_point.u2[j] = T[(j + 12) * N + i];
			tangent_point.u3[j] = T[(j + 15) * N + i];
		}
		tangent_points.push_back(tangent_point);
	}
	return tangent_points;
}

Vector3d ray_triangle_intersection(const Vector3d p0, const Vector3d p1, const Vector3d p2, const Vector3d o, const Vector3d d) {
	Vector3d i = std::numeric_limits<double>::max() *Vector3d::Ones();

	double epsilon = 0.00001;

	Vector3d e1 = p1 - p0;
	Vector3d e2 = p2 - p0;
	Vector3d q = d.cross(e2);
	double a = e1.dot(q); // determinant of the matrix M

	if (a > -epsilon && a < epsilon) {
		// the vector is parallel to the plane(the intersection is at infinity)
		return i;
	}

	double f = 1 / a;
	Vector3d s = o - p0;
	double u = f * s.dot(q);

	if (u < 0.0) {
		// the intersection is outside of the triangle
		return i;
	}

	Vector3d r = s.cross(e1);
	double v = f * d.dot(r);

	if (v<0.0 || u + v>1.0) {
		// the intersection is outside of the triangle
		return i;
	}

	double t = f * e2.dot(r); // verified!
	i = o + t * d;

	return i;
}

Vector3d ray_cone_intersection(const Vector3d & pa, const Vector3d & va, double alpha, const Vector3d & p, const Vector3d & v) {

	Vector3d i = std::numeric_limits<double>::max() *Vector3d::Ones();

	double cos2 = cos(alpha) * cos(alpha);
	double sin2 = sin(alpha) * sin(alpha);
	Vector3d delta_p = p - pa;

	Vector3d e = v - (v.dot(va))*va;
	double f = v.dot(va);
	Vector3d g = delta_p - delta_p.dot(va)*va;
	double h = delta_p.dot(va);

	double A = cos2 * e.dot(e) - sin2 * f * f;
	double B = 2 * cos2 * e.dot(g) - 2 * sin2 * f * h;
	double C = cos2 * g.dot(g) - sin2 * h * h;

	double D = B*B - 4 * A*C;

	double t1 = std::numeric_limits<double>::max();
	double t2 = std::numeric_limits<double>::max();
	Vector3d i1, i2;
	if (D >= 0) {
		t1 = (-B - sqrt(D)) / 2 / A;
		t2 = (-B + sqrt(D)) / 2 / A;
		i1 = p + t1 * v;
		i2 = p + t2 * v;
	}
	
	if (t1 < t2) {
		i = i1;
	}
	if (t1 > t2) {
		i = i2;
	}
	return i;
}

Vector3d ray_sphere_intersection(const Vector3d & c, double r, const Vector3d & p, const Vector3d & v) {

	double A = v.transpose() * v;
	double B = -2 * (c - p).transpose() * v;
	double C = (c - p).transpose() * (c - p) - r*r;
	double D = B*B - 4 * A*C;

	double t1 = std::numeric_limits<double>::max();
	double t2 = std::numeric_limits<double>::max();
	Vector3d i1, i2;
	if (D >= 0) {
		t1 = (-B - sqrt(D)) / 2 / A;
		t2 = (-B + sqrt(D)) / 2 / A;
		i1 = p + t1 * v;
		i2 = p + t2 * v;
	}

	Vector3d i = std::numeric_limits<double>::max() *Vector3d::Ones();
	if (t1 < t2) {
		i = i1;
	}
	if (t1 > t2) {
		i = i2;
	}
	return i;
}

Vector3d ray_convsegment_intersection(const Vector3d & c1, const Vector3d &c2, double r1, double r2, const Vector3d & p, const Vector3d & v) {
	Vector3d n = (c2 - c1) / (c2 - c1).norm();
	double beta = asin((r1 - r2) / (c1 - c2).norm());
	double eta1 = r1 * sin(beta);
	Vector3d s1 = c1 + eta1 * n;
	double eta2 = r2 * sin(beta);
	Vector3d s2 = c2 + eta2 * n;

	Vector3d z = c1 + (c2 - c1) * r1 / (r1 - r2);
	double r = r1 * cos(beta);
	double h = (z - s1).norm();
	double alpha = atan(r / h);

	Vector3d i = std::numeric_limits<double>::max() *Vector3d::Ones();

	// Ray - cone intersections
	Vector3d i12 = ray_cone_intersection(z, n, alpha, p, v);
	if (n.transpose() *(i12 - s1) >= 0 && n.transpose() * (i12 - s2) <= 0 && i12.norm() < std::numeric_limits<double>::max()) {
		i = i12;
	}

	// Ray - sphere intersection
	Vector3d i1 = ray_sphere_intersection(c1, r1, p, v);
	if (n.transpose() * (i1 - s1) < 0 && i1.norm() < std::numeric_limits<double>::max()) {
		i = i1;
	}

	// Ray - sphere intersection
	Vector3d i2 = ray_sphere_intersection(c2, r2, p, v);
	if (n.transpose() * (i2 - s2) > 0 && i2.norm() < std::numeric_limits<double>::max()) {
		i = i2;
	}
	return i;
}

Vector3d ray_convtriangle_intersection(const Vector3d & c1, const Vector3d & c2, const Vector3d & c3, const Vector3d & v1, const Vector3d & v2, const Vector3d & v3,
	const Vector3d & u1, const Vector3d & u2, const Vector3d & u3, double r1, double r2, double r3, const Vector3d & p, const Vector3d & v) {

	vector<Vector3d> I;
	I.push_back(ray_convsegment_intersection(c1, c2, r1, r2, p, v));
	I.push_back(ray_convsegment_intersection(c1, c3, r1, r3, p, v));
	I.push_back(ray_convsegment_intersection(c2, c3, r2, r3, p, v));
	I.push_back(ray_triangle_intersection(v1, v2, v3, p, v));
	I.push_back(ray_triangle_intersection(u1, u2, u3, p, v));

	double min_value = std::numeric_limits<double>::max();
	int min_index = 0;
	for (size_t j = 0; j < I.size(); j++) {
		double value = (p - I[j]).norm();
		if (value < min_value) {
			min_value = value;
			min_index = j;
		}
	}
	Vector3d i = I[min_index];
	return i;
}

Vector3d ray_model_intersection(const vector<Vector3d> & centers, const vector<vector<int>> & blocks,
	const VectorXd & radii, const vector<six> & tangent_points, const Vector3d & p, const Vector3d & d) {
	Vector3d i;
	Vector3d min_i = std::numeric_limits<double>::max() *Vector3d::Ones();
	Vector3d c1, c2, c3, v1, v2, v3, u1, u2, u3;
	double r1, r2, r3;
	for (size_t j = 0; j < blocks.size(); j++) {
		vector<int> block = blocks[j];
		six tangent_point = tangent_points[j];
		if (block.size() == 3) {
			c1 = centers[block[0]]; c2 = centers[block[1]]; c3 = centers[block[2]];
			r1 = radii[block[0]]; r2 = radii[block[1]]; r3 = radii[block[2]];
			v1 = tangent_point.v1; v2 = tangent_point.v2; v3 = tangent_point.v3;
			u1 = tangent_point.u1; u2 = tangent_point.u2; u3 = tangent_point.u3;
			i = ray_convtriangle_intersection(c1, c2, c3, v1, v2, v3, u1, u2, u3, r1, r2, r3, p, d);
			if ((p - i).norm() < (p - min_i).norm()) {
				min_i = i;
			}
		}
		if (block.size() == 2) {
			c1 = centers[block[0]]; c2 = centers[block[1]];
			r1 = radii[block[0]]; r2 = radii[block[1]];
			i = ray_convsegment_intersection(c1, c2, r1, r2, p, d);
			if ((p - i).norm() < (p - min_i).norm()) {
				min_i = i;
			}
		}
	}

	i = min_i;
	return i;
}

void render_model(const vector<Vector3d> & centers, const vector<vector<int>> & blocks,
const VectorXd & radii, const vector<six> & tangent_points, const Matrix<double, 3, 3> & M, const Vector3d & p, int W, int H) {
	
	MatrixXf D = -1.5 * MatrixXf::Ones(H, W);	
	Vector3d d, i;
	for (size_t n = 0; n < W; n=n+1) {
		for (size_t m = 0; m < H; m = m+1) {	
			d = M * Vector3d(n + 1, m + 1, 1);
			d.normalize();
			i = ray_model_intersection(centers, blocks, radii, tangent_points, p, d);
			if (i.norm() < std::numeric_limits<double>::max()) {
				D(m, n) = i(2);
			}
		}
	}
}

void main() {
	Vector3d p;
	size_t H, W;
	get_input_3d_vector("p", p);
	get_input_scalar<size_t>("H", H);
	get_input_scalar<size_t>("W", W);

	MatrixXd B, T, C, R, M;
	get_input_matrix("B", B);
	get_input_matrix("T", T);
	get_input_matrix("C", C);
	get_input_matrix("R", R);
	get_input_matrix("M", M);

	double * B_pointer = B.data();
	double * T_pointer = T.data();
	double * C_pointer = C.data();
	double * R_pointer = R.data();
	double * M_pointer = M.data();

	vector<vector<int>> blocks = parse_blocks<int>(B_pointer, B.rows());
	vector<Vector3d> centers = parse_points(C_pointer, C.rows());
	vector<six> tangent_points = parse_tangent_points(T_pointer, T.rows());
	VectorXd radii = VectorXd::Zero(R.rows());
	for (size_t i = 0; i < R.rows(); i++) radii(i) = R(i, 0);

	render_model(centers, blocks, radii, tangent_points, M, p, W, H);

	system("pause");
}