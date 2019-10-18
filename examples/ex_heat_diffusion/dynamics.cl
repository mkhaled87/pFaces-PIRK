
float dynamics_element_global(__global float* x, __global float* u, float t, unsigned int i) {
    // LONGER DESCRIPTION OF THE MODEL SHOULD GO HERE
    // short description: a linear ODE system derived from spatially discretizing the heat equation on a cube of unit dimension.
	
    // Parameters
    unsigned int N = 1000;  // grid side length. total state dimension will be N*N*N.
    float diffusivity = 0.01;
    
    float dx = 0;
    
    if(i - 1 > -1) {
        dx += x[i-1];
        dx -= x[i];
    }
    if(i + 1 < N*N*N) {
        dx += x[i+1];
        dx -= x[i];
    }
    else {
        // The x = +1.0 side isn't insulated, so there is always some loss across this side
        dx -= x[i]*.5;
    }
    if(i - N > -1) {
        dx += x[i-N];
        dx -= x[i];
    }
    if(i + N < N*N*N) {
        dx += x[i+N];
        dx -= x[i];
    }
    if(i - N*N > -1) {
        dx += x[i-N*N];
        dx -= x[i];
    }
    if(i + N*N < N*N*N) {
        dx += x[i+N*N];
        dx -= x[i];
    }
    dx = diffusivity*dx/6.0;
    
    //Now for the affine input term
    dx = dx + u[i];
    return dx;
}
