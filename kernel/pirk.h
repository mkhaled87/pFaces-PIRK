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

	// function: saveBufferToFile
	void saveBufferToFile(const pfacesParallelProgram& thisParallelProgram, char* pData, size_t pDataSize, std::string fileTag);

	// class: pirk
	class pirk : public pfaces2DKernel {
	private:
		const std::shared_ptr<pfacesConfigurationReader> m_spCfg;

		/* sub-buffers */
		std::vector<std::pair<size_t, size_t>> SubBufers_GB_0_initialize_center_0_initial_state;
		std::vector<std::pair<size_t, size_t>> SubBufers_GB_0_initialize_center_1_final_state;
		std::vector<std::pair<size_t, size_t>> SubBufers_GB_0_initialize_center_2_input;
		std::vector<std::pair<size_t, size_t>> SubBufers_GB_0_initialize_center_3_k0;
		std::vector<std::pair<size_t, size_t>> SubBufers_GB_0_initialize_center_4_k1;
		std::vector<std::pair<size_t, size_t>> SubBufers_GB_0_initialize_center_5_k2;
		std::vector<std::pair<size_t, size_t>> SubBufers_GB_0_initialize_center_6_k3;
		std::vector<std::pair<size_t, size_t>> SubBufers_GB_0_initialize_center_7_tmp;
		std::vector<std::pair<size_t, size_t>> SubBufers_GB_5_initialize_radius_1_final_state;
		std::vector<std::pair<size_t, size_t>> SubBufers_GB_6_compute_contraction_matrix_0_cidxs;
		std::vector<std::pair<size_t, size_t>> SubBufers_GB_6_compute_contraction_matrix_1_cvals;
		std::vector<std::pair<size_t, size_t>> SubBufers_GB_6_compute_contraction_matrix_2_ncel;


	public:
		/* some vars for local storage */
		size_t states_dim;
		size_t inputs_dim;
		size_t method_choice;
		float integration_time;
		size_t nsteps;
		size_t nsamples;
		size_t row_max;
		float true_step_size;
		std::string dynamics_element_code;
		std::string method_choice_err;

		pirk(const std::shared_ptr<pfacesKernelLaunchState>& spLaunchState, const std::shared_ptr<pfacesConfigurationReader>& spCfg);
		~pirk() = default;

		void configureParameters(std::vector<std::string> params, std::vector<std::string> paramvals);
		void configureParallelProgram(pfacesParallelProgram& parallelProgram);
		void configureTuneParallelProgram(pfacesParallelProgram& tuneParallelProgram, size_t targetFunctionIdx);

		void initializeGrowthBound(const std::shared_ptr<pfacesKernelLaunchState>& spLaunchState);
		void configureParallelProgramGrowthBound(pfacesParallelProgram& parallelProgram);

		void initializeCTMM(const std::shared_ptr<pfacesKernelLaunchState>& spLaunchState);
		void configureParallelProgramCTMM(pfacesParallelProgram& parallelProgram);

		void initializeMonteCarlo(const std::shared_ptr<pfacesKernelLaunchState>& spLaunchState);
		void configureParallelProgramMonteCarlo(pfacesParallelProgram& parallelProgram);

	};

}

#endif /* PFACES_KERNEL_PIRK_H_ */
