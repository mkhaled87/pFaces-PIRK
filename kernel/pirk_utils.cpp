#include <pfaces-sdk.h>
#include <iostream>
#include "pirk.h"

namespace pirk{
	void pirk::configureParameters(std::vector<std::string> params, std::vector<std::string> paramvals){
	  //int method_choice;
	  int method_choice;
	  method_choice = std::stoi(m_spCfg->readConfigValueString("method_choice"));
	  params.push_back("@@method_choice@@");
	  paramvals.push_back(std::to_string(method_choice));

	  nsamples = std::stoi(m_spCfg->readConfigValueString("nsamples"));
	  params.push_back("@@nsamples@@");
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
	  float true_step_size;
	  integration_time = final_time - initial_time;
	  nsteps = (size_t)ceil(integration_time / step_size);
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

	  std::string dynamics_element_code;
	  dynamics_element_code = m_spCfg->readConfigValueString("dynamics_element_code");
	  params.push_back("@@dynamics_element_code@@");
	  paramvals.push_back(dynamics_element_code);

	  std::string initial_state_lower_bound_code;
	  initial_state_lower_bound_code = m_spCfg->readConfigValueString("initial_state_lower_bound_code");
	  params.push_back("@@initial_state_lower_bound_code@@");
	  paramvals.push_back(initial_state_lower_bound_code);

	  std::string initial_state_upper_bound_code;
	  initial_state_upper_bound_code = m_spCfg->readConfigValueString("initial_state_upper_bound_code");
	  params.push_back("@@initial_state_upper_bound_code@@");
	  paramvals.push_back(initial_state_upper_bound_code);

	  std::string input_lower_bound_code;
	  input_lower_bound_code = m_spCfg->readConfigValueString("input_lower_bound_code");
	  params.push_back("@@input_lower_bound_code@@");
	  paramvals.push_back(input_lower_bound_code);

	  std::string input_upper_bound_code;
	  input_upper_bound_code = m_spCfg->readConfigValueString("input_upper_bound_code");
	  params.push_back("@@input_upper_bound_code@@");
	  paramvals.push_back(input_upper_bound_code);

	  std::string growth_bound_matrix_code;
	  growth_bound_matrix_code = m_spCfg->readConfigValueString("growth_bound.growth_bound_matrix_code");
	  params.push_back("@@growth_bound_matrix_code@@");
	  paramvals.push_back(growth_bound_matrix_code);

	  row_max = std::stoi(m_spCfg->readConfigValueString("row_max"));
	  params.push_back("@@row_max@@");
	  paramvals.push_back(std::to_string(row_max));

	  // updating the list of params
	  updatePrameters(params, paramvals);  /* TODO: the word "parameters" is misspelled in this function name */
	}
}
