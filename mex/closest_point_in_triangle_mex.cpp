#include "mex.h"
#include <vector>
#include "math.h"
#include <Eigen/Dense>

using namespace std;
using Eigen::MatrixXd;
using Eigen::Vector3d;

using Eigen::VectorXd;
using Eigen::RowVector3d;
using Eigen::Map;

const int D = 3;

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
	vector<vector<int> > indices;
	indices.push_back(index12); indices.push_back(index13); indices.push_back(index23);
	Vector3d d;
	d << d12, d13, d23;
	int i; d.minCoeff(&i);
	t = T[i]; index = indices[i];
}


void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{     
    double * v1_pointer = mxGetPr(prhs[0]);
    Map<RowVector3d> v1 = Map<RowVector3d>(v1_pointer);
    double * v2_pointer = mxGetPr(prhs[1]);
    Map<RowVector3d> v2 = Map<RowVector3d>(v2_pointer);
    double * v3_pointer = mxGetPr(prhs[2]);
    Map<RowVector3d> v3 = Map<RowVector3d>(v3_pointer);
    double * p_pointer = mxGetPr(prhs[3]);
    Map<RowVector3d> p = Map<RowVector3d>(p_pointer);
    int index1 = (int) mxGetScalar(prhs[4]);
    int index2 = (int) mxGetScalar(prhs[5]);
    int index3 = (int) mxGetScalar(prhs[6]);
    
    Vector3d t;
	vector<int> index;
    closest_point_in_triangle(v1, v2, v3, p, index1, index2, index3, t, index);

    plhs[0] = mxCreateDoubleMatrix((mwSize)D, (mwSize)1, mxREAL);
    double * t_pointer = mxGetPr(plhs[0]);   
    plhs[1] = mxCreateDoubleMatrix((mwSize) index.size(), (mwSize)1, mxREAL);
    double * index_pointer = mxGetPr(plhs[1]);
  
    for (int i = 0; i < index.size(); i++)
        index_pointer[i] = index[i];
    for (int i = 0; i < D; i++)
        t_pointer[i] = t(i); 
    
    
    
}