/* some handy functions */
void flat_to_symbolic(unsigned int* symbolic_value, unsigned int dim, const unsigned int flat_value, const unsigned int* dim_width) {

	unsigned int fltCurrent;
	unsigned int fltIntial;
	unsigned int fltVolume;
	unsigned int fltTmp;

	fltIntial = flat_value;
	for (int i = dim - 1; i >= 0; i--) {
		fltCurrent = fltIntial;

		fltVolume = 1;
		for (int k = 0; k < i; k++) {
			fltTmp = dim_width[k];
			fltVolume = fltVolume*fltTmp;
		}

		fltCurrent = fltCurrent/fltVolume;
		fltTmp = dim_width[i];
		fltCurrent = fltCurrent % fltTmp;

		symbolic_value[i] = fltCurrent;

		fltCurrent = fltCurrent*fltVolume;
		fltIntial = fltIntial - fltCurrent;
	}
}
void symbolic_to_concrete(float* out_conc_value, unsigned int dim, const unsigned int* symbolic_value, const float* lb, const float* ub, const float* eta) {

	// set grid centers as concrete values
	for (unsigned int i = 0; i < dim; i++)
		out_conc_value[i] = lb[i] + (((float)symbolic_value[i]) * eta[i]);
}

/* the dynamics */
float dynamics_element_global(__global float* x, __global float* u, float t, unsigned int i) {	

	// the sequence of input for the current thread will be here
	unsigned int input_seq[4];
	
	// convert the time 0~4000 to one of four time slots {0,1,2,3}
	unsigned int time_slot_idx = (unsigned int)floor(t/1000.0f);
	
	// compute the input sequence
	input_seq[0] = i%100;
	input_seq[1] = (i/100)%100;
	input_seq[2] = ((i/100)/100)%100;
	input_seq[3] = (((i/100)/100)/100)%100;
	
	// now we have a specific input index
	unsigned int u_flat = input_seq[time_slot_idx];
	
	// getting the concrete input
	unsigned int u_widths[2] = {10, 10};
	float u_lb[2]  = {-5.0f,-5.0f};
	float u_ub[2]  = { 5.0f, 5.0f};
	float u_eta[2] = { 1.0f, 1.0f};
	unsigned int u_sym[2];
	float u_conc[2];
	flat_to_symbolic(u_sym, 2, u_flat, u_widths);
	symbolic_to_concrete(u_conc, 2, u_sym, u_lb, u_ub, u_eta);
	
	// compute the dynamics
	unsigned int state_idx = i%VEHICLE_DIM;
	if(state_idx == 0)
		x[i] = u_conc[0]*cos(atan((float)(tan(u_conc[1])/2.0))+x[i+2])/cos((float)atan((float)(tan(u_conc[1])/2.0)));
	else if(state_idx == 1)
		x[i] = u_conc[0]*sin(atan((float)(tan(u_conc[1])/2.0))+x[i+1])/cos((float)atan((float)(tan(u_conc[1])/2.0)));
	else if(state_idx == 2)
		x[i] = u_conc[0]*tan(u_conc[1]);
	
    return 0;
}
