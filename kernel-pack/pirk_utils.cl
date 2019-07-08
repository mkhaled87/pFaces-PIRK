
#include "@@config_file_directory@@/dynamics.cl"
#include "@@config_file_directory@@/bounds.cl"

#include "@@config_file_directory@@/growth_bound_matrix.cl"
#include "@@config_file_directory@@/jacobian_bounds.cl"

float growth_bound_radius_dynamics(float* r, float* u, float t, int i)
{
  float dr=0;
  for (int j=0; j < @@states_dim@@; j++) {
    dr += growth_bound_matrix(i,j,u)*r[j];
  }
  dr += u[i]; //this is causing the bug
  return dr;
}
