#include "mex.h"

void sum(double * a, double * b, double * c, mwSize N){    
    for (size_t i = 0; i < N; i++) {
        c[i] = a[i] + b[i];
    }
}

void mexFunction(int nlhs, mxArray*plhs[], int nrhs, mxArray*prhs[]) {
    mwSize N = (mwSize) mxGetM(prhs[0]);
    double * a = mxGetPr(prhs[0]);
    double * b = mxGetPr(prhs[1]);    
    plhs[0] = mxCreateDoubleMatrix((mwSize)N, (mwSize)1, mxREAL); 
    double * c = mxGetPr(plhs[0]);
    sum(a, b, c, N);
}