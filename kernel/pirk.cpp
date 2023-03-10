#include "pirk.h"
#include <math.h>       /* ceil */
#include <chrono>  // for high_resolution_clock

namespace pirk{

	/* pirk kernel constructor */
	pirk::pirk(const std::shared_ptr<pfacesKernelLaunchState>& spLaunchState, const std::shared_ptr<pfacesConfigurationReader>& spCfg) :
		  pfaces2DKernel(spLaunchState->getDefaultSourceFilePath("pirk"), 1,1, spCfg),
		  m_spCfg(spCfg){

	  // Updating the params
	  //---------------------------
	  std::vector<std::string> params;
	  std::vector<std::string> paramvals;
	  this->configureParameters(params, paramvals);


	  // Creating the kernel function and load their memory fingerprints
	  //------------------------------------------------------------------------
	  method_choice = std::stoi(m_spCfg->readConfigValueString("method_choice"));
	  method_choice_err = std::string("Invalid method selection ") + std::to_string(method_choice) + std::string("! Please set method_choice to 1 (growth bound), 2 (CTMM), 3 (Monte Carlo), or 4 (Mont Carlo for High-Dimensions).");
	  if(method_choice == 1)
		  initializeGrowthBound(spLaunchState);
	  else if (method_choice == 2)
		  initializeCTMM(spLaunchState);
	  else if (method_choice == 3)
		  initializeMonteCarlo(spLaunchState);
	  else if (method_choice == 4)
		  initializeMonteCarloHD(spLaunchState);
	  else
		  throw std::runtime_error(method_choice_err);
	}

	/* providing implementation of the virtual method: configureParallelProgram*/
	void pirk::configureParallelProgram(pfacesParallelProgram& parallelProgram){
		
		std::vector<std::shared_ptr<void>> postExecuteParamsList;
		save_result = m_spCfg->readConfigValueBool("save_result");
		record_pipe = m_spCfg->readConfigValueBool("record_pipe");
		if(!save_result)
			record_pipe = false;
		
		// configure the program and register a post-execute instruction to save the data
		if(method_choice == 1) {
			configureParallelProgramGrowthBound(parallelProgram);
			if(save_result)
				registerPostExecuteFunction(gb_saveData, "Saving results", postExecuteParamsList);

		} else if (method_choice == 2) {
			configureParallelProgramCTMM(parallelProgram);
			if (save_result)
				registerPostExecuteFunction(ctmm_saveData, "Saving results", postExecuteParamsList);

			if(save_result && record_pipe)
				pfacesTerminal::showWarnMessage("TODO: add support for pipe-recording in CTMM.");				
		} else if (method_choice == 3) {
			configureParallelProgramMonteCarlo(parallelProgram);
			
			if (save_result)
				registerPostExecuteFunction(mc_saveData, "Saving results", postExecuteParamsList);

			if(save_result && record_pipe)
				pfacesTerminal::showWarnMessage("TODO: add support for pipe-recording in Mont-Carlo.");				
		}
		else if (method_choice == 4) {
			configureParallelProgramMonteCarloHD(parallelProgram);

			if (save_result)
				registerPostExecuteFunction(mchd_saveData, "Saving results", postExecuteParamsList);

			if(save_result && record_pipe)
				pfacesTerminal::showWarnMessage("TODO: add support for pipe-recording in Mont-Carlo.");
		}

		// add extra include path: the config file path
		std::string CFG_DIR = pfacesFileIO::getFileDirectoryPath(m_spCfg->getConfigFilePath());
		if(CFG_DIR.empty())
			CFG_DIR = std::string(".") + std::string(PFACES_PATH_SPLITTER);
		std::string INC_CFG_DIR = std::string(" -I") + CFG_DIR;
		parallelProgram.m_oclOptions += INC_CFG_DIR + std::string(" -cl-opt-disable");
	}

	/* providing implementation of the virtual method: configureTuneParallelProgram*/
	void pirk::configureTuneParallelProgram(pfacesParallelProgram& tuneParallelProgram, size_t targetFunctionIdx) {
		(void)tuneParallelProgram;
		(void)targetFunctionIdx;
	}
}

PFACES_REGISTER_LOADABLE_KERNEL(pirk::pirk)
