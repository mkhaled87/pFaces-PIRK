#include <pfaces-sdk.h>
#include "pirk.h"

namespace pirk{

	std::vector<concrete_t> gb_pipe_center;
	std::vector<concrete_t> gb_pipe_radius;

	// host-side functions to updae the pipe storage
	size_t hfUpdatePipe_center(void* pPackedKernel, void* pPackedParallelProgram){

		static pfacesParallelProgram*  pParallelProgram = (pfacesParallelProgram*)pPackedParallelProgram;
		static pirk* pKernel = (pirk*)pPackedKernel;	
		static concrete_t* pCenter	= (concrete_t*)pParallelProgram->m_dataPool[1].first;	
		static size_t current_step = 0;

		/* first time initialize */
		if(current_step == 0)
			gb_pipe_center.resize(pKernel->nsteps*pKernel->states_dim);		

		/* record in the pipe */
		for(size_t i=0; i<pKernel->states_dim; i++)
			gb_pipe_center.data()[current_step*pKernel->states_dim + i] = pCenter[i];

		current_step++;

		return 0;
	}
	size_t hfUpdatePipe_radius(void* pPackedKernel, void* pPackedParallelProgram){

		static pfacesParallelProgram*  pParallelProgram = (pfacesParallelProgram*)pPackedParallelProgram;
		static pirk* pKernel = (pirk*)pPackedKernel;	
		static concrete_t* pRadius	= (concrete_t*)pParallelProgram->m_dataPool[9].first;	
		static size_t current_step = 0;

		/* first time initialize */
		if(current_step == 0)
			gb_pipe_radius.resize(pKernel->nsteps*pKernel->states_dim);		

		/* record in the pipe */
		for (size_t i = 0; i < pKernel->states_dim; i++)
			gb_pipe_radius.data()[current_step * pKernel->states_dim + i] = pRadius[i];

		current_step++;

		return 0;
	}	


	// A post-execcute functions to save the data
	// -----------------------------------------------
	size_t gb_saveData(
		const pfaces2DKernel& thisKernel,
		const pfacesParallelProgram& thisParallelProgram,
		std::vector<std::shared_ptr<void>>& postExecuteParamsList) {

		(void)thisKernel;
		(void)postExecuteParamsList;

		saveBufferToFile(thisParallelProgram, thisParallelProgram.m_dataPool[1].first, thisParallelProgram.m_dataPool[1].second, "result_gb_center");
		saveBufferToFile(thisParallelProgram, thisParallelProgram.m_dataPool[9].first, thisParallelProgram.m_dataPool[9].second, "result_gb_radius");

		if(((pirk*)(&thisKernel))->record_pipe){
			saveBufferToFile(thisParallelProgram, (char*)gb_pipe_center.data(), gb_pipe_center.size()*sizeof(concrete_t), "result_gb_center_pipe");
			saveBufferToFile(thisParallelProgram, (char*)gb_pipe_radius.data(), gb_pipe_radius.size()*sizeof(concrete_t), "result_gb_radius_pipe");
		}

		return 0;
	}

	/* the growth bound constructor */
	void pirk::initializeGrowthBound(const std::shared_ptr<pfacesKernelLaunchState>& spLaunchState){

		std::string mem_fingerprint_file = 
			spLaunchState->getKernelPackPath() + std::string("growth_bound") + 
			std::string(PFACES_PATH_SPLITTER) + std::string("gb.mem");

		mem_efficient = m_spCfg->readConfigValueBool("mem_efficient");


		/* some constants */
		std::vector<std::string> argNames_center;
		std::vector<std::string> argNames_radius;
		argNames_center = { "initial_state", "final_state", "input", "k0","k1","k2","k3","tmp", "t" };
		if (!mem_efficient) {
			argNames_radius = { "initial_state", "final_state", "input", "k0","k1","k2","k3","tmp", "t", "cidxs", "cvals", "ncel" };
		}
		else {
			argNames_radius = { "initial_state", "final_state", "input", "k0","k1","k2","k3","tmp", "t" };
		}

	  
		/* creating the "initialize_center" kernel function (function 0) */
		pfacesKernelFunctionArguments args_gb_initialize_center = pfacesKernelFunctionArguments::loadFromFile(
			mem_fingerprint_file,  /* name of the file to load the fingerprint from */
			"gb_initialize_center",  /* name of the function to add */
			argNames_center  /* list of the names of its args */
		);
		pfacesKernelFunction function_gb_initialize_center("gb_initialize_center", args_gb_initialize_center);
		addKernelFunction(function_gb_initialize_center);

		/* creating the "gb_integrate_center_1" kernel function (function 1) */
		pfacesKernelFunctionArguments args_gb_integrate_center_1 = pfacesKernelFunctionArguments::loadFromFile(
			mem_fingerprint_file,  /* name of the file to load the fingerprint from */
			"gb_integrate_center_1",  /* name of the function to add */
			argNames_center  /* list of the names of its args */
		);
		pfacesKernelFunction function_gb_integrate_center_1("gb_integrate_center_1", args_gb_integrate_center_1);
		addKernelFunction(function_gb_integrate_center_1);

		/* creating the "gb_integrate_center_2" kernel function (function 2) */
		pfacesKernelFunctionArguments args_gb_integrate_center_2 = pfacesKernelFunctionArguments::loadFromFile(
			mem_fingerprint_file,  /* name of the file to load the fingerprint from */
			"gb_integrate_center_2",  /* name of the function to add */
			argNames_center  /* list of the names of its args */
		);
		pfacesKernelFunction function_gb_integrate_center_2("gb_integrate_center_2", args_gb_integrate_center_2);
		addKernelFunction(function_gb_integrate_center_2);

		/* creating the "gb_integrate_center_3" kernel function (function 3) */
		pfacesKernelFunctionArguments args_gb_integrate_center_3 = pfacesKernelFunctionArguments::loadFromFile(
			mem_fingerprint_file,  /* name of the file to load the fingerprint from */
			"gb_integrate_center_3",  /* name of the function to add */
			argNames_center  /* list of the names of its args */
		);
		pfacesKernelFunction function_gb_integrate_center_3("gb_integrate_center_3", args_gb_integrate_center_3);
		addKernelFunction(function_gb_integrate_center_3);

		/* creating the "gb_integrate_center_4" kernel function (function 4) */	  
		pfacesKernelFunctionArguments args_gb_integrate_center_4 = pfacesKernelFunctionArguments::loadFromFile(
			mem_fingerprint_file,  /* name of the file to load the fingerprint from */
			"gb_integrate_center_4",  /* name of the function to add */
			argNames_center  /* list of the names of its args */
		);
		pfacesKernelFunction function_gb_integrate_center_4("gb_integrate_center_4", args_gb_integrate_center_4);
		addKernelFunction(function_gb_integrate_center_4);

		/* creating the "gb_gb_initialize_radius" kernel function (function 5) */	  
		pfacesKernelFunctionArguments args_gb_initialize_radius = pfacesKernelFunctionArguments::loadFromFile(
			mem_fingerprint_file,  /* name of the file to load the fingerprint from */
			"gb_initialize_radius",  /* name of the function to add */
			argNames_center  /* list of the names of its args */
		);
		pfacesKernelFunction function_gb_initialize_radius("gb_initialize_radius", args_gb_initialize_radius);
		addKernelFunction(function_gb_initialize_radius);
	  
		/* creating the "compute_contraction_matrix" kernel function (function 6) */
		if(!mem_efficient){		  
			pfacesKernelFunctionArguments args_gb_compute_contraction_matrix = pfacesKernelFunctionArguments::loadFromFile(
				mem_fingerprint_file,  /* name of the file to load the fingerprint from */
				"gb_compute_contraction_matrix",  /* name of the function to add */
				{"cidxs", "cvals", "ncel"}  /* list of the names of its args */
			);
			size_t size_cidxs = row_max * sizeof(cl_int);
			size_t size_cvals = row_max * sizeof(float);
			size_t size_ncel =  sizeof(cl_int);
			args_gb_compute_contraction_matrix.m_baseTypeSize = {size_cidxs,size_cvals,size_ncel};
			pfacesKernelFunction function_gb_compute_contraction_matrix("gb_compute_contraction_matrix", args_gb_compute_contraction_matrix);
			addKernelFunction(function_gb_compute_contraction_matrix);
		}
	  
		/* creating the "gb_integrate_radius_1" kernel function (function 7) */
		pfacesKernelFunctionArguments args_gb_integrate_radius_1 = pfacesKernelFunctionArguments::loadFromFile(
			mem_fingerprint_file,  /* name of the file to load the fingerprint from */
			"gb_integrate_radius_1",  /* name of the function to add */
			argNames_radius  /* list of the names of its args */
		);
		pfacesKernelFunction function_gb_integrate_radius_1("gb_integrate_radius_1",args_gb_integrate_radius_1);
		addKernelFunction(function_gb_integrate_radius_1);

		/* creating the "gb_integrate_radius_2" kernel function (function 8) */
		pfacesKernelFunctionArguments args_gb_integrate_radius_2 = pfacesKernelFunctionArguments::loadFromFile(
			mem_fingerprint_file,  /* name of the file to load the fingerprint from */
			"gb_integrate_radius_2",  /* name of the function to add */
			argNames_radius  /* list of the names of its args */
		);
		pfacesKernelFunction function_gb_integrate_radius_2("gb_integrate_radius_2",  /* name of the function to add */args_gb_integrate_radius_2);
		addKernelFunction(function_gb_integrate_radius_2);

		/* creating the "gb_integrate_radius_3" kernel function (function 9) */	  
		pfacesKernelFunctionArguments args_gb_integrate_radius_3 = pfacesKernelFunctionArguments::loadFromFile(
			mem_fingerprint_file,  /* name of the file to load the fingerprint from */
			"gb_integrate_radius_3",  /* name of the function to add */
			argNames_radius  /* list of the names of its args */
		);
		pfacesKernelFunction function_gb_integrate_radius_3("gb_integrate_radius_3",  args_gb_integrate_radius_3);
		addKernelFunction(function_gb_integrate_radius_3);

		/* creating the "gb_integrate_radius_4" kernel function (function 10) */
		pfacesKernelFunctionArguments args_gb_integrate_radius_4 = pfacesKernelFunctionArguments::loadFromFile(
			mem_fingerprint_file,  /* name of the file to load the fingerprint from */
			"gb_integrate_radius_4",  /* name of the function to add */
			argNames_radius  /* list of the names of its args */
		);
		pfacesKernelFunction function_gb_integrate_radius_4("gb_integrate_radius_4", args_gb_integrate_radius_4);
		addKernelFunction(function_gb_integrate_radius_4);

	}

	/* the growth bound configutrator */
	void pirk::configureParallelProgramGrowthBound(pfacesParallelProgram& parallelProgram){

		bool multiple_devices = parallelProgram.countTargetDevices() > 1;

		// A parallel advisor used for task scheduling
		pfacesParallelAdvisor parallelAdvisor(parallelProgram.getMachine(), parallelProgram.getTargetDevicesIndicies());

		/* This range specifies how the task is going to be split up. */
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

		std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_gb_integrate_center_1;
		jobsPerDev_gb_integrate_center_1 = parallelAdvisor.distributeJob(
				*this,
				1, /* function index */
				ndProcessRangeStateDim, /* process range */
				ndProcessOffsetStateDim,  /* process offset */
				parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
				parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
				true, false, false  /* some additional flags */
		);

		std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_gb_integrate_center_2;
		jobsPerDev_gb_integrate_center_2 = parallelAdvisor.distributeJob(
				*this,
				2, /* function index */
				ndProcessRangeStateDim, /* process range */
				ndProcessOffsetStateDim,  /* process offset */
				parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
				parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
				true, false, false  /* some additional flags */
		);

		std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_gb_integrate_center_3;
		jobsPerDev_gb_integrate_center_3 = parallelAdvisor.distributeJob(
				*this,
				3, /* function index */
				ndProcessRangeStateDim, /* process range */
				ndProcessOffsetStateDim,  /* process offset */
				parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
				parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
				true, false, false  /* some additional flags */
		);

		std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_gb_integrate_center_4;
		jobsPerDev_gb_integrate_center_4 = parallelAdvisor.distributeJob(
				*this,
				4, /* function index */
				ndProcessRangeStateDim, /* process range */
				ndProcessOffsetStateDim,  /* process offset */
				parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
				parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
				true, false, false  /* some additional flags */
		);


		std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_gb_initialize_radius;
		jobsPerDev_gb_initialize_radius = parallelAdvisor.distributeJob(
				*this,
				5, /* function index */
				ndProcessRangeStateDim, /* process range */
				ndProcessOffsetStateDim,  /* process offset */
				parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
				parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
				true, false, false  /* some additional flags */
		);

		std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_gb_compute_contraction_matrix;
		int shift = 0;
		if (!mem_efficient) {
			jobsPerDev_gb_compute_contraction_matrix = parallelAdvisor.distributeJob(
				*this,
				6, /* function index */
				ndProcessRangeStateDim, /* process range */
				ndProcessOffsetStateDim,  /* process offset */
				parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
				parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
				true, false, false  /* some additional flags */
			);
		}
		else {
			shift = -1;
		}

		std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_gb_integrate_radius_1;
		jobsPerDev_gb_integrate_radius_1 = parallelAdvisor.distributeJob(
				*this,
				7 + shift, /* function index */
				ndProcessRangeStateDim, /* process range */
				ndProcessOffsetStateDim,  /* process offset */
				parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
				parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
				true, false, false  /* some additional flags */
		);

		std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_gb_integrate_radius_2;
		jobsPerDev_gb_integrate_radius_2 = parallelAdvisor.distributeJob(
				*this,
				8 + shift, /* function index */
				ndProcessRangeStateDim, /* process range */
				ndProcessOffsetStateDim,  /* process offset */
				parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
				parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
				true, false, false  /* some additional flags */
		);

		std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_gb_integrate_radius_3;
		jobsPerDev_gb_integrate_radius_3 = parallelAdvisor.distributeJob(
				*this,
				9 + shift, /* function index */
				ndProcessRangeStateDim, /* process range */
				ndProcessOffsetStateDim,  /* process offset */
				parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
				parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
				true, false, false  /* some additional flags */
		);

		std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_gb_integrate_radius_4;
		jobsPerDev_gb_integrate_radius_4 = parallelAdvisor.distributeJob(
				*this,
				10 + shift, /* function index */
				ndProcessRangeStateDim, /* process range */
				ndProcessOffsetStateDim,  /* process offset */
				parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
				parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
				true, false, false  /* some additional flags */
		);


		// print the task-scheduling report
		if (!mem_efficient) {
			parallelAdvisor.printTaskSchedulingReport(
				parallelProgram.getMachine(),
				{
					"gb_initialize_center",
					"gb_integrate_center_1",
					"gb_integrate_center_2",
					"gb_integrate_center_3",
					"gb_integrate_center_4",
					"gb_initialize_radius",
					"gb_compute_contraction_matrix",
					"gb_integrate_radius_1",
					"gb_integrate_radius_2",
					"gb_integrate_radius_3",
					"gb_integrate_radius_4",
				},
			{
			jobsPerDev_gb_initialize_center,
				jobsPerDev_gb_integrate_center_1,
				jobsPerDev_gb_integrate_center_2,
				jobsPerDev_gb_integrate_center_3,
				jobsPerDev_gb_integrate_center_4,
				jobsPerDev_gb_initialize_radius,
				jobsPerDev_gb_compute_contraction_matrix,
				jobsPerDev_gb_integrate_radius_1,
				jobsPerDev_gb_integrate_radius_2,
				jobsPerDev_gb_integrate_radius_3,
				jobsPerDev_gb_integrate_radius_4,
			},
			ndUniversalRangeStateDim[0]
			);
		}
		else {
			parallelAdvisor.printTaskSchedulingReport(
				parallelProgram.getMachine(),
				{
					"gb_initialize_center",
					"gb_integrate_center_1",
					"gb_integrate_center_2",
					"gb_integrate_center_3",
					"gb_integrate_center_4",
					"gb_initialize_radius",
					"gb_integrate_radius_1",
					"gb_integrate_radius_2",
					"gb_integrate_radius_3",
					"gb_integrate_radius_4",
				},
			{
			jobsPerDev_gb_initialize_center,
				jobsPerDev_gb_integrate_center_1,
				jobsPerDev_gb_integrate_center_2,
				jobsPerDev_gb_integrate_center_3,
				jobsPerDev_gb_integrate_center_4,
				jobsPerDev_gb_initialize_radius,
				jobsPerDev_gb_integrate_radius_1,
				jobsPerDev_gb_integrate_radius_2,
				jobsPerDev_gb_integrate_radius_3,
				jobsPerDev_gb_integrate_radius_4,
			},
			ndUniversalRangeStateDim[0]
			);
		}


		// ---------------------------------------------------------
		// MEMORY ALLOCATION
		// ---------------------------------------------------------
		std::vector<std::pair<char*, size_t>> dataPool;
		pFacesMemoryAllocationReport memReport;
		memReport = allocateMemory(dataPool, parallelProgram.getMachine(), parallelProgram.getTargetDevicesIndicies(),
					pfacesUtils::oclGetRangeVolume(ndProcessRangeStateDim), false);
		memReport.PrintReport();


		// ---------------------------------------------------------
		// SUB-BUFFERS
		// ---------------------------------------------------------
		if (multiple_devices) {
			SubBufers_GB_0_initialize_center_0_initial_state	= getSubBuffers(jobsPerDev_gb_initialize_center, 0, 0, memReport.bufferFinalSize[0], 1);
			SubBufers_GB_0_initialize_center_1_final_state		= getSubBuffers(jobsPerDev_gb_initialize_center, 0, 1, memReport.bufferFinalSize[1], 1);
			SubBufers_GB_0_initialize_center_2_input			= getSubBuffers(jobsPerDev_gb_initialize_center, 0, 2, memReport.bufferFinalSize[2], 1);
			SubBufers_GB_0_initialize_center_3_k0				= getSubBuffers(jobsPerDev_gb_initialize_center, 0, 3, memReport.bufferFinalSize[3], 1);
			SubBufers_GB_0_initialize_center_4_k1				= getSubBuffers(jobsPerDev_gb_initialize_center, 0, 4, memReport.bufferFinalSize[4], 1);
			SubBufers_GB_0_initialize_center_5_k2				= getSubBuffers(jobsPerDev_gb_initialize_center, 0, 5, memReport.bufferFinalSize[5], 1);
			SubBufers_GB_0_initialize_center_6_k3				= getSubBuffers(jobsPerDev_gb_initialize_center, 0, 6, memReport.bufferFinalSize[6], 1);
			SubBufers_GB_0_initialize_center_7_tmp				= getSubBuffers(jobsPerDev_gb_initialize_center, 0, 7, memReport.bufferFinalSize[7], 1);
			SubBufers_GB_5_initialize_radius_1_final_state		= getSubBuffers(jobsPerDev_gb_initialize_radius, 5, 1, memReport.bufferFinalSize[9], 1);
			if (!mem_efficient) {
				SubBufers_GB_6_compute_contraction_matrix_0_cidxs = getSubBuffers(jobsPerDev_gb_compute_contraction_matrix, 6, 0, memReport.bufferFinalSize[10], 1);
				SubBufers_GB_6_compute_contraction_matrix_1_cvals = getSubBuffers(jobsPerDev_gb_compute_contraction_matrix, 6, 1, memReport.bufferFinalSize[11], 1);
				SubBufers_GB_6_compute_contraction_matrix_2_ncel = getSubBuffers(jobsPerDev_gb_compute_contraction_matrix, 6, 2, memReport.bufferFinalSize[12], 1);
			}

			// printing the sub-buffering report
			if (!mem_efficient) {
				parallelAdvisor.printSubBufferingReport(
					{ "gb_initialize_center",	"gb_integrate_center_1",	"gb_integrate_center_2",	"gb_integrate_center_3",	"gb_integrate_center_4",
					  "gb_initialize_radius",	"gb_compute_contraction_matrix",	"gb_integrate_radius_1",	"gb_integrate_radius_2",
					  "gb_integrate_radius_3",	"gb_integrate_radius_4" },

					{ 0,					0,						0,						0,						0,
						0,					0,						0,						5,
						6,					6,						6 },

					{ 0,					1,						2,						3,						4,
						5,					6,						7,						1,
						0,					1,						2 },

					{ 9,					9,						9,						9,						9,
						9,					9,						9,						9,
						3,					3,						3 },

				{
					SubBufers_GB_0_initialize_center_0_initial_state,
					SubBufers_GB_0_initialize_center_1_final_state,
					SubBufers_GB_0_initialize_center_2_input,
					SubBufers_GB_0_initialize_center_3_k0,
					SubBufers_GB_0_initialize_center_4_k1,
					SubBufers_GB_0_initialize_center_5_k2,
					SubBufers_GB_0_initialize_center_6_k3,
					SubBufers_GB_0_initialize_center_7_tmp,
					SubBufers_GB_5_initialize_radius_1_final_state,
					SubBufers_GB_6_compute_contraction_matrix_0_cidxs,
					SubBufers_GB_6_compute_contraction_matrix_1_cvals,
					SubBufers_GB_6_compute_contraction_matrix_2_ncel
				}
				);
			}
			else {
				parallelAdvisor.printSubBufferingReport(
					{ "gb_initialize_center",	"gb_integrate_center_1",	"gb_integrate_center_2",	"gb_integrate_center_3",	"gb_integrate_center_4",
					  "gb_initialize_radius",	"gb_integrate_radius_1",	"gb_integrate_radius_2",	"gb_integrate_radius_3",	"gb_integrate_radius_4" },

					{ 0,					0,						0,						0,						0,
						0,					0,						0,						5},

					{ 0,					1,						2,						3,						4,
						5,					6,						7,						1},

					{ 9,					9,						9,						9,						9,
						9,					9,						9,						9},

				{
					SubBufers_GB_0_initialize_center_0_initial_state,
					SubBufers_GB_0_initialize_center_1_final_state,
					SubBufers_GB_0_initialize_center_2_input,
					SubBufers_GB_0_initialize_center_3_k0,
					SubBufers_GB_0_initialize_center_4_k1,
					SubBufers_GB_0_initialize_center_5_k2,
					SubBufers_GB_0_initialize_center_6_k3,
					SubBufers_GB_0_initialize_center_7_tmp,
					SubBufers_GB_5_initialize_radius_1_final_state
				}
				);
			}

		}
		
		if(multiple_devices)
			throw std::runtime_error("--- stopped here ----");

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

		std::shared_ptr<pfacesInstruction> instrHostUpdatePipe_center = std::make_shared<pfacesInstruction>();
		std::shared_ptr<pfacesInstruction> instrHostUpdatePipe_radius = std::make_shared<pfacesInstruction>();
		instrHostUpdatePipe_center->setAsHostFunction(hfUpdatePipe_center, "hfUpdatePipe_center");
		instrHostUpdatePipe_radius->setAsHostFunction(hfUpdatePipe_radius, "hfUpdatePipe_radius");


		// INSTRUCTION: a start message
		std::shared_ptr<pfacesInstruction> instrMsg_start = std::make_shared<pfacesInstruction>();
		instrMsg_start->setAsMessage("The program has started (Grouth-bound Method).");
		instrList.push_back(instrMsg_start);

		// INSTRUCTION: write memory bags to devices
		// if not using th direct access to host memory, we write the data to the device memory
		// and followed by a barrier to sync among all device threads
		if (!parallelProgram.m_useHostMemory) {
			instrList.push_back(instr_writeAllData);
			if (multiple_devices)
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

		size_t rk4_nint = 5;
		size_t total_steps = nsteps * rk4_nint;

		// INSTRUCTIONS: Perform center integration
		for (size_t w = 0; w < total_steps; w++) {

			// INSTRUCTIONS: Perform center integration 1
			for (size_t i = 0; i < jobsPerDev_gb_integrate_center_1.size(); i++) {
				std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
				tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_gb_integrate_center_1[i]);
				instrList.push_back(tmpExecuteInstr);
			}
			if (multiple_devices){
				instrList.push_back(instrSyncPoint);
			}
			// INSTRUCTIONS: Perform center integration 2
			for (size_t i = 0; i < jobsPerDev_gb_integrate_center_2.size(); i++) {
				std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
				tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_gb_integrate_center_2[i]);
				instrList.push_back(tmpExecuteInstr);
			}
			if (multiple_devices){
				instrList.push_back(instrSyncPoint);
			}

			// INSTRUCTIONS: Perform center integration 3
			for (size_t i = 0; i < jobsPerDev_gb_integrate_center_3.size(); i++) {
				std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
				tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_gb_integrate_center_3[i]);
				instrList.push_back(tmpExecuteInstr);
			}
			if (multiple_devices){
				instrList.push_back(instrSyncPoint);
			}

			// INSTRUCTIONS: Perform center integration 4
			for (size_t i = 0; i < jobsPerDev_gb_integrate_center_4.size(); i++) {
				std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
				tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_gb_integrate_center_4[i]);
				instrList.push_back(tmpExecuteInstr);
			}
			if (multiple_devices){
				instrList.push_back(instrSyncPoint);
			}

			// should i record the latest center in the pipe data ?
			if(save_result && record_pipe && (w%rk4_nint == 0)){	
				instrList.push_back(instr_readAllData);
				instrList.push_back(instrSyncPoint);
				instrList.push_back(instrHostUpdatePipe_center);
			}
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


		if (!mem_efficient) {
			// INSTRUCTION: a sync point after initialization
			instrList.push_back(instrSyncPoint);

			std::shared_ptr<pfacesInstruction> instrMsgSp = std::make_shared<pfacesInstruction>();
			instrMsgSp->setAsMessage("Computing sparse representation of contraction matrix...");
			instrList.push_back(instrMsgSp);
			// INSTRUCTIONS: computing the sparse contraction matrix
			for (size_t i = 0; i < jobsPerDev_gb_compute_contraction_matrix.size(); i++) {
				std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
				tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_gb_compute_contraction_matrix[i]);
				instrList.push_back(tmpExecuteInstr);
			}
		}

		// INSTRUCTION: a sync point after computing the contraction matrix
		instrList.push_back(instrSyncPoint);

		std::shared_ptr<pfacesInstruction> instrMsg3 = std::make_shared<pfacesInstruction>();
		instrMsg3->setAsMessage("Performing radius integration...");
		instrList.push_back(instrMsg3);

		// INSTRUCTIONS: Perform radius integration
		for (size_t w = 0; w < total_steps; w++) {

			// INSTRUCTIONS: Perform radius integration 1
			for (size_t i = 0; i < jobsPerDev_gb_integrate_radius_1.size(); i++) {
				std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
				tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_gb_integrate_radius_1[i]);
				instrList.push_back(tmpExecuteInstr);
			}
			if (multiple_devices){
				instrList.push_back(instrSyncPoint);
			}

			// INSTRUCTIONS: Perform radius integration 2
			for (size_t i = 0; i < jobsPerDev_gb_integrate_radius_2.size(); i++) {
				std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
				tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_gb_integrate_radius_2[i]);
				instrList.push_back(tmpExecuteInstr);
			}
			if (multiple_devices){
				instrList.push_back(instrSyncPoint);
			}

			// INSTRUCTIONS: Perform radius integration 3
			for (size_t i = 0; i < jobsPerDev_gb_integrate_radius_3.size(); i++) {
				std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
				tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_gb_integrate_radius_3[i]);
				instrList.push_back(tmpExecuteInstr);
			}
			if (multiple_devices){
				instrList.push_back(instrSyncPoint);
			}

			// INSTRUCTIONS: Perform radius integration 4
			for (size_t i = 0; i < jobsPerDev_gb_integrate_radius_4.size(); i++) {
				std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
				tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_gb_integrate_radius_4[i]);
				instrList.push_back(tmpExecuteInstr);
			}
			if (multiple_devices){
				instrList.push_back(instrSyncPoint);
			}

			// should i record the latest radius in the pipe data ?
			if(save_result && record_pipe && (w%rk4_nint == 0)){
				instrList.push_back(instr_readAllData);
				instrList.push_back(instrSyncPoint);
				instrList.push_back(instrHostUpdatePipe_radius);
			}			
		}

		// INSTRUCTION: read memory bags from devices
		// if not using direct access to host memory, we write the data to the device memory
		// and followed by a barrier to sync among all device threads
		if (!parallelProgram.m_useHostMemory) {
			instrList.push_back(instr_readAllData);
			if (multiple_devices)
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
