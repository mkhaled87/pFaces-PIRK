#include "dynamics.cl"
#include "bounds.cl"
#include "growth_bound_matrix.cl"
#include "jacobian_bounds.cl"

/* useful defines for RK4 integration */
#define step_size @@true_step_size@@
#define RK4_NINT 5
#define RK4_H ((@@true_step_size@@/RK4_NINT))

float 
growth_bound_radius_dynamics(
	__global float* r, 
	__global float* u, 
	__global int *cidxs, 
	__global float *cvals, 
	__global int *ncel, 
	float t, 
	int i){

	float dr=0;
	int idx;

	for (int j=0; j < ncel[i]; j++) {
		idx = cidxs[i*@@row_max@@ + j];
		dr += cvals[i*@@row_max@@ + j]*r[idx];
	}
	dr += u[i];
	
	return dr;
}


// 1 <= *seed < m
int 
krand(int* seed){ 

	int const a = 16807; //ie 7**5
	int const m = 2147483647; //ie 2**31-1
	int tmp = *seed;
	//*seed = ((long( tmp * a)%m;
	*seed = tmp * a;
	*seed = *seed %m;
	return(*seed);
}