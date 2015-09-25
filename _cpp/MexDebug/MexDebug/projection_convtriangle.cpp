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

using namespace std;
using Eigen::MatrixXd;
using Eigen::Vector2d;
using Eigen::Vector3d;
using Eigen::Vector3i;
using Eigen::VectorXd;
using Eigen::RowVector3d;
using Eigen::Map;

const int D = 3;
string path = "C:\\Users\\tkach\\OneDrive\\EPFL\\Code\\HandModel\\_cpp\\Input\\";

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
				for (size_t i = 0; i < input.rows(); i++) {
					for (size_t j = 0; j < input.cols(); j++) {
						input(i, j) = numbers[i * input.cols() + j];
					}
				}
			}
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

bool test_insideness(Vector3d p, Vector3d q, Vector3d s) {
	bool inside = false;
	if ((p - s).norm() < (q - s).norm())
		inside = true;
	return inside;
}

bool is_point_in_trinagle(Vector3d p, Vector3d a, Vector3d b, Vector3d c) {
	Vector3d v0 = b - a;
	Vector3d v1 = c - a;
	Vector3d v2 = p - a;
	double d00 = v0.dot(v0);
	double	d01 = v0.dot(v1);
	double	d11 = v1.dot(v1);
	double	d20 = v2.dot(v0);
	double	d21 = v2.dot(v1);
	double	denom = d00 * d11 - d01 * d01;
	double alpha = (d11 * d20 - d01 * d21) / denom;
	double beta = (d00 * d21 - d01 * d20) / denom;
	double gamma = 1.0 - alpha - beta;

	if (alpha >= 0 && alpha <= 1 && beta >= 0 && beta <= 1 && gamma >= 0 && gamma <= 1)
		return true;
	else return false;
}

void closest_point_in_segment(Vector3d c1, Vector3d c2, Vector3d p, int index1, int index2, Vector3d & t, vector<int> & index) {

	Vector3d u = c2 - c1;
	Vector3d v = p - c1;

	double q = u.dot(v) / u.dot(u);

	if (q <= 0) {
		t = c1;
		index.push_back(index1);
	}
	if (q > 0 && q < 1) {
		t = c1 + q * u;
		index.push_back(index1);
		index.push_back(index2);
	}
	if (q >= 1) {
		t = c2;
		index.push_back(index2);
	}
}

void closest_point_in_triangle(Vector3d v1, Vector3d v2, Vector3d v3, Vector3d p, int index1, int index2, int index3,
	Vector3d & t, vector<int> & index) {

	Vector3d n = (v1 - v2).cross(v1 - v3);
	n = n / n.norm();
	double distance = (p - v1).dot(n);
	t = p - n * distance;

	bool is_in_triangle = is_point_in_trinagle(t, v1, v2, v3);

	if (is_in_triangle == true) {
		index.push_back(index1);
		index.push_back(index2);
		index.push_back(index3);
		return;
	}

	Vector3d t12, t13, t23;
	vector<int> index12, index13, index23;
	closest_point_in_segment(v1, v2, p, index1, index2, t12, index12);
	closest_point_in_segment(v1, v3, p, index1, index3, t13, index13);
	closest_point_in_segment(v2, v3, p, index2, index3, t23, index23);
	double d12 = (p - t12).norm();
	double d13 = (p - t13).norm();
	double d23 = (p - t23).norm();

	vector<Vector3d> T;
	T.push_back(t12); T.push_back(t13); T.push_back(t23);
	vector<vector<int>> indices;
	indices.push_back(index12); indices.push_back(index13); indices.push_back(index23);
	Vector3d d;
	d << d12, d13, d23;
	size_t i; d.minCoeff(&i);
	t = T[i]; index = indices[i];
}

void projection_convsegment(Vector3d p, Vector3d c1, Vector3d c2, double r1, double r2, int index1, int index2,
	Vector3d & s, Vector3d & q, vector<int> & index, bool & is_inside) {
	if (r2 > r1) {
		swap(r1, r2);
		swap(c1, c2);
		swap(index1, index2);
	}

	Vector3d u = c2 - c1;
	Vector3d v = p - c1;
	double alpha = u.dot(v) / u.dot(u);
	Vector3d t = c1 + alpha * u;

	double omega = sqrt(u.dot(u) - (r1 - r2)*(r1 - r2));
	double delta = (p - t).norm() * (r1 - r2) / omega;

	if (alpha <= 0) {
		s = c1;
		q = c1 + r1 * (p - c1) / (p - c1).norm();
		index = vector<int>(1, index1);
	}
	if (alpha > 0 && alpha < 1) {
		if ((c1 - t).norm() < delta) {
			s = c1;
			q = c1 + r1 * (p - c1) / (p - c1).norm();
			index = vector<int>(1, index1);
		}
	}
	if (alpha >= 1) {
		if ((t - c2).norm() > delta) {
			s = c2;
			q = c2 + r2 * (p - c2) / (p - c2).norm();
			index = vector<int>(1, index2);
		}
		if ((c1 - c2).norm() < delta) {
			s = c1;
			q = c1 + r1 * (p - c1) / (p - c1).norm();
			index = vector<int>(1, index2);
		}
	}
	if (index.empty()) {
		s = t - delta * (c2 - c1) / (c2 - c1).norm();
		double gamma = (r1 - r2) * (c2 - t + delta * u / u.norm()).norm() / sqrt(u.dot(u));
		q = s + (p - s) / (p - s).norm() * (gamma + r2);
		index.push_back(index1);
		index.push_back(index2);
	}

	if ((p - s).norm() - (q - s).norm() > 10e-7) is_inside = false;
	else is_inside = true;
}

void projection_convtriangle(Vector3d p, Vector3d c1, Vector3d c2, Vector3d c3, double r1, double r2, double r3,
	Vector3d v1, Vector3d v2, Vector3d v3, Vector3d u1, Vector3d u2, Vector3d u3, int index1, int index2, int index3,
	vector<int> & index, Vector3d & q, Vector3d & s, bool & is_inside) {

	Vector3d q1, q2; vector<int> indexa, indexb;
	closest_point_in_triangle(v1, v2, v3, p, index1, index2, index3, q1, indexa);
	closest_point_in_triangle(u1, u2, u3, p, -index1, -index2, -index3, q2, indexb);
	Vector3d n = (c1 - c2).cross(c1 - c3);
	n = n / n.norm();
	double distance = (p - c1).dot(n);
	s = p - n * distance;

	vector<vector<int>> I;
	I.push_back(indexa); I.push_back(indexb);
	vector<Vector3d> Q, S;
	Q.push_back(q1); Q.push_back(q2);
	Vector2d d;
	d << (q1 - p).norm(), (q2 - p).norm();
	size_t k; d.minCoeff(&k);
	q = Q[k]; index = I[k];

	if (index.size() == 3) {
		if ((p - s).norm() - (q - s).norm() > 10e-7) is_inside = false;
		else is_inside = true;
		return;
	}

	// Compute projections to convsegments
	bool bool_placeholder; vector<int> vector_placeholder;
	vector<int> index12, index13, index23;
	Vector3d q12, s12, q13, s13, q23, s23;
	projection_convsegment(p, c1, c2, r1, r2, index1, index2, s12, q12, index12, bool_placeholder);
	projection_convsegment(p, c1, c3, r1, r3, index1, index3, s13, q13, index13, bool_placeholder);
	projection_convsegment(p, c2, c3, r2, r3, index2, index3, s23, q23, index23, bool_placeholder);

	Q.clear(); I.clear();
	Q.push_back(q12); Q.push_back(q23); Q.push_back(q13);
	S.push_back(s12); S.push_back(s23);	S.push_back(s13);
	I.push_back(index12); I.push_back(index23); I.push_back(index13);

	Vector3i is_inside_vector = Vector3i::Zero();
	for (size_t j = 0; j < D; j++) {
		if ((p - S[j]).norm() < (Q[j] - S[j]).norm()) {
			is_inside_vector(j) = 1;
		}
	}

	// If the point is simultaneously inside two convsegments
	
	if (is_inside_vector.sum() > 1) {

		if (is_inside_vector(0) == 1 && is_inside_vector(1) == 1) {
			projection_convsegment(q23, c1, c2, r1, r2, index1, index2, s, q, vector_placeholder, bool_placeholder);
			if (!test_insideness(q23, q, s)) {
				q = q23; s = s23;
				index = index23;
			}
			else {
				q = q12; s = s12;
				index = index12;
			}
		}
		else if (is_inside_vector(0) == 1 && is_inside_vector(2) == 1) {
			projection_convsegment(q13, c1, c2, r1, r2, index1, index2, s, q, vector_placeholder, bool_placeholder);

			if (!test_insideness(q13, q, s)) {
				q = q13; s = s13;
				index = index13;
			}
			else {
				q = q12; s = s12;
				index = index12;
			}
		}
		else if (is_inside_vector(1) == 1 && is_inside_vector(2) == 1) {
			projection_convsegment(q13, c2, c3, r2, r3, index2, index3, s, q, vector_placeholder, bool_placeholder);
			if (!test_insideness(q13, q, s)) {
				q = q13; s = s13;
				index = index13;
			}
			else {
				q = q23; s = s23;
				index = index23;
			}
		}
	}

	// If point is inside one capsule
	else if (is_inside_vector.sum() == 1) {
		size_t k; is_inside_vector.maxCoeff(&k);
		q = Q[k]; s = S[k]; index = I[k];
	}
	// If point is outside
	else {
		Vector3d e; e << (p - q12).norm(), (p - q23).norm(), (p - q13).norm(); 
		size_t k; e.minCoeff(&k);
		q = Q[k]; s = S[k]; index = I[k];
	}

	// Check if inside
	if ((p - s).norm() - (q - s).norm() > 10e-7) is_inside = false;
	else is_inside = true;
}

int main() {
	Vector3d c1, c2, c3, v1, v2, v3, u1, u2, u3, p;
	double r1, r2, r3;
	int index1, index2, index3;
	get_input_3d_vector("p", p);
	get_input_3d_vector("c1", c1);
	get_input_3d_vector("c2", c2);
	get_input_3d_vector("c3", c3);
	get_input_3d_vector("v1", v1);
	get_input_3d_vector("v2", v2);
	get_input_3d_vector("v3", v3);
	get_input_3d_vector("u1", u1);
	get_input_3d_vector("u2", u2);
	get_input_3d_vector("u3", u3);
	get_input_scalar<double>("r1", r1);
	get_input_scalar<double>("r2", r2);
	get_input_scalar<double>("r3", r3);
	get_input_scalar<int>("index1", index1);
	get_input_scalar<int>("index2", index2);
	get_input_scalar<int>("index3", index3);

	Vector3d s, q;
	vector<int> index;
	bool is_inside;
	projection_convtriangle(p, c1, c2, c3, r1, r2, r3, v1, v2, v3, u1, u2, u3, index1, index2, index3, index, q, s, is_inside);

	double * s_pointer = s.data();

	cout << setprecision(15) << q << endl << endl;
	cout << setprecision(15) << s << endl << endl;
	cout << is_inside << endl << endl;
	for (size_t i = 0; i < index.size(); i++) {
		cout << index[i] << " ";
	}
	cout << endl;
	std::cin.get();
}