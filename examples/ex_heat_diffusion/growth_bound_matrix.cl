float growth_bound_matrix(unsigned int i, unsigned int j) {
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
        x_lower_coeff = 1./6.;
        loss_coeff -= 1./6.;
    }
    if(i + 1 < N*N*N) {
        x_upper_coeff = 1./6.;
        loss_coeff -= 1./6.;
    }
    else {
        // The x = +1.0 side isn't insulated, so there is always some loss across this side.
        // The heat exchange constant is 0.5.
        loss_coeff -= 0.5/6.;
    }
    if(i - N > -1) {
        y_lower_coeff = 1./6.;
        loss_coeff -= 1./6.;
    }
    if(i + N < N*N*N) {
        y_upper_coeff = 1./6.;
        loss_coeff -= 1./6.;
    }
    if(i - N*N > -1) {
        z_lower_coeff = 1./6.;
        loss_coeff -= 1./6.;
    }
    if(i + N*N < N*N*N) {
        z_upper_coeff = 1./6.;
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
    unsigned int N = 1000;  // grid side length. total state dimension will be 2*N*N.
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
    if(i - 1 > -1) {
        i0 = i - 1;
    }
    else {
        i0 = 0;
    }
    if(i + 1 < N*N*N) {
        i1 = i + 1;
    }
    else {
        i1 = 0;
    }
    if(i - N > -1) {
        i2 = i - N;
    }
    else {
        i2 = 0;
    }
    if(i + N < N*N*N) {
        i3 = i + N;
    }
    else {
        i3 = 0;
    }
    if(i - N*N > -1) {
        i4 = i - N*N;
    }
    else {
        i4 = 0;
    }
    if(i + N*N < N*N*N) {
        i5 = i + N*N;
    }
    else {
        i5 = 0;
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
