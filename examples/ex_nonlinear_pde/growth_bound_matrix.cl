float growth_bound_matrix(unsigned int i, unsigned int j){
	
	
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
inline unsigned int next_largest(unsigned int i, unsigned int i0, unsigned int i1, unsigned int i2, unsigned int i3, unsigned int i4, unsigned int i5);
inline unsigned int next_largest(unsigned int i, unsigned int i0, unsigned int i1, unsigned int i2, unsigned int i3, unsigned int i4, unsigned int i5) {
    /**
     * Returns the smallest unsigned integer in the list v0...v5 that us larger than a.
     */
	 unsigned int ret = i;
	 unsigned int smallest;
	 unsigned int smallest_set = 0;
	 
	 if(i0 > ret){
		 if(smallest_set == 0){
			 smallest_set = 1;
			 ret = i0;
			 smallest = i0;
		 }else{
			 if (i0 < smallest){
				 ret = i0;
				 smallest = i0;				 
			 }
		 }
	 }
	 
	 if(i1 > ret){
		 if(smallest_set == 0){
			 smallest_set = 1;
			 ret = i1;
			 smallest = i1;
		 }else{
			 if (i1 < smallest){
				 ret = i1;
				 smallest = i1;				 
			 }
		 }
	 }

	 if(i2 > ret){
		 if(smallest_set == 0){
			 smallest_set = 1;
			 ret = i2;
			 smallest = i2;
		 }else{
			 if (i2 < smallest){
				 ret = i2;
				 smallest = i2;				 
			 }
		 }
	 }

	 if(i3 > ret){
		 if(smallest_set == 0){
			 smallest_set = 1;
			 ret = i3;
			 smallest = i3;
		 }else{
			 if (i3 < smallest){
				 ret = i3;
				 smallest = i3;				 
			 }
		 }
	 }

	 if(i4 > ret){
		 if(smallest_set == 0){
			 smallest_set = 1;
			 ret = i4;
			 smallest = i4;
		 }else{
			 if (i4 < smallest){
				 ret = i4;
				 smallest = i4;				 
			 }
		 }
	 }	 
	 
	 
	 if(i5 > ret){
		 if(smallest_set == 0){
			 smallest_set = 1;
			 ret = i5;
			 smallest = i5;
		 }else{
			 if (i5 < smallest){
				 ret = i5;
				 smallest = i5;				 
			 }
		 }
	 }	 
	  
	 
    return ret;
}

inline unsigned int largest(unsigned int i0, unsigned int i1, unsigned int i2, unsigned int i3, unsigned int i4, unsigned int i5);
inline unsigned int largest(unsigned int i0, unsigned int i1, unsigned int i2, unsigned int i3, unsigned int i4, unsigned int i5) {
    /**
     * returns the largest element of the list i0...i5.	 
     */
	 unsigned int ret = i0;
	 
	 if(i1 > ret)
		 ret = i1;
	 
	 if(i2 > ret)
		 ret = i2;
	 
	 if(i3 > ret)
		 ret = i3;

	 if(i4 > ret)
		 ret = i4;

	 if(i5 > ret)
		 ret = i5;
	 
    return ret;
}

inline unsigned int smallest(unsigned int i0, unsigned int i1, unsigned int i2, unsigned int i3, unsigned int i4, unsigned int i5);
inline unsigned int smallest(unsigned int i0, unsigned int i1, unsigned int i2, unsigned int i3, unsigned int i4, unsigned int i5) {
    /**
     * returns the largest element of the list i0...i5.	 
     */
	 unsigned int ret = i0;
	 
	 if(i1 < ret)
		 ret = i1;
	 
	 if(i2 < ret)
		 ret = i2;
	 
	 if(i3 < ret)
		 ret = i3;

	 if(i4 < ret)
		 ret = i4;

	 if(i5 < ret)
		 ret = i5;
	 
    return ret;
}

// this is needed to inform PIRK we will use the next smart function for sparsity
#define USE_SMART_SPARSE_GB

// This function utilizes the sparsity in the grouth-bound matrix
// by giving the next non-zero value in the i'th row
// given: last_j (last column), which should be -1 in first trial.
// It sets new_j to the new index and assigns done=1 if it is the last value
// in the row.
float getNextNonZeroGrouthBoundValue(unsigned int i, unsigned int last_j, unsigned int* done, unsigned int* new_j){
		
    // Parameters
    unsigned int N = 10;  // grid side length. total state dimension will be 2*N*N.
	unsigned int i0, i1, i2, i3, i4, i5;
	unsigned int nxt, lrg;
	
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
		i0 = i;
		i1 = (i-1)%(N*N);		
		i2 = (i+1)%(N*N);		
		i3 = (i-N)%(N*N);		
		i4 = (i+N)%(N*N);
		i5 = i + N*N;			
    }
    else{		
		i0 = i;
		i1 = (i-1)%(N*N) + N*N;
		i2 = (i+1)%(N*N) + N*N;		
		i3 = (i-N)%(N*N) + N*N;		
		i4 = (i+N)%(N*N) + N*N;		
		i5 = i + N*N;
    }
	
	if(last_j == -1){
		lrg = smallest(i0, i1, i2, i3, i4, i5);
		nxt = next_largest(lrg, i0, i1, i2, i3, i4, i5);
	} else {
		nxt = next_largest(last_j, i0, i1, i2, i3, i4, i5);
		lrg = largest(i0, i1, i2, i3, i4, i5);		
	}
	
	*new_j = nxt;
	if (*new_j == lrg) {
		*done = 1;
	}
	else {
		*done = 0;
	}
		

    float val = growth_bound_matrix(i, *new_j);
    return val;
}
