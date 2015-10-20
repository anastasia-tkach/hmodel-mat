//mex compute_projections_mex.cpp -largeArrayDims -IC:\Users\tkach\OneDrive\EPFL\Code\External\eigen_dir

#include "mex.h"
#include <vector>
#include "math.h"
#include <Eigen/Dense>

using namespace Eigen;
using namespace std;

const int D = 3;

struct six {
	Vector3d v1;
	Vector3d v2;
	Vector3d v3;
	Vector3d u1;
	Vector3d u2;
	Vector3d u3;
};

template <typename T> int sign(T val) {
	return (T(0) < val) - (val < T(0));
}

template <class T>
vector<vector<T> > parse_blocks(double * B, int N) {
	vector<vector<T> > blocks;
	for (int i = 0; i < N; i++) {
		vector<T> block;
		for (int j = 0; j < D; j++) {  
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
	for (int i = 0; i < N; i++) {
		Vector3d center = Vector3d::Zero();
		for (int j = 0; j < D; j++) {
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
	for (int i = 0; i < values_vector.size(); i++) {
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
	vector<vector<int> > indices;
	indices.push_back(index12); indices.push_back(index13); indices.push_back(index23);
	Vector3d d;
	d << d12, d13, d23;
	int i; d.minCoeff(&i);
	t = T[i]; index = indices[i];
}

vector<int> get_intersecting_blocks(const Vector3d & p, const vector<int> & indices, const vector<vector<int> > & blocks, const vector<Vector3d> & centers, const VectorXd & radii) {
	vector<int> intersecting_blocks_indices; int index;
	if (indices.size() > 1) {
		VectorXd distances = VectorXd::Zero(indices.size());
		for (int i = 0; i < indices.size(); i++) {
			distances(i) = abs((p - centers[abs(indices[i])]).norm() - radii[i]);
		}
		int min_index; distances.minCoeff(&min_index);
		index = abs(indices[min_index]);
	}
	else {
		index = indices[0];
	}
	for (int j = 0; j < blocks.size(); j++) {
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

	if ((p - s).norm() - (q - s).norm() > -10e-7) is_inside = false;
	else is_inside = true;
}

void projection_convtriangle(const Vector3d & p, const Vector3d & c1, const Vector3d & c2, const Vector3d c3, double r1, double r2, double r3,
	Vector3d v1, Vector3d v2, Vector3d v3, Vector3d u1, Vector3d u2, Vector3d u3, int index1, int index2, int index3,
	vector<int> & index, Vector3d & q, Vector3d & s, bool & is_inside) {

	Vector3d q1, q2; vector<int> indexa, indexb, indexc;
	closest_point_in_triangle(v1, v2, v3, p, index1, index2, index3, q1, indexa);
	closest_point_in_triangle(u1, u2, u3, p, -index1, -index2, -index3, q2, indexb);
    closest_point_in_triangle(c1, c2, c3, p, index1, index2, index3, s, indexc);
	//Vector3d n = (c1 - c2).cross(c1 - c3);
	//n = n / n.norm();
	//double distance = (p - c1).dot(n);  
	//s = p - n * distance;
    /*for(int i = 0; i<indexa.size(); i++)
        mexPrintf("%d ", indexa[i]);
    mexPrintf("\n");
    for(int i = 0; i<indexb.size(); i++)
        mexPrintf("%d ", indexb[i]);
    mexPrintf("\n");*/

	vector<vector<int> > I;
	I.push_back(indexa); I.push_back(indexb);
	vector<Vector3d> Q, S;
	Q.push_back(q1); Q.push_back(q2);
	Vector2d d;
	d << (q1 - p).norm(), (q2 - p).norm();
	int k; d.minCoeff(&k);
	q = Q[k]; index = I[k];

	if (index.size() == 3) {
		if ((p - s).norm() - (q - s).norm() > -10e-7) is_inside = false;
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
	for (int j = 0; j < D; j++) {
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
		int k; is_inside_vector.maxCoeff(&k);
		q = Q[k]; s = S[k]; index = I[k];
	}
	// If point is outside
	else {
		Vector3d e; e << (p - q12).norm(), (p - q23).norm(), (p - q13).norm();
		int k; e.minCoeff(&k);
		q = Q[k]; s = S[k]; index = I[k];
	}

	// Check if inside
	if ((p - s).norm() - (q - s).norm() > -10e-7) is_inside = false;
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

void compute_projection(const Vector3d & p, const vector<vector<int> > & blocks, const vector<six> & tangent_points, const VectorXd & radii, const vector<Vector3d> & centers,
	vector<int> & indices, Vector3d & closest_projection, int & block_index) {

	double min_distance = std::numeric_limits<double>::max();
	vector<Vector3d> all_projections;
	vector<double> all_distances;
	vector<vector<int> > all_indices;
	vector<int> all_block_indices;

	for (int j = 0; j < blocks.size(); j++) {
        //mexPrintf("->%d\n", j);
		vector<int> index; Vector3d q; Vector3d s; bool is_inside;
		projection(p, blocks[j], tangent_points[j], radii, centers, index, q, s, is_inside);
		all_projections.push_back(q);
        double distance = (p - q).norm();
        if (is_inside) distance = - distance;
		all_distances.push_back(distance);
		all_indices.push_back(index);
		all_block_indices.push_back(j);

		if (distance < min_distance) {
			min_distance = distance;
			indices = index;
			closest_projection = q;
			block_index = j;
		}
	}   

	// Compute insideness matrix
	vector<int> intersecting_blocks_indices = get_intersecting_blocks(p, indices, blocks, centers, radii);
	MatrixXi insideness_matrix = MatrixXi::Zero(intersecting_blocks_indices.size(), intersecting_blocks_indices.size());
	for (int k = 0; k < intersecting_blocks_indices.size(); k++) {
		for (int l = 0; l < intersecting_blocks_indices.size(); l++) {
			int u = intersecting_blocks_indices[k];
			int v = intersecting_blocks_indices[l];
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
		closest_projection = Vector3d();
		return;
	}
	vector<int> best_blocks_indices;
	for (int i = 0; i < intersecting_blocks_indices.size(); i++) {
		if (insideness_vector[i] == min_element) {
			best_blocks_indices.push_back(intersecting_blocks_indices[i]);
		}
	}

	// Choose the most outer projection
	VectorXd all_distance_at_best_blocks_indices = VectorXd::Zero(best_blocks_indices.size());
	for (int i = 0; i < best_blocks_indices.size(); i++) {
		all_distance_at_best_blocks_indices(i) = all_distances[best_blocks_indices[i]];
	}
	int min_best_block_index; all_distance_at_best_blocks_indices.minCoeff(&min_best_block_index);		
	int min_index = best_blocks_indices[min_best_block_index];
	indices = all_indices[min_index];
	closest_projection = all_projections[min_index];
	block_index = all_block_indices[min_index];
}

void compute_projections(const vector<Vector3d> & points, const vector<Vector3d> & centers, const vector<vector<int> > & blocks, const VectorXd & radii, const vector<six> & tangent_points,
	double * indices, double * projections, double * block_indices) {
	
	vector<int> index;
	Vector3d projection;
	int block_index;
	for (int i = 0; i < points.size(); i++) {
		compute_projection(points[i], blocks, tangent_points, radii, centers, index, projection, block_index);

        int index_sign  = 1;
        if (index.size() == 3){
            for (int j = 0; j < index.size(); j++) {
                if (index[j] != 0){
                    index_sign = sign<int>(index[j]); break;
                }
            }
        }
        
		for (int j = 0; j < D; j++) {
			if (index.size() > j) {				       
                index[j] += index_sign;                
				indices[j * points.size() + i] = (double) index[j];
            }
			else indices[j * points.size() + i] = RAND_MAX;
		}
		for (int j = 0; j < D; j++) {
			projections[j * points.size() + i] = projection[j];
		}	
        block_index += sign<int>(block_index);
        if (block_index == 0) block_index++;
		block_indices[i] = block_index;	
	}
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mwSize P_rows = (mwSize) mxGetM(prhs[0]);
    mwSize C_rows = (mwSize) mxGetM(prhs[1]);
    mwSize R_rows = (mwSize) mxGetM(prhs[2]);
    mwSize B_rows = (mwSize) mxGetM(prhs[3]);
    mwSize T_rows = (mwSize) mxGetM(prhs[4]);
    double * P = mxGetPr(prhs[0]);  
    double * C = mxGetPr(prhs[1]);  
    double * R = mxGetPr(prhs[2]);  
    double * B = mxGetPr(prhs[3]);  
    double * T = mxGetPr(prhs[4]);    
   
	vector<Vector3d> points = parse_points(P, P_rows);
	vector<vector<int> > blocks = parse_blocks<int>(B, B_rows);
	vector<Vector3d> centers = parse_points(C, C_rows);	
	vector<six> tangent_points = parse_tangent_points(T, T_rows);
	VectorXd radii = VectorXd::Zero(R_rows);
	for (size_t i = 0; i < R_rows; i++) radii(i) = R[i];  
    
    ///////////////////////////////////////////////////////////////////////
    /*for(int i = 0; i < blocks.size(); i++){
        for(int j = 0; j < D; j++){
            if (j < blocks[i].size())
                mexPrintf("%d ", blocks[i][j]);
        }
        mexPrintf("\n");
    }*/
    ///////////////////////////////////////////////////////////////////////    
	    
    plhs[0] = mxCreateDoubleMatrix((mwSize) P_rows, (mwSize)D, mxREAL);
    double * indices = mxGetPr(plhs[0]);
    plhs[1] = mxCreateDoubleMatrix((mwSize) P_rows, (mwSize)D, mxREAL);
    double * projections = mxGetPr(plhs[1]);
    plhs[2] = mxCreateDoubleMatrix((mwSize) P_rows, (mwSize)1, mxREAL);
    double * block_indices = mxGetPr(plhs[2]);
    
	compute_projections(points, centers, blocks, radii, tangent_points, indices, projections, block_indices);    
 
}


