/* the dynamics post function without any noise : noise is assumed to be additive */
//void dynamics_element(__global float* dx, __global float* x, __global float* u, float t, int i);
void dynamics_element(__global float* dx, __global float* x, __global float* u, float t, int i) {
  @@dynamics_element_code@@
}

float growth_bound_matrix(int i, int j, __global float* u)
{
  float c;
  @@growth_bound_matrix_code@@
  return c;
}

void growth_bound_radius_dynamics(__global float* dr, __global float* r, __global float* u, float t, int i)
{
  dr[i] = 0;
  for (int j=0; j < @@states_dim@@; j++) {
    //dr[i] += growth_bound_matrix(i,j,u)*r[j];
    dr[i] += 0.1;
  }
  dr[i] += u[i]; //this is causing the bug
}
