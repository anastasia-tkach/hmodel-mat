//mex render_orthographic_model_mex.cpp -largeArrayDims -IC:\Users\tkach\OneDrive\EPFL\Code\External\eigen_dir

#include "mex.h"
#include <vector>
#include "math.h"
#include <Eigen/Dense>

using namespace Eigen;
using namespace std;

const int D = 3;
const int C = 50;

struct six {
    Vector3d v1;
    Vector3d v2;
    Vector3d v3;
    Vector3d u1;
    Vector3d u2;
    Vector3d u3;
};


template <class T>
        vector<vector<T>> parse_blocks(double * B, int N) {
    vector<vector<T>> blocks;
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
    for (int i = 0; i < N; i++) {
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
        for (int j = 0; j < D; j++) {
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

Vector3d ray_triangle_intersection(const Vector3d p0, const Vector3d p1, const Vector3d p2, const Vector3d o, const Vector3d d) {
    Vector3d i = std::numeric_limits<double>::max() *Vector3d::Ones();
    
    double epsilon = 0.00001;
    
    Vector3d e1 = p1 - p0;
    Vector3d e2 = p2 - p0;
    Vector3d q = d.cross(e2);
    double a = e1.dot(q); // determinant of the matrix M
    
    if (a > -epsilon && a < epsilon) {
        // the vector is parallel to the plane(the intersection is at infinity)
        return i;
    }
    
    double f = 1 / a;
    Vector3d s = o - p0;
    double u = f * s.dot(q);
    
    if (u < 0.0) {
        // the intersection is outside of the triangle
        return i;
    }
    
    Vector3d r = s.cross(e1);
    double v = f * d.dot(r);
    
    if (v<0.0 || u + v>1.0) {
        // the intersection is outside of the triangle
        return i;
    }
    
    double t = f * e2.dot(r); // verified!
    i = o + t * d;
    
    return i;
}

Vector3d ray_cone_intersection(const Vector3d & pa, const Vector3d & va, double alpha, const Vector3d & p, const Vector3d & v) {
    
    Vector3d i = std::numeric_limits<double>::max() *Vector3d::Ones();
    
    double cos2 = cos(alpha) * cos(alpha);
    double sin2 = sin(alpha) * sin(alpha);
    Vector3d delta_p = p - pa;
    
    Vector3d e = v - (v.dot(va))*va;
    double f = v.dot(va);
    Vector3d g = delta_p - delta_p.dot(va)*va;
    double h = delta_p.dot(va);
    
    double A = cos2 * e.dot(e) - sin2 * f * f;
    double B = 2 * cos2 * e.dot(g) - 2 * sin2 * f * h;
    double C = cos2 * g.dot(g) - sin2 * h * h;
    
    double D = B*B - 4 * A*C;
    
    double t1 = std::numeric_limits<double>::max();
    double t2 = std::numeric_limits<double>::max();
    Vector3d i1 = std::numeric_limits<double>::max() *Vector3d::Ones();
    Vector3d i2 = std::numeric_limits<double>::max() *Vector3d::Ones();
    if (D >= 0) {
        t1 = (-B - sqrt(D)) / 2 / A;
        t2 = (-B + sqrt(D)) / 2 / A;
        i1 = p + t1 * v;
        i2 = p + t2 * v;
        if (va.dot(i1 - pa) > 0) t1 = std::numeric_limits<double>::max();
        if (va.dot(i2 - pa) > 0) t2 = std::numeric_limits<double>::max();
    }
    
    if ((p - i1).norm() < (p - i2).norm()) {
        i = i1;
    }
    if ((p - i2).norm() < (p - i1).norm()) {
        i = i2;
    }
    return i;
}

Vector3d ray_sphere_intersection(const Vector3d & c, double r, const Vector3d & p, const Vector3d & v) {
    
    double A = v.transpose() * v;
    double B = -2 * (c - p).transpose() * v;
    double C = (c - p).transpose() * (c - p) - r*r;
    double D = B*B - 4 * A*C;
    
    double t1 = std::numeric_limits<double>::max();
    double t2 = std::numeric_limits<double>::max();
    Vector3d i1, i2;
    if (D >= 0) {
        t1 = (-B - sqrt(D)) / 2 / A;
        t2 = (-B + sqrt(D)) / 2 / A;
        i1 = p + t1 * v;
        i2 = p + t2 * v;
    }
    
    Vector3d i = std::numeric_limits<double>::max() *Vector3d::Ones();
    if (abs(t1) < abs(t2)) {
        i = i1;
    }
    if (abs(t1) > abs(t2)) {
        i = i2;
    }
    return i;
}

Vector3d ray_convsegment_intersection(const Vector3d & c1, const Vector3d &c2, double r1, double r2, int index1, int index2, const Vector3d & p, const Vector3d & v) {
    Vector3d n = (c2 - c1) / (c2 - c1).norm();
    double beta = asin((r1 - r2) / (c1 - c2).norm());
    double eta1 = r1 * sin(beta);
    Vector3d s1 = c1 + eta1 * n;
    double eta2 = r2 * sin(beta);
    Vector3d s2 = c2 + eta2 * n;
    
    Vector3d z = c1 + (c2 - c1) * r1 / (r1 - r2);
    double r = r1 * cos(beta);
    double h = (z - s1).norm();
    double alpha = atan(r / h);
    
    Vector3d i = std::numeric_limits<double>::max() *Vector3d::Ones();
    
    // Ray - cone intersections
    Vector3d i12 = ray_cone_intersection(z, n, alpha, p, v);
    if (n.transpose() *(i12 - s1) >= 0 && n.transpose() * (i12 - s2) <= 0 && i12.norm() < std::numeric_limits<double>::max()) {
        i = i12;        
    }
    
    // Ray - sphere intersection
    Vector3d i1 = ray_sphere_intersection(c1, r1, p, v);
    if (n.transpose() * (i1 - s1) < 0 && i1.norm() < std::numeric_limits<double>::max()) {
        i = i1;       
    }
    
    // Ray - sphere intersection
    Vector3d i2 = ray_sphere_intersection(c2, r2, p, v);
    if (n.transpose() * (i2 - s2) > 0 && i2.norm() < std::numeric_limits<double>::max()) {
        i = i2;        
    }
    return i;
}

Vector3d ray_convtriangle_intersection(const Vector3d & c1, const Vector3d & c2, const Vector3d & c3, const Vector3d & v1, const Vector3d & v2, const Vector3d & v3,
        const Vector3d & u1, const Vector3d & u2, const Vector3d & u3, double r1, double r2, double r3, int index1, int index2, int index3, const Vector3d & p, const Vector3d & v, int & w) {
    
    vector<Vector3d> I;
    vector<int> W;
    I.push_back(ray_convsegment_intersection(c1, c2, r1, r2, index1, index2, p, v)); w = C * index1 + index2; W.push_back(w);
    I.push_back(ray_convsegment_intersection(c1, c3, r1, r3, index1, index3, p, v)); w = C * index1 + index3; W.push_back(w);
    I.push_back(ray_convsegment_intersection(c2, c3, r2, r3, index2, index3, p, v)); w = C * index2 + index3; W.push_back(w);
    I.push_back(ray_triangle_intersection(v1, v2, v3, p, v)); w = C * C * index1 + C * index2 + index3; W.push_back(w);
    I.push_back(ray_triangle_intersection(u1, u2, u3, p, v)); w = -w; W.push_back(w);
    
    double min_value = std::numeric_limits<double>::max();
    int min_index = 0;
    for (int j = 0; j < I.size(); j++) {
        double value = (p - I[j]).norm();
        if (value < min_value) {
            min_value = value;
            min_index = j;
        }
    }
    Vector3d i = I[min_index];
    w = W[min_index];
    return i;
}

Vector3d ray_model_intersection(const vector<Vector3d> & centers, const vector<vector<int>> & blocks,
        const VectorXd & radii, const vector<six> & tangent_points, const Vector3d & p, const Vector3d & d, int & w) {
    Vector3d i;
    int min_w = -RAND_MAX;
    Vector3d min_i = std::numeric_limits<double>::max() *Vector3d::Ones();
    double min_distance = std::numeric_limits<double>::max();
    Vector3d c1, c2, c3, v1, v2, v3, u1, u2, u3;
    double r1, r2, r3;
    for (int j = 0; j < blocks.size(); j++) {
        vector<int> block = blocks[j];
        six tangent_point = tangent_points[j];
        if (block.size() == 3) {
            c1 = centers[block[0]]; c2 = centers[block[1]]; c3 = centers[block[2]];
            r1 = radii[block[0]]; r2 = radii[block[1]]; r3 = radii[block[2]];
            v1 = tangent_point.v1; v2 = tangent_point.v2; v3 = tangent_point.v3;
            u1 = tangent_point.u1; u2 = tangent_point.u2; u3 = tangent_point.u3;
            i = ray_convtriangle_intersection(c1, c2, c3, v1, v2, v3, u1, u2, u3, r1, r2, r3, block[0], block[1], block[2], p, d, w);
            if ((p - i).norm() < min_distance) {
                min_distance = (p - i).norm();
                min_i = i;
                min_w = w;
            }
        }
        if (block.size() == 2) {
            c1 = centers[block[0]]; c2 = centers[block[1]];
            r1 = radii[block[0]]; r2 = radii[block[1]];
            i = ray_convsegment_intersection(c1, c2, r1, r2, block[0], block[1], p, d);
            if ((p - i).norm() < min_distance ) {
                min_distance = (p - i).norm();
                min_i = i;
                min_w = C * block[0] + block[1];
            }            
        }
    }
    w = min_w;
    return min_i;
}

void render_model(const vector<Vector3d> & centers, const vector<vector<int>> & blocks,
        const VectorXd & radii, const vector<six> & tangent_points, const Matrix<double, 3, 3> & M, const Vector3d & p, int W, int H,
        double * U, double * V, double * D, int * I) {
    
    Vector3d i, c;
    Vector3d d = Vector3d(0, 0, 1);
    int w = -RAND_MAX;
    for (int n = 0; n < W; n++) {
        for (int m = 0; m < H; m++) {
            c = M * Vector3d(n, m, 1);
            c(2) = p(2);
            i = ray_model_intersection(centers, blocks, radii, tangent_points, c, d, w);
            
            if (i.norm() < std::numeric_limits<double>::max()) {
                U[n * H + m] = i(0);
                V[n * H + m] = i(1);
                D[n * H + m] = i(2);
                I[n * H + m] = w;
                
                //mexPrintf("n = %d, m = %d, p = %f %f %f\n", n, m, c(0), c(1), c(2), w);
            }
            else {
                U[n * H + m] = - RAND_MAX;
                V[n * H + m] = - RAND_MAX;
                D[n * H + m] = - RAND_MAX;
                I[n * H + m] = - RAND_MAX;
            }            
        }
    }
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])

{
    //(C, R, B, T, M, W, H, p)
    
    mwSize C_rows = (mwSize) mxGetM(prhs[0]);
    mwSize R_rows = (mwSize) mxGetM(prhs[1]);
    mwSize B_rows = (mwSize) mxGetM(prhs[2]);
    mwSize T_rows = (mwSize) mxGetM(prhs[3]);
    mwSize M_rows = (mwSize) mxGetM(prhs[4]);
    double * C = mxGetPr(prhs[0]);
    double * R = mxGetPr(prhs[1]);
    double * B = mxGetPr(prhs[2]);
    double * T = mxGetPr(prhs[3]);
    double * M = mxGetPr(prhs[4]);
    int W = (int) mxGetScalar(prhs[5]);
    int H = (int) mxGetScalar(prhs[6]);
    double * p_pointer = mxGetPr(prhs[7]);
    Map<RowVector3d> p = Map<RowVector3d>(p_pointer);
    
    vector<Vector3d> centers = parse_points(C, C_rows);
    VectorXd radii = VectorXd::Zero(R_rows);
    for (int i = 0; i < R_rows; i++) radii(i) = R[i];
    vector<vector<int>> blocks = parse_blocks<int>(B, B_rows);
    vector<six> tangent_points = parse_tangent_points(T, T_rows);
    Matrix<double, 3, 3> matrix =  Matrix<double, 3, 3>::Zero();
    for (int i = 0; i < 3; i++){
        for(int j = 0; j < 3; j++){
            matrix(i, j) = M[j * 3 + i];
        }
    }
    
    plhs[0] = mxCreateDoubleMatrix((mwSize) H, (mwSize)W, mxREAL);
    double * U = mxGetPr(plhs[0]);
    
    plhs[1] = mxCreateDoubleMatrix((mwSize) H, (mwSize)W, mxREAL);
    double * V = mxGetPr(plhs[1]);
    
    plhs[2] = mxCreateDoubleMatrix((mwSize) H, (mwSize)W, mxREAL);
    double * D = mxGetPr(plhs[2]);
    
    plhs[3] = mxCreateNumericMatrix((mwSize) H, (mwSize)W, mxINT32_CLASS, mxREAL);
    int * I = (int *) mxGetPr(plhs[3]);
    
    render_model(centers, blocks, radii, tangent_points, matrix, p, W, H, U, V, D, I);
    
}


