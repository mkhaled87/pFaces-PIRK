/*
 * RungeKutta45.hh
 *
 *  created on: 22.04.2015
 *      author: rungger
 *  modified by M.Khaled on 11.1.2020
 */

#ifndef RUNGEKUTTA4_HH_
#define RUNGEKUTTA4_HH_

#define PRINT_STATES

/* class: RungeKutta4 
 * Fixed step size ode solver implementing a Runge Kutta scheme of order 4 */
class OdeSolver {
private:
  /* dimension */
  const int dim_;
  /* number of intermediate steps */
  const int nint_;

  /* intermidiate step size = tau_/nint_ */
  const float h_;
 
  /*initial time*/
  float initial_t_;
  
public:
  /* function: OdeSolver
   *
   * Input:
   * dim - state space dimension 
   * nint - number of intermediate steps
   * tau - sampling time
   */
  OdeSolver(int dim, int nint, float tau) : dim_(dim), nint_(nint), h_(tau/nint) { };
  void setInitialTime(float it){initial_t_ = it;}

  /* function: ()
   *
   * Input:
   * rhs - rhs of ode  dx/dt = rhs(x,u)
   * x - current state x
   * u - current input u
   */
  template<class RHS>
  inline void operator()(RHS rhs, float* x, float* u) {
		float k[4][dim_];
		float tmp[dim_];
		float time=initial_t_;

		for(int t=0; t<nint_; t++) {
			
			for(int i=0;i<dim_;i++)
				k[0][i] = rhs(x,u,time,i);			
			for(int i=0;i<dim_;i++)
				tmp[i]=x[i]+h_/2*k[0][i];

			for(int i=0;i<dim_;i++)
				k[1][i] = rhs(tmp,u,time,i);
			for(int i=0;i<dim_;i++)
				tmp[i]=x[i]+h_/2*k[1][i];

			for(int i=0;i<dim_;i++)
				k[2][i] = rhs(tmp,u,time,i);
			for(int i=0;i<dim_;i++)
				tmp[i]=x[i]+h_*k[2][i];

			for(int i=0;i<dim_;i++)
				k[3][i] = rhs(tmp,u,time,i);
			for(int i=0; i<dim_; i++)
				x[i] = x[i] + (h_/6)*(k[0][i] + 2*k[1][i] + 2*k[2][i] + k[3][i]);
		
			time += h_;
			
			#ifdef PRINT_STATES
				std::cout << "[" << std::setprecision(6) <<  time << "]: \t";
				for(int i=0; i<dim_; i++)
					std::cout << std::setprecision(6) << x[i] << "\t";
				std::cout << std::endl;					
			#endif
		}
	}
};

#endif /* RUNGEKUTTA4_HH_ */
