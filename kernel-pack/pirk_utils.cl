#define SS_DIM @@states_dim@@
#define IS_DIM @@inputs_dim@@

#include "dynamics.cl"
#include "bounds.cl"

#ifdef MC_1 /* growth bound ? */
#include "growth_bound_matrix.cl"
#endif

#ifdef MC_2  /* CTMM ? */
#include "jacobian_bounds.cl"
#endif

/* useful defines for RK4 integration */
#define step_size @@true_step_size@@
#define RK4_NINT 5
#define RK4_H ((@@true_step_size@@/RK4_NINT))


#ifndef MEM_EFFICIENT
float 
growth_bound_radius_dynamics(
	__global float* r, 
	__global float* u, 
	__global unsigned int *cidxs,
	__global float *cvals, 
	__global unsigned int *ncel,
	float t, 
	unsigned int i){

	float dr=0;
	unsigned int idx;

	for (unsigned int j=0; j < ncel[i]; j++) {
		idx = cidxs[i*@@row_max@@ + j];
		dr += cvals[i*@@row_max@@ + j]*r[idx];
	}
	dr += u[i];
	
	return dr;
}
#else
#ifndef USE_SMART_SPARSE_GB
#error "To use memory efficnet version, please provide the smart contraction matrix function (getNextNonZeroGrouthBoundValue)."
#endif
float
growth_bound_radius_dynamics(
	__global float* r,
	__global float* u,
	float t,
	unsigned int i) {

	unsigned int last_j = -1;
	unsigned int new_j = -1;
	unsigned int done = 0;
	float dr = 0;
	float c;

	do {
		c = getNextNonZeroGrouthBoundValue(i, last_j, &done, &new_j);

		// does this i have all zeros ?
		if (new_j == -1 && done == 1) {
			break;
		}

		dr += c * r[new_j];
		last_j = new_j;
	} while (done == 0);
	dr += u[i];

	return dr;
}
#endif