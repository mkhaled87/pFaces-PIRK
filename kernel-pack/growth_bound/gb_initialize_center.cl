__kernel 
void gb_initialize_center( 
    __global float *initial_state,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t){

	unsigned int i;
	float x_low, x_up, u_low, u_up;
	
	i = get_global_id(0);
	x_low = initial_state_lower_bound(i);
	x_up = initial_state_upper_bound(i);
	u_low = input_lower_bound(i);
	u_up = input_upper_bound(i);
	
	/* for the center dynamics, we want the initial state to be the center of the interval 
	* (hence the name), that is the mean of the upper and lower bound. */
	initial_state[i] = 0.5f * (x_low + x_up);
	final_state[i] = initial_state[i];
	k0[i] = 0.0f;
	k1[i] = 0.0f;
	k2[i] = 0.0f;
	k3[i] = 0.0f;
	tmp[i] = 0.0f;
	input[i] = 0.5f * (u_up + u_low);

	if(i == 0)
		*t = @@initial_time@@f;
}
