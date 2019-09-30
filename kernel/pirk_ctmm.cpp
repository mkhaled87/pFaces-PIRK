#include <pfaces-sdk.h>
#include "pirk.h"

namespace pirk{

    void pirk::initializeCTMM(const std::shared_ptr<pfacesKernelLaunchState>& spLaunchState){

	std::string mem_fingerprint_file =
		spLaunchState->kernelPackPath + std::string("ctmm") +
		std::string(PFACES_PATH_SPLITTER) + std::string("ctmm.mem");

    /* ----------------------------------------------------------------------------------------------------------------------------- */
    /* begin code for creating the "initialize" kernel function (function 10) */
    pfacesKernelFunction function_ctmm_initialize(
        "ctmm_initialize",  /* name of the function to add */
        {"initial_state", "final_state", "input", "k0","k1","k2","k3","tmp", "t"}  /* list of the names of its args */
    );
    pfacesKernelFunctionArguments args_ctmm_initialize = pfacesKernelFunctionArguments::loadFromFile(
        mem_fingerprint_file,  /* name of the file to load the fingerprint from */
        "ctmm_initialize",  /* name of the function to add */
        {"initial_state", "final_state", "input", "k0","k1","k2","k3","tmp", "t"}  /* list of the names of its args */
    );
    function_ctmm_initialize.setArguments(args_ctmm_initialize);
    addKernelFunction(function_ctmm_initialize);
    /* end code for creating the "initialize_center" kernel function */
    /* ----------------------------------------------------------------------------------------------------------------------------- */

    /* ----------------------------------------------------------------------------------------------------------------------------- */
    /* begin code for creating the "integrate_1" kernel function (function 11) */
    pfacesKernelFunction function_ctmm_integrate_1(
        "ctmm_integrate_1",  /* name of the function to add */
        {"initial_state", "final_state", "input", "k0","k1","k2","k3","tmp", "t"}  /* list of the names of its args */
    );
    pfacesKernelFunctionArguments args_ctmm_integrate_1 = pfacesKernelFunctionArguments::loadFromFile(
        mem_fingerprint_file,  /* name of the file to load the fingerprint from */
        "ctmm_integrate_1",  /* name of the function to add */
        {"initial_state", "final_state", "input", "k0","k1","k2","k3","tmp", "t"}  /* list of the names of its args */
    );
    function_ctmm_integrate_1.setArguments(args_ctmm_integrate_1);
    addKernelFunction(function_ctmm_integrate_1);
    /* end code for creating the "integrate_1_center" kernel function */
    /* ----------------------------------------------------------------------------------------------------------------------------- */

    /* ----------------------------------------------------------------------------------------------------------------------------- */
    /* begin code for creating the "integrate_2" kernel function (function 12) */
    pfacesKernelFunction function_ctmm_integrate_2(
        "ctmm_integrate_2",  /* name of the function to add */
        {"initial_state", "final_state", "input", "k0","k1","k2","k3","tmp", "t"}  /* list of the names of its args */
    );
    pfacesKernelFunctionArguments args_ctmm_integrate_2 = pfacesKernelFunctionArguments::loadFromFile(
        mem_fingerprint_file,  /* name of the file to load the fingerprint from */
        "ctmm_integrate_2",  /* name of the function to add */
        {"initial_state", "final_state", "input", "k0","k1","k2","k3","tmp", "t"}  /* list of the names of its args */
    );
    function_ctmm_integrate_2.setArguments(args_ctmm_integrate_2);
    addKernelFunction(function_ctmm_integrate_2);
    /* end code for creating the "integrate_2_center" kernel function */
    /* ----------------------------------------------------------------------------------------------------------------------------- */

    /* ----------------------------------------------------------------------------------------------------------------------------- */
    /* begin code for creating the "integrate_3" kernel function (function 13) */
    pfacesKernelFunction function_ctmm_integrate_3(
        "ctmm_integrate_3",  /* name of the function to add */
        {"initial_state", "final_state", "input", "k0","k1","k2","k3","tmp", "t"}  /* list of the names of its args */
    );
    pfacesKernelFunctionArguments args_ctmm_integrate_3 = pfacesKernelFunctionArguments::loadFromFile(
        mem_fingerprint_file,  /* name of the file to load the fingerprint from */
        "ctmm_integrate_3",  /* name of the function to add */
        {"initial_state", "final_state", "input", "k0","k1","k2","k3","tmp", "t"}  /* list of the names of its args */
    );
    function_ctmm_integrate_3.setArguments(args_ctmm_integrate_3);
    addKernelFunction(function_ctmm_integrate_3);
    /* end code for creating the "integrate_3_center" kernel function */
    /* ----------------------------------------------------------------------------------------------------------------------------- */

    /* ----------------------------------------------------------------------------------------------------------------------------- */
    /* begin code for creating the "integrate_4" kernel function (function 14) */
    pfacesKernelFunction function_ctmm_integrate_4(
        "ctmm_integrate_4",  /* name of the function to add */
        {"initial_state", "final_state", "input", "k0","k1","k2","k3","tmp", "t"}  /* list of the names of its args */
    );
    pfacesKernelFunctionArguments args_ctmm_integrate_4 = pfacesKernelFunctionArguments::loadFromFile(
        mem_fingerprint_file,  /* name of the file to load the fingerprint from */
        "ctmm_integrate_4",  /* name of the function to add */
        {"initial_state", "final_state", "input", "k0","k1","k2","k3","tmp", "t"}  /* list of the names of its args */
    );
    function_ctmm_integrate_4.setArguments(args_ctmm_integrate_4);
    addKernelFunction(function_ctmm_integrate_4);
    /* end code for creating the "integrate_4_center" kernel function */
    /* ----------------------------------------------------------------------------------------------------------------------------- */

    }

    void pirk::configureParallelProgramCTMM(pfacesParallelProgram& parallelProgram){

    pfacesTerminal::showInfoMessage("Configuring the CTMM parallel program...");
    // A parallel advisor used for task scheduling
    pfacesParallelAdvisor parallelAdvisor(parallelProgram.getMachine(), parallelProgram.getTargetDevicesIndicies());

    /* This range specifies how the task is going to be split up. */
    pfacesTerminal::showInfoMessage(std::to_string(states_dim));
    cl::NDRange ndUniversalRangeStateDim(
        pfacesBigInt::getPrimitiveValue(2*states_dim),
        pfacesBigInt::getPrimitiveValue(1)  /* dummy value, no need for second dimension */
    );
    /* note: if you want to use more or fewer dimensions than 2, you can still use this function.
    *       you just give it as many arguments as you want dimensions. */

    std::pair<cl::NDRange, cl::NDRange> stateDimProcessRangeAndOffset = parallelAdvisor.getProcessNDRangeAndOffset(ndUniversalRangeStateDim);
    cl::NDRange ndProcessRangeStateDim = stateDimProcessRangeAndOffset.first;
    cl::NDRange ndProcessOffsetStateDim = stateDimProcessRangeAndOffset.second;

    cl::NDRange ndUniversalOffsetStateDim = cl::NullRange;

    std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_ctmm_initialize;
    jobsPerDev_ctmm_initialize = parallelAdvisor.distributeJob(
            *this,
            0, /* function index */
            ndProcessRangeStateDim, /* process range */
            ndProcessOffsetStateDim,  /* process offset */
            parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
            parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
            true, false, false  /* some additional flags */
    );

    std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_ctmm_integrate_1;
    jobsPerDev_ctmm_integrate_1 = parallelAdvisor.distributeJob(
            *this,
            1, /* function index */
            ndProcessRangeStateDim, /* process range */
            ndProcessOffsetStateDim,  /* process offset */
            parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
            parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
            true, false, false  /* some additional flags */
    );

    std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_ctmm_integrate_2;
    jobsPerDev_ctmm_integrate_2 = parallelAdvisor.distributeJob(
            *this,
            2, /* function index */
            ndProcessRangeStateDim, /* process range */
            ndProcessOffsetStateDim,  /* process offset */
            parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
            parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
            true, false, false  /* some additional flags */
    );

    std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_ctmm_integrate_3;
    jobsPerDev_ctmm_integrate_3 = parallelAdvisor.distributeJob(
            *this,
            3, /* function index */
            ndProcessRangeStateDim, /* process range */
            ndProcessOffsetStateDim,  /* process offset */
            parallelProgram.m_isFixedJobDistribution, /* whether or not to use a fixed job distribution, or to tune automatically */
            parallelProgram.m_fixedJobDistribution, /* the fixed distribution, if one is being used */
            true, false, false  /* some additional flags */
    );

    std::vector<std::shared_ptr<pfacesDeviceExecuteJob>> jobsPerDev_ctmm_integrate_4;
    jobsPerDev_ctmm_integrate_4 = parallelAdvisor.distributeJob(
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
        "ctmm_initialize",
            "ctmm_integrate_1",
            "ctmm_integrate_2",
            "ctmm_integrate_3",
            "ctmm_integrate_4",
        },
        {
        jobsPerDev_ctmm_initialize,
            jobsPerDev_ctmm_integrate_1,
            jobsPerDev_ctmm_integrate_2,
            jobsPerDev_ctmm_integrate_3,
            jobsPerDev_ctmm_integrate_4,
        },
        ndUniversalRangeStateDim[0]
    );


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
    instrMsg_start->setAsMessage("The program has started (CTMM Method).");
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
    instrMsg0->setAsMessage("Initializing integration...");
    instrList.push_back(instrMsg0);

    // INSTRUCTIONS: initializing for center integration
    for (size_t i = 0; i < jobsPerDev_ctmm_initialize.size(); i++) {
        std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
        tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_ctmm_initialize[i]);
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
        for (size_t i = 0; i < jobsPerDev_ctmm_integrate_1.size(); i++) {
            std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
            tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_ctmm_integrate_1[i]);
            instrList.push_back(tmpExecuteInstr);
        }
        if (multiple_devices){
            instrList.push_back(instrSyncPoint);
        }
        // INSTRUCTIONS: Perform center integration
        for (size_t i = 0; i < jobsPerDev_ctmm_integrate_2.size(); i++) {
            std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
            tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_ctmm_integrate_2[i]);
            instrList.push_back(tmpExecuteInstr);
        }
        if (multiple_devices){
            instrList.push_back(instrSyncPoint);
        }

        // INSTRUCTIONS: Perform center integration
        for (size_t i = 0; i < jobsPerDev_ctmm_integrate_3.size(); i++) {
            std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
            tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_ctmm_integrate_3[i]);
            instrList.push_back(tmpExecuteInstr);
        }
        if (multiple_devices){
            instrList.push_back(instrSyncPoint);
        }

        // INSTRUCTIONS: Perform center integration
        for (size_t i = 0; i < jobsPerDev_ctmm_integrate_4.size(); i++) {
            std::shared_ptr<pfacesInstruction> tmpExecuteInstr = std::make_shared<pfacesInstruction>();
            tmpExecuteInstr->setAsDeviceExecute(jobsPerDev_ctmm_integrate_4[i]);
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

}  /* end of pirk namespace */
