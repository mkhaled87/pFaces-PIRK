float growth_bound_matrix(int i, int j){
	
	if(i == 0 && j == 0)
		return -1.1f;
	else if (i == 0 && j == 1)
		return 1.0f;
	else if (i == 1 && j == 0)
		return 1.0f;
	else if (i == 1 && j == 1)
		return -1.1f;
	else
		return 0.0f;
	
}