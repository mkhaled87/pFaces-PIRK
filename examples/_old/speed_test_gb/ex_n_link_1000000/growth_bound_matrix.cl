float growth_bound_matrix(int i, int j)
{
    // Parameters
    int nlinks = 1000000;
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

// this is needed to inform PIRK we will use the next smart function for sparsity
#define USE_SMART_SPARSE_GB

// This function utilizes the sparsity in the grouth-bound matrix
// by giving the next non-zero value in the i'th row
// given: last_j (last column), which should be -1 in first trial.
// It sets new_j to the new index and assigns done=1 if it is the last value
// in the row.
float getNextNonZeroGrouthBoundValue(int i, int last_j, int* done, int* new_j){

    int nlinks = 10;

    // this example is simle: only two values in each row so we can implement it as 
    // an if statement

    // first occurances in the row i
    if(last_j == -1) {
        if(i == 0){
            *new_j = 1;
            *done = 0;
        } else if ((i == 1) || (i == 2)) {
            *new_j = 0;
            *done = 0;
        } else if ((i == (nlinks - 1)) || (i == (nlinks - 2))) {
            *new_j = i - 2;
            *done = 1;
        } else {
            *new_j = i - 2;
            *done = 0;
        }
    } else {
        if(i == 0){
            *new_j = 2;
        } else {
            *new_j = i + 2;
        }
        *done = 1;
    }

    float val = growth_bound_matrix(i, *new_j);

    if(val == 0)
        printf("Oh something is not OK. check i=%d, j=%d\n", i, *new_j);

    return val;
}
