__kernel void mc_initialize( 
    __global float *initial_state,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t,
    __global float *rands1,
    __global float *rands2)
{
  int sample_idx = get_global_id(0);
  int state_idx = get_global_id(1);
  int flat_idx = sample_idx*@@states_dim@@ + state_idx;
  int randseed = flat_idx;

  float x_low, x_up, u_low, u_up;
  x_low = initial_state_lower_bound(state_idx);
  x_up = initial_state_upper_bound(state_idx);
  u_low = input_lower_bound(state_idx);
  u_up = input_upper_bound(state_idx);
  
  initial_state[flat_idx] = x_low + rands1[flat_idx]*(x_up-x_low);
  final_state[flat_idx] = initial_state[flat_idx];
  input[flat_idx] = u_low + rands2[flat_idx]*(u_up-u_low);

  k0[flat_idx] = 0;
  k1[flat_idx] = 0;
  k2[flat_idx] = 0;
  k3[flat_idx] = 0;
  tmp[flat_idx] = 0;
  *t = @@initial_time@@;

}
