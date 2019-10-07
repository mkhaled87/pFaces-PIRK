float state_jacobian_lower_bound(unsigned int i, unsigned int j) {
    // Parameters
    unsigned int N = 10;  // grid side length. total state dimension will be 2*N*N.
    float du = 1.0;
    float dv = 1.0;
    float sigma = 1.0;
    float tau = 1.0;
    float lam = 1.0;
    float kappa = 1.0;
    
    float c = 0;
    
    if(j - i == -N*N) {
        // In this case, x_i is in the u grid, x_j is in the v grid, and they are both in the same position on the grid.
        // That means that this Jacobian element corresponds to a cross term; specifically, from the v grid to the u grid.
        c = -sigma;
    }
    else if(j - i == N*N) {
        // In this case, x_i is in the v grid, x_j is in the u grid, and they are both in the same position on the grid.
        // That means that this Jacobian element corresponds to a cross term; specifically, from the u grid to the v grid.
        c = 1/tau;
    }
    // All other nonzero Jacobian terms will only take place between elements on the same grid, and we can consider these two cases separately.
    else if(i < N*N && j < N*N) {
        if(i==j) {
            // This is the reaction term of the u grid with itself.
            // In the dynamics, there is a -x^3 term, which becomes -3x^2 in the Jacobian. This term is can be arbitrarily low, so the Jacobian lower bound is negative infinity.
            c = -inf;
        }
        else {
            // if this wasn't the reaction term, it may still be a diffusion term. We'll check that now.
            int rpos = (i - j)%(N*N); // this is the "relative position" of element j to element i on the u grid.
            if(
                (j - i)%(N*N) == 1  // j is "one to the right of" i 
             || (j - i)%(N*N) == N  // j is "one below" i
             || (j - i)%(N*N) == N*N - 1  // j is "one to the left of" i
             || (j - i)%(N*N) == N *N - N  // j is "one above" i
            ) {
                c = du*du/4;
            }
        }
    }
    else if(i >= N*N && j >= N*N) {
        if(i==j) {
            // This is the reaction term of the v grid with itself.
            c = (-dv*dv - 1)/tau;
        }
        else {
            // if this wasn't the reaction term, it may still be a diffusion term. We'll check that now.
            int rpos = (i - j)%(N*N); // this is the "relative position" of element j to element i on the u grid.
            if(
                (j - i)%(N*N) == 1  // j is "one to the right of" i 
             || (j - i)%(N*N) == N  // j is "one below" i
             || (j - i)%(N*N) == N*N - 1  // j is "one to the left of" i
             || (j - i)%(N*N) == N *N - N  // j is "one above" i
            ) {
                c = dv*dv/(4*tau);
            }
        }
    }
    else {
        c = 0;
    }
    
    return c;
}

float state_jacobian_upper_bound(unsigned int i, unsigned int j) {
    // Parameters
    unsigned int N = 10;  // grid side length. total state dimension will be 2*N*N.
    float du = 1.0;
    float dv = 1.0;
    float sigma = 1.0;
    float tau = 1.0;
    float lam = 1.0;
    float kappa = 1.0;
    
    float c = 0;
    
    if(j - i == -N*N) {
        // In this case, x_i is in the u grid, x_j is in the v grid, and they are both in the same position on the grid.
        // That means that this Jacobian element corresponds to a cross term; specifically, from the v grid to the u grid.
        c = -sigma;
    }
    else if(j - i == N*N) {
        // In this case, x_i is in the v grid, x_j is in the u grid, and they are both in the same position on the grid.
        // That means that this Jacobian element corresponds to a cross term; specifically, from the u grid to the v grid.
        c = 1/tau;
    }
    // All other nonzero Jacobian terms will only take place between elements on the same grid, and we can consider these two cases separately.
    else if(i < N*N && j < N*N) {
        if(i==j) {
            // This is the reaction term of the u grid with itself.
            // In the dynamics, there is a -x^3 term, which becomes -3x^2 in the Jacobian. The largest value this term attains is 0, which is why it doesn't appear here in the upper bound.
            c = -du*du + lam;
        }
        else {
            // if this wasn't the reaction term, it may still be a diffusion term. We'll check that now.
            int rpos = (i - j)%(N*N); // this is the "relative position" of element j to element i on the u grid.
            if(
                (j - i)%(N*N) == 1  // j is "one to the right of" i 
             || (j - i)%(N*N) == N  // j is "one below" i
             || (j - i)%(N*N) == N*N - 1  // j is "one to the left of" i
             || (j - i)%(N*N) == N *N - N  // j is "one above" i
            ) {
                c = du*du/4;
            }
        }
    }
    else if(i >= N*N && j >= N*N) {
        if(i==j) {
            // This is the reaction term of the v grid with itself.
            c = (-dv*dv - 1)/tau;
        }
        else {
            // if this wasn't the reaction term, it may still be a diffusion term. We'll check that now.
            int rpos = (i - j)%(N*N); // this is the "relative position" of element j to element i on the u grid.
            if(
                (j - i)%(N*N) == 1  // j is "one to the right of" i 
             || (j - i)%(N*N) == N  // j is "one below" i
             || (j - i)%(N*N) == N*N - 1  // j is "one to the left of" i
             || (j - i)%(N*N) == N *N - N  // j is "one above" i
            ) {
                c = dv*dv/(4*tau);
            }
        }
    }
    else {
        c = 0;
    }
    
    return c;
}

float input_jacobian_lower_bound(unsigned int i, unsigned int j) {
    // Just the identity matrix.
    if(i == j) {
        return 1.0;
    }
    else {
        return 0.0;
    }
}

float input_jacobian_upper_bound(unsigned int i, unsigned int j) {
    // Just the identity matrix.
    if(i == j) {
        return 1.0;
    }
    else {
        return 0.0;
    }
}
