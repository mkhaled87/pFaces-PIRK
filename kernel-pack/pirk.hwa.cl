/*
* amytiss.cpu.cl
*
*  date    : 28.04.2019
*  author  : M. Khaled | Hybrid control systems @ Technical University of Munich, Germany
*  about   : an OpenCL kernel (optimized for HWAs) used to of the tool AMYTISS.
*            AMYTISS is a tool for an abstractuin based synthesis of stochastic systems.
* ***********************************************************************
*  The kernel manager will replace parameters enclosed by "@@" before compiling !
*/

#define HWA_VERSION

// pFaces-Including a KERNEL-Function: initialize
@pfaces-include:"initialize.cl"
// pFaces-Including a KERNEL-Function: rk4
@pfaces-include:"rk4.cl"

