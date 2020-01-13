#define x1 x[0]
#define x2 x[1]
#define x3 x[2]
#define x4 x[3]
#define x5 x[4]
#define x6 x[5]
#define x7 x[6]
#define x8 x[7]
#define x9 x[8]
#define x10 x[9]
#define x11 x[10]
#define x12 x[11]

#define g 9.81f
#define m 1.4f
#define J_x 0.054f
#define J_y 0.054f
#define J_z 0.104f
#define u1 1.0f
#define u2 0.0f
#define u3 0.0f

float dynamics_element_global(__global float* x, __global float* u, float t, unsigned int i) {
	
    if (i == 0) {
        return cos(x8)*cos(x9)*x4 + (sin(x7)*sin(x8)*cos(x9) - cos(x7)*sin(x9))*x5 + (cos(x7)*sin(x8)*cos(x9) + sin(x7)*sin(x9))*x6;
    } else if(i == 1) {
        return cos(x8)*sin(x9)*x4 + (sin(x7)*sin(x8)*sin(x9) + cos(x7)*cos(x9))*x5 + (cos(x7)*sin(x8)*sin(x9) - sin(x7)*cos(x9))*x6;
    } else if(i == 2) {
        return sin(x8)*x4 - sin(x7)*cos(x8)*x5 - cos(x7)*cos(x8)*x6;
    } else if(i == 3) {
        return x12*x5 - x11*x6 - g*sin(x8);
    } else if(i == 4) {
        return x10*x6 - x12*x4 + g*cos(x8*sin(x7));
    } else if(i == 5) {
        return x11*x4 - x10*x5 + g*cos(x8*cos(x7)) - 1.0f/m*(m*g - 10.0f*(x3 - u1) + 3.0f*x6);
    } else if(i == 6) {
        return x10 + (sin(x7)*tan(x8))*x11 + (cos(x7)*tan(x8))*x12;
	} else if(i == 7) {
		return cos(x7)*x11 - sin(x7)*x12;
	} else if(i == 8) {
		return sin(x7)/cos(x8)*x11 + cos(x7)/cos(x8)*x12;
	} else if(i == 9) {
		return (J_y - J_z)/J_x*x11*x12 + 1.0f/J_x*(-(x7 - u2) - x10);
	} else if(i == 10) {
		return (J_z - J_x)/J_y*x10*x12 + 1.0f/J_y*(-(x8 - u3) - x11);
	} else if(i == 11) {
		return (J_x - J_y)/J_z*x10*x11 + 1.0f/J_z*0.0f;
    } else {
        printf("Huh! %d\n",i);
    }

    return 0.0f;
}
