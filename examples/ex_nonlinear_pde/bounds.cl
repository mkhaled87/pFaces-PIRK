/*
 * I was unsure of what bounds to use for this example problem, so I have 
 * chosen to use these boring ones. It might be interesting to try 
 * to encode some other shape, such as a circle, or a 'dot' in the middle of the grid.
 */

float initial_state_lower_bound(unsigned int i)
{
    return 0.0;
}

float initial_state_upper_bound(unsigned int i)
{
    return 1.0;
}

float input_lower_bound(unsigned int i)
{
    return -0.5;
}

float input_upper_bound(unsigned int i)
{
    return 0.5;
}
