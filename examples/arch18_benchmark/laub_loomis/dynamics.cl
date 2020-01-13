#define x1 x[0]
#define x2 x[1]
#define x3 x[2]
#define x4 x[3]
#define x5 x[4]
#define x6 x[5]
#define x7 x[6]

float dynamics_element_global(__global float* x, __global float* u, float t, unsigned int i) {
	
    if (i == 0) {
        return 1.4 * x3 - 0.9 * x1;
    } else if(i == 1) {
        return 2.5 * x5 - 1.5 * x2;
    } else if(i == 2) {
        return 0.6 * x7 - 0.8 * x2 * x3;
    } else if(i == 3) {
        return 2.0 - 1.3 * x3 * x4;
    } else if(i == 4) {
        return 0.7 * x1 - x4 * x5;
    } else if(i == 5) {
        return 0.3 * x1 - 3.1 * x6;
    } else if(i == 6) {
        return 1.8 * x6 - 1.5 * x2 * x7;
    } else {
        printf("Huh! %d\n",i);
    }

    return 0.0f;
}
