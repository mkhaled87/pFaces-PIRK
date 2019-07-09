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

/* includes for the growth bound method */
// @@config_file_directory@@/hi.cl

/* common utility file */
@pfaces-include:"pirk_utils.cl"

#ifdef MC_1 /* start of growth bound */
@pfaces-include:"growth_bound/gb_initialize_center.cl"

#define gb_integrate_dynchoice_1 gb_integrate_center_1
#define gb_integrate_dynchoice_2 gb_integrate_center_2
#define gb_integrate_dynchoice_3 gb_integrate_center_3
#define gb_integrate_dynchoice_4 gb_integrate_center_4

#define dynfn dynamics_element_global

@pfaces-include:"growth_bound/integrate_kfns.cl"

@pfaces-include:"growth_bound/gb_initialize_radius.cl"

#undef gb_integrate_dynchoice_1
#undef gb_integrate_dynchoice_2
#undef gb_integrate_dynchoice_3
#undef gb_integrate_dynchoice_4

#undef dynfn

#define gb_integrate_dynchoice_1 gb_integrate_radius_1
#define gb_integrate_dynchoice_2 gb_integrate_radius_2
#define gb_integrate_dynchoice_3 gb_integrate_radius_3
#define gb_integrate_dynchoice_4 gb_integrate_radius_4
#define dynfn growth_bound_radius_dynamics

@pfaces-include:"growth_bound/integrate_kfns.cl"
#endif /* end of growth bound */

#ifdef MC_2  /* start of CTMM */
@pfaces-include:"ctmm/ctmm_decomposition_dynamics.cl"
@pfaces-include:"ctmm/ctmm_initialize.cl"
@pfaces-include:"ctmm/ctmm_integrate_kfns.cl"
#endif  /* end of CTMM */
