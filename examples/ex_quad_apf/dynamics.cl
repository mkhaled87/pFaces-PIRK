
float dynamics_element_global(__global float* x, __global float* u, float t, unsigned int i) {
    // LONGER DESCRIPTION OF THE MODEL SHOULD GO HERE
    // short description: a swarm of quadrotors. Each quadrotor has 12 states.
    
    // Parameters
    float f = 1.0f;
    float m = 1.0f;
    float g = 9.8f;
    float fatt = 0.5;  // maximum attactive force
    float frep= 1.0;   // maximum repulsive force
    float dx = 0.0f;
    float apf_term = 0.0;
    float dynamics_term = 0.0;
    unsigned int nstates = SS_DIM;
    unsigned int nquads = nstates / 12;
    unsigned int this_quad_idx = i / 12;
    unsigned int k = i % 12;
    unsigned int w = i - k;
    unsigned int closest_quad_idx = 0;
    float quad_dist = 0.0;
    float quad_signed_dist = 0.0;
    float closest_quad_dist = INFINITY;
    float closest_quad_signed_dist = INFINITY;
    

    if(k==0) {
        dx = x[w+6];
    }
    else if(k==1) {
        dx = x[w+7];
    }
    else if(k==2) {
        dx = x[w+8];
    }
    else if(k==3) {
        dx = x[w+9];
    }
    else if(k==4) {
        dx = x[w+10];
    }
    else if(k==5) {
        dx = x[w+11];
    }
    else if(k==6) {
        closest_quad_dist = INFINITY;
        // find the index of the nearest quadrotor in this direction
        for(unsigned int quad_idx = 0; quad_idx < nquads; quad_idx++) {  // iterate through each quadrotor
            if(quad_idx != this_quad_idx){ // but skip THIS quadrotor, of course
                quad_signed_dist = x[w+6] - x[12*quad_idx+6];
                quad_dist = fabs(quad_signed_dist);
                if(quad_dist < closest_quad_dist) {
                    closest_quad_dist = quad_dist;
                    closest_quad_signed_dist = quad_signed_dist;
                    closest_quad_idx = quad_idx;
                }
            }
        }
        apf_term = frep*(closest_quad_signed_dist/closest_quad_dist)*exp(-closest_quad_dist) - fatt*x[w+6]/fabs(x[w+6]);
        dynamics_term = (f/m) * (-cos(x[w+3])*sin(x[w+4])*cos(x[w+5]) - sin(x[w+3])*sin(x[w+5]));
        dx = dynamics_term + apf_term;
    }
    else if(k==7) {
        closest_quad_dist = INFINITY;
        // find the index of the nearest quadrotor in this direction
        for(unsigned int quad_idx = 0; quad_idx < nquads; quad_idx++) { // iterate through each quadrotor
            if(quad_idx != this_quad_idx){ // but skip THIS quadrotor, of course
                quad_signed_dist = x[w+7] - x[12*quad_idx+7];
                quad_dist = fabs(quad_signed_dist);
                if(quad_dist < closest_quad_dist) {
                    closest_quad_dist = quad_dist;
                    closest_quad_signed_dist = quad_signed_dist;
                    closest_quad_idx = quad_idx;
                }
            }
        }
        apf_term = frep*(closest_quad_signed_dist/closest_quad_dist)*exp(-closest_quad_dist) - fatt*x[w+7]/fabs(x[w+7]);
        dynamics_term = (f/m) * (-cos(x[w+3])*sin(x[w+4])*sin(x[w+5]) + sin(x[w+3])*cos(x[w+5]));
        dx = dynamics_term + apf_term;
    }
    else if(k==8) {
        closest_quad_dist = INFINITY;
        // find the index of the nearest quadrotor in this direction
        for(unsigned int quad_idx = 0; quad_idx < nquads; quad_idx++) { // iterate through each quadrotor
            if(quad_idx != this_quad_idx){ // but skip THIS quadrotor, of course
                quad_signed_dist = x[w+8] - x[12*quad_idx+8];
                quad_dist = fabs(quad_signed_dist);
                if(quad_dist < closest_quad_dist) {
                    closest_quad_dist = quad_dist;
                    closest_quad_signed_dist = quad_signed_dist;
                    closest_quad_idx = quad_idx;
                }
            }
        }
        apf_term = frep*(closest_quad_signed_dist/closest_quad_dist)*exp(-closest_quad_dist) - fatt*x[w+8]/fabs(x[w+8]);
        dynamics_term = g - (f/m)*cos(x[w+3])*cos(x[w+4]);
        dx = dynamics_term + apf_term;
    }
    else if(k==9) {
        dx = 0.0f;
    }
    else if(k==10) {
        dx = 0.0f;
    }
    else if(k==11) {
        dx = 0.0f;
    }
	else {
		printf("Huh ?? i=%d, k=%d", i, k);
	}
	
    // Now for the affine input term
    dx = dx + u[i];
    return dx;
}



float dynamics_element_private(float* x, float* u, float t,unsigned int i) {
    // LONGER DESCRIPTION OF THE MODEL SHOULD GO HERE
    // short description: a swarm of quadrotors. Each quadrotor has 12 states.
    
    // Parameters
    float f = 1.0f;
    float m = 1.0f;
    float g = 9.8f;
    float fatt = 0.5;  // maximum attactive force
    float frep= 1.0;   // maximum repulsive force
    float dx = 0.0f;
    float apf_term = 0.0;
    float dynamics_term = 0.0;
    unsigned int nstates = SS_DIM;
    unsigned int nquads = nstates / 12;
    unsigned int this_quad_idx = i / 12;
    unsigned int k = i % 12;
    unsigned int w = i - k;
    unsigned int closest_quad_idx = 0;
    float quad_dist = 0.0;
    float quad_signed_dist = 0.0;
    float closest_quad_dist = INFINITY;
    float closest_quad_signed_dist = INFINITY;
    

    if(k==0) {
        dx = x[w+6];
    }
    else if(k==1) {
        dx = x[w+7];
    }
    else if(k==2) {
        dx = x[w+8];
    }
    else if(k==3) {
        dx = x[w+9];
    }
    else if(k==4) {
        dx = x[w+10];
    }
    else if(k==5) {
        dx = x[w+11];
    }
    else if(k==6) {
        closest_quad_dist = INFINITY;
        // find the index of the nearest quadrotor in this direction
        for(unsigned int quad_idx = 0; quad_idx < nquads; quad_idx++) {  // iterate through each quadrotor
            if(quad_idx != this_quad_idx){ // but skip THIS quadrotor, of course
                quad_signed_dist = x[w+6] - x[12*quad_idx+6];
                quad_dist = fabs(quad_signed_dist);
                if(quad_dist < closest_quad_dist) {
                    closest_quad_dist = quad_dist;
                    closest_quad_signed_dist = quad_signed_dist;
                    closest_quad_idx = quad_idx;
                }
            }
        }
        apf_term = frep*(closest_quad_signed_dist/closest_quad_dist)*exp(-closest_quad_dist) - fatt*x[w+6]/fabs(x[w+6]);
        dynamics_term = (f/m) * (-cos(x[w+3])*sin(x[w+4])*cos(x[w+5]) - sin(x[w+3])*sin(x[w+5]));
        dx = dynamics_term + apf_term;
    }
    else if(k==7) {
        closest_quad_dist = INFINITY;
        // find the index of the nearest quadrotor in this direction
        for(unsigned int quad_idx = 0; quad_idx < nquads; quad_idx++) { // iterate through each quadrotor
            if(quad_idx != this_quad_idx){ // but skip THIS quadrotor, of course
                quad_signed_dist = x[w+7] - x[12*quad_idx+7];
                quad_dist = fabs(quad_signed_dist);
                if(quad_dist < closest_quad_dist) {
                    closest_quad_dist = quad_dist;
                    closest_quad_signed_dist = quad_signed_dist;
                    closest_quad_idx = quad_idx;
                }
            }
        }
        apf_term = frep*(closest_quad_signed_dist/closest_quad_dist)*exp(-closest_quad_dist) - fatt*x[w+7]/fabs(x[w+7]);
        dynamics_term = (f/m) * (-cos(x[w+3])*sin(x[w+4])*sin(x[w+5]) + sin(x[w+3])*cos(x[w+5]));
        dx = dynamics_term + apf_term;
    }
    else if(k==8) {
        closest_quad_dist = INFINITY;
        // find the index of the nearest quadrotor in this direction
        for(unsigned int quad_idx = 0; quad_idx < nquads; quad_idx++) { // iterate through each quadrotor
            if(quad_idx != this_quad_idx){ // but skip THIS quadrotor, of course
                quad_signed_dist = x[w+8] - x[12*quad_idx+8];
                quad_dist = fabs(quad_signed_dist);
                if(quad_dist < closest_quad_dist) {
                    closest_quad_dist = quad_dist;
                    closest_quad_signed_dist = quad_signed_dist;
                    closest_quad_idx = quad_idx;
                }
            }
        }
        apf_term = frep*(closest_quad_signed_dist/closest_quad_dist)*exp(-closest_quad_dist) - fatt*x[w+8]/fabs(x[w+8]);
        dynamics_term = g - (f/m)*cos(x[w+3])*cos(x[w+4]);
        dx = dynamics_term + apf_term;
    }
    else if(k==9) {
        dx = 0.0f;
    }
    else if(k==10) {
        dx = 0.0f;
    }
    else if(k==11) {
        dx = 0.0f;
    }
	else {
		printf("Huh ?? i=%d, k=%d", i, k);
	}
	
    // Now for the affine input term
    dx = dx + u[i];
    return dx;
}
