#ifndef MEM_EFFICIENT
__kernel 
void gb_compute_contraction_matrix(
	__global unsigned int *cidxs,
	__global float *cvals, 
	__global unsigned int *ncel){

	// i is row_idx
	unsigned int i = get_global_id(0);
	unsigned int nonzero_count = 0;
	float c;

#ifdef USE_SMART_SPARSE_GB
	unsigned int last_j = -1;
	unsigned int new_j = -1;
	unsigned int done = 0;

	do{
		c = getNextNonZeroGrouthBoundValue(i, last_j, &done, &new_j);
		cidxs[i * @@row_max@@ + nonzero_count] = new_j;
		cvals[i * @@row_max@@ + nonzero_count] = c;
		nonzero_count++;		
		last_j = new_j;
	}while(done == 0);
#else
	for (unsigned int col_idx = 0; col_idx < @@states_dim@@; col_idx++) {
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
#endif
