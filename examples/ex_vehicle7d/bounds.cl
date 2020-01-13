#define INITIAL_POSITION_X 6.0f
#define INITIAL_POSITION_Y 4.5f
#define VEHICLE_WIDTH 2.0f
#define VEHICLE_LENGTH 4.7f

float initial_state_lower_bound(unsigned int i)
{	
	if(i == 0)
		return INITIAL_POSITION_X-VEHICLE_WIDTH/2.0f;
	else if(i == 1)
		return INITIAL_POSITION_Y-VEHICLE_LENGTH/2.0f;
	else if(i == 4)
        return  1.5708f;
	else
		return 0.0f;
}

float initial_state_upper_bound(unsigned int i)
{	
	if(i == 0)
		return INITIAL_POSITION_X+VEHICLE_WIDTH/2.0f;
	else if(i == 1)
		return INITIAL_POSITION_Y+VEHICLE_LENGTH/2.0f;
	else if(i == 4)
        return 1.5708f;
	else
		return 0.0f;
}

float input_lower_bound(unsigned int i)
{
    return 0.0f;
}

float input_upper_bound(unsigned int i)
{
    return 0.0f;
}