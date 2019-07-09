/*
 * pfaces-kernel-minimal.h
 *
 *  Created on: Jun 12, 2019
 *      Author: hcs
 */

#ifndef PFACES_KERNEL_PIRK_H_
#define PFACES_KERNEL_PIRK_H_

/* pfaces related include files */
#include <pfaces-sdk.h>

namespace pirk{

class pirk : public pfaces2DKernel {
/* Notice that this class extends pfaces2DKernel. When we write the constructor for this class, we'll be calling the constructor
 * for pfaces2DKernel in the initializer list. */
private:

/* the configuration reader */
const std::shared_ptr<pfacesConfigurationReader> m_spCfg;


public:
  /* some vars for local storage */
  /* Your vars here */
  int states_dim;
  int inputs_dim;
  int method_choice;
  float integration_time;
  int nsteps;
  int nsamples;
  float true_step_size;
  string dynamics_element_code;
  std::string method_choice_err;

  /* All pFaces kernel classes need to provide the following three methods: */
  //pfacesKernelMinimal(const std::string& kernelScope
  //	, const std::shared_ptr<pfacesConfigurationReader>& spCfg);
  pirk(const std::shared_ptr<pfacesKernelLaunchState>& spLaunchState,
		      const std::shared_ptr<pfacesConfigurationReader>& spCfg);
  ~pirk() = default;

  void configureParameters(std::vector<std::string> params, std::vector<std::string> paramvals);

  void configureParallelProgram(pfacesParallelProgram& parallelProgram);

  void configureTuneParallelProgram(pfacesParallelProgram& tuneParallelProgram, size_t targetFunctionIdx);


  void initializeGrowthBound(const std::shared_ptr<pfacesKernelLaunchState>& spLaunchState,
				      const std::shared_ptr<pfacesConfigurationReader>& spCfg);
  void configureParallelProgramGrowthBound(pfacesParallelProgram& parallelProgram);

  void initializeCTMM(const std::shared_ptr<pfacesKernelLaunchState>& spLaunchState,
  				      const std::shared_ptr<pfacesConfigurationReader>& spCfg);
  void configureParallelProgramCTMM(pfacesParallelProgram& parallelProgram);

  void initializeMonteCarlo(const std::shared_ptr<pfacesKernelLaunchState>& spLaunchState,
    				      const std::shared_ptr<pfacesConfigurationReader>& spCfg);
  void configureParallelProgramMonteCarlo(pfacesParallelProgram& parallelProgram);

};

}

#endif /* PFACES_KERNEL_PIRK_H_ */
