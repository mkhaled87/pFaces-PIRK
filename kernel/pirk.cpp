#include "pirk.h"
#include <math.h>       /* ceil */
#include "pirk_utils.cpp"
#include "pirk_growthbound.cpp"
#include "pirk_ctmm.cpp"

namespace pirk{


  // -----------------------------------------------
  // A post-execcute to save the data
  // -----------------------------------------------
size_t saveData(
    const pfaces2DKernel& thisKernel,
    const pfacesParallelProgram& thisParallelProgram,
    std::vector<std::shared_ptr<void>>& postExecuteParamsList)
{

  pfacesTerminal::showInfoMessage("This is where I'd write to a save file... IF I HAD ONE");
  pirk* knl = ((pirk*)(&thisKernel));
  /* index 1 is the final state for the center */
  // for growth bound, use idx 1
  float* A = (float*)(thisParallelProgram.m_dataPool[0].first);
  for(int i=0; i<knl->states_dim; i++) {
      pfacesTerminal::showMessage(std::to_string(A[i]));
    }
    pfacesTerminal::showMessage("-------------------");
  //for growth bound, use idx 9
  A = (float*)(thisParallelProgram.m_dataPool[1].first);
  for(int i=0; i<knl->states_dim; i++) {
      pfacesTerminal::showMessage(std::to_string(A[i]));
    }

  return 0;
}

pirk::pirk(const std::shared_ptr<pfacesKernelLaunchState>& spLaunchState, const std::shared_ptr<pfacesConfigurationReader>& spCfg)
  /* member initialization list */
  :   /* First up, we'll initialize the parent class, pfaces2DKernel. */
      pfaces2DKernel(
      spLaunchState->getDefaultSourceFilePath(std::string("pirk"), spLaunchState->kernelScope, spLaunchState->kernelPackPath),
      1,1),
      /* Now we can initialize the other members of pfacesKernelMinimal. */
      m_spCfg(spCfg)
      /* initializer list ends */
/* rest of constructor code begins */
{

  // TASK1: Updating the params
  //---------------------------
  /* Here is where you would take the local variables you made and add them to the parameter list,
   * so that you can use them in your kernel functions.*/
  std::vector<std::string> params;
  std::vector<std::string> paramvals;

  method_choice = std::stoi(m_spCfg->readConfigValueString("method_choice"));
  params.push_back("@@method_choice@@");
  paramvals.push_back(std::to_string(method_choice));

  configureParameters(params, paramvals);

  // TASK2: Creating the kernel function and load their memory fingerprints
  //------------------------------------------------------------------------

  /* call the growth bound initialization function. We'll choose which constructor to call based on method_choice.  */
  method_choice_err = "Invalid method selection! Please set method_choice to 1 (growth bound) or 2 (CTMM).";
  if(method_choice == 1) {
      initializeGrowthBound(spLaunchState, spCfg);
  } else if (method_choice == 2) {
      initializeCTMM(spLaunchState, spCfg);
  } else {
      throw std::runtime_error(method_choice_err);
  }

}
/* constructor code ends */

void pirk::configureParallelProgram(pfacesParallelProgram& parallelProgram)
{

  if(method_choice == 1) {
      configureParallelProgramGrowthBound(parallelProgram);
  } else if (method_choice == 2) {
      configureParallelProgramCTMM(parallelProgram);
  } else {
      throw std::runtime_error(method_choice_err);
  }

  // register a post-execute instruction to save the data
  std::vector<std::shared_ptr<void>> postExecuteParamsList;
  registerPostExecuteFunction(saveData, "Saving results", postExecuteParamsList);

}

}  /* end of pirk namespace */

PFACES_REGISTER_LOADABLE_KERNEL(pirk::pirk)

