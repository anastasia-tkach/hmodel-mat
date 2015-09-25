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
    
    if ((p - s).norm() - (q - s).norm() > -10e-7) is_inside = false;
    else is_inside = true;
}


void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double * p_pointer = mxGetPr(prhs[0]);
    Map<RowVector3d> p = Map<RowVector3d>(p_pointer);
    double * c1_pointer = mxGetPr(prhs[1]);
    Map<RowVector3d> c1 = Map<RowVector3d>(c1_pointer);
    double * c2_pointer = mxGetPr(prhs[2]);
    Map<RowVector3d> c2 = Map<RowVector3d>(c2_pointer);
    double r1 = mxGetScalar(prhs[3]);
    double r2 = mxGetScalar(prhs[4]);
    size_t index1 = (size_t) mxGetScalar(prhs[5]);
    size_t index2 = (size_t) mxGetScalar(prhs[6]);
    
    Vector3d s, q;
	vector<size_t> index;
	bool is_inside;
    projection_convsegment(p, c1, c2, r1, r2, index1, index2, s, q, index, is_inside);

    plhs[0] = mxCreateDoubleMatrix((mwSize) index.size(), (mwSize)1, mxREAL);
    double * index_pointer = mxGetPr(plhs[0]);
    plhs[1] = mxCreateDoubleMatrix((mwSize)D, (mwSize)1, mxREAL);
    double * q_pointer = mxGetPr(plhs[1]);
    plhs[2] = mxCreateDoubleMatrix((mwSize)D, (mwSize)1, mxREAL);
    double * s_pointer = mxGetPr(plhs[2]);
    plhs[3] = mxCreateDoubleMatrix((mwSize)1, (mwSize)1, mxREAL);
    double * is_inside_pointer = mxGetPr(plhs[3]);
    for (size_t i = 0; i < index.size(); i++)
        index_pointer[i] = index[i];
    for (size_t i = 0; i < D; i++)
        q_pointer[i] = q(i);
    for (size_t i = 0; i < D; i++)
        s_pointer[i] = s(i);
    is_inside_pointer[0] = is_inside;  
    
    
    
}