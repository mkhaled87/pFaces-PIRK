
#include "@@config_file_directory@@/dynamics.cl"
#include "@@config_file_directory@@/bounds.cl"

#include "@@config_file_directory@@/growth_bound_matrix.cl"
#include "@@config_file_directory@@/jacobian_bounds.cl"

/* useful defines for RK4 integration */
#define step_size @@true_step_size@@
#define RK4_NINT 5
#define RK4_H ((@@true_step_size@@/RK4_NINT))


float growth_bound_radius_dynamics(__global float* r, __global float* u, __global int *cidxs, __global float *cvals, __global float *ncel, float t, int i)
{
  float dr=0;
  int idx;
  for (int j=0; j < ncel[i]; j++) {
    idx = cidxs[i*@@row_max@@ + j];
    dr += cvals[idx]*r[j];
  }
  dr += u[i];
  return dr;
}


int krand(int* seed) // 1 <= *seed < m
{
    int const a = 16807; //ie 7**5
    int const m = 2147483647; //ie 2**31-1
    int tmp = *seed;
    //*seed = ((long( tmp * a)%m;
    *seed = tmp * a;
    *seed = *seed %m;
    return(*seed);
}