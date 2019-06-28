/* the dynamics post function without any noise : noise is assumed to be additive */
//void dynamics_element(__global float* dx, __global float* x, __global float* u, float t, int i);
void dynamics_element(__global float* dx, __global float* x, __global float* u, float t, int i) {
  @@dynamics_element_code@@
}

void growth_bound_radius_dynamics(__global float* dr, global float* u, i)
{
  dr[i] = 0;
  for (j=0; j < @@states_dim@@; j++) {
    dr[i] += growth_bound_matrix(i,j,u);
  }
  dr[i] += u[i];
}

float growth_bound_matrix(int i, int j, float* u)
{
  @@growth_bound_matrix_code@@
  return c;
}