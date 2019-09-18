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
		StringDataDictionary metadata;
		metadata.push_back(std::make_pair("project_name", thisParallelProgram.m_spCfgReader->readConfigValueString("project_name")));
		metadata.push_back(std::make_pair("method_choice", thisParallelProgram.m_spCfgReader->readConfigValueString("method_choice")));
		metadata.push_back(std::make_pair("initial_time", thisParallelProgram.m_spCfgReader->readConfigValueString("initial_time")));
		metadata.push_back(std::make_pair("final_time", thisParallelProgram.m_spCfgReader->readConfigValueString("final_time")));
		metadata.push_back(std::make_pair("step_size", thisParallelProgram.m_spCfgReader->readConfigValueString("step_size")));
		metadata.push_back(std::make_pair("states.dim", thisParallelProgram.m_spCfgReader->readConfigValueString("states.dim")));
		metadata.push_back(std::make_pair("inputs.dim", thisParallelProgram.m_spCfgReader->readConfigValueString("inputs.dim")));
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
