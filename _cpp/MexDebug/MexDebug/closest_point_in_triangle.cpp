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
using Eigen::Vector3d;
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


void closest_point_in_segment(Vector3d c1, Vector3d c2, Vector3d p, size_t index1, size_t index2, Vector3d & t, vector<size_t> & index) {

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


void closest_point_in_triangle(Vector3d v1, Vector3d v2, Vector3d v3, Vector3d p, size_t index1, size_t index2, size_t index3,
	Vector3d & t, vector<size_t> & index) {

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
	vector<size_t> index12, index13, index23;
	closest_point_in_segment(v1, v2, p, index1, index2, t12, index12);
	closest_point_in_segment(v1, v3, p, index1, index3, t13, index13);
	closest_point_in_segment(v2, v3, p, index2, index3, t23, index23);
	double d12 = (p - t12).norm();
	double d13 = (p - t13).norm(); 
	double d23 = (p - t23).norm();

	vector<Vector3d> T;
	T.push_back(t12); T.push_back(t13); T.push_back(t23);
	vector<vector<size_t>> indices;
	indices.push_back(index12); indices.push_back(index13); indices.push_back(index23);
	Vector3d d;
	d << d12, d13, d23;
	size_t i; d.minCoeff(&i);
	t = T[i]; index = indices[i];
}

int main() {
	Vector3d v1, v2, v3, p;
	size_t index1, index2, index3;
	get_input_3d_vector("p", p);
	get_input_3d_vector("v1", v1);
	get_input_3d_vector("v2", v2);
	get_input_3d_vector("v3", v3);
	get_input_scalar<size_t>("index1", index1);
	get_input_scalar<size_t>("index2", index2);
	get_input_scalar<size_t>("index3", index3);
	//cout << setprecision(15) << index1 << endl;

	Vector3d t;
	vector<size_t> index;

	closest_point_in_triangle(v1, v2, v3, p, index1, index2, index3, t, index);


	cout << setprecision(15) << t << endl << endl;
	for (size_t i = 0; i < index.size(); i++) {
		cout << index[i] << " ";
	}
	cout << endl;
	std::cin.get();
}