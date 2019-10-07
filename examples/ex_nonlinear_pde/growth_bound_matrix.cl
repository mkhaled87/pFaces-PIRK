float growth_bound_matrix(unsigned int i, unsigned int j)
{
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
        c = sigma;  // This term is negative in the Jacobian, but in the Contraction matrix it's positive (since it's an off-diagonal term).
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


// this is needed to inform PIRK we will use the next smart function for sparsity
#define USE_SMART_SPARSE_GB

unsigned int next_largest(unsigned int a, unsigned int *lst, unsigned int n);
unsigned int largest(unsigned int *lst, unsigned int n);

// This function utilizes the sparsity in the grouth-bound matrix
// by giving the next non-zero value in the i'th row
// given: last_j (last column), which should be -1 in first trial.
// It sets new_j to the new index and assigns done=1 if it is the last value
// in the row.
float getNextNonZeroGrouthBoundValue(unsigned int i, unsigned int last_j, unsigned int* done, unsigned int* new_j){
    
    // Parameters
    unsigned int N = 10;  // grid side length. total state dimension will be 2*N*N.
    /*
     * The code here is a bit obscure, so I'll do my best to explain.
     * Each row of the Jacobian has six nonzero elements. The column position of
     * these elements depends on the row index i, and whether the row
     * corresponds to a u grid element or a v grid element. These column
     * positions are stored in the array nonzero_values. To get the next
     * non-zero growth bound value based on the current i and j, we just
     * use the current i value to calculate the possible nonzero column
     * positions, and set the next j to be the "next largest" column position
     * after the current j. Then, if the "next j" is set to the largest
     * of the nonzero column positions, then we know we're done with this row.
     * This is why it was necessary to write the helper functions next_largest
     * and largest.
     */
    if(i < N*N) {
        unsigned int nonzero_values[6] = {
            i, 
            (i-1)%(N*N),
            (i+1)%(N*N),
            (i-N)%(N*N),
            (i+N)%(N*N),
            i + N*N
        };
        unsigned int nxt = next_largest(last_j, nonzero_values, 6);
        unsigned int lrg = largest(nonzero_values, 6);
        *new_j = nxt;
        if (*new_j == lrg) {
            *done = 1;
        }
        else {
            *done = 0;
        }
    }
    else{
        unsigned int nonzero_values[6] = {
            i, 
            (i-1)%(N*N) + N*N,
            (i+1)%(N*N) + N*N,
            (i-N)%(N*N) + N*N,
            (i+N)%(N*N) + N*N,
            i + N*N
        };
        unsigned int nxt = next_largest(last_j, nonzero_values, 6);
        unsigned int lrg = largest(nonzero_values, 6);
        *new_j = nxt;
        if (*new_j == lrg) {
            *done = 1;
        }
        else {
            *done = 0;
        }
    }

    float val = growth_bound_matrix(i, *new_j);

    //You better put me back later
//     if(val == 0)
//         prunsigned intf("Oh something is not OK. check i=%d, j=%d\n", i, *new_j);
    //printf("Gonna try to get the GB value at %d, %d", i, *new_j);

    return val;
}

unsigned int next_largest(unsigned int a, unsigned int *lst, unsigned int n) {
    /**
     * Returns the smallest unsigned integer in lst larger than a. n is the length of lst.
     */
    unsigned int nl = 40000000;
    for(unsigned int i = 0; i < n; i++) {
        if(lst[i] >= a && lst[i] <= nl) {
            nl = lst[i];
        }        
    }
//     printf("%d -> %d\n", a, nl);
    return nl;
}

unsigned int largest(unsigned int *lst, unsigned int n) {
    /**
     * returns the largest element of the array lst.
     */
    unsigned int r = -40000000;
    for(unsigned int i = 0; i < n; i++) {
        if(lst[i] > r) {
            r = lst[i];
        }        
    }
    return r;
}
