__kernel void ctmm_integrate_1( 
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
    int i = get_global_id(0);  
    k0[i] = ctmm_decomposition_dynamics(final_state, input, *t, i);
    tmp[i] = final_state[i] + RK4_H / 2.0*k0[i];
}

__kernel void ctmm_integrate_2( 
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
    int i = get_global_id(0);  
    k1[i] = ctmm_decomposition_dynamics(tmp, input, *t + 0.5*step_size,  i);
    tmp[i] = final_state[i] + RK4_H / 2.0*k1[i];
}

__kernel void ctmm_integrate_3( 
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
    int i = get_global_id(0);  
    k2[i] = ctmm_decomposition_dynamics(tmp, input, *t + 0.5*step_size, i);
    tmp[i] = final_state[i] + RK4_H * k2[i];
}

__kernel void ctmm_integrate_4( 
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
    int i = get_global_id(0);  
    k3[i] = ctmm_decomposition_dynamics(tmp, input, *t +  step_size, i);
    final_state[i] = final_state[i] + (RK4_H / 6.0)*(k0[i] + 2.0*k1[i] + 2.0*k2[i] + k3[i]);
    *t += RK4_H;
}
