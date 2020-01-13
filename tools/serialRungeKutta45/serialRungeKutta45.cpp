/******************************************************************************

                              Online C++ Compiler.
               Code, Compile, Run and Debug C++ program online.
Write your code in this editor and press "Run" button to compile and execute it.

*******************************************************************************/

#include <iostream>
#include <iomanip>
#include <math.h>

#define PRINT_PRECISION 5

using namespace std;

// the ode solver class
#include "RungeKutta4.h"

// the dynamics/bounds come from example files
#define __global	/* removes the OpenCl global keyword */
#include "dynamics.cl"
#include "bounds.cl"

// the oder solver object
const int nint=5;
OdeSolver ode_solver(SS_DIM,nint,STEP_SIZE);


int main(){
	std::cout << std::fixed << std::setprecision(PRINT_PRECISION);
	std::cout << "ss dim = " << SS_DIM << std::endl;
	std::cout << "intial time = " << INITIAL_TIME << std::endl;
	std::cout << "final time = " << FINAL_TIME << std::endl;
	std::cout << "step size = " << STEP_SIZE << std::endl;
	
	// compute the initial state/input
	std::cout << "initial state = ";
	float center_x[SS_DIM] = {0.330970, 0.244649, -0.133796, 5.046261, -0.002903, 0.044322, 0.046198};
	for(int i=0; i<SS_DIM; i++){
		//center_x[i] = initial_state_lower_bound(i) + (initial_state_upper_bound(i)-initial_state_lower_bound(i))/2.0f;
		std::cout << std::setprecision(PRINT_PRECISION) << center_x[i] << "\t";
	}
	std::cout << std::endl;
	std::cout << "initial input = ";
	float center_u[IS_DIM];
	for(int i=0; i<IS_DIM; i++){
		center_u[i] = input_lower_bound(i) + (input_upper_bound(i)-input_lower_bound(i))/2.0f;
		std::cout << std::setprecision(PRINT_PRECISION) << center_u[i] << "\t";
	}
	std::cout << std::endl;	
	
	
	// solve the ode
	float t=INITIAL_TIME;
	do{
		ode_solver.setInitialTime(t);
		ode_solver(dynamics_element_global, center_x, center_u);
		t+=STEP_SIZE;
	}while(t < FINAL_TIME);

    return 0;
}
