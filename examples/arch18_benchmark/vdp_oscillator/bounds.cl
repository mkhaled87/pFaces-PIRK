float initial_state_lower_bound(unsigned int i){

    if(i == 0)
        return 1.25f;
    else if (i == 1)
        return 2.35f;
    else 
        return 0.0f;
}

float initial_state_upper_bound(unsigned int i){

    if(i == 0)
        return 1.55f;
    else if (i == 1)
        return 2.45f;
    else 
        return 0.0f;
}

float input_lower_bound(unsigned int i){

    return 0.0f;
}

float input_upper_bound(unsigned int i){

    return 0.0f;
}