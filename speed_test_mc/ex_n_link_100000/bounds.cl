float initial_state_lower_bound(int i)
{
 return 100.;
}

float initial_state_upper_bound(int i)
{
 return 200.;
}

float input_lower_bound(int i)
{
    float T = 30.; // Time step
    if (i == 0) {
        return 0.0;
        //return 40./T;
    }
    else {
        return 0.0;
    }
}

float input_upper_bound(int i)
{
    float T = 30.; // Time step
    if (i == 0) {
        //return 60./T;
        return 0.0;
    }
    else {
        return 0.0;
    }
}