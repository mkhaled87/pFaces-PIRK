classdef pirkDataFile    
    properties
        pfacesDataOnject
        
        concrete_data_type
        concrete_data_size
       
        method_choice
        initial_time
        final_time
        step_size
        states_dim
        inputs_dim
        
        data_size
        data_array
        num_elements
    end
    
    methods(Static)
        function v = getValueFromArray(array, start_idx, data_type, data_type_size)
            bytes = array(start_idx+1:start_idx+data_type_size);
            v = typecast(uint8(bytes), data_type);            
        end
    end    
    methods
        function obj = pirkDataFile(filename)

            obj.pfacesDataOnject = DataFile(filename, false, true);
            obj.concrete_data_type = 'single';
            obj.concrete_data_size = 4;   

            obj.method_choice = str2double(obj.pfacesDataOnject.getMetadataElement('method_choice'));
            obj.initial_time = str2double(obj.pfacesDataOnject.getMetadataElement('initial_time'));
            obj.final_time = str2double(obj.pfacesDataOnject.getMetadataElement('final_time'));
            obj.step_size = str2double(obj.pfacesDataOnject.getMetadataElement('step_size'));
            obj.states_dim = str2double(obj.pfacesDataOnject.getMetadataElement('states.dim'));
            obj.inputs_dim = str2double(obj.pfacesDataOnject.getMetadataElement('inputs.dim'));
            
            obj.data_size = str2double(obj.pfacesDataOnject.getMetadataElement('raw_data_size'));
            obj.data_array = obj.pfacesDataOnject.getBlock(0, obj.data_size);
            obj.num_elements = obj.data_size/obj.concrete_data_size;
        end
        
        function val = getElement(obj, element_idx)
            if(element_idx >= obj.num_elements)
                error('Invalid idx value !');
            end
            idx = element_idx*obj.concrete_data_size;
            val = pirkDataFile.getValueFromArray(obj.data_array, idx, obj.concrete_data_type, obj.concrete_data_size);
        end
        
        function c = countElements(obj)
            c = obj.num_elements;
        end
        
        % read meta-data element value
        function element_value = getMetadataElement(obj, element_name)
            element_value = obj.pfacesDataOnject.getMetadataElement(element_name);
        end         
        
    end
end

