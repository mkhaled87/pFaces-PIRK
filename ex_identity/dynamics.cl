float dynamics_element_global(__global float* x, __global float* u, float t, int i) {
    return 100*x[i];
}