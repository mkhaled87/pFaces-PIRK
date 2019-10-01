float initial_state_lower_bound(unsigned int i)
{
 return 100.0f;
}

float initial_state_upper_bound(unsigned int i)
{
 return 200.0f;
}

float input_lower_bound(unsigned int i)
{
    float T = 30.0f; // Time step
    if (i == 0) {
        return 40.0f/T;
    }
    else {
        return 0.0f;
    }
}

float input_upper_bound(unsigned int i)
{
    float T = 30.0f; // Time step
    if (i == 0) {
        return 60.0f/T;
    }
    else {
        return 0.0f;
    }
}