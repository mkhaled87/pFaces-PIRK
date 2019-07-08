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

/* includes for the growth bound method */
// @@config_file_directory@@/hi.cl

/* common utility file */
@pfaces-include:"pirk_utils.cl"

@pfaces-include:"growth_bound/gb_initialize_center.cl"

#define step_size @@true_step_size@@
#define RK4_NINT 5
#define RK4_H ((@@true_step_size@@/RK4_NINT))

#define gb_integrate_dynchoice_1 gb_integrate_center_1
#define gb_integrate_dynchoice_2 gb_integrate_center_2
#define gb_integrate_dynchoice_3 gb_integrate_center_3
#define gb_integrate_dynchoice_4 gb_integrate_center_4
#define gb_integrate_dynchoice_5 gb_integrate_center_5
#define gb_integrate_dynchoice_6 gb_integrate_center_6
#define gb_integrate_dynchoice_7 gb_integrate_center_7
#define gb_integrate_dynchoice_8 gb_integrate_center_8

#define dynfn dynamics_element

@pfaces-include:"growth_bound/integrate_kfns.cl"

@pfaces-include:"growth_bound/gb_initialize_radius.cl"

#undef gb_integrate_dynchoice_1
#undef gb_integrate_dynchoice_2
#undef gb_integrate_dynchoice_3
#undef gb_integrate_dynchoice_4
#undef gb_integrate_dynchoice_5
#undef gb_integrate_dynchoice_6
#undef gb_integrate_dynchoice_7
#undef gb_integrate_dynchoice_8

#undef dynfn

#define gb_integrate_dynchoice_1 gb_integrate_radius_1
#define gb_integrate_dynchoice_2 gb_integrate_radius_2
#define gb_integrate_dynchoice_3 gb_integrate_radius_3
#define gb_integrate_dynchoice_4 gb_integrate_radius_4
#define gb_integrate_dynchoice_5 gb_integrate_radius_5
#define gb_integrate_dynchoice_6 gb_integrate_radius_6
#define gb_integrate_dynchoice_7 gb_integrate_radius_7
#define gb_integrate_dynchoice_8 gb_integrate_radius_8
#define dynfn growth_bound_radius_dynamics

@pfaces-include:"growth_bound/integrate_kfns.cl"

@pfaces-include:"ctmm/ctmm_decomposition_dynamics.cl"
@pfaces-include:"ctmm/ctmm_initialize.cl"
@pfaces-include:"ctmm/ctmm_integrate_kfns.cl"