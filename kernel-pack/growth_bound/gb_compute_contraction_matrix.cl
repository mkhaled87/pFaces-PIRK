__kernel void gb_compute_contraction_matrix(__global int *cidxs, __global float *cvals, __global int *ncel)
{
    int row_idx = get_global_id(0);
    int nonzero_count = 0;
    float c;
    for (int col_idx = 0; col_idx < @@states_dim@@; col_idx++) {
       c = growth_bound_matrix(row_idx, col_idx);
       //if(row_idx==0) {printf("%d %f\n",col_idx, c);}
       if(c != 0.) {
           if(row_idx==0) printf("gonna save the index %d to position %d, with the value %f\n",col_idx, nonzero_count, c);
           cidxs[row_idx * @@row_max@@ + nonzero_count] = col_idx;
           cvals[row_idx * @@row_max@@ + nonzero_count] = c;
           nonzero_count++;
       }
    }
    ncel[row_idx] = nonzero_count;
    //if(row_idx == 0){
    //    printf("nonzero elements in row %d of contraction matrix: %d\n", row_idx, ncel[row_idx]);
    //    printf("elements in row %d:\n",row_idx);
    //    int idx;
    //    for(int q = 0; q < ncel[row_idx];q++){
    //        idx = cidxs[row_idx*@@row_max@@ + q];
    //        printf("[%d], col %d: %f\n",q, idx, cvals[row_idx*@@row_max@@ + q]);
     //   }
    //}
}