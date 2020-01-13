#define W 0.01f

float initial_state_lower_bound(unsigned int i){
    if(i == 0)
        return 1.20f - W;
    else if (i == 1)
        return 1.05f - W;
    else if (i == 2)
        return 1.50f - W;
    else if (i == 3)
        return 2.40f - W;
    else if (i == 4)
        return 1.00f - W;
    else if (i == 5)
        return 0.10f - W;
    else if (i == 6)
        return 0.45f - W;
    else 
        return 0.0f;
}

float initial_state_upper_bound(unsigned int i){
    if(i == 0)
        return 1.20f + W;
    else if (i == 1)
        return 1.05f + W;
    else if (i == 2)
        return 1.50f + W;
    else if (i == 3)
        return 2.40f + W;
    else if (i == 4)
        return 1.00f + W;
    else if (i == 5)
        return 0.10f + W;
    else if (i == 6)
        return 0.45f + W;
    else 
        return 0.0f;
}

float input_lower_bound(unsigned int i){

    return 0.0f;
}

float input_upper_bound(unsigned int i){

    return 0.0f;
}