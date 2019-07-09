__kernel void ctmm_initialize( 
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
    if(i - @@states_dim@@ < 0) {
        /* The index is in the 'upper half', so we're computing g(x,u,xhat,uhat). */
        initial_state[i] = initial_state_lower_bound(i);
        final_state[i] = initial_state[i];
        input[i] = input_lower_bound(i);

    }
    else {
        /* the index is in the 'lower half', so we're computing g(xhat,uhat,x,u). */
        initial_state[i] = initial_state_upper_bound(i-@@states_dim@@);
        final_state[i] = initial_state[i];
        input[i] = input_upper_bound(i-@@states_dim@@);
    }
  k0[i] = 0;
  k1[i] = 0;
  k2[i] = 0;
  k3[i] = 0;
  tmp[i] = 0;
  *t = @@initial_time@@;

}