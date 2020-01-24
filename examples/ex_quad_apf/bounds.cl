float initial_state_lower_bound(unsigned int i) {
	
    unsigned int k = i % 12;
    if(k < 3 ) {
       return -0.4f; 
    }
    else if(k < 6) {
        return -0.1f;
    }
    else if(k < 9) {
        return -0.4f;
    }
    else {
        return 0.0f;
    }
}

float initial_state_upper_bound(unsigned int i){
	
    unsigned int k = i % 12;
    if(k < 3 ) {
       return 0.4f; 
    }
    else if(k < 6) {
        return 0.1f;
    }
    else if(k < 9) {
        return 0.4f;
    }
    else {
        return 0.0f;
    }
}

float input_lower_bound(unsigned int i)
{
    return 0.0f;
}

float input_upper_bound(unsigned int i)
{
    return 0.0f;
}
