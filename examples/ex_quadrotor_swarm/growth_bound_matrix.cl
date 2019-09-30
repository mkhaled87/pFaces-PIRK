float growth_bound_matrix(unsigned int i,unsigned  int j)
{
    // Parameters
    float f = 1.0f;
    float m = 1.0f;
    float g = 9.8f;
	float c = 0.0f;
    
    unsigned int i_swarm_element = i/12;
    unsigned int j_swarm_element = j/12;
	unsigned int k = i % 12;
	unsigned int l = j % 12;
    
    if(i_swarm_element == j_swarm_element) {

        if(k == 0 && l == 6) {
            c = 1;
        }
        else if(k == 1 && l == 7) {
            c = 1;
        }
        else if(k == 2 && l == 8) {
            c = 1;
        }
        else if(k == 3 && l == 9) {
            c = 1;
        }
        else if(k == 4 && l == 10) {
            c = 1;
        }
        else if(k == 5 && l == 11) {
            c = 1;
        }
        else if(k == 6 && l == 3) {
            c = f/m;
        }
        else if(k == 6 && l == 4) {
            c = f/m;
        }
        else if(k == 6 && l == 5) {
            c = f/m;
        }
        else if(k == 7 && l == 3) {
            c = f/m;
        }
        else if(k == 7 && l == 4) {
            c = f/m;
        }
        else if(k == 7 && l == 5) {
            c = f/m;
        }
        else if(k == 8 && l == 3) {
            c = g + f/m;
        }
        else if(k == 8 && l == 4) {
            c = g + f/m;
        }
        else {
            c = 0;
        }
    }
    else {
        c = 0;
    }
    return c;
}


// this is needed to inform PIRK we will use the next smart function for sparsity
#define USE_SMART_SPARSE_GB

// This function utilizes the sparsity in the grouth-bound matrix
// by giving the next non-zero value in the i'th row
// given: last_j (last column), which should be -1 in first trial.
// It sets new_j to the new index and assigns done=1 if it is the last value
// in the row.
float getNextNonZeroGrouthBoundValue(unsigned int i,unsigned int last_j,unsigned int* done,unsigned int* new_j){
	
    unsigned int k = i % 12;
	unsigned int base_i = 12*(i/12);
	
    if(k < 6) {
		if(last_j ==-1){
			*done = 1;
			*new_j = i + 6;
		}
    }
    else if(k == 6 || k == 7) {
        if(last_j == -1) {
            *new_j = base_i + 3;
            *done = 0;
        }
        else if(last_j == base_i + 3) {
            *new_j = base_i + 4;
            *done = 0;
        }
        else if(last_j == base_i + 4) {
            *new_j = base_i + 5;
            *done = 1;
        }
    }
    else if(k == 8) {
		if(last_j == -1) {
            *new_j = base_i + 3;
            *done = 0;
        }
        else if(last_j == base_i + 3) {
            *new_j = base_i + 4;
            *done = 1;
        }
    }
	// k == 9 || 10 || 11   ===> row full of zeros
    else{
		*new_j = -1;
        *done = 1;
        return 0;
    }

    float val = growth_bound_matrix(i, *new_j);

    if(val == 0)
        printf("Oh something is not OK. check i=%d, j=%d\n", i, *new_j);

    return val;
}
