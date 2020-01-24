float state_jacobian_lower_bound(unsigned int i,unsigned int j) {
    // Parameters
    float f = 1.;
    float m = 1.;
    float g = 9.8;
    float c = 0.0;
    float fatt = 0.5;  // maximum attactive force
    float frep= 1.0;   // maximum repulsive force
    unsigned int i_swarm_element = i/12;
    unsigned int j_swarm_element = j/12;
    unsigned int k = i % 12;
    unsigned int l = j % 12;
    
    if(i_swarm_element == j_swarm_element) {
        if(k == 0 && l == 6) {
            c = 1;
        }
        else if(k == 1 && l == 7) {
            c = 1;
        }
        else if(k == 2 && l == 8) {
            c = 1;
        }
        else if(k == 3 && l == 9) {
            c = 1;
        }
        else if(k == 4 && l == 10) {
            c = 1;
        }
        else if(k == 5 && l == 11) {
            c = 1;
        }
        else if(k == 6 && l == 3) {
            c = -f/m;
        }
        else if(k == 6 && l == 4) {
            c = -f/m;
        }
        else if(k == 6 && l == 5) {
            c = -f/m;
        }
        else if(k == 6 && l == 6) {
            c = -frep;
        }
        else if(k == 7 && l == 3) {
            c = -f/m;
        }
        else if(k == 7 && l == 4) {
            c = -f/m;
        }
        else if(k == 7 && l == 5) {
            c = -f/m;
        }
        else if(k == 7 && l == 7) {
            c = -frep;
        }
        else if(k == 8 && l == 3) {
            c = g - f/m;
        }
        else if(k == 8 && l == 4) {
            c = g - f/m;
        }
        else if(k == 8 && l == 8) {
            c = -frep;
        }
        else {
            c = 0;
        }
    }
    else if(k == l) {
        if(k == 6 || k == 7 || k == 8) {
            c = -frep;
        }
    }
    else {
        c = 0;
    }
    return c;
}

float state_jacobian_upper_bound(unsigned int i,unsigned int j) {
    // Parameters
    float f = 1.;
    float m = 1.;
    float g = 9.8;
    float c = 0.0;
    float fatt = 0.5;  // maximum attactive force
    float frep= 1.0;   // maximum repulsive force
    
    unsigned int i_swarm_element = i/12;
    unsigned int j_swarm_element = j/12;
    unsigned int k = i % 12;
    unsigned int l = j % 12;
    
    if(i_swarm_element == j_swarm_element) {
        if(k == 0 && l == 6) {
            c = 1;
        }
        else if(k == 1 && l == 7) {
            c = 1;
        }
        else if(k == 2 && l == 8) {
            c = 1;
        }
        else if(k == 3 && l == 9) {
            c = 1;
        }
        else if(k == 4 && l == 10) {
            c = 1;
        }
        else if(k == 5 && l == 11) {
            c = 1;
        }
        else if(k == 6 && l == 3) {
            c = f/m;
        }
        else if(k == 6 && l == 4) {
            c = f/m;
        }
        else if(k == 6 && l == 5) {
            c = f/m;
        }
        else if(k == 6 && l == 6) {
            c = frep;
        }
        else if(k == 7 && l == 3) {
            c = f/m;
        }
        else if(k == 7 && l == 4) {
            c = f/m;
        }
        else if(k == 7 && l == 5) {
            c = f/m;
        }
        else if(k == 7 && l == 7) {
            c = frep;
        }
        else if(k == 8 && l == 3) {
            c = g + f/m;
        }
        else if(k == 8 && l == 4) {
            c = g + f/m;
        }
        else if(k == 8 && l == 8) {
            c = frep;
        }
        else {
            c = 0;
        }

    }
    else if(k == l) {
        if(k == 6 || k == 7 || k == 8) {
            c = frep;
        }
    }
    else {
        c = 0;
    }
    return c;
}

float input_jacobian_lower_bound(unsigned int i,unsigned int j) {
    
	// There is no interaction between quadrotors, so let's see if the i and j indices correspond to the same quadrotor.
	unsigned int i_swarm_element = i/12;
    unsigned int j_swarm_element = j/12;
	
    if(i_swarm_element == j_swarm_element) {
        //if they do, then only input effect is from the last three inputs affecting the last three states.
        unsigned int k = i % 12;
        unsigned int l = j % 12;
        if(k > 8 && l == k) {
            return 1;
        }
        else {
            return 0;
        }
	}
    else {
        return 0;
    }
}

float input_jacobian_upper_bound(unsigned int i, unsigned int j) {
    
	// There is no interaction between quadrotors, so let's see if the i and j indices correspond to the same quadrotor.
    unsigned int i_swarm_element = i/12;
    unsigned int j_swarm_element = j/12;
	
    if(i_swarm_element == j_swarm_element) {
        
		//if they do, then only input effect is from the last three inputs affecting the last three states.
        unsigned int k = i % 12;
        unsigned int l = j % 12;
		
        if(k > 8 && l == k) {
            return 1;
        }
        else {
            return 0;
        }
	}
    else {
        return 0;
    }    
}
