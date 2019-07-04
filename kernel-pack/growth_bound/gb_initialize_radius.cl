__kernel void gb_initialize_radius( 
    __global float *initial_state,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t)
{
  float x_low, x_up, u_low, u_up;
  int i = get_global_id(0);
  x_low = initial_state_lower_bound(i);
  x_up = initial_state_upper_bound(i);
  u_low = input_lower_bound(i);
  u_up = input_upper_bound(i);
  /* for the radius dynamics, we want the initial state to be the radius of the interval 
   * (hence the name), that is one-half the distance between the upper and lower bound. */
  initial_state[i] = 0.5 * (x_up - x_low);
  final_state[i] = initial_state[i];
  k0[i] = 0;
  k1[i] = 0;
  k2[i] = 0;
  k3[i] = 0;
  tmp[i] = 0;
  input[i]=0.5 * (u_up - u_low);
  printf("%f\n",input[i]);
  *t = @@initial_time@@;

}