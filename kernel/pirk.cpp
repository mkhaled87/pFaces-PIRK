#include "pirk.h"
#include <math.h>       /* ceil */
#include <chrono>  // for high_resolution_clock

namespace pirk{

	// A post-execcute functions to save the data
	// -----------------------------------------------
	size_t gb_saveData(
		const pfaces2DKernel& thisKernel,
		const pfacesParallelProgram& thisParallelProgram,
		std::vector<std::shared_ptr<void>>& postExecuteParamsList){

		(void)thisKernel;
		(void)postExecuteParamsList;

		pfacesTerminal::showInfoMessage("This is the reach set as from the GB method for the 10-link example:");
		float* center = (float*)(thisParallelProgram.m_dataPool[1].first);	/* index 1 is the final state for the center */
		float* radius = (float*)(thisParallelProgram.m_dataPool[9].first);	/* index 1 is the final state for the radius */

		pfacesTerminal::showMessage("Center\n-------------------");
		for (int i = 0; i < 10; i++)
			pfacesTerminal::showMessage(std::to_string(center[i]) + std::string(", "), false);

		pfacesTerminal::showMessage("\nRadius\n-------------------");
		for (int i = 0; i < 10; i++)
			pfacesTerminal::showMessage(std::to_string(radius[i]) + std::string(", "), false);

		pfacesTerminal::showMessage("\nSuccessor lower\n-------------------");
		for(int i=0; i<10; i++)
			pfacesTerminal::showMessage(std::to_string(center[i] - radius[i]));

		pfacesTerminal::showMessage("Successor upper\n-------------------");
		for(int i=0; i<10; i++)
			pfacesTerminal::showMessage(std::to_string(radius[i] + center[i]));

		saveBufferToFile(thisParallelProgram, thisParallelProgram.m_dataPool[1].first, thisParallelProgram.m_dataPool[1].second, "result_gb_radius");
		saveBufferToFile(thisParallelProgram, thisParallelProgram.m_dataPool[9].first, thisParallelProgram.m_dataPool[9].second, "result_gb_center");

		return 0;
	}

	size_t ctmm_saveData(
		const pfaces2DKernel& thisKernel,
		const pfacesParallelProgram& thisParallelProgram,
		std::vector<std::shared_ptr<void>>& postExecuteParamsList){

		(void)thisKernel;
		(void)postExecuteParamsList;			

		//pfacesTerminal::showInfoMessage("This is where I'd write to a save file... IF I HAD ONE\nCTMM");
		//pirk* knl = ((pirk*)(&thisKernel));
		//float* A = (float*)(thisParallelProgram.m_dataPool[1].first);
		////  pfacesTerminal::showMessage("Successor lower\n-------------------");
		////  for(int i = 0; i < 2 * knl->states_dim; i++) {
		////      pfacesTerminal::showMessage(std::to_string(A[i]));
		////      if(i == knl->states_dim -1){
		////        pfacesTerminal::showMessage("Successor upper\n-------------------");
		////      }
		////    }

		saveBufferToFile(thisParallelProgram, thisParallelProgram.m_dataPool[1].first, thisParallelProgram.m_dataPool[1].second, "result_ctmm_radius");
		saveBufferToFile(thisParallelProgram, thisParallelProgram.m_dataPool[9].first, thisParallelProgram.m_dataPool[9].second, "result_ctmm_center");

		return 0;
	}

	size_t mc_saveData(
		const pfaces2DKernel& thisKernel,
		const pfacesParallelProgram& thisParallelProgram,
		std::vector<std::shared_ptr<void>>& postExecuteParamsList){

		(void)thisKernel;
		(void)postExecuteParamsList;			

		//pfacesTerminal::showInfoMessage("This is where I'd write to a save file... IF I HAD ONE\nMC");
		//pirk* knl = ((pirk*)(&thisKernel));
		//float* A = (float*)(thisParallelProgram.m_dataPool[1].first);
		///* index 1 is the final state for the center */
		//// for growth bound, use idx 1
		//std::vector<float> succ_up(knl->states_dim);
		//std::vector<float> succ_low(knl->states_dim);
		//float cmp;
		//for(int i = 0; i < knl->states_dim; i++) {
			// succ_up[i] = -INFINITY;
			// succ_low[i] = INFINITY;
			// for(int w = 0; w < knl->nsamples; w++) {
			// cmp = A[w*knl->states_dim + i];
			// if(cmp > succ_up[i]) {
			//  succ_up[i] = cmp;
			// }
			// if(cmp < succ_low[i]) {
			//  succ_low[i] = cmp;
			// }
			// }
		//}
		//  pfacesTerminal::showMessage("Lower sucessor\n-------------------");
		//  for(int i=0; i<knl->states_dim; i++) {
		//      pfacesTerminal::showMessage(std::to_string(succ_low[i]));
		//    }
		//  pfacesTerminal::showMessage("Upper sucessor\n-------------------");
		//  for(int i=0; i<knl->states_dim; i++) {
		//      pfacesTerminal::showMessage(std::to_string(succ_up[i]));
		//    }

		saveBufferToFile(thisParallelProgram, thisParallelProgram.m_dataPool[1].first, thisParallelProgram.m_dataPool[1].second, "result_mc_radius");
		saveBufferToFile(thisParallelProgram, thisParallelProgram.m_dataPool[9].first, thisParallelProgram.m_dataPool[9].second, "result_mc_center");

		return 0;
	}


	/* pirk kernel constructor */
	pirk::pirk(const std::shared_ptr<pfacesKernelLaunchState>& spLaunchState, const std::shared_ptr<pfacesConfigurationReader>& spCfg) :
		  pfaces2DKernel(spLaunchState->getDefaultSourceFilePath(std::string("pirk"), spLaunchState->kernelScope, spLaunchState->kernelPackPath), 1,1),
		  m_spCfg(spCfg){

	  // Updating the params
	  //---------------------------
	  std::vector<std::string> params;
	  std::vector<std::string> paramvals;
	  method_choice = std::stoi(m_spCfg->readConfigValueString("method_choice"));
	  params.push_back("@@method_choice@@");
	  paramvals.push_back(std::to_string(method_choice));
	  this->configureParameters(params, paramvals);

	  // Creating the kernel function and load their memory fingerprints
	  //------------------------------------------------------------------------
	  method_choice_err = "Invalid method selection! Please set method_choice to 1 (growth bound), 2 (CTMM), or 3 (Monte Carlo).";
	  if(method_choice == 1) {
		  initializeGrowthBound(spLaunchState);
	  } else if (method_choice == 2) {
		  initializeCTMM(spLaunchState);
	  } else if (method_choice == 3) {
		  initializeMonteCarlo(spLaunchState);
	  } else {
		  throw std::runtime_error(method_choice_err);
	  }
	}

	/* providing implementation of the virtual method: configureParallelProgram*/
	void pirk::configureParallelProgram(pfacesParallelProgram& parallelProgram){
		
		std::vector<std::shared_ptr<void>> postExecuteParamsList;
		
		// configure the program and register a post-execute instruction to save the data
		if(method_choice == 1) {
			configureParallelProgramGrowthBound(parallelProgram);
			registerPostExecuteFunction(gb_saveData, "Saving results", postExecuteParamsList);
		} else if (method_choice == 2) {
			configureParallelProgramCTMM(parallelProgram);
			registerPostExecuteFunction(ctmm_saveData, "Saving results", postExecuteParamsList);
		} else if (method_choice == 3) {
			configureParallelProgramMonteCarlo(parallelProgram);
			registerPostExecuteFunction(mc_saveData, "Saving results", postExecuteParamsList);
		} else {
			throw std::runtime_error(method_choice_err);
		}

		// add extra include path: the config file path
		std::string CFG_DIR = pfacesFileIO::getFileDirectoryPath(m_spCfg->getConfigFilePath());
		std::string INC_CFG_DIR = std::string(" -I") + CFG_DIR;
		parallelProgram.m_oclOptions += INC_CFG_DIR;
	}

	/* providing implementation of the virtual method: configureTuneParallelProgram*/
	void pirk::configureTuneParallelProgram(pfacesParallelProgram& tuneParallelProgram, size_t targetFunctionIdx) {
		(void)tuneParallelProgram;
		(void)targetFunctionIdx;
	}
}

PFACES_REGISTER_LOADABLE_KERNEL(pirk::pirk)


