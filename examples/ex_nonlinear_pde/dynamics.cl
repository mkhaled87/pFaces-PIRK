
float dynamics_element_global(__global float* x, __global float* u, float t, unsigned int i) {
    // LONGER DESCRIPTION OF THE MODEL SHOULD GO HERE
    // short description: a nonlinear ODE system derived from spatially discretizing a nonlinear PDE, namely a reaction-diffusion system called the FitzHigh-Nagumo equation.
	
    // Parameters
    unsigned int N = 10;  // grid side length. total state dimension will be 2*N*N.
    float du = 1.0;
    float dv = 1.0;
    float sigma = 1.0;
    float tau = 1.0;
    float lam = 1.0;
    float kappa = 1.0;
    
    float dx = 0;
    unsigned int max_states = 2*N*N;
    
    float diffusion_term = 0;
    float reaction_term = 0;
    float cross_term = 0;
	
    //The dynamics comes in two "flavors": the dynamics for elements of the u grid (i < N*N) and the dynamics for elements on the v grid (i >= N*N).
    if(i < N*N) {
	
		
        //uncommenting the following if statement makes the segfault happen later (not until the radius integration)
        if(i>=max_states || (i-1)%(N*N) >= max_states || (i+1)%(N*N) >= max_states || (i-N)%(N*N) >= max_states || (i+N)%(N*N) >= max_states || i+N*N >= max_states) {
            printf("OH NO\n");
        }
        // in this case, the element x_i is on the u grid
        diffusion_term = du*du/4.0*(
            x[(i-1)%(N*N)] // element "to the left" of x_i
          + x[(i+1)%(N*N)] // element "to the right" of x_i
          + x[(i-N)%(N*N)] // element "above" x_i
          + x[(i+N)%(N*N)] // element "below" x_i
          - 4.0*x[i]
        );
		// The modulo N*N enforces the periodic boundary condition.
        reaction_term = lam*x[i] -x[i]*x[i]*x[i] - kappa;
		unsigned int idx = i+N*N;
		cross_term = x[i+N*N];  // this is the interaction from the v grid to the u grid
        dx = reaction_term + diffusion_term + cross_term;
    }
    else {
		
        // in this case, the element x_i is on the v grid
        diffusion_term = dv*dv/4.0*(
            x[(i-1)%(N*N)+N*N] // element "to the left" of x_i
          + x[(i+1)%(N*N)+N*N] // element "to the right" of x_i
          + x[(i-N)%(N*N)+N*N] // element "above" x_i
          + x[(i+N)%(N*N)+N*N] // element "below" x_i
          - 4.0*x[i]
        );
        // Like the "u grid" case, the modulo N*N enforces the periodic boundary condition.
        // However, the modulo operation also removes an N*N term from the index (recall that i >= N*N in this case)
        // so we have to add it back.
        reaction_term = -x[i];
		unsigned int idx = i-N*N;
		cross_term = x[idx];  // this is the interaction from the u grid to the v grid
        dx = (reaction_term + diffusion_term + cross_term)/tau;
    }
    //Now for the affine input term
    dx = dx + u[i];
    return dx;
}
