float dynamics_element(__global float* x, __global float* u, float t, int i) {
    float dx = 0.;
    int nx = 10;
    if(i==0) {
     dx = x[0]+x[1];
     printf("%f, %f\n",x[0],x[1]);
     return dx;
    }
    else if(i==nx-1) {
     dx = x[nx-1]+x[nx-2];
     return  dx;
    }
    else if(i>0 && i <nx-1) {
     dx = x[i-1]+x[i]+x[i+1];
     return dx;
    }
    else {
     printf("um\n");
     return 0.;
    }
}