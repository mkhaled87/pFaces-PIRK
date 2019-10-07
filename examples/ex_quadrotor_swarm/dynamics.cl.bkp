
float dynamics_element_global(__global float* x, __global float* u, float t, unsigned int i) {
    // LONGER DESCRIPTION OF THE MODEL SHOULD GO HERE
    // short description: a swarm of quadrotors. Each quadrotor has 12 states.
    
    // Parameters
    float f = 1.0f;
    float m = 1.0f;
    float g = 9.8f;
	float dx = 0.0f;
    
    unsigned int k = i % 12;
    if(k==0) {
        dx = x[6];
    }
    else if(k==1) {
        dx = x[7];
    }
    else if(k==2) {
        dx = x[8];
    }
    else if(k==3) {
        dx = x[9];
    }
    else if(k==4) {
        dx = x[10];
    }
    else if(k==5) {
        dx = x[11];
    }
    else if(k==6) {
        dx = (f/m) * (-cos(x[3])*sin(x[4])*cos(x[5]) - sin(x[3])*sin(x[5]));
    }
    else if(k==7) {
        dx = (f/m) * (-cos(x[3])*sin(x[4])*cos(x[5]) + sin(x[3])*sin(x[5]));
    }
    else if(k==8) {
        dx = g - (f/m)*cos(x[3])*cos(x[4]);
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
	float dx = 0.0f;
    
    unsigned int k = i % 12;
    if(k==0) {
        dx = x[6];
    }
    else if(k==1) {
        dx = x[7];
    }
    else if(k==2) {
        dx = x[8];
    }
    else if(k==3) {
        dx = x[9];
    }
    else if(k==4) {
        dx = x[10];
    }
    else if(k==5) {
        dx = x[11];
    }
    else if(k==6) {
        dx = (f/m) * (-cos(x[3])*sin(x[4])*cos(x[5]) - sin(x[3])*sin(x[5]));
    }
    else if(k==7) {
        dx = (f/m) * (-cos(x[3])*sin(x[4])*cos(x[5]) + sin(x[3])*sin(x[5]));
    }
    else if(k==8) {
        dx = g - (f/m)*cos(x[3])*cos(x[4]);
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
	
	
    // Now for the affine input term
    dx = dx + u[i];
    return dx;
    
}
