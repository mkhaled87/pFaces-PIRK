__kernel 
void gb_integrate_radius_1( 
    __global float *initial_state,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t
#ifndef MEM_EFFICIENT
	,
    __global unsigned int *cidxs,
    __global float *cvals,
    __global unsigned int *ncel
#endif
){

	unsigned int i;

	i = get_global_id(0);
#ifndef MEM_EFFICIENT
	k0[i] = growth_bound_radius_dynamics(final_state, input, cidxs, cvals, ncel, *t, i);
#else
	k0[i] = growth_bound_radius_dynamics(final_state, input, *t, i);	
#endif
	tmp[i] = final_state[i] + RK4_H/2.0f*k0[i];
}

__kernel 
void gb_integrate_radius_2( 
    __global float *initial_state,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
	__global float* t
#ifndef MEM_EFFICIENT
	,
	__global unsigned int *cidxs,
	__global float *cvals,
	__global unsigned int *ncel
#endif
) {

	unsigned int i;

	i = get_global_id(0);
#ifndef MEM_EFFICIENT
	k1[i] = growth_bound_radius_dynamics(tmp, input, cidxs, cvals, ncel, *t + 0.5f*step_size,  i);
#else
	k1[i] = growth_bound_radius_dynamics(tmp, input, *t + 0.5f*step_size, i);	
#endif
	tmp[i] = final_state[i] + RK4_H/2.0f*k1[i];
}

__kernel 
void gb_integrate_radius_3( 
    __global float *initial_state,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
	__global float* t
#ifndef MEM_EFFICIENT
	,
	__global unsigned int *cidxs,
	__global float *cvals,
	__global unsigned int *ncel
#endif
) {

	unsigned int i;

	i = get_global_id(0);
#ifndef MEM_EFFICIENT
	k2[i] = growth_bound_radius_dynamics(tmp, input, cidxs, cvals, ncel, *t + 0.5f*step_size, i);
#else
	k2[i] = growth_bound_radius_dynamics(tmp, input, *t + 0.5f*step_size, i);
#endif
	tmp[i] = final_state[i] + RK4_H*k2[i];
}

__kernel 
void gb_integrate_radius_4( 
    __global float *initial_state,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
	__global float* t
#ifndef MEM_EFFICIENT
	,
	__global unsigned int *cidxs,
	__global float *cvals,
	__global unsigned int *ncel
#endif
) {

	unsigned int i;

	i = get_global_id(0);
#ifndef MEM_EFFICIENT
	k3[i] = growth_bound_radius_dynamics(tmp, input, cidxs, cvals, ncel, *t +  step_size, i);
#else
	k3[i] = growth_bound_radius_dynamics(tmp, input, *t + step_size, i);
#endif
	final_state[i] = final_state[i] + (RK4_H/6.0f)*(k0[i] + 2.0f*k1[i] + 2.0f*k2[i] + k3[i]);


	// MK: This is not correct. It works now since the systems are not time dependent
	// if i=0 gets executed before others, time will be changed and other threads will use
	// different time
	// TODO: Make a different function to increment the time
	if (i == 0)
		*t += RK4_H;
}

