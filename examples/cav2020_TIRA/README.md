# Modified implementation of the tool TIRA for the CAV2020 submission

This folder contains a version of the tool TIRA contains the examples that are reported in our tool paper submitted for the conference CAV2020. Unlike the original version of TIRA, this one supports Monte-Carlo simulation as a method to compute the reach-sets of a dynamical system. This allows us to compare between our tool, PIRK, and TIRA and eventually report the results in
the paper.

TIRA is based on MATLAB and you need to have a MATLAB installation to be able to run the experiments.

Here in this version, we provide two examples:

- n-Link Road Traffic Model
- Quadrotor Swarm 

and we use one of two methods:

- Growth-bound Method
- Monte-Carlo Simulation

In the next sections, we discuss how you can set the example and the method. From now on, we will be working with files inside the directory [Examples](./Examples).

## Selecting the Target Example

Simply open the file [MAIN_CALL.m](./Examples/MAIN_CALL.m) and you should find a command line that sets the target example. The command line look like this:

```(cpp)
system_choice = 1;
```

Setting **system_choice** to (1) will set the target example to the n-link traffic model. Setting **system_choice** to (2) will set the target example to Quadrotor swarm.

If you choose the n-link traffic model, you may need to set the number of links. In the same file, you find in line 39, a parameter **n_x** that is used to set the number of links.

If you choose the Quadrotor swarm model, you may need to set the number of quadrotors. In the same file, you find in line 61, a parameter **n_quads** that is used to set the number of quadrotors.

## Selecting the Target Method

Simply open the file [Solver_parameters.m](./Examples/Solver_parameters.m) and you should find a command line that sets the target method. The command line should look like this:

```(cpp)
parameters.OA_method = 2;
```

Setting **parameters.OA_method** to (2) will set the target method to Growth-Bound. Setting **parameters.OA_method** to (6) will set the target method to Monte-Carlo.

If you choose to select the Monte-Carlo method, you may need to change the Epsilon and Delta parameters reported in the paper. You will find such parameters in the same file and the command lines to change them should look like:

```(cpp)
parameters.montecarlo_epsilon = 0.05;
parameters.montecarlo_delta = 0.05;
```

## Running the Example

Now, after setting the target example and target method, you are ready to run the example. From inside MATLAB, make sure to navigate to the [Examples](./Examples) folder and then run the command:

```(cpp)
>> MAIN_CALL
```

This will run TIRA to solve the problem and it will report the time once finished.