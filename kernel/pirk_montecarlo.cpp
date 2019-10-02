#include <pfaces-sdk.h>
#include "pirk.h"

namespace pirk{

	size_t mc_hostFunctionGenerateRandomNumbers(void* pPackedKernel, void* pPackedParallelProgram) {
		
		// the randoom values arrays from the data pool
		float* rands1 = (float*)(((pfacesParallelProgram*)pPackedParallelProgram)->m_dataPool[9].first);
		float* rands2 = (float*)(((pfacesParallelProgram*)pPackedParallelProgram)->m_dataPool[10].first);

		size_t nsamples = ((pirk*)pPackedKernel)->nsamples;
		size_t states_dim = ((pirk*)pPackedKernel)->states_dim;
		
		size_t gen_space = nsamples * states_dim;
		pfacesUtils::threaded_for(gen_space, [&rands1, &rands2](int start, int end) {
			std::srand(start*std::time(NULL));
			for (size_t i = start; i < end; i++){
				rands1[i] = ((float)std::rand() / RAND_MAX);
				rands2[i] = ((float)std::rand() / RAND_MAX);
			}
		});

		return 0;
	}

	size_t mc_saveData(
		const pfaces2DKernel& thisKernel,
		const pfacesParallelProgram& thisParallelProgram,
		std::vector<std::shared_ptr<void>>& postExecuteParamsList) {

		(void)thisKernel;
		(void)postExecuteParamsList;

		saveBufferToFile(thisParallelProgram, thisParallelProgram.m_dataPool[1].first, thisParallelProgram.m_dataPool[1].second, "result_mc_posts");

		return 0;
	}


	void pirk::initializeMonteCarlo(const std::shared_ptr<pfacesKernelLaunchState>& spLaunchState){

		std::string mem_fingerprint_file =
			spLaunchState->kernelPackPath + std::string("monte_carlo") +
			std::string(PFACES_PATH_SPLITTER) + std::string("mc.mem");

		/* some constants */
		std::vector<std::string> argNames_initialize = { "initial_state", "final_state", "input", "k0","k1","k2","k3","tmp", "t", "rands1", "rands2" };
		std::vector<std::string> argNames_integrate  = { "initial_state", "final_state", "input", "k0","k1","k2","k3","tmp", "t" };

		/* creating the "initialize" kernel function (function 0) */
		pfacesKernelFunctionArguments args_mc_initialize = pfacesKernelFunctionArguments::loadFromFile(
			mem_fingerprint_file,  /* name of the file to load the fingerprint from */
			"mc_initialize",  /* name of the function to add */
			argNames_initialize);
		pfacesKernelFunction function_mc_initialize("mc_initialize", args_mc_initialize);
		function_mc_initialize.setArguments(args_mc_initialize);
		addKernelFunction(function_mc_initialize);

		/* creating the "integrate_1" kernel function (function 1) */
		pfacesKernelFunctionArguments args_mc_integrate_1 = pfacesKernelFunctionArguments::loadFromFile(
			mem_fingerprint_file,  /* name of the file to load the fingerprint from */
			"mc_integrate_1",  /* name of the function to add */
			argNames_integrate
		);
		pfacesKernelFunction function_mc_integrate_1("mc_integrate_1", args_mc_integrate_1);
		function_mc_integrate_1.setArguments(args_mc_integrate_1);
		addKernelFunction(function_mc_integrate_1);

		/* creating the "integrate_2" kernel function (function 2) */
		pfacesKernelFunctionArguments args_mc_integrate_2 = pfacesKernelFunctionArguments::loadFromFile(
			mem_fingerprint_file,  /* name of the file to load the fingerprint from */
			"mc_integrate_2",  /* name of the function to add */
			argNames_integrate  /* list of the names of its args */
		);
		pfacesKernelFunction function_mc_integrate_2("mc_integrate_2", args_mc_integrate_2);
		function_mc_integrate_2.setArguments(args_mc_integrate_2);
		addKernelFunction(function_mc_integrate_2);

		/* creating the "integrate_3" kernel function (function 3) */
		pfacesKernelFunctionArguments args_mc_integrate_3 = pfacesKernelFunctionArguments::loadFromFile(
			mem_fingerprint_file,  /* name of the file to load the fingerprint from */
			"mc_integrate_3",  /* name of the function to add */
			argNames_integrate  /* list of the names of its args */
		);
		pfacesKernelFunction function_mc_integrate_3("mc_integrate_3", args_mc_integrate_3);
		function_mc_integrate_3.setArguments(args_mc_integrate_3);
		addKernelFunction(function_mc_integrate_3);
		
		/* creating the "integrate_4" kernel function (function 4) */
		pfacesKernelFunctionArguments args_mc_integrate_4 = pfacesKernelFunctionArguments::loadFromFile(
			mem_fingerprint_file,  /* name of the file to load the fingerprint from */
			"mc_integrate_4",  /* name of the function to add */
			argNames_integrate  /* list of the names of its args */
		);
		pfacesKernelFunction function_mc_integrate_4("mc_integrate_4", args_mc_integrate_4);
		function_mc_integrate_4.setArguments(args_mc_integrate_4);
		addKernelFunction(function_mc_integrate_4);
	}

	void pirk::configureParallelProgramMonteCarlo(pfacesParallelProgram& parallelProgram)
	{
		// A parallel advisor used for task scheduling
		pfacesParallelAdvisor parallelAdvisor(parallelProgram.getMachine(), parallelProgram.getTargetDevicesIndicies());

		/* This range specifies how the task is going to be split up. */
		cl::NDRange ndUniversalRangeStateDim(
			pfacesBigInt::getPrimitiveValue(nsamples),
			pfacesBigInt::getPrimitiveValue(states_dim)
		);
		/* note: if you want to use more or fewer dimensions than 2, you can still use this function.
		*       you just give it as many arguments as you want dimensions. */

		std::pair<cl::NDRange, cl::NDRange> stateDimProcessRangeAndOffset = parallelAdvisor.getProcessNDRangeAndOffset(ndUniversalRangeStateDim);
		cl::NDRange ndProcessRangeStateDim = stateDimProcessRangeAndOffset.first;
		cl::NDRange ndProcessOffsetStateDim = stateDimProcessRangeAndOffset.second;

		cl::NDRange ndUniversalOffsetStateDim = cl::NullRange;

		std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_mc_initialize;
		jobsPerDev_mc_initialize = parallelAdvisor.distributeJob(
				*this,
				0, /* function index */
				ndProcessRangeStateDim, /* process range */
				ndProcessOffsetStateDim,  /* process offset */
				parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
				parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
				true, false, false  /* some additional flags */
		);

		std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_mc_integrate_1;
		jobsPerDev_mc_integrate_1 = parallelAdvisor.distributeJob(
				*this,
				1, /* function index */
				ndProcessRangeStateDim, /* process range */
				ndProcessOffsetStateDim,  /* process offset */
				parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
				parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
				true, false, false  /* some additional flags */
		);

		std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_mc_integrate_2;
		jobsPerDev_mc_integrate_2 = parallelAdvisor.distributeJob(
				*this,
				2, /* function index */
				ndProcessRangeStateDim, /* process range */
				ndProcessOffsetStateDim,  /* process offset */
				parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
				parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
				true, false, false  /* some additional flags */
		);

		std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_mc_integrate_3;
		jobsPerDev_mc_integrate_3 = parallelAdvisor.distributeJob(
				*this,
				3, /* function index */
				ndProcessRangeStateDim, /* process range */
				ndProcessOffsetStateDim,  /* process offset */
				parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
				parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
				true, false, false  /* some additional flags */
		);

		std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_mc_integrate_4;
		jobsPerDev_mc_integrate_4 = parallelAdvisor.distributeJob(
				*this,
				4, /* function index */
				ndProcessRangeStateDim, /* process range */
				ndProcessOffsetStateDim,  /* process offset */
				parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
				parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
				true, false, false  /* some additional flags */
		);

		parallelAdvisor.printTaskSchedulingReport(
			parallelProgram.getMachine(),
			{
				"mc_initialize",
				"mc_integrate_1",
				"mc_integrate_2",
				"mc_integrate_3",
				"mc_integrate_4",
			},
			{
			jobsPerDev_mc_initialize,
				jobsPerDev_mc_integrate_1,
				jobsPerDev_mc_integrate_2,
				jobsPerDev_mc_integrate_3,
				jobsPerDev_mc_integrate_4,
			},
			ndUniversalRangeStateDim[0]
		);


		// ---------------------------------------------------------
		// MEMORY ALLOCATION
		// ---------------------------------------------------------
		/**/
		std::vector<std::pair<char*, size_t>> dataPool;
		pFacesMemoryAllocationReport memReport;
		memReport = allocateMemory(dataPool, parallelProgram.getMachine(), 
			parallelProgram.getTargetDevicesIndicies(),
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
			0,  /* index of the kernel function we're to read data from (0 in this case, since matrixAdd is index 0 */
			9  /* how many arguments it has (matrixAdd takes 3; the two matrices to add, and the result */
		);
		instr_readAllData->setAsReadAllDeviceData(jobReadAllData);

		std::shared_ptr<pfacesDeviceWriteJob> jobWriteAllData;
		std::shared_ptr<pfacesInstruction> instr_writeAllData = std::make_shared<pfacesInstruction>();
		jobWriteAllData = std::make_shared<pfacesDeviceWriteJob>(dataAccessDevice);
		jobWriteAllData->setKernelFunctionIdx(
			0,  /* index of the kernel function we're to write data to */
			9  /* how many arguments it has */
		);
		instr_writeAllData->setAsWriteAllDeviceData(jobWriteAllData);

		std::shared_ptr<pfacesInstruction> instrSyncPoint = std::make_shared<pfacesInstruction>();
		instrSyncPoint->setAsBlockingSyncPoint();

		std::shared_ptr<pfacesInstruction> instrLogOn = std::make_shared<pfacesInstruction>();
		instrLogOn->setAsLogOn();

		std::shared_ptr<pfacesInstruction> instrLogOff = std::make_shared<pfacesInstruction>();
		instrLogOff->setAsLogOff();

		std::shared_ptr<pfacesInstruction> instrHostSideFuncGenerateRandomNumbers = std::make_shared<pfacesInstruction>();
		instrHostSideFuncGenerateRandomNumbers->setAsHostFunction(mc_hostFunctionGenerateRandomNumbers, "mc_hostFunctionGenerateRandomNumbers");

		// INSTRUCTION: a start message
		std::shared_ptr<pfacesInstruction> instrMsg_start = std::make_shared<pfacesInstruction>();
		instrMsg_start->setAsMessage("The program has started (Mont-Carlo Method).");
		instrList.push_back(instrMsg_start);

		// INSTRUCTION: a message for random number
		std::shared_ptr<pfacesInstruction> instrMsg_rng = std::make_shared<pfacesInstruction>();
		instrMsg_rng->setAsMessage("Generating random numbers at Host-side (in parallel) ...");
		instrList.push_back(instrMsg_rng);

		// INSTRUCTION: host-side generation of random numbers
		instrList.push_back(instrSyncPoint);
		instrList.push_back(instrHostSideFuncGenerateRandomNumbers);
		

		// INSTRUCTION: write memory bags to devices
		// if not using th direct access to host memory, we write the data to the device memory
		// and followed by a barrier to sync among all device threads
		if (!parallelProgram.m_useHostMemory) {
			instrList.push_back(instr_writeAllData);
			if (parallelProgram.countTargetDevices() > 1)
			instrList.push_back(instrSyncPoint);
		}

		std::shared_ptr<pfacesInstruction> instrMsg0 = std::make_shared<pfacesInstruction>();
		instrMsg0->setAsMessage("Initializing integration...");
		instrList.push_back(instrMsg0);

		// INSTRUCTIONS: initializing for center integration
		for (size_t i = 0; i < jobsPerDev_mc_initialize.size(); i++) {
			std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
			tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_mc_initialize[i]);
			instrList.push_back(tmpExecuteInstr);
		}

		// INSTRUCTION: a sync point after initialization
		instrList.push_back(instrSyncPoint);

		std::shared_ptr<pfacesInstruction> instrMsg1 = std::make_shared<pfacesInstruction>();
		instrMsg1->setAsMessage("Performing integration...");
		instrList.push_back(instrMsg1);

		size_t rk4_nint = 5;
		size_t total_steps = nsteps * rk4_nint;


		int multiple_devices = parallelProgram.countTargetDevices() > 1;

		for (size_t w = 0; w < total_steps; w++) {

		// INSTRUCTIONS: Perform center integration
		for (size_t i = 0; i < jobsPerDev_mc_integrate_1.size(); i++) {
			std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
			tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_mc_integrate_1[i]);
			instrList.push_back(tmpExecuteInstr);
		}
		if (multiple_devices){
			instrList.push_back(instrSyncPoint);
		}
		// INSTRUCTIONS: Perform center integration
		for (size_t i = 0; i < jobsPerDev_mc_integrate_2.size(); i++) {
			std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
			tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_mc_integrate_2[i]);
			instrList.push_back(tmpExecuteInstr);
		}
		if (multiple_devices){
			instrList.push_back(instrSyncPoint);
		}

		// INSTRUCTIONS: Perform center integration
		for (size_t i = 0; i < jobsPerDev_mc_integrate_3.size(); i++) {
			std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
			tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_mc_integrate_3[i]);
			instrList.push_back(tmpExecuteInstr);
		}
		if (multiple_devices){
			instrList.push_back(instrSyncPoint);
		}

		// INSTRUCTIONS: Perform center integration
		for (size_t i = 0; i < jobsPerDev_mc_integrate_4.size(); i++) {
			std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
			tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_mc_integrate_4[i]);
			instrList.push_back(tmpExecuteInstr);
		}
		if (multiple_devices){
			instrList.push_back(instrSyncPoint);
		}

		}


		// INSTRUCTION: a sync point after center integration
		instrList.push_back(instrSyncPoint);

		std::shared_ptr<pfacesInstruction> instrMsg2 = std::make_shared<pfacesInstruction>();
		instrMsg2->setAsMessage("Initializing radius integration...");
		instrList.push_back(instrMsg2);

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
}
