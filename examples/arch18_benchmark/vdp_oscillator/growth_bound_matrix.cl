float growth_bound_matrix(int i, int j){
	
	if(i == 0 && j == 0)
		return -0.2f;
	else if (i == 0 && j == 1)
		return 0.0f;
	else if (i == 1 && j == 0)
		return 0.0f;
	else if (i == 1 && j == 1)
		return -0.2f;
	else
		return 0.0f;
	
}