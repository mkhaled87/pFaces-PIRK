/*
* pirk.cpu.cl
*
*  date    : 04.07.2019
*  author  : A. Devonport | Electrical Engineering and Computer Sciences, Univeristy of California, Berkeley
*  about   : An OpenCL kernel for computing interval overapproximations of reachable sets.
* ***********************************************************************
*  The kernel manager will replace parameters enclosed by "@@" before compiling !
*/

#define CPU_VERSION
#define MC_@@method_choice@@

/* common utility file */
@pfaces-include:"pirk_utils.cl"

#ifdef MC_1 /* start of growth bound */
@pfaces-include:"growth_bound/gb_initialize_center.cl"
@pfaces-include:"growth_bound/gb_integrate_center.cl"
@pfaces-include:"growth_bound/gb_compute_contraction_matrix.cl"
@pfaces-include:"growth_bound/gb_initialize_radius.cl"
@pfaces-include:"growth_bound/gb_integrate_radius.cl"
#endif /* end of growth bound */

#ifdef MC_2  /* start of CTMM */
@pfaces-include:"ctmm/ctmm_decomposition_dynamics.cl"
@pfaces-include:"ctmm/ctmm_initialize.cl"
@pfaces-include:"ctmm/ctmm_integrate_kfns.cl"
#endif  /* end of CTMM */

#ifdef MC_3  /* start of monte carlo */
@pfaces-include:"monte_carlo/mc_initialize.cl"
@pfaces-include:"monte_carlo/mc_integrate_kfns.cl"
#endif  /* end of monte carlo */