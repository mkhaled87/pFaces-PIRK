#define x1 x[0]
#define x2 x[1]
#define x3 x[2]
#define x4 x[3]
#define x5 x[4]
#define x6 x[5]
#define x7 x[6]

#define u1 u[0]
#define u2 u[1]

/* BMW 320i params */
#define param_mu 1.0489f
#define param_C_Sf 20.898084f
#define param_C_Sr 20.898084f
#define param_lf 1.156195f
#define param_lr 1.422717f
#define param_h 0.613730f
#define param_m 1.093295e+03f
#define param_I 1.791599e+03f
#define param_g 9.81f
#define param_lwb 2.578913f

float dynamics_element_global(__global float* x, __global float* u, float t, unsigned int i) {

    if(t > 5.0){
        u1 = 0.05;
        u2 = 2.0f;
    }
    else if(t > 2.5){
        u1 = -0.08;
        u2 = 2.0f;
    }
    else{
        u1 = 0.04;
        u2 = 2.0f;
    }
        

    float ret = 0.0f;

    // kinematic model for small velocities ?
    if (fabs((float)x4) < 0.1f){
        if(i == 0)
            ret = x4*cos((float)x5);
        else if (i == 1)
            ret = x4*sin((float)x5);
        else if (i == 2)
            ret = u1;
        else if (i == 3)
            ret = u2;
        else if (i == 4)
            ret = x4/param_lwb*tan((float)x3);
        else if (i == 5)
            ret = u2*param_lwb*tan((float)x3) + x4/(param_lwb*cos((float)x3)*cos((float)x3))*u1;
        else if (i == 6)
            ret = 0.0f;
    }
    else{
        if(i == 0)
            ret = x4*cos((float)(x7 + x5));
        else if (i == 1)
            ret = x4*sin((float)(x7 + x5));
        else if (i == 2)
            ret = u1;
        else if (i == 3)
            ret = u2;
        else if (i == 4)
            ret = x6;
        else if (i == 5)
            ret = -param_mu*param_m/(x4*param_I*(param_lr+param_lf))*(param_lf*param_lf*param_C_Sf*(param_g*param_lr-u2*param_h) + param_lr*param_lr*param_C_Sr*(param_g*param_lf + u2*param_h))*x6
                +param_mu*param_m/(param_I*(param_lr+param_lf))*(param_lr*param_C_Sr*(param_g*param_lf + u2*param_h) - param_lf*param_C_Sf*(param_g*param_lr - u2*param_h))*x7
                +param_mu*param_m/(param_I*(param_lr+param_lf))*param_lf*param_C_Sf*(param_g*param_lr - u2*param_h)*x3;
        else if (i == 6)
            ret = (param_mu/(x4*x4*(param_lr+param_lf))*(param_C_Sr*(param_g*param_lf + u2*param_h)*param_lr - param_C_Sf*(param_g*param_lr - u2*param_h)*param_lf)-1)*x6
                -param_mu/(x4*(param_lr+param_lf))*(param_C_Sr*(param_g*param_lf + u2*param_h) + param_C_Sf*(param_g*param_lr-u2*param_h))*x7
                +param_mu/(x4*(param_lr+param_lf))*(param_C_Sf*(param_g*param_lr-u2*param_h))*x3; 
    }

    return ret;
}
