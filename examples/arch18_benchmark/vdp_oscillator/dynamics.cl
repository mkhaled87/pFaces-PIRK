float dynamics_element_global(__global float* x, __global float* u, float t, unsigned int i) {
	
    if (i == 0) {
        return x[1];
    } else if(i == 1) {
        return x[1] - x[0] - x[0]*x[0]*x[1];
    } else {
        printf("Huh! %d\n",i);
    }

    return 0.0f;
}
