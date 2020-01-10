#include <pfaces-sdk.h>
#include <iostream>
#include "pirk.h"

namespace pirk{
	void saveBufferToFile(const pfacesParallelProgram& thisParallelProgram, 
		char* pData, size_t pDataSize, std::string fileTag) {

		size_t beVerboseLevel = thisParallelProgram.m_beVerboseLevel;

		std::string	outPath =
			pfacesFileIO::getFileDirectoryPath(thisParallelProgram.m_spCfgReader->getConfigFilePath()) +
			std::string(thisParallelProgram.m_spCfgReader->readConfigValueString("project_name")) + std::string(".") + fileTag + std::string(".raw");

		// encapsulate the data
		pfacesRawData rawData(pData, pDataSize);

		// prepare the metadata
		float initial_time = std::stof(thisParallelProgram.m_spCfgReader->readConfigValueString("initial_time"));
		float final_time = std::stof(thisParallelProgram.m_spCfgReader->readConfigValueString("final_time"));
		float step_size = std::stof(thisParallelProgram.m_spCfgReader->readConfigValueString("step_size"));
		float integration_time = final_time - initial_time;
		size_t nsteps = (size_t)ceil(integration_time / step_size);
		step_size = integration_time / (float)(nsteps);

		StringDataDictionary metadata;
		metadata.push_back(std::make_pair("project_name", thisParallelProgram.m_spCfgReader->readConfigValueString("project_name")));
		metadata.push_back(std::make_pair("method_choice", thisParallelProgram.m_spCfgReader->readConfigValueString("method_choice")));
		metadata.push_back(std::make_pair("initial_time", std::to_string(initial_time)));
		metadata.push_back(std::make_pair("final_time", std::to_string(final_time)));
		metadata.push_back(std::make_pair("step_size", std::to_string(step_size)));
		metadata.push_back(std::make_pair("states.dim", thisParallelProgram.m_spCfgReader->readConfigValueString("states.dim")));
		metadata.push_back(std::make_pair("inputs.dim", thisParallelProgram.m_spCfgReader->readConfigValueString("inputs.dim")));
		metadata.push_back(std::make_pair("nsamples", thisParallelProgram.m_spCfgReader->readConfigValueString("nsamples")));
		metadata.push_back(std::make_pair("nsteps", std::to_string(nsteps)));
		metadata.push_back(std::make_pair("raw_data_size",std::to_string(pDataSize)));


		// Informing the user we are saving
		if (beVerboseLevel >= 2) {
			pfacesTerminal::showMessage(std::string("Saving an output file (") + fileTag +  std::string(") ... "), false);
		}

		// actual writin
		bool writeFileStatus = pfacesDataFile::writeData(outPath, DataFileType::DATA_FILE_RAW, rawData, metadata, beVerboseLevel >= 2);

		// Informing the user we are done
		if (beVerboseLevel >= 2) {
			if (!writeFileStatus)
				pfacesTerminal::showWarnMessage("Failed to write one or more output files !");
			else {
				double total_size_in_mb = (((double)pDataSize) / ((double)(1024 * 1024)));
				pfacesTerminal::showMessage(std::string(" done! [Raw-size: ") + std::to_string(total_size_in_mb) + std::string(" M.B.]"));
			}
		}
	}
}
