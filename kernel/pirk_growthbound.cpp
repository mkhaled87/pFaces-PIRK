#include <pfaces-sdk.h>
#include "pirk.h"

namespace pirk{

void pirk::initializeGrowthBound(const std::shared_ptr<pfacesKernelLaunchState>& spLaunchState,
				      const std::shared_ptr<pfacesConfigurationReader>& spCfg)
{

  std::string mem_fingerprint_file = spLaunchState->kernelPackPath + std::string("pirk.mem");

  /* begin code for creating the "initialize_center" kernel function (function 0) */
  pfacesKernelFunction function_gb_initialize_center(
      "gb_initialize_center",  /* name of the function to add */
      {"initial_state", "final_state", "input", "k0","k1","k2","k3","tmp"}  /* list of the names of its args */
  );
  pfacesKernelFunctionArguments args_gb_initialize_center = pfacesKernelFunctionArguments::loadFromFile(
      mem_fingerprint_file,  /* name of the file to load the fingerprint from */
      "gb_initialize_center",  /* name of the function to add */
      {"initial_state", "final_state", "input", "k0","k1","k2","k3","tmp"}  /* list of the names of its args */
  );
  function_gb_initialize_center.setArguments(args_gb_initialize_center);
  addKernelFunction(function_gb_initialize_center);
  /* end code for creating the "initialize_center" kernel function */

  /* begin code for creating the "gb_integrate_center" kernel function (function 1) */
  pfacesKernelFunction function_gb_integrate_center(
      "gb_integrate_center",  /* name of the function to add */
      {"initial_state", "final_state", "input", "k0","k1","k2","k3","tmp"}  /* list of the names of its args */
  );
  pfacesKernelFunctionArguments args_gb_integrate_center = pfacesKernelFunctionArguments::loadFromFile(
      mem_fingerprint_file,  /* name of the file to load the fingerprint from */
      "gb_integrate_center",  /* name of the function to add */
      {"initial_state", "final_state", "input", "k0","k1","k2","k3","tmp"}  /* list of the names of its args */
  );
  function_gb_integrate_center.setArguments(args_gb_integrate_center);
  addKernelFunction(function_gb_integrate_center);
  /* end code for creating the "gb_integrate_center" kernel function */

  /* begin code for creating the "gb_gb_initialize_radius" kernel function (function 2) */
  pfacesKernelFunction function_gb_initialize_radius(
      "gb_initialize_radius",  /* name of the function to add */
      {"initial_state", "final_state", "input", "k0","k1","k2","k3","tmp"}  /* list of the names of its args */
  );
  pfacesKernelFunctionArguments args_gb_initialize_radius = pfacesKernelFunctionArguments::loadFromFile(
      mem_fingerprint_file,  /* name of the file to load the fingerprint from */
      "gb_initialize_radius",  /* name of the function to add */
      {"initial_state", "final_state", "input", "k0","k1","k2","k3","tmp"}  /* list of the names of its args */
  );
  function_gb_initialize_radius.setArguments(args_gb_initialize_radius);
  addKernelFunction(function_gb_initialize_radius);
  /* end code for creating the "gb_gb_initialize_radius" kernel function */

  /* begin code for creating the "gb_integrate_radius" kernel function (function 3) */
  pfacesKernelFunction function_gb_integrate_radius(
      "gb_integrate_radius",  /* name of the function to add */
      {"initial_state", "final_state", "input", "k0","k1","k2","k3","tmp"}  /* list of the names of its args */
  );
  pfacesKernelFunctionArguments args_gb_integrate_radius = pfacesKernelFunctionArguments::loadFromFile(
      mem_fingerprint_file,  /* name of the file to load the fingerprint from */
      "gb_integrate_radius",  /* name of the function to add */
      {"initial_state", "final_state", "input", "k0","k1","k2","k3","tmp"}  /* list of the names of its args */
  );
  function_gb_integrate_radius.setArguments(args_gb_integrate_radius);
  addKernelFunction(function_gb_integrate_radius);
  /* end code for creating the "gb_integrate_radius" kernel function */

} /* End of the growth bound constructor */

void pirk::configureParallelProgramGrowthBound(pfacesParallelProgram& parallelProgram)
{

  // A parallel advisor used for task scheduling
  pfacesParallelAdvisor parallelAdvisor(parallelProgram.getMachine(), parallelProgram.getTargetDevicesIndicies());

  /* This range specifies how the task is going to be split up. */
  pfacesTerminal::showInfoMessage(std::to_string(states_dim));
  cl::NDRange ndUniversalRangeStateDim(
      pfacesBigInt::getPrimitiveValue(states_dim),
      pfacesBigInt::getPrimitiveValue(1)  /* dummy value, no need for second dimension */
  );
  /* note: if you want to use more or fewer dimensions than 2, you can still use this function.
   *       you just give it as many arguments as you want dimensions. */

  std::pair<cl::NDRange, cl::NDRange> stateDimProcessRangeAndOffset = parallelAdvisor.getProcessNDRangeAndOffset(ndUniversalRangeStateDim);
  cl::NDRange ndProcessRangeStateDim = stateDimProcessRangeAndOffset.first;
  cl::NDRange ndProcessOffsetStateDim = stateDimProcessRangeAndOffset.second;

  cl::NDRange ndUniversalOffsetStateDim = cl::NullRange;

  std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_gb_initialize_center;
  jobsPerDev_gb_initialize_center = parallelAdvisor.distributeJob(
	      *this,
	      0, /* function index */
	      ndProcessRangeStateDim, /* process range */
	      ndProcessOffsetStateDim,  /* process offset */
	      parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
	      parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
	      true, false, false  /* some additional flags */
  );

  std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_gb_integrate_center;
  jobsPerDev_gb_integrate_center = parallelAdvisor.distributeJob(
	      *this,
	      1, /* function index */
	      ndProcessRangeStateDim, /* process range */
	      ndProcessOffsetStateDim,  /* process offset */
	      parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
	      parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
	      true, false, false  /* some additional flags */
  );

  std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_gb_initialize_radius;
  jobsPerDev_gb_initialize_radius = parallelAdvisor.distributeJob(
	      *this,
	      2, /* function index */
	      ndProcessRangeStateDim, /* process range */
	      ndProcessOffsetStateDim,  /* process offset */
	      parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
	      parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
	      true, false, false  /* some additional flags */
  );

  std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_gb_integrate_radius;
  jobsPerDev_gb_integrate_radius = parallelAdvisor.distributeJob(
	      *this,
	      3, /* function index */
	      ndProcessRangeStateDim, /* process range */
	      ndProcessOffsetStateDim,  /* process offset */
	      parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
	      parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
	      true, false, false  /* some additional flags */
  );


  // print the task-scheduling report
  //*
  parallelAdvisor.printTaskSchedulingReport(
      parallelProgram.getMachine(),
      {"gb_initialize_center", "gb_integrate_center", "gb_initialize_radius", "gb_integrate_radius"},
      {jobsPerDev_gb_initialize_center, jobsPerDev_gb_integrate_center, jobsPerDev_gb_initialize_radius, jobsPerDev_gb_integrate_radius},
      ndUniversalRangeStateDim[0]
  );
  //*/

  // ---------------------------------------------------------
  // MEMORY ALLOCATION
  // ---------------------------------------------------------
  /**/
  std::vector<std::pair<char*, size_t>> dataPool;
  pFacesMemoryAllocationReport memReport;
  memReport = allocateMemory(dataPool, parallelProgram.getMachine(), parallelProgram.getTargetDevicesIndicies(),
			 pfacesUtils::oclGetRangeVolume(ndProcessRangeStateDim), false);

  memReport.PrintReport();

  // ---------------------------------------------------------
  // Creating the parallel program
  // ---------------------------------------------------------
  std::vector<std::shared_ptr<pfacesInstruction>> instrList;
  const cl::Device& dataAccessDevice = parallelProgram.getTargetDevices()[0];

  // preparing some commonly used instructions

  std::shared_ptr<pfacesDeviceReadJob> jobReadAllData;
  std::shared_ptr<pfacesInstruction> instr_readAllData = std::make_shared<pfacesInstruction>();


  jobReadAllData = std::make_shared<pfacesDeviceReadJob>(dataAccessDevice);

  jobReadAllData->setKernelFunctionIdx(  /* this function tells the instruction where to read the data from */
      1,  /* index of the kernel function we're to read data from (0 in this case, since matrixAdd is index 0 */
      8  /* how many arguments it has (matrixAdd takes 3; the two matrices to add, and the result */
  );
  instr_readAllData->setAsReadAllDeviceData(jobReadAllData);

  std::shared_ptr<pfacesDeviceWriteJob> jobWriteAllData;
  std::shared_ptr<pfacesInstruction> instr_writeAllData = std::make_shared<pfacesInstruction>();
  jobWriteAllData = std::make_shared<pfacesDeviceWriteJob>(dataAccessDevice);
  jobWriteAllData->setKernelFunctionIdx(
      1,  /* index of the kernel function we're to write data to */
      8  /* how many arguments it has */
  );
  instr_writeAllData->setAsWriteAllDeviceData(jobWriteAllData);

  std::shared_ptr<pfacesInstruction> instrSyncPoint = std::make_shared<pfacesInstruction>();
  instrSyncPoint->setAsBlockingSyncPoint();

  std::shared_ptr<pfacesInstruction> instrLogOn = std::make_shared<pfacesInstruction>();
  instrLogOn->setAsLogOn();

  std::shared_ptr<pfacesInstruction> instrLogOff = std::make_shared<pfacesInstruction>();
  instrLogOff->setAsLogOff();

  // INSTRUCTION: a start message
  std::shared_ptr<pfacesInstruction> instrMsg_start = std::make_shared<pfacesInstruction>();
  instrMsg_start->setAsMessage("The program has started.");
  instrList.push_back(instrMsg_start);

  // INSTRUCTION: write memory bags to devices
  // if not using th direct access to host memory, we write the data to the device memory
  // and followed by a barrier to sync among all device threads
  if (!parallelProgram.m_useHostMemory) {
      instrList.push_back(instr_writeAllData);
      if (parallelProgram.countTargetDevices() > 1)
      instrList.push_back(instrSyncPoint);
  }

  std::shared_ptr<pfacesInstruction> instrMsg0 = std::make_shared<pfacesInstruction>();
  instrMsg0->setAsMessage("Initializing center integration...");
  instrList.push_back(instrMsg0);

  // INSTRUCTIONS: initializing for center integration
  for (size_t i = 0; i < jobsPerDev_gb_initialize_center.size(); i++) {
      std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
      tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_gb_initialize_center[i]);
      instrList.push_back(tmpExecuteInstr);
  }

  // INSTRUCTION: a sync point after initialization
  instrList.push_back(instrSyncPoint);

  std::shared_ptr<pfacesInstruction> instrMsg1 = std::make_shared<pfacesInstruction>();
  instrMsg1->setAsMessage("Performing center integration...");
  instrList.push_back(instrMsg1);

  // INSTRUCTIONS: Perform center integration
  for (size_t i = 0; i < jobsPerDev_gb_integrate_center.size(); i++) {
      std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
      tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_gb_integrate_center[i]);
      instrList.push_back(tmpExecuteInstr);
  }

  // INSTRUCTION: a sync point after center integration
  instrList.push_back(instrSyncPoint);

  std::shared_ptr<pfacesInstruction> instrMsg2 = std::make_shared<pfacesInstruction>();
  instrMsg2->setAsMessage("Initializing radius integration...");
  instrList.push_back(instrMsg2);
  // INSTRUCTIONS: initializing for radius integration
  for (size_t i = 0; i < jobsPerDev_gb_initialize_radius.size(); i++) {
      std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
      tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_gb_initialize_radius[i]);
      instrList.push_back(tmpExecuteInstr);
  }

  // INSTRUCTION: a sync point after initialization
  instrList.push_back(instrSyncPoint);


  std::shared_ptr<pfacesInstruction> instrMsg3 = std::make_shared<pfacesInstruction>();
  instrMsg3->setAsMessage("Performing radius integration...");
  instrList.push_back(instrMsg3);
  // INSTRUCTIONS: performing radius integration
  for (size_t i = 0; i < jobsPerDev_gb_integrate_radius.size(); i++) {
      std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
      tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_gb_integrate_radius[i]);
      instrList.push_back(tmpExecuteInstr);
  }

  // INSTRUCTION: a sync point after initialization
  instrList.push_back(instrSyncPoint);

  // INSTRUCTION: a sync point after initialization
  instrList.push_back(instrSyncPoint);


  // INSTRUCTION: read memory bags from devices
  // if not using direct access to host memory, we write the data to the device memory
  // and followed by a barrier to sync among all device threads
  if (!parallelProgram.m_useHostMemory) {
      instrList.push_back(instr_readAllData);
      if (parallelProgram.countTargetDevices() > 1)
	instrList.push_back(instrSyncPoint);
  }

  // INSTRUCTION: a sync point after the matrix elements have all been added together
  instrList.push_back(instrSyncPoint);


  // INSTRUCTION: a message
  // Notify the user that abstraction is complete
  std::shared_ptr<pfacesInstruction> instr_MsgAddComplete = std::make_shared<pfacesInstruction>();
  instr_MsgAddComplete->setAsMessage("program complete.");
  instrList.push_back(instr_MsgAddComplete);

  // INSTRUCTION: last instructin is a sync point !
  instrList.push_back(instrSyncPoint);

  // ---------------------------------------------------------
  // Finalize !
  // ---------------------------------------------------------
  // setting the params back to the parallel program
  parallelProgram.m_Universal_globalNDRange = ndUniversalRangeStateDim;
  parallelProgram.m_Universal_offsetNDRange = ndUniversalOffsetStateDim;
  parallelProgram.m_dataPool = dataPool;
  parallelProgram.m_spInstructionList = instrList;


}

/* providing implementation of the virtual method: configureTuneParallelProgram*/
void pirk::configureTuneParallelProgram(pfacesParallelProgram& tuneParallelProgram, size_t targetFunctionIdx) {
  (void)tuneParallelProgram;
  (void)targetFunctionIdx;

  pfacesTerminal::showInfoMessage("Tuning function to be added later.");
}

}  /* End namespace pirk */
