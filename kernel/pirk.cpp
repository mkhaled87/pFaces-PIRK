#include "pirk.h"
#include <math.h>       /* ceil */
#include "pirk_growthbound.cpp"

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
  char* pData = thisParallelProgram.m_dataPool[1].first;
  float* A = (float*)(thisParallelProgram.m_dataPool[1].first);
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

  // TASK0: setting the local vars
  // -----------------------------
  /* This is where you'd read from the config file to load in variables, and set any other local variables. */
  /* for example: */
  // nRows = std::stoi(m_spCfg->readConfigValueString("matdims.rows"));
  // nCols = std::stoi(m_spCfg->readConfigValueString("matdims.cols"));

  // TASK1: Updating the params
  //---------------------------
  /* Here is where you would take the local variables you made and add them to the parameter list,
   * so that you can use them in your kernel functions.*/
  std::vector<std::string> params;
  std::vector<std::string> paramvals;

  //int method_choice;
  method_choice = std::stoi(m_spCfg->readConfigValueString("method_choice"));
  params.push_back("@@method_choice@@");
  paramvals.push_back(std::to_string(method_choice));

  //float initial_time;
  float initial_time = std::stof(m_spCfg->readConfigValueString("initial_time"));
  params.push_back("@@initial_time@@");
  paramvals.push_back(std::to_string(initial_time));

  //float final_time;
  float final_time = std::stof(m_spCfg->readConfigValueString("final_time"));
  params.push_back("@@final_time@@");
  paramvals.push_back(std::to_string(final_time));

  //float step_size;
  float step_size = std::stof(m_spCfg->readConfigValueString("step_size"));
  params.push_back("@@step_size@@");
  paramvals.push_back(std::to_string(step_size));

  // true step size
  float integration_time;
  int nsteps;
  float true_step_size;
  integration_time = final_time - initial_time;
  nsteps = ceil(integration_time / step_size);
  true_step_size = integration_time / (float)(nsteps);

  params.push_back("@@true_step_size@@");
  paramvals.push_back(std::to_string(true_step_size));

  params.push_back("@@nsteps@@");
  paramvals.push_back(std::to_string(nsteps));

  //int states_dim;
  states_dim = std::stoi(m_spCfg->readConfigValueString("states.dim"));
  params.push_back("@@states_dim@@");
  paramvals.push_back(std::to_string(states_dim));

  //int inputs_dim;
  inputs_dim = std::stoi(m_spCfg->readConfigValueString("inputs.dim"));
  params.push_back("@@inputs_dim@@");
  paramvals.push_back(std::to_string(inputs_dim));

  dynamics_element_code = m_spCfg->readConfigValueString("dynamics_element_code");
  params.push_back("@@dynamics_element_code@@");
  paramvals.push_back(dynamics_element_code);

  // updating the list of params
  updatePrameters(params, paramvals);

  // TASK2: Creating the kernel function and load their memory fingerprints
  //------------------------------------------------------------------------

  /* call the growth bound initialization function. There will be a switch or an if/else here later, once we have other methods  */
  initializeGrowthBound(spLaunchState, spCfg);

}
/* constructor code ends */

void pirk::configureParallelProgram(pfacesParallelProgram& parallelProgram)
{

  configureParallelProgramGrowthBound(parallelProgram);

  // register a post-execute instruction to save the data
  std::vector<std::shared_ptr<void>> postExecuteParamsList;
  registerPostExecuteFunction(saveData, "Saving results", postExecuteParamsList);

}

}  /* end of pirk namespace */

PFACES_REGISTER_LOADABLE_KERNEL(pirk::pirk)

