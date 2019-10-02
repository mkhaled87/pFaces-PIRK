__kernel void mc_initialize( 
    __global float *rands,
    __global float *final_state, 
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t,
    __global float *reachlb,
    __global float *reachub) {

	unsigned int i = get_global_id(0);
	float x_low, x_up, u_low, u_up;
	float randValue = rands[i];
	
	// using the last final state to expand the reach set
	// note that this function will be called for each sample iteration
	if (final_state[i] == 0.0f && reachlb[i] == 0.0f && reachub[i] == 0.0f) {
		reachlb[i] = initial_state_lower_bound(i);
		reachub[i] = initial_state_upper_bound(i);
	}
	else {
		if (final_state[i] < reachlb[i])
			reachlb[i] = final_state[i];
		if (final_state[i] > reachub[i])
			reachub[i] = final_state[i];
	}

	// generating a random state/input
	x_low = initial_state_lower_bound(i);
	x_up = initial_state_upper_bound(i);
	u_low = input_lower_bound(i);
	u_up = input_upper_bound(i);
	final_state[i] = x_low + randValue*(x_up - x_low);
	input[i] = u_low + randValue*(u_up-u_low);

	// initializiations
	k0[i] = 0.0f;
	k1[i] = 0.0f;
	k2[i] = 0.0f;
	k3[i] = 0.0f;
	tmp[i] = 0.0f;

	if (i == 0)
		*t = @@initial_time@@;
}
