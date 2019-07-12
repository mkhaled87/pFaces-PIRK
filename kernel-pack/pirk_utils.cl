
#include "@@config_file_directory@@/dynamics.cl"
#include "@@config_file_directory@@/bounds.cl"

#ifdef MC_1
#include "@@config_file_directory@@/growth_bound_matrix.cl"
#endif
#ifdef MC_2
#include "@@config_file_directory@@/jacobian_bounds.cl"
#endif

/* useful defines for RK4 integration */
#define step_size @@true_step_size@@
#define RK4_NINT 5
#define RK4_H ((@@true_step_size@@/RK4_NINT))


float growth_bound_radius_dynamics(__global float* r, __global float* u, float t, int i)
{
  float dr=0;
  for (int j=0; j < @@states_dim@@; j++) {
    dr += growth_bound_matrix(i,j,u)*r[j];
  }
  dr += u[i]; //this is causing the bug
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