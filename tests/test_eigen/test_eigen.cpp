//mex test_eigen.cpp -largeArrayDims -IC:\Users\tkach\OneDrive\EPFL\Code\External\eigen_dir

#include "mex.h"
#include <Eigen/Dense>

using Eigen::MatrixXd;
void mexFunction(int nlhs, mxArray*plhs[], int nrhs, mxArray*prhs[])
{
    plhs[0] = mxCreateDoubleMatrix((mwSize)4, (mwSize)1, mxREAL);
    double * c = mxGetPr(plhs[0]);
    MatrixXd m(4, 1);
    m(0,0) = 3;
    m(1,0) = 2.5;
    m(2,0) = -1;
    m(3,0) = m(1,0) + m(2,0);
    
    for (size_t i = 0; i < 4; i++) {
        c[i] = m(i, 0);
    }
    
}