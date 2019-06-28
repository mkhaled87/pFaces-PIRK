__kernel void initialize( 
    __global float* initial_state
    ) 
{
  int i = get_global_id(0);
  initial_state[i] = 1;
}
