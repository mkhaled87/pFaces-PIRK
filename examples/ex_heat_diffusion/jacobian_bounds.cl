float state_jacobian_lower_bound(unsigned int i, unsigned int j) {
    // Notice that the state Jacobian upper and lower bounds are the same. This is because the system is linear, so the Jacobian is a constant matrix.
    unsigned int N = 1000;  // grid side length. total state dimension will be N*N*N.
    float diffusivity = 0.01;
    
    float c = 0;
    
    float loss_coeff = 0.0;
    float x_lower_coeff = 0.0;
    float x_upper_coeff = 0.0;
    float y_lower_coeff = 0.0;
    float y_upper_coeff = 0.0;
    float z_lower_coeff = 0.0;
    float z_upper_coeff = 0.0;
    
    // This set of if statements handles the boundary PDE boundary conditions, namely that all sides except the x=+1.0 side are insulated.
    // This means that if the i index corresponds to a point that is on one of the boundaries, the corresponding Jacobian element may be missing some terms.
    if(i - 1 > -1) {
        x_lower_coeff = 1./6.
        loss_coeff -= 1./6.;
    }
    if(i + 1 < N*N*N) {
        x_upper_coeff = 1./6.
        loss_coeff -= 1./6.;
    }
    else {
        // The x = +1.0 side isn't insulated, so there is always some loss across this side
        loss_coeff -= 0.5/6.;
    }
    if(i - N > -1) {
        y_lower_coeff = 1./6.
        loss_coeff -= 1./6.;
    }
    if(i + N < N*N*N) {
        y_upper_coeff = 1./6.
        loss_coeff -= 1./6.;
    }
    if(i - N*N > -1) {
        z_lower_coeff = 1./6.
        loss_coeff -= 1./6.;
    }
    if(i + N*N < N*N*N) {
        z_upper_coeff = 1./6.
        loss_coeff -= 1./6.;
    }

    if(j - i == 0) {
        // This is a diagonal term.
        c = -loss_coeff;
    }
    if(j - i == 1) {
        c = x_upper_coeff;
    }
    if(j - i == -1) {
        c = x_lower_coeff;
    }
    if(j - i == N) {
        c = y_upper_coeff;
    }
    if(j - i == -N) {
        c = y_lower_coeff;
    }
    if(j - i == N*N) {
        c = z_upper_coeff;
    }
    if(j - i == -N*N) {
        c = z_lower_coeff;
    }
    
    c = diffusivity * c;
    
    return c;
}

float state_jacobian_upper_bound(unsigned int i, unsigned int j) {
    // Notice that the state Jacobian upper and lower bounds are the same. This is because the system is linear, so the Jacobian is a constant matrix.
    unsigned int N = 1000;  // grid side length. total state dimension will be N*N*N.
    float diffusivity = 0.01;
    
    float c = 0;
    
    float loss_coeff = 0.0;
    float x_lower_coeff = 0.0;
    float x_upper_coeff = 0.0;
    float y_lower_coeff = 0.0;
    float y_upper_coeff = 0.0;
    float z_lower_coeff = 0.0;
    float z_upper_coeff = 0.0;
    
    // This set of if statements handles the boundary PDE boundary conditions, namely that all sides except the x=+1.0 side are insulated.
    // This means that if the i index corresponds to a point that is on one of the boundaries, the corresponding Jacobian element may be missing some terms.
    if(i - 1 > -1) {
        x_lower_coeff = 1./6.
        loss_coeff -= 1./6.;
    }
    if(i + 1 < N*N*N) {
        x_upper_coeff = 1./6.
        loss_coeff -= 1./6.;
    }
    else {
        // The x = +1.0 side isn't insulated, so there is always some loss across this side
        loss_coeff -= 0.5/6.;
    }
    if(i - N > -1) {
        y_lower_coeff = 1./6.
        loss_coeff -= 1./6.;
    }
    if(i + N < N*N*N) {
        y_upper_coeff = 1./6.
        loss_coeff -= 1./6.;
    }
    if(i - N*N > -1) {
        z_lower_coeff = 1./6.
        loss_coeff -= 1./6.;
    }
    if(i + N*N < N*N*N) {
        z_upper_coeff = 1./6.
        loss_coeff -= 1./6.;
    }

    if(j - i == 0) {
        // This is a diagonal term.
        c = -loss_coeff;
    }
    if(j - i == 1) {
        c = x_upper_coeff;
    }
    if(j - i == -1) {
        c = x_lower_coeff;
    }
    if(j - i == N) {
        c = y_upper_coeff;
    }
    if(j - i == -N) {
        c = y_lower_coeff;
    }
    if(j - i == N*N) {
        c = z_upper_coeff;
    }
    if(j - i == -N*N) {
        c = z_lower_coeff;
    }
    
    c = diffusivity * c;
    
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
