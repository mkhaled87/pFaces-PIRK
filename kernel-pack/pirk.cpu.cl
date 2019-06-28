/*
* amytiss.cpu.cl
*
*  date    : 28.04.2019
*  author  : M. Khaled | Hybrid control systems @ Technical University of Munich, Germany
*  about   : an OpenCL kernel (optimized for CPUs) used to of the tool AMYTISS.
*            AMYTISS is a tool for an abstractuin based synthesis of stochastic systems.
* ***********************************************************************
*  The kernel manager will replace parameters enclosed by "@@" before compiling !
*/

#define CPU_VERSION

/* common utility file */
@pfaces-include:"pirk_utils.cl"

/* includes for the growth bound method */
@pfaces-include:"growth_bound/gb_initialize_center.cl"
@pfaces-include:"growth_bound/gb_integrate_center.cl"
@pfaces-include:"growth_bound/gb_initialize_radius.cl"
@pfaces-include:"growth_bound/gb_integrate_radius.cl"


