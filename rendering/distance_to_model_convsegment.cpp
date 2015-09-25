#include "mex.h"
#include <vector>
#include "math.h"

double dot(double * a, double * b, mwSize D){
    double c = 0;
    for (size_t i = 0; i < D; i++) {
        c += a[i] * b[i];
    }
    return c;
}

double norm(double * a, mwSize D){
    double b = 0;
    for (size_t i = 0; i < D; i++) {
        b += a[i] * a[i];
    }
    return sqrt(b);
}

double norm_diff(double * a, double * b, mwSize D){
    double c = 0;
    for (size_t i = 0; i < D; i++) {
        c += (a[i] - b[i]) * (a[i] - b[i]);
    }
    return sqrt(c);
}

double compute_distance(double * c1, double * c2, double r1, double r2, double * p, mwSize D){
    double distance = 0;
    double * u = new double[D];
    double * v = new double[D];
    
    for (size_t i = 0; i < D; i++) {
        u[i] = c2[i] - c1[i];
    }
    for (size_t i = 0; i < D; i++) {
        v[i] = p[i] - c1[i];
    }
    double alpha = dot(u, v, D) / dot(u, u, D);
    
    double * t = new double[D];
    for (size_t i = 0; i < D; i++) {
        t[i] = c1[i] + alpha * u[i];
    }
    
    double omega = sqrt(dot(u, u, D) - (r1 - r2)*(r1 - r2));
    double * p_minus_t = new double[D];
    for (size_t i = 0; i < D; i++) {
        p_minus_t[i] = p[i] - t[i];
    }
    double delta =  norm(p_minus_t, D) * (r1 - r2) / omega;
    
    bool done = false;
    double * s = new double[D];
    double * q = new double[D];
    
    if (alpha <= 0) {
        for (size_t i = 0; i < D; i++) {
            s[i] = c1[i];
        }
        for (size_t i = 0; i < D; i++) {
            q[i] =  c1[i] + r1 * (p[i] - c1[i]) / norm_diff(p, c1, D);
        }
        done  = true;
    }
    
    if (alpha > 0 && alpha < 1) {
        if (norm_diff(c1, t, D) < delta) {
            for (size_t i = 0; i < D; i++) {
                s[i] = c1[i];
            }
            for (size_t i = 0; i < D; i++) {
                q[i] =  c1[i] + r1 * (p[i] - c1[i]) / norm_diff(p, c1, D);
            }
            done  = true;
        }
    }
    
    if (alpha >= 1) {
        if (norm_diff(t, c2, D) > delta) {
            for (size_t i = 0; i < D; i++) {
                s[i] = c2[i];
            }
            for (size_t i = 0; i < D; i++) {
                q[i] =  c2[i] + r2 * (p[i] - c2[i]) / norm_diff(p, c2, D);
            }
            done  = true;
        }
        
        if (norm_diff(c1, c2, D) < delta) {
            for (size_t i = 0; i < D; i++) {
                s[i] = c1[i];
            }
            for (size_t i = 0; i < D; i++) {
                q[i] =  c1[i] + r1 * (p[i] - c1[i]) / norm_diff(p, c1, D);
            }
            done  = true;
        }
    }
    
    if (done == false) {
        for (size_t i = 0; i < D; i++) {
            s[i] = t[i] - delta * (c2[i] - c1[i]) / norm_diff(c2, c1, D);
        }
        double * y = new double[D];
        for (size_t i = 0; i < D; i++) {
            y[i] = c2[i] - t[i] + delta * u[i] / norm(u, D);
        }
        double gamma = (r1 - r2) * norm(y, D)/norm(u, D);
        for (size_t i = 0; i < D; i++) {
            q[i] = s[i] + (p[i] - s[i]) / norm_diff(p, s, D) * (gamma + r2);
        }
        delete[] y;
    }
    
    if (norm_diff(p, s, D) >= norm_diff(q, s, D))
        distance = norm_diff(p, q, D);
    else
        distance = - norm_diff(p, q, D);
    
    delete[] u;
    delete[] v;
    delete[] t;
    delete[] s;
    delete[] q;
    
    return distance;
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mwSize D = (mwSize) mxGetM(prhs[0]);
    double * c1 = mxGetPr(prhs[0]);
    double * c2 = mxGetPr(prhs[1]);
    double r1 = mxGetScalar(prhs[2]);
    double r2 = mxGetScalar(prhs[3]);
    double * P =  mxGetPr(prhs[4]);
    mwSize N = (mwSize) mxGetN(prhs[4]);
    
    plhs[0] = mxCreateDoubleMatrix((mwSize)N, (mwSize)1, mxREAL);
    double * distances = mxGetPr(plhs[0]);
    
    double * p = new double[D];
    for (size_t i = 0; i < N; i++){
        for (size_t k = 0; k < D; k++) {
            p[k] = P[i * D + k];            
        }
        distances[i] = compute_distance(c1, c2, r1, r2, p, D);
    }
    delete[] p;
    
}
