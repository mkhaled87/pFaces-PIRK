
float dynamics_element_global(__global float* x, __global float* u, float t, int i) {
    // Traffic diverge nx-link (needs n_x >= 5)
        
    // through a three-way intersection, using the cell transmission
    // model. Here, x represents the traffic flow, in vehicles/period,
    // and the links are organized as follows:
    //           /-----(2)---(4)--- ... ---(nx-1)
    //   (1)----<
    //           \-----(3)---(5)--- ... ---(nx) 
    // Vehicles move from link 1 to the remaining links, making this a
    // "diverge" junction.
    // A more detailed description of this system is available in
    // Meyer et al., "TIRA: Toolbox for Interval Reachability Analysis".
     
    // inputs:
    //     p: traffic flow injected into the first link
    //        note: although the input is one-dimensional for this
    //        system, we have modeled it as having the same dimension as
    //        the state so that the growth bound method can be applied
    //        to the system. We compensate by forcing all input terms
    //        but the first (i.e. the real one) to be zero.

    // Parameters
    int nlinks = 10000000;
    float v = 0.5;            // free-flow speed, in links/period
    float w = (float)(1./6.);            // congestion-wave speed, in links/period
    float c = 40.;             // capacity (max downstream flow), in vehicles/period
    float xbar = 320.;         // max occupancy when jammed, in vehicles
    float b = (float)(3./4.);            // fraction of vehicule staying on the network after each link
    float T = 30.;             // time step for the continuous-time model
    float dx = 0.;
    float t1 = 0.;
    float t2 = 0.;
  
    barrier(CLK_GLOBAL_MEM_FENCE);
    if(i == 0) {
    //dx(1) = 1/T*(-fmin([c ; v*x(1) ; 2*w*(xbar-x(2)) ; 2*w*(xbar-x(3))]));
        dx = 1/T*(-fmin(fmin(c, v*x[0]), 
                        fmin(2*w*(xbar-x[1]), 2*w*(xbar-x[2]))
                        )
                 );
    }

    else if(i == 1) {
    //1/T*(min([c/2 ; v*x(1)/2 ; w*(xbar-x(2)) ; w*(xbar-x(3))]) - min([c ; v*x(2) ; w/b*(xbar-x(4))]));
        t1 = fmin((float) fmin(0.5*c, 0.5*v*x[0]),  /* Won't compile without that (float), claims 'ambiguous call'. */
                   fmin(w*(xbar-x[1]), w*(xbar-x[2]))
                 );
        t2 = fmin(fmin(c, v*x[1]), 
                  w/b * (xbar - x[3])
                 );
        dx = 1/T * (t1 - t2);
    } 
    
    else if(i == 2) {
    //1/T*(min([c/2 ; v*x(1)/2 ; w*(xbar-x(2)) ; w*(xbar-x(3))]) - min([c ; v*x(3) ; w/b*(xbar-x(5))]));
        t1 = fmin((float) fmin(0.5*c, 0.5*v*x[0]),
                   fmin(w*(xbar-x[1]), w*(xbar-x[2]))
                 );
        t2 = fmin(fmin(c, v*x[2]), 
                  w/b * (xbar - x[4])
                 );
        dx = 1/T * (t1 - t2);
    } 
    
    else if(i == nlinks - 2) {
    //dx(end-1) = 1/T*(b*min([c ; v*x(end-3) ; w*(xbar-x(end-1))]) - fmin([c ; v*x(end-1)])); 
        t1 = b * fmin(fmin(c, v*x[(nlinks-2) - 2]), 
                  w* (xbar - x[(nlinks-2)])
                 );
        t2 = fmin(c, v * x[(nlinks-1) - 1]);
        dx = 1/T * (t1 - t2);
    }
    
    else if(i == nlinks - 1) {
    //dx(end) = 1/T*(b*min([c ; v*x(end-2) ; w*(xbar-x(end))]) - fmin([c ; v*x(end)]));    
        t1 = b * fmin(fmin(c, v*x[(nlinks-1) - 2]), 
                  w* (xbar - x[(nlinks-1)])
                 );
        t2 = fmin(c, v * x[(nlinks-1)]);
        dx = 1/T * (t1 - t2);
    }

    else if (i > 2 && i < nlinks-2) {
    //dx(i) = 1/T*(b*min([c ; v*x(i-2) ; w*(xbar-x(i))])-fmin([c ; v*x(i) ; w/b*(xbar-x(i+2))])); 
        t1 = b * fmin(fmin(c, v*x[(i) - 2]), 
                  w * (xbar - x[(i)])
                 );
        t2 =     fmin(fmin(c, v*x[(i)]), 
                  w/b * (xbar - x[(i)+2])
                 );
        dx = 1/T * (t1 - t2);
    } 
    
    else {
        printf("Huh! %d\n",i);
    }

    // Now for the affine input term
    dx = dx + u[i];
    return dx;
}
float dynamics_element_private(float* x, float* u, float t, int i) {
    // Traffic diverge nx-link (needs n_x >= 5)
        
    // through a three-way intersection, using the cell transmission
    // model. Here, x represents the traffic flow, in vehicles/period,
    // and the links are organized as follows:
    //           /-----(2)---(4)--- ... ---(nx-1)
    //   (1)----<
    //           \-----(3)---(5)--- ... ---(nx) 
    // Vehicles move from link 1 to the remaining links, making this a
    // "diverge" junction.
    // A more detailed description of this system is available in
    // Meyer et al., "TIRA: Toolbox for Interval Reachability Analysis".
     
    // inputs:
    //     p: traffic flow injected into the first link
    //        note: although the input is one-dimensional for this
    //        system, we have modeled it as having the same dimension as
    //        the state so that the growth bound method can be applied
    //        to the system. We compensate by forcing all input terms
    //        but the first (i.e. the real one) to be zero.

    // Parameters
    int nlinks = 10000000;
    float v = 0.5;            // free-flow speed, in links/period
    float w = (float)(1./6.);            // congestion-wave speed, in links/period
    float c = 40.;             // capacity (max downstream flow), in vehicles/period
    float xbar = 320.;         // max occupancy when jammed, in vehicles
    float b = (float)(3./4.);            // fraction of vehicule staying on the network after each link
    float T = 30.;             // time step for the continuous-time model
    float dx = 0.;
    float t1 = 0.;
    float t2 = 0.;
  
    barrier(CLK_GLOBAL_MEM_FENCE);
    if(i == 0) {
    //dx(1) = 1/T*(-fmin([c ; v*x(1) ; 2*w*(xbar-x(2)) ; 2*w*(xbar-x(3))]));
        dx = 1/T*(-fmin(fmin(c, v*x[0]), 
                        fmin(2*w*(xbar-x[1]), 2*w*(xbar-x[2]))
                        )
                 );
    }

    else if(i == 1) {
    //1/T*(min([c/2 ; v*x(1)/2 ; w*(xbar-x(2)) ; w*(xbar-x(3))]) - min([c ; v*x(2) ; w/b*(xbar-x(4))]));
        t1 = fmin((float) fmin(0.5*c, 0.5*v*x[0]),  /* Won't compile without that (float), claims 'ambiguous call'. Why? */
                   fmin(w*(xbar-x[1]), w*(xbar-x[2]))
                 );
        t2 = fmin(fmin(c, v*x[1]), 
                  w/b * (xbar - x[3])
                 );
        dx = 1/T * (t1 - t2);
    } 
    
    else if(i == 2) {
    //1/T*(min([c/2 ; v*x(1)/2 ; w*(xbar-x(2)) ; w*(xbar-x(3))]) - min([c ; v*x(3) ; w/b*(xbar-x(5))]));
        t1 = fmin((float) fmin(0.5*c, 0.5*v*x[0]),
                   fmin(w*(xbar-x[1]), w*(xbar-x[2]))
                 );
        t2 = fmin(fmin(c, v*x[2]), 
                  w/b * (xbar - x[4])
                 );
        dx = 1/T * (t1 - t2);
    } 
    
    else if(i == nlinks - 2) {
    //dx(end-1) = 1/T*(b*min([c ; v*x(end-3) ; w*(xbar-x(end-1))]) - fmin([c ; v*x(end-1)])); 
        t1 = b * fmin(fmin(c, v*x[(nlinks-2) - 2]), 
                  w* (xbar - x[(nlinks-2)])
                 );
        t2 = fmin(c, v * x[(nlinks-1) - 1]);
        dx = 1/T * (t1 - t2);
    }
    
    else if(i == nlinks - 1) {
    //dx(end) = 1/T*(b*min([c ; v*x(end-2) ; w*(xbar-x(end))]) - fmin([c ; v*x(end)]));    
        t1 = b * fmin(fmin(c, v*x[(nlinks-1) - 2]), 
                  w* (xbar - x[(nlinks-1)])
                 );
        t2 = fmin(c, v * x[(nlinks-1)]);
        dx = 1/T * (t1 - t2);
    }

    else if (i > 2 && i < nlinks-2) {
    //dx(i) = 1/T*(b*min([c ; v*x(i-2) ; w*(xbar-x(i))])-fmin([c ; v*x(i) ; w/b*(xbar-x(i+2))])); 
        t1 = b * fmin(fmin(c, v*x[(i) - 2]), 
                  w * (xbar - x[(i)])
                 );
        t2 =     fmin(fmin(c, v*x[(i)]), 
                  w/b * (xbar - x[(i)+2])
                 );
        dx = 1/T * (t1 - t2);
    } 
    
    else {
        printf("Huh! %d\n",i);
    }

    // Now for the affine input term
    dx = dx + u[i];
    return dx;
}
