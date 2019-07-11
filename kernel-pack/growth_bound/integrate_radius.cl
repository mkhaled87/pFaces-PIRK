__kernel void gb_integrate_radius_1( 
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
    int j = get_global_id(1);  
    float dr = growth_bound_matrix(i,j,input)*final_state[j] + input[i] / @@states_dim@@;
    k0[i] += dr;
    final_state[i] += (RK4_H/6.0)*dr;
    tmp[i] += RK4_H / 2.0*dr;
    if(j==0) {
        tmp[i] += final_state[i];
    }
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
    __global float *t)
{
    int i = get_global_id(0);  
    int j = get_global_id(1);  
    float dr = growth_bound_matrix(i,j,input)*tmp[j] + input[i] / @@states_dim@@;
    k1[i] += dr;
    tmp[i] += RK4_H / 2.0*dr;
    final_state[i] += (RK4_H/6.0)*2.0*dr;
    if(j==0) {
        tmp[i] -= RK4_H/2.0 * k0[i];  
    }
    /* after this is done, we should have tmp[i] = final_state[i] + RK4_H/2.0*k1[i] */
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
    __global float *t)
{
    int i = get_global_id(0);  
    int j = get_global_id(1);  
    float dr = growth_bound_matrix(i,j,input)*tmp[j] + input[i] / @@states_dim@@;
    k2[i] += dr;
    tmp[i] += RK4_H / 2.0*dr;
    final_state[i] += (RK4_H/6.0)*2.0*dr;
    if(j==0) {
        tmp[i] -= RK4_H/2.0 * k1[i];  
    }
    /* after this is done, we should have tmp[i] = final_state[i] + RK4_H/2.0*k2[i] */
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
    __global float *t)
{
    int i = get_global_id(0);  
    int j = get_global_id(1);  
    float dr = growth_bound_matrix(i,j,input)*tmp[j] + input[i] / @@states_dim@@;
    k3[i] += dr;
    final_state[i] += (RK4_H/6.0)*dr;
    
    *t += RK4_H;
    /* reset the temp vars for the next round */
    k0[i] = 0;
    k1[i] = 0;
    k2[i] = 0;
    k3[i] = 0;
    tmp[i] = 0;

}

