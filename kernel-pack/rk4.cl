#define RK4_NINT 5
#define RK4_H ((@@true_step_size@@/RK4_NINT))

__kernel void rk4( 
    __global float *initial_state,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp)
{

  int i = get_global_id(0);
  float t = @@initial_time@@;
  int nsteps = @@nsteps@@;
  float step_size = @@true_step_size@@;
  
  final_state[i] = initial_state[i];
  for (unsigned int k=0; k < @@nsteps@@; k++) {

    for (unsigned int t = 0; t < RK4_NINT; t++) {
    
      #define dyn_fn dynamics_element
      #include "dynamics_body.cl"

    }
  }
}