float growth_bound_matrix(int i, int j, __global float* u)
{
    if(i==j) {
        return 1.0;
    }
    else {
        return 0.0;
    }
}