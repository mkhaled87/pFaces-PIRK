__kernel void mc_integrate_1( 
    __global float *initial_state,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t){

	unsigned int sample_idx = get_global_id(0);
	unsigned int state_idx = get_global_id(1);
	unsigned int flat_idx = sample_idx*@@states_dim@@ + state_idx;

	__global float *current_sample_ptr;
	current_sample_ptr = final_state + sample_idx*@@states_dim@@;

	//current_sample_ptr = final_state; 
	k0[flat_idx] = dynamics_element_global(current_sample_ptr, input, *t, state_idx);
	tmp[flat_idx] = final_state[flat_idx] + RK4_H / 2.0*k0[flat_idx];
}

__kernel void mc_integrate_2( 
    __global float *initial_state,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t){

	unsigned int sample_idx = get_global_id(0);
	unsigned int state_idx = get_global_id(1);
	unsigned int flat_idx = sample_idx*@@states_dim@@ + state_idx;

    __global float *current_sample_ptr;
    current_sample_ptr = tmp + sample_idx*@@states_dim@@;

    //current_sample_ptr = tmp;
    k1[flat_idx] = dynamics_element_global(current_sample_ptr, input, *t + 0.5*step_size, state_idx);
    tmp[flat_idx] = final_state[flat_idx] + RK4_H / 2.0*k1[flat_idx];
}

__kernel void mc_integrate_3( 
    __global float *initial_state,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t){

	unsigned int sample_idx = get_global_id(0);
	unsigned int state_idx = get_global_id(1);
	unsigned int flat_idx = sample_idx*@@states_dim@@ + state_idx;

    __global float *current_sample_ptr;
    current_sample_ptr = tmp + sample_idx*@@states_dim@@;

    //current_sample_ptr = tmp;
    k2[flat_idx] = dynamics_element_global(current_sample_ptr, input, *t + 0.5*step_size, state_idx);
    tmp[flat_idx] = final_state[flat_idx] + RK4_H * k2[flat_idx];
}

__kernel void mc_integrate_4( 
    __global float *initial_state,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t){

	unsigned int sample_idx = get_global_id(0);
	unsigned int state_idx = get_global_id(1);
	unsigned int flat_idx = sample_idx*@@states_dim@@ + state_idx;

    __global float *current_sample_ptr;
    current_sample_ptr = tmp + sample_idx*@@states_dim@@;

    //current_sample_ptr = tmp;
    k3[flat_idx] = dynamics_element_global(current_sample_ptr, input, *t +  step_size, state_idx);
    final_state[flat_idx] = final_state[flat_idx] + (RK4_H / 6.0)*(k0[flat_idx] + 2.0*k1[flat_idx] + 2.0*k2[flat_idx] + k3[flat_idx]);

	if (flat_idx == 0)
		*t += RK4_H;
}