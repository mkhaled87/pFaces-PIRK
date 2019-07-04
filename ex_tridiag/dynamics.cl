float dynamics_element(__global float* x, __global float* u, float t, int i) {
    int nx = 20;
    float dx = 0;
    if(i==0) {
     dx = x[0]+x[1]+x[nx-1];
    }
    else if(i==nx-1) {
     dx = x[nx-1]+x[nx-2]+x[0];
    }
    else if(i>0 && i <nx-1) {
     dx = x[i-1]+x[i]+x[i+1];
    }
    else {
     printf("um\n");
     dx=0.;
    }
    return dx;
}