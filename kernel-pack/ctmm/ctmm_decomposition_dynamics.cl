float ctmm_decomposition_dynamics(
  __global float *x,
  __global float *u,
  float t,
  int i
)
{
    /* First, we need to figure out if we're computing the 'top half' or the 'bottom half' of the dynamics. The only difference will be
    which 'half' of the vectors we treat as the 'star' part and which we treat as the 'non-star' part.*/
    int idx;
    int idx_hat;

    int idx_nom;
    int offset;
    int hat_offset;
    if(i - @@states_dim@@ <= 0) {
        /* The index is in the 'upper half', so we're computing g(x,u,xhat,uhat). */
        idx = i;
        offset = 0;
        idx_hat = i + @@states_dim@@;
        hat_offset = @@states_dim@@;
        idx_nom = i;

    }
    else {
        /* the index is in the 'lower half', so we're computing g(xhat,uhat,x,u). */
        idx = i;
        offset = @@states_dim@@;
        idx_hat = i - @@states_dim@@;
        hat_offset = 0;
        idx_nom = i - @@states_dim@@;
    }
    float xi[@@states_dim@@];
    float pi[@@states_dim@@];
    float alpha[@@states_dim@@];
    float beta[@@states_dim@@];
    float dh;
    
    for(int k=0; k < @@states_dim@@; k++) {
        float ju = state_jacobian_upper_bound(i,k);
        float jl = state_jacobian_lower_bound(i,k);
        float jm = 0.5 * (ju + jl);
        if(jm >= 0) {
            xi[k] = x[idx];
            alpha[k] = fmax((float) 0.0, -jl);
        }
        else {
            xi[k] = x[idx_hat];
            alpha[k] = fmax((float) 0.0, ju);
        }
    }
    alpha[idx_nom] = 0.0;
    xi[idx_nom] = x[idx];

    for(int k=0; k < @@inputs_dim@@; k++) {
        float ju = input_jacobian_upper_bound(i,k);
        float jl = input_jacobian_lower_bound(i,k);
        float jm = 0.5 * (ju + jl);
        if(jm >= 0) {
            pi[k] = u[idx];
            beta[k] = fmax((float) 0.0, -jl);
        }
        else {
            pi[k] = u[idx_hat];
            beta[k] = fmax((float) 0.0, ju);
        }
    }
    
    dh = dynamics_element_local(xi, pi, t, i);
    for(int k=0; k < @@states_dim@@; k++) {
        dh += alpha[k] * (x[k+offset] - x[k+hat_offset]);
    }
    for(int k=0; k < @@inputs_dim@@; k++) {
        dh += beta[k] * (u[k+offset] - u[k+hat_offset]);
    }
    return dh;
    
    

}