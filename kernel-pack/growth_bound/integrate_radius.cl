__kernel void gb_integrate_radius_1( 
    __global float *initial_state,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *tmp2,
    __global float *t)
{
    int i = get_global_id(0);  
    int j = get_global_id(1);  
    
    printf("i,j=%d,%d\n",i,j);
    
    float dr = growth_bound_matrix(i,j,input)*tmp2[j] + input[i] / @@states_dim@@;
    k0[i] += dr;
    final_state[i] += (RK4_H/6.0)*dr;
    tmp[i] += RK4_H / 2.0*dr;
    /* after this kfun: */
    /* tmp[i] = final_state[i] + RK4_H/2*k0[i] */
    /* tmp2[i] = final_state */
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
    __global float *tmp2,
    __global float *t)
{
    int i = get_global_id(0);  
    int j = get_global_id(1);  
    float dr = growth_bound_matrix(i,j,input)*tmp[j] + input[i] / @@states_dim@@;
    k1[i] += dr;
    tmp2[i] += RK4_H / 2.0*dr;
    //final_state[i] += (RK4_H/6.0)*2.0*dr;
    /* after this kfun: */
    /* tmp[i] = final_state[i] + RK4_H/2*k0[i] */
    /* tmp2[i] = final_state[i]+ RK4_H/2*k1[i] */
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
    __global float *tmp2,
    __global float *t)
{
    int i = get_global_id(0);  
    int j = get_global_id(1);  
    float dr = growth_bound_matrix(i,j,input)*tmp2[j] + input[i] / @@states_dim@@;
    k2[i] += dr;
    tmp[i] += RK4_H / 2.0*dr;
    //final_state[i] += (RK4_H/6.0)*2.0*dr;
    if(j==1) {
        tmp[i] -= RK4_H/2.0 * k0[i];  
    }
    /* after this kfun: */
    /* tmp[i] = final_state[i] + RK4_H/2*k2[i] */
    /* tmp2[i] = final_state[i]+ RK4_H/2*k1[i] */
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
    __global float *tmp2,
    __global float *t)
{
    int i = get_global_id(0);  
    int j = get_global_id(1);  
    float dr = growth_bound_matrix(i,j,input)*tmp[j] + input[i] / @@states_dim@@;
    k3[i] += dr;
    //final_state[i] += (RK4_H/6.0)*dr;
    
    *t += RK4_H;
    /* reset the temp vars for the next round */
    k0[i] = 0;
    k1[i] = 0;
    k2[i] = 0;
    k3[i] = 0;
    tmp[i] = final_state[i];
    tmp2[i] = final_state[i];
    //if(i==0 && j==0) printf("%f\n",final_state[i]);

}

