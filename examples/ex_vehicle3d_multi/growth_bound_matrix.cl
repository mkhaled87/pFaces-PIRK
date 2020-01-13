float growth_bound_matrix(int i, int j){
}


// this is needed to inform PIRK we will use the next smart function for sparsity
#define USE_SMART_SPARSE_GB

// This function utilizes the sparsity in the grouth-bound matrix
// by giving the next non-zero value in the i'th row
// given: last_j (last column), which should be -1 in first trial.
// It sets new_j to the new index and assigns done=1 if it is the last value
// in the row.
float getNextNonZeroGrouthBoundValue(int i, int last_j, int* done, int* new_j){
	
	if(last_j == -1){
		*new_j = i/VEHICLE_DIM;
		*done = 0;
	}
	else{
		*new_j = last_j+1;
		if(last_j%VEHICLE_DIM == 1)
			*done = 1;
		else
			*done = 0;
	}
	
    return growth_bound_matrix(i, *new_j);
}