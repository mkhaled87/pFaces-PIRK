__kernel void gb_compute_contraction_matrix(
	__global int *cidxs, 
	__global float *cvals, 
	__global int *ncel)
{
    int row_idx = get_global_id(0);
    int nonzero_count = 0;
    float c;
    for (int col_idx = 0; col_idx < @@states_dim@@; col_idx++) {
       c = growth_bound_matrix(row_idx, col_idx);
       //if(row_idx == 0) printf("col %d\n",col_idx);
       if(c != 0.) {
           cidxs[row_idx * @@row_max@@ + nonzero_count] = col_idx;
           cvals[row_idx * @@row_max@@ + nonzero_count] = c;
           nonzero_count++;
       }
    }
    ncel[row_idx] = nonzero_count;
}
