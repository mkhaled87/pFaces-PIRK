#define VEHICLE_DIM 3
#define INITIAL_THETA 0.0f
#define THETA_DISTURBANCE 0.1f
#define INITIAL_POSITION_X 4.5f
#define INITIAL_POSITION_Y 4.5f
#define VEHICLE_WIDTH 2.09f
#define VEHICLE_LENGTH 4.7f

float initial_state_lower_bound(unsigned int i)
{
	unsigned int vehicle_idx = i/VEHICLE_DIM;
	unsigned int state_idx = i%VEHICLE_DIM;
	
	if(state_idx == 0)
		return INITIAL_POSITION_X-VEHICLE_WIDTH/2.0f;
	else if(state_idx == 1)
		return INITIAL_POSITION_Y-VEHICLE_LENGTH/2.0f;;
	else if(state_idx == 2)
		return INITIAL_THETA-THETA_DISTURBANCE;
	else
		return 0.0f;
}

float initial_state_upper_bound(unsigned int i)
{
	unsigned int vehicle_idx = i/VEHICLE_DIM;
	unsigned int state_idx = i%VEHICLE_DIM;
	
	if(state_idx == 0)
		return INITIAL_POSITION_X+VEHICLE_WIDTH/2.0f;
	else if(state_idx == 1)
		return INITIAL_POSITION_Y+VEHICLE_LENGTH/2.0f;;
	else if(state_idx == 2)
		return INITIAL_THETA+THETA_DISTURBANCE;
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