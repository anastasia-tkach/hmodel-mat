#include "mex.h"
#include <vector>
#include "math.h"
#include <limits>

const int D = 3;

double dot(double * a, double * b){
    double c = 0;
    for (size_t i = 0; i < D; i++) {
        c += a[i] * b[i];
    }
    return c;
}

void product(double s, double * a, double * b){
    for (size_t i = 0; i < D; i++) {
        b[i] = s * a[i];
    }
}

double norm(double * a){
    double b = 0;
    for (size_t i = 0; i < D; i++) {
        b += a[i] * a[i];
    }
    return sqrt(b);
}


double sum(bool * a){
    double b = 0;
    for (size_t i = 0; i < D; i++) {
        b += a[i];
    }
    return b;
}

double norm_diff(double * a, double * b){
    double c = 0;
    for (size_t i = 0; i < D; i++) {
        c += (a[i] - b[i]) * (a[i] - b[i]);
    }
    return sqrt(c);
}

void cross(double * a, double * b, double * c){
    c[0] = a[1]* b[2] - a[2] * b[1];
    c[1] = a[2]* b[0] - a[0] * b[2];
    c[2] = a[0]* b[1] - a[1] * b[0];
}

void minus(double * a, double * b, double * c){
    for (size_t i = 0; i < D; i++) {
        c[i] = a[i] - b[i];
    }
}

void plus(double * a, double * b, double * c){
    for (size_t i = 0; i < D; i++) {
        c[i] = a[i] + b[i];
    }
}

void normalize(double * a){
    double n = norm(a);
    for (size_t i = 0; i < D; i++) {
        a[i] = a[i]/n;
    }
}

void copy(double * a, double * b){
    for (size_t i = 0; i < D; i++) {
        b[i] = a[i];
    }
}

bool test_insideness(double * p, double * q, double * s) {
    if (norm_diff(p, s) < norm_diff(q, s))
        return true;
    else
        return false;
}

size_t find(bool * a) {
    for (size_t i = 0; i < D; i++) {
        if (a[i] == 1) return i;
    }
}

size_t min_index(double * a){
    double min_value = std::numeric_limits<double>::max();
    size_t min_index = 0;
    for (size_t i = 0; i < D; i++) {
        if (a[i] < min_value) {
            min_value = a[i];
            min_index = i;
        }
    }
    return min_index;
}

void print(char* name, double * a){    
    mexPrintf("%s:\t\t", name);
    for (size_t i = 0; i < D; i++) {
        mexPrintf("%7.5f\t\t", a[i]);
    }
    mexPrintf("\n");
    mexEvalString("drawnow;");
}

void projection_on_triangle(double * v1, double * v2, double * v3, double * p, double * q){
    double o1[D]; minus(v1, v2, o1);
    double o2[D]; minus(v1, v3, o2);
    double m[D]; cross(o1, o2, m);
    normalize(m);
    double o3[D]; minus(p, v1, o3);
    double distance = dot(o3, m);
    double o4[D]; product(distance, m, o4);
    minus(p, o4, q);
}

bool is_point_in_triangle(double * a, double * b, double * c, double * p){
    double v0[D]; minus(b, a, v0);
    double v1[D]; minus(c, a, v1);
    double v2[D]; minus(p, a, v2);
    double d00 = dot(v0, v0);
    double d01 = dot(v0, v1);
    double d11 = dot(v1, v1);
    double d20 = dot(v2, v0);
    double d21 = dot(v2, v1);
    double denom = d00 * d11 - d01 * d01;
    double alpha = (d11 * d20 - d01 * d21) / denom;
    double beta = (d00 * d21 - d01 * d20) / denom;
    double gamma = 1.0 - alpha - beta;
    
    if (alpha >= 0 && alpha <= 1 && beta >= 0 && beta <= 1 && gamma >= 0 && gamma <= 1)
        return true;
    else
        return false;
}

void projection_on_capsule(double * c1, double * c2, double r1, double r2, double * p, double * s, double * q){
    double distance = 0;
    double u[D];
    double v[D];
    
    for (size_t i = 0; i < D; i++) {
        u[i] = c2[i] - c1[i];
    }
    for (size_t i = 0; i < D; i++) {
        v[i] = p[i] - c1[i];
    }
    double alpha = dot(u, v) / dot(u, u);
    
    double t[D];
    for (size_t i = 0; i < D; i++) {
        t[i] = c1[i] + alpha * u[i];
    }
    
    double omega = sqrt(dot(u, u) - (r1 - r2)*(r1 - r2));
    double p_minus_t[D];
    for (size_t i = 0; i < D; i++) {
        p_minus_t[i] = p[i] - t[i];
    }
    double delta =  norm(p_minus_t) * (r1 - r2) / omega;
    
    bool done = false;
    if (alpha <= 0) {
        for (size_t i = 0; i < D; i++) {
            s[i] = c1[i];
        }
        for (size_t i = 0; i < D; i++) {
            q[i] =  c1[i] + r1 * (p[i] - c1[i]) / norm_diff(p, c1);
        }
        done  = true;
    }
    
    if (alpha > 0 && alpha < 1) {
        if (norm_diff(c1, t) < delta) {
            for (size_t i = 0; i < D; i++) {
                s[i] = c1[i];
            }
            for (size_t i = 0; i < D; i++) {
                q[i] =  c1[i] + r1 * (p[i] - c1[i]) / norm_diff(p, c1);
            }
            done  = true;
        }
    }
    
    if (alpha >= 1) {
        if (norm_diff(t, c2) > delta) {
            for (size_t i = 0; i < D; i++) {
                s[i] = c2[i];
            }
            for (size_t i = 0; i < D; i++) {
                q[i] =  c2[i] + r2 * (p[i] - c2[i]) / norm_diff(p, c2);
            }
            done  = true;
        }
        
        if (norm_diff(c1, c2) < delta) {
            for (size_t i = 0; i < D; i++) {
                s[i] = c1[i];
            }
            for (size_t i = 0; i < D; i++) {
                q[i] =  c1[i] + r1 * (p[i] - c1[i]) / norm_diff(p, c1);
            }
            done  = true;
        }
    }
    
    if (done == false) {
        for (size_t i = 0; i < D; i++) {
            s[i] = t[i] - delta * (c2[i] - c1[i]) / norm_diff(c2, c1);
        }
        double y[D];
        for (size_t i = 0; i < D; i++) {
            y[i] = c2[i] - t[i] + delta * u[i] / norm(u);
        }
        double gamma = (r1 - r2) * norm(y)/norm(u);
        for (size_t i = 0; i < D; i++) {
            q[i] = s[i] + (p[i] - s[i]) / norm_diff(p, s) * (gamma + r2);
        }
    }
}

void projection_on_convtriangle(double * c1, double * c2, double * c3, double r1, double r2, double r3,
        double * v1, double * v2, double * v3, double * u1, double * u2, double * u3, double * p, double * s, double * q) {
    double q1[D]; projection_on_triangle(v1, v2, v3, p, q1);
    double q2[D]; projection_on_triangle(u1, u2, u3, p, q2);
    
    projection_on_triangle(c1, c2, c3, p, s);
    
    bool is_in_triangle1 = is_point_in_triangle(v1, v2, v3, p);
    bool is_in_triangle2 = is_point_in_triangle(u1, u2, u3, p);
    
    double o1[D]; minus(q1, p, o1);
    double o2[D]; minus(q2, p, o2);
    bool is_in_triangle = false;
    if (norm(o1) < norm(o2)) {
        copy(q1, q);
        is_in_triangle = is_in_triangle1;
    }
    else {
        copy(q2, q);
        is_in_triangle = is_in_triangle2;
    }
    
    if (is_in_triangle) return;
    
    //mexPrintf("MEX: Not in triangle\n");
    
    double s12[D]; double q12[D]; projection_on_capsule(c1, c2, r1, r2, p, s12, q12);
    double s23[D]; double q23[D]; projection_on_capsule(c2, c3, r2, r3, p, s23, q23);
    double s13[D]; double q13[D]; projection_on_capsule(c1, c3, r1, r3, p, s13, q13);
    
    std::vector<double * > S;
    S.push_back(s12); S.push_back(s23); S.push_back(s13);
    std::vector<double * > Q;
    Q.push_back(q12); Q.push_back(q23); Q.push_back(q13);
    
    bool is_inside[3];
    for (size_t i = 0; i < 3; i++) {
        if (norm_diff(p, S[i]) <= norm_diff(Q[i], S[i]))
            is_inside[i] = 1;
        else
            is_inside[i] = 0;
    }
    
    if (sum(is_inside) > 1) {
        //mexPrintf("MEX: 2 inside\n");
        double s_[D]; double q_[D]; 
        if (is_inside[0] == 1 && is_inside[1] == 1 ) {            
            //mexPrintf("MEX: 1 & 2\n");
            projection_on_capsule(c1, c2, r1, r2, q23, s_, q_);
            if (!test_insideness(q23, q_, s_)) { copy(q23, q); copy(s23, s);
            } else { copy(q12, q); copy(s12, s); }
        } else if (is_inside[0] == 1 && is_inside[2] == 1) {
            //mexPrintf("MEX: 1 & 3\n");
            projection_on_capsule(c1, c2, r1, r2, q13, s_, q_);
            if (!test_insideness(q13, q_, s_)) { copy(q13, q); copy(s13, s);
            } else { copy(q12, q); copy(s12, s); }
        } else if (is_inside[1] == 1 && is_inside[2] == 1) {
            //mexPrintf("MEX: 1 & 3\n");
            projection_on_capsule(c2, c3, r2, r3, q13, s_, q_);
            if (!test_insideness(q13, q_, s_)) { copy(q13, q); copy(s13, s);
            } else { copy(q23, q); copy(s23, s); }
        }
    }
    else if (sum(is_inside) == 1) {
        //mexPrintf("MEX: 1 inside\n");
        size_t k = find(is_inside);
        copy(Q[k], q);
        copy(S[k], s);
    }
    else if (sum(is_inside) == 0) {
        //mexPrintf("MEX: 0 inside\n");
        double norms[D];
        norms[0] = norm_diff(p, q12);
        norms[1] = norm_diff(p, q23);
        norms[2] = norm_diff(p, q13);
        size_t k = min_index(norms);
        copy(Q[k], q);
        copy(S[k], s);
    }
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double * c1 = mxGetPr(prhs[0]);
    double * c2 = mxGetPr(prhs[1]);
    double * c3 = mxGetPr(prhs[2]);
    
    double r1 = mxGetScalar(prhs[3]);
    double r2 = mxGetScalar(prhs[4]);
    double r3 = mxGetScalar(prhs[5]);
    
    double * v1 = mxGetPr(prhs[6]);
    double * v2 = mxGetPr(prhs[7]);
    double * v3 = mxGetPr(prhs[8]);
    
    double * u1 = mxGetPr(prhs[9]);
    double * u2 = mxGetPr(prhs[10]);
    double * u3 = mxGetPr(prhs[11]);
    
    double * P =  mxGetPr(prhs[12]);
    mwSize N = (mwSize) mxGetN(prhs[12]);
    
    plhs[0] = mxCreateDoubleMatrix((mwSize)N, (mwSize)1, mxREAL);
    double * distances = mxGetPr(plhs[0]);  
    
    double p[D]; double q[D]; double s[D];
    for (size_t i = 0; i < N; i++){
        for (size_t k = 0; k < D; k++) {
            p[k] = P[i * D + k];
        }
        projection_on_convtriangle(c1, c2, c3, r1, r2, r3, v1, v2, v3, u1, u2, u3, p, s, q);        
        if (norm_diff(p, s) >= norm_diff(q, s))
            distances[i] = norm_diff(p, q);
        else
            distances[i] = - norm_diff(p, q);
    }   
    
}
