__kernel 
void gb_integrate_center_1( 
    __global float *initial_state,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t){

	unsigned int i = get_global_id(0);
    k0[i] = dynamics_element_global(initial_state, input, *t, i);
    tmp[i] = final_state[i] + RK4_H / 2.0*k0[i];
}

__kernel 
void gb_integrate_center_2( 
    __global float *initial_state,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t){

	unsigned int i = get_global_id(0);
    k1[i] = dynamics_element_global(tmp, input, *t + 0.5*step_size,  i);
    tmp[i] = final_state[i] + RK4_H / 2.0*k1[i];
}

__kernel 
void gb_integrate_center_3( 
    __global float *initial_state,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t){

	unsigned int i = get_global_id(0);
    k2[i] = dynamics_element_global(tmp, input, *t + 0.5*step_size, i);
    tmp[i] = final_state[i] + RK4_H * k2[i];
}

__kernel void gb_integrate_center_4( 
    __global float *initial_state,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t){

	unsigned int i = get_global_id(0);
    k3[i] = dynamics_element_global(tmp, input, *t +  step_size, i);
    final_state[i] = final_state[i] + (RK4_H / 6.0)*(k0[i] + 2.0*k1[i] + 2.0*k2[i] + k3[i]);


	// MK: This is not correct. It works now since the systems are not time dependent
	// if i=0 gets executed before others, time will be changed and other threads will use
	// different time
	// TODO: Make a different function to increment the time
    if(i==0)
		*t += RK4_H;
}

