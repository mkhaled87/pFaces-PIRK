__kernel void gb_integrate_radius_1( 
    __global float *initial_state,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t,
    __global int *cidxs,
    __global float *cvals,
    __global float *ncel)
{
    int i = get_global_id(0);  
    k0[i] = growth_bound_radius_dynamics(initial_state, input, cidxs, cvals, ncel, *t, i);
    tmp[i] = final_state[i] + RK4_H / 2.0*k0[i];
}

__kernel void gb_integrate_radius_2( 
    __global float *initial_state,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t,
    __global int *cidxs,
    __global float *cvals,
    __global float *ncel)
{
    int i = get_global_id(0);  
    k1[i] = growth_bound_radius_dynamics(tmp, input, cidxs, cvals, ncel, *t + 0.5*step_size,  i);
    tmp[i] = final_state[i] + RK4_H / 2.0*k1[i];
}

__kernel void gb_integrate_radius_3( 
    __global float *initial_state,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t,
    __global int *cidxs,
    __global float *cvals,
    __global float *ncel)
{
    int i = get_global_id(0);  
    k2[i] = growth_bound_radius_dynamics(tmp, input, cidxs, cvals, ncel, *t + 0.5*step_size, i);
    tmp[i] = final_state[i] + RK4_H * k2[i];
}

__kernel void gb_integrate_radius_4( 
    __global float *initial_state,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t,
    __global int *cidxs,
    __global float *cvals,
    __global float *ncel)
{
    int i = get_global_id(0);  
    k3[i] = growth_bound_radius_dynamics(tmp, input, cidxs, cvals, ncel, *t +  step_size, i);
    final_state[i] = final_state[i] + (RK4_H / 6.0)*(k0[i] + 2.0*k1[i] + 2.0*k2[i] + k3[i]);
    if(i==0) {
        *t += RK4_H;
    }
}

