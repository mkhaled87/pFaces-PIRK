#define W 0.4f

float initial_state_lower_bound(unsigned int i){
    return 0.0f - W;
}

float initial_state_upper_bound(unsigned int i){
    return 0.0f + W;
}

float input_lower_bound(unsigned int i){

    return 0.0f;
}

float input_upper_bound(unsigned int i){

    return 0.0f;
}