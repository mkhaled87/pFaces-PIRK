
float dynamics_element_global(__global float* x, __global float* u, float t, unsigned int i) {
    // LONGER DESCRIPTION OF THE MODEL SHOULD GO HERE
    // short description: a swarm of quadrotors. Each quadrotor has 12 states.
    
    // Parameters
    float f = 1.0f;
    float m = 1.0f;
    float g = 9.8f;
	float dx = 0.0f;
    
    unsigned int k = i % 12;
    unsigned int w = i - k;
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
        dx = (f/m) * (-cos(x[w+3])*sin(x[w+4])*cos(x[w+5]) - sin(x[w+3])*sin(x[w+5]));
    }
    else if(k==7) {
        dx = (f/m) * (-cos(x[w+3])*sin(x[w+4])*sin(x[w+5]) + sin(x[w+3])*cos(x[w+5]));
    }
    else if(k==8) {
        dx = g - (f/m)*cos(x[w+3])*cos(x[w+4]);
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
        dx = x[i+6];
    }
    else if(k==1) {
        dx = x[i+7];
    }
    else if(k==2) {
        dx = x[i+8];
    }
    else if(k==3) {
        dx = x[i+9];
    }
    else if(k==4) {
        dx = x[i+10];
    }
    else if(k==5) {
        dx = x[i+11];
    }
    else if(k==6) {
        dx = (f/m) * (-cos(x[i+3])*sin(x[i+4])*cos(x[i+5]) - sin(x[i+3])*sin(x[i+5]));
    }
    else if(k==7) {
        dx = (f/m) * (-cos(x[i+3])*sin(x[i+4])*cos(x[i+5]) + sin(x[i+3])*sin(x[i+5]));
    }
    else if(k==8) {
        dx = g - (f/m)*cos(x[i+3])*cos(x[i+4]);
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
