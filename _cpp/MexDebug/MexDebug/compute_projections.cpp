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

template <class T>
bool ismember(T value, const vector<T> & values_vector) {
	for (size_t i = 0; i < values_vector.size(); i++) {
		if (value == values_vector[i]) {
			return true;
		}
	}
	return false;
}

bool test_insideness(const Vector3d & p, const Vector3d & q, const Vector3d & s) {
	bool inside = false;
	if ((p - s).norm() < (q - s).norm())
		inside = true;
	return inside;
}

bool is_point_in_trinagle(const Vector3d & p, const Vector3d & a, const Vector3d & b, const Vector3d & c) {
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

void closest_point_in_segment(const Vector3d & c1, const Vector3d & c2, const Vector3d & p, int index1, int index2, 
	Vector3d & t, vector<int> & index) {

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

void closest_point_in_triangle(const Vector3d & v1, const Vector3d & v2, const Vector3d & v3, const Vector3d & p, int index1, int index2, int index3,
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

vector<int> get_intersecting_blocks(const Vector3d & p, const vector<int> & indices, const vector<vector<int>> & blocks, const vector<Vector3d> & centers, const VectorXd & radii) {
	vector<int> intersecting_blocks_indices; int index;
	if (indices.size() > 1) {
		VectorXd distances = VectorXd::Zero(indices.size());
		for (size_t i = 0; i < indices.size(); i++) {
			distances(i) = abs((p - centers[abs(indices[i])]).norm() - radii[i]);
		}
		size_t min_index; distances.minCoeff(&min_index);
		index = abs(indices[min_index]);
	}
	else {
		index = indices[0];
	}
	for (size_t j = 0; j < blocks.size(); j++) {
		if (ismember(index, blocks[j])) {
			intersecting_blocks_indices.push_back(j);
		}
	}
	return intersecting_blocks_indices;
}

void projection_convsegment(const Vector3d & p, Vector3d c1, Vector3d c2, double r1, double r2, int index1, int index2,
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

void projection_convtriangle(const Vector3d & p, const Vector3d & c1, const Vector3d & c2, const Vector3d c3, double r1, double r2, double r3,
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

void projection(const Vector3d & p, const vector<int> & block, const six & tangent_points, const VectorXd & radii, const vector<Vector3d> & centers,
	vector<int> & index, Vector3d & q, Vector3d & s, bool & is_inside) {
	Vector3d c1, c2, c3, v1, v2, v3, u1, u2, u3;
	double r1, r2, r3; int index1, index2, index3;	
	if (block.size() == 3) {
		c1 = centers[block[0]]; c2 = centers[block[1]]; c3 = centers[block[2]];
		r1 = radii[block[0]]; r2 = radii[block[1]]; r3 = radii[block[2]];
		v1 = tangent_points.v1; v2 = tangent_points.v2; v3 = tangent_points.v3;
		u1 = tangent_points.u1; u2 = tangent_points.u2; u3 = tangent_points.u3;
		index1 = block[0]; index2 = block[1]; index3 = block[2];
		projection_convtriangle(p, c1, c2, c3, r1, r2, r3, v1, v2, v3, u1, u2, u3, index1, index2, index3, index, q, s, is_inside);
	}

	if (block.size() == 2) {
		c1 = centers[block[0]]; c2 = centers[block[1]];
		r1 = radii[block[0]]; r2 = radii[block[1]];
		index1 = block[0]; index2 = block[1];
		projection_convsegment(p, c1, c2, r1, r2, index1, index2, s, q, index, is_inside);
	}
}

void compute_projection(const Vector3d & p, const vector<vector<int>> & blocks, const vector<six> & tangent_points, const VectorXd & radii, const vector<Vector3d> & centers,
	vector<int> & indices, Vector3d & closest_projection, int & block_index) {

	double min_distance = std::numeric_limits<double>::max();
	vector<Vector3d> all_projections;
	vector<double> all_distances;
	vector<vector<int>> all_indices;
	vector<int> all_block_indices;

	for (size_t j = 0; j < blocks.size(); j++) {
		vector<int> index; Vector3d q; Vector3d s; bool is_inside;
		projection(p, blocks[j], tangent_points[j], radii, centers, index, q, s, is_inside);
		all_projections.push_back(q);
		all_distances.push_back((p - q).norm());
		all_indices.push_back(index);
		all_block_indices.push_back(j);

		if ((p - q).norm() < min_distance) {
			min_distance = (p - q).norm();
			indices = index;
			closest_projection = q;
			block_index = j;
		}
	}

	// Compute insideness matrix
	vector<int> intersecting_blocks_indices = get_intersecting_blocks(p, indices, blocks, centers, radii);
	MatrixXi insideness_matrix = MatrixXi::Zero(intersecting_blocks_indices.size(), intersecting_blocks_indices.size());
	for (size_t k = 0; k < intersecting_blocks_indices.size(); k++) {
		for (size_t l = 0; l < intersecting_blocks_indices.size(); l++) {
			size_t u = intersecting_blocks_indices[k];
			size_t v = intersecting_blocks_indices[l];
			if (u == v) continue;
			vector<int> index; Vector3d q; Vector3d s; bool is_inside;
			projection(all_projections[u], blocks[v], tangent_points[v], radii, centers, index, q, s, is_inside);
			insideness_matrix(k, l) = is_inside;
		}
	}

	VectorXi insideness_vector = insideness_matrix.rowwise().sum();
	int min_element = insideness_vector.minCoeff();
	if (min_element > 0) {
		indices = vector<int>();
		closest_projection = Vector3d::Zero();
		return;
	}
	vector<int> best_blocks_indices;
	for (size_t i = 0; i < intersecting_blocks_indices.size(); i++) {
		if (insideness_vector[i] == min_element) {
			best_blocks_indices.push_back(intersecting_blocks_indices[i]);
		}
	}

	// Choose the most outer projection
	VectorXd all_distance_at_best_blocks_indices = VectorXd::Zero(best_blocks_indices.size());
	for (size_t i = 0; i < best_blocks_indices.size(); i++) {
		all_distance_at_best_blocks_indices(i) = all_distances[best_blocks_indices[i]];
	}
	size_t min_best_block_index; all_distance_at_best_blocks_indices.minCoeff(&min_best_block_index);		
	int min_index = best_blocks_indices[min_best_block_index];
	indices = all_indices[min_index];
	closest_projection = all_projections[min_index];
	block_index = all_block_indices[min_index];
}

void compute_projections(const vector<Vector3d> & points, const vector<Vector3d> & centers, const vector<vector<int>> & blocks, const VectorXd & radii, const vector<six> & tangent_points,
	int ** indices, double ** projections, int * block_indices) {
	
	vector<int> index;
	Vector3d projection;
	int block_index;
	for (size_t i = 0; i < points.size(); i++) {
		compute_projection(points[i], blocks, tangent_points, radii, centers, index, projection, block_index);
		for (size_t j = 0; j < D; j++) {
			if (index.size() > j) {
				index[j] += sign<int>(index[j]);
				if (index[j] == 0) index[j]++;
				indices[i][j] = index[j];
			}
			else indices[i][j] = RAND_MAX;
		}
		for (size_t j = 0; j < D; j++) {
			projections[i][j] = projection[j];
		}		
		block_index += sign<int>(block_index);
		if (block_index == 0) block_index++;
		block_indices[i] = block_index;	
	}
}

int main() {
	MatrixXd B, T, C, R, P;
	get_input_matrix("B", B);
	get_input_matrix("T", T);
	get_input_matrix("C", C);
	get_input_matrix("P", P);
	get_input_matrix("R", R);

	double * P_pointer = P.data();
	double * B_pointer = B.data();
	double * T_pointer = T.data();
	double * C_pointer = C.data();
	double * R_pointer = R.data();
	vector<Vector3d> points = parse_points(P_pointer, P.rows());
	vector<vector<int>> blocks = parse_blocks<int>(B_pointer, B.rows());
	vector<Vector3d> centers = parse_points(C_pointer, C.rows());	
	vector<six> tangent_points = parse_tangent_points(T_pointer, T.rows());
	VectorXd radii = VectorXd::Zero(R.rows());
	for (size_t i = 0; i < R.rows(); i++) radii(i) = R(i, 0);
	
	//vector<vector<int>> indices;
	//vector<Vector3d> projections; 
	//vector<int> block_indices;
	int** indices = new int*[points.size()];
	for (int i = 0; i < points.size(); ++i)
		indices[i] = new int[D];
	double** projections = new double*[points.size()];
	for (int i = 0; i < points.size(); ++i)
		projections[i] = new double[D];
	int * block_indices = new int[points.size()];

	compute_projections(points, centers, blocks, radii, tangent_points, indices, projections, block_indices); 

	for (size_t i = 0; i < points.size(); i++) {
		for (size_t j = 0; j < D; j++) {
			cout << indices[i][j] << "\t";
		}
		cout << endl;
	}
	cout << endl << endl;
	for (size_t i = 0; i < points.size(); i++) {
		for (size_t j = 0; j < D; j++) {
			cout << projections[i][j] << "\t";
		}
		cout << endl;
	}
	cout << endl << endl;
	for (size_t i = 0; i < points.size(); i++) {
		cout << block_indices[i] << endl;
	}
	
	system("pause");
}