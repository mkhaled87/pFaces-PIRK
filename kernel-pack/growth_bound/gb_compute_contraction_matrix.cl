__kernel 
void gb_compute_contraction_matrix(
	__global int *cidxs, 
	__global float *cvals, 
	__global int *ncel){

	// i is row_idx
	int i = get_global_id(0);
	int nonzero_count = 0;
	float c;

#ifdef USE_SMART_SPARSE_GB
	int last_j = -1;
	int new_j = -1;
	int done = 0;

	do{
		c = getNextNonZeroGrouthBoundValue(i, last_j, &done, &new_j);
		cidxs[i * @@row_max@@ + nonzero_count] = new_j;
		cvals[i * @@row_max@@ + nonzero_count] = c;
		nonzero_count++;		
		last_j = 0;
	}while(done == 0);
#else
	for (int col_idx = 0; col_idx < @@states_dim@@; col_idx++) {
		c = growth_bound_matrix(i, col_idx);
       
		if(c != 0) {
			cidxs[i * @@row_max@@ + nonzero_count] = col_idx;
			cvals[i * @@row_max@@ + nonzero_count] = c;
			nonzero_count++;
		}
	}
#endif

	if(nonzero_count > @@row_max@@)
		printf("Error: row_max=%d is not sufficient ! nonzero_count reached %d.\n", @@row_max@@, nonzero_count);

	ncel[i] = nonzero_count;
}
