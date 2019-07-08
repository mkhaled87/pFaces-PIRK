__kernel void gb_integrate_dynchoice_1( 
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
    k0[i] = dynfn(initial_state, input, *t, i);
    tmp[i] = final_state[i] + RK4_H / 2.0*k0[i];
}

__kernel void gb_integrate_dynchoice_2( 
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
    k1[i] = dynfn(tmp, input, *t + 0.5*step_size,  i);
    tmp[i] = final_state[i] + RK4_H / 2.0*k1[i];
}

__kernel void gb_integrate_dynchoice_3( 
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
    k2[i] = dynfn(tmp, input, *t + 0.5*step_size, i);
    tmp[i] = final_state[i] + RK4_H * k2[i];
}

__kernel void gb_integrate_dynchoice_4( 
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
    k3[i] = dynfn(tmp, input, *t +  step_size, i);
    final_state[i] = final_state[i] + (RK4_H / 6.0)*(k0[i] + 2.0*k1[i] + 2.0*k2[i] + k3[i]);
    *t += RK4_H;
}

