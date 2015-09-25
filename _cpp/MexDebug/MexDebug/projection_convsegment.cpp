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
				input = (T) numbers[0];
			}
		}
		inputfile.close();
	}
}

void projection_convsegment(Vector3d p, Vector3d c1, Vector3d c2, double r1, double r2, size_t index1, size_t index2, 	
	Vector3d & s, Vector3d & q, vector<size_t> & index, bool & is_inside) {
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
		index = vector<size_t>(1, index1);
	}
	if (alpha > 0 && alpha < 1) {
		if ((c1 - t).norm() < delta) {
			s = c1;
			q = c1 + r1 * (p - c1) / (p - c1).norm();
			index = vector<size_t>(1, index1);
		}
	}
	if (alpha >= 1) {
		if ((t - c2).norm() > delta) {
			s = c2;
			q = c2 + r2 * (p - c2) / (p - c2).norm();
			index = vector<size_t>(1, index2);
		}
		if ((c1 - c2).norm() < delta) {
			s = c1;
			q = c1 + r1 * (p - c1) / (p - c1).norm();
			index = vector<size_t>(1, index2);
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

int main() {
	Vector3d p, c1, c2;
	double r1, r2;
	size_t index1, index2;
	get_input_3d_vector("p", p);
	get_input_3d_vector("c1", c1);
	get_input_3d_vector("c2", c2);
	get_input_scalar<double>("r1", r1);
	get_input_scalar<double>("r2", r2);
	get_input_scalar<size_t>("index1", index1);
	get_input_scalar<size_t>("index2", index2);
	//cout << setprecision(15) << index1 << endl;

	double * p_pointer = new double[D];
	for (size_t i = 0; i < D; i++) {
		p_pointer[i] = p(i);
	}

	Vector3d s, q;
	vector<size_t> index;
	bool is_inside;
	projection_convsegment(p, c1, c2, r1, r2, index1, index2, s, q, index, is_inside);

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