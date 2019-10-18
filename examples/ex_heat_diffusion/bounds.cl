
float initial_state_lower_bound(unsigned int i)
{
    unsigned int N = 1000;
    unsigned int x_pos = i % N;
    unsigned int y_pos = (i/N) % N;
    unsigned int z_pos = i/(N*N); 
    if(x_pos < 2 && y_pos < 2 && z_pos < 2) {
        return 0.9;
    }
    else {
        return 0.0;
    }
}

float initial_state_upper_bound(unsigned int i)
{
    unsigned int N = 1000;
    unsigned int x_pos = i % N;
    unsigned int y_pos = (i/N) % N;
    unsigned int z_pos = i/(N*N); 
    if(x_pos < 400 && y_pos < 200 && z_pos < 100) {
        return 1.1;
    }
    else {
        return 0.0;
    }
}

float input_lower_bound(unsigned int i)
{
    return 0.0;
}

float input_upper_bound(unsigned int i)
{
    return 0.0;
}
