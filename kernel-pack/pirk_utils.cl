
// code to load the dynamics from the config file. TODO: integrate this back in
/* the dynamics post function without any noise : noise is assumed to be additive */
//void dynamics_element(__global float* dx, __global float* x, __global float* u, float t, int i);
//void dynamics_element(__global float* dx, __global float* x, __global float* u, float t, int i) {
//  @@dynamics_element_code@@
//}
#include "@@config_file_directory@@/dynamics.cl"
#include "@@config_file_directory@@/bounds.cl"

//float growth_bound_matrix(int i, int j, __global float* u)
//{
//  float c;
//  @@growth_bound_matrix_code@@
//  return c;
//}
#include "@@config_file_directory@@/growth_bound_matrix.cl"


float growth_bound_radius_dynamics( __global float* r, __global float* u, float t, int i)
{
  float dr;
  dr = 0;
  for (int j=0; j < @@states_dim@@; j++) {
    dr += growth_bound_matrix(i,j,u)*r[j];
  }
  dr += u[i]; //this is causing the bug
  return dr;
}
