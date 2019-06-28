__kernel void gb_initialize_center( 
    __global float *initial_state,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp)
{
  float x_low, x_up, u_low, u_up;
  @@initial_state_lower_bound_code@@
  @@initial_state_upper_bound_code@@
  @@input_lower_bound_code@@
  @@input_upper_bound_code@@
  int i = get_global_id(0);
  /* for the center dynamics, we want the initial state to be the center of the interval 
   * (hence the name), that is the mean of the upper and lower bound. */
  initial_state[i] = 0.5 * (x_low + x_up);
  final_state[i] = 0;
  k0[i] = 0;
  k1[i] = 0;
  k2[i] = 0;
  k3[i] = 0;
  tmp[i] = 0;

}
