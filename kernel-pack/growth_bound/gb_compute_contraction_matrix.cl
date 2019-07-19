__kernel void gb_compute_contraction_matrix(__global int *cidxs, __global float *cvals, __global int *ncel)
{
    int row_idx = get_global_id(0);
    int nonzero_count = 0;
    float c;
    for (int col_idx = 0; col_idx < @@states_dim@@; col_idx++) {
       c = growth_bound_matrix(row_idx, col_idx);
    }
    ncel[row_idx] = nonzero_count;
}