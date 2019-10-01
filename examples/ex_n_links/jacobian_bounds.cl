float state_jacobian_lower_bound(unsigned int i, unsigned int j) {
    // Parameters
    unsigned int nlinks = SS_DIM;
    float v = 0.5;            // free-flow speed, in links/period
    float w =  1.0/6.0;            // congestion-wave speed, in links/period
    float xbar = 320.0;         // max occupancy when jammed, in vehicles
    float b =  3.0/4.0;            // fraction of vehicule staying on the network after each link
    float T = 30.0;             // time step for the continuous-time model
    float c = 0.0;
    if(i==0 && j==0) {
        c = -v;
    }
    else if(i==1 && j==2) {
        c = -w;
    }
    else if(i==2 && j==1) {
        c = -w;
    }
    else if(i==j) {
        c = -(v+w);
    }
    else {
        c = 0;
    }
    c = c/T;
    return c;
}

float state_jacobian_upper_bound(unsigned int i, unsigned int j) {
    // Parameters
    unsigned int nlinks = SS_DIM;
    float v = 0.5;            // free-flow speed, in links/period
    float w =  1.0/6.0;            // congestion-wave speed, in links/period
    float xbar = 320.0;         // max occupancy when jammed, in vehicles
    float b =  3.0/4.0;            // fraction of vehicule staying on the network after each link
    float T = 30.0;             // time step for the continuous-time model
    float c = 0.0;

    if (i==0 && j == 1) {
        c = 2 * w;
    } else if (i == 0 && j == 2) {
        c = 2 * w;
    } else if (i == 1 && j == 0) {
        c = 0.5 * v;
    } else if (i == 2 && j == 0) {
        c = 0.5 * v;
    } else if (i - j == 2) {
        c = b * v;
    } else if (i - j == -2) {
        c = w / b;
    } else if (i == (nlinks - 1) && j == (nlinks - 1) - 2) {
        c = b * v;
    } else if (i == (nlinks - 1) - 1 && j == (nlinks - 1) - 3) {
        c = b * b;
    }
    else {
        c = 0;
    }
    c = c / T;
    return c;
}

float input_jacobian_lower_bound(unsigned int i, unsigned int j) {
    if(i == 0 && j == 0) {
      return 1.0;
    } else {
      return 0.0;
    }
}

float input_jacobian_upper_bound(unsigned int i, unsigned int j) {
    if(i == 0  && j == 0) {
      return 1.0;
    } else {
      return 0.0;
    }
}