# **PIRK**: Parallel Computation of Reachable Sets for General Nonlinear Systems  

PIRK is a tool to efficiently compute reachable sets for general nonlinear systems of *extremely high dimensions*.
It introduces three parallel algorithms for computing interval approximations of forward reachable sets, based on: component-wise contraction properties, mixed monotonicity, and Monte Carlo-based approaches.

Implemented to utilize the acceleration ecosystem [pFaces](http://www.parallall.com/pfaces), PIRK targets HPC platforms for computing the reachable sets. It has been tested on several systems, with state dimensions ranging from ten up to 4 billion.
The scalability of PIRK's parallel implementations is found to be highly favorable.

PIRK can be used to:
- Compute the reachable sets (or pipes) for high-dimensional nonlinear systems. For instance, in the provided examples [n-links traffic network](/examples/ex_n_links/) and [Quadrotor swarm](/examples/ex_quadrotor_swarm/), PIRK can compute the reachable sets for systems with up to 4 billion state variables.

- Efficiently verify the behavior of systems. Given a fixed time-window and input sequence, PIRK calculates, efficiently, the reach pipe of the of the system in hand. This can be verify that the behavior of the system will not violate the design specification. For now, this requires extra code from the user side to verify the computed reach pipe. In the provided [BMW 320i example](/examples/ex_vehicle7d/), PIRK computes in milliseconds the reach pipe of the vehicle in planned lane-change maneuver, which helps verify that that the autonomously-driven car will not crash into the car in front of it. The result of running this example is provided in the *Getting Started* section below in this guide.

# **Installation using Docker**
Here, we assume you will be using Linux or MacOS machine. Commands will be slightly different on Windows if you use Windows PowerShell.

First, make sure to configure Docker to use all of the resources available (e.g., all CPU cores). Otherwise, PIRK will run slower than expected. Also, in case you are using a GPU, make sure to pass-through the GPU in Docker. See this [guide](https://docs.docker.com/config/containers/resource_constraints/).

Download the Dockerfile:
``` bash
$ mkdir pirk
$ cd pirk
$ wget https://raw.githubusercontent.com/mkhaled87/pFaces-PIRK/master/Dockerfile
```    

Build the Docker image:
``` bash
$ docker build -t pirk/latest .
```    

Run/enter the image's interactive shell
``` bash
$ docker run -it pirk/latest
```    

Now you can use PIRK. It is located in the director **pFaces-PIRK** and you can navigate to it as follows:
``` bash
$ cd pFaces-PIRK
```

In the Docker image, we installed Oclgrind to simulate an OpenCL platform/device that utilizes all the CPU cores usign threads. Unless you will be passing-through your device (e.g., a GPU), you MUST preced any pFaces command with oclgrind. For example, to check available devices in the prespective of Oclgrind, run:
``` bash
$ oclgrind pfaces -CGH -l
```


# **Installation using Source code**

## **Prerequisites**

You first need to have have [pFaces](http://www.parallall.com/pfaces) installed on the target machine. Once installed, test its installation and make sure it recognizes the parallel hardware in your machine by running the following command:

```
pfaces -CGH -l
```

where the command *pfaces* here calls pFaces launcher as installed in your machine. This should list all available HW configurations (HWCs) attached to your machine. If you see one or more devices, this means you are ready to work with PIRK. In case a device you know is not listed, you may need to install its device-driver or any OpenCL runtime environment that is provided by the vendor.

## Building PIRK

PIRK is given as source code that need to be built one time. This requires a modern C/C++ compiler such as:

- For windows: Microsoft Visual C++ (MS VisualStudio 2019 is recommended and there is a free version called [MS VisualStudio Community Edition](https://visualstudio.microsoft.com/downloads/) you can use);
- For Linux/MacOS: any GCC/G++ with C++ 11 support will do the job.

### **Building on Windows**

If you will be using Windows, download the repository and extract it. Then, open the provided VisualStudio-solution file [pFaces-PIRK.sln](pFaces-PIRK.sln) and build it using the **Release (x64)** configuration. Building with Debug configuration will result in a slower operation and requires having the debug binaries of pFaces.

### **Building on Linux/MacOS**

If you will be using Linux or MacOS and assuming you have a GIT client, simply run the following command to clone this repository locally:

```
$ git clone --depth=1 https://github.com/mkhaled87/pFaces-PIRK.git
```

PIRK requires to link with pFaces SDK, which should be already installed with pFaces. 
The environment variable **PFACES_SDK_ROOT** should point to pFaces SDK root directory. 
Make sure you have the environment variable **PFACES_SDK_ROOT** pointing to the full absolute pFaces SDK folder. If not, do it as follows:

```
$ export PFACES_SDK_ROOT=/full/path/to/pfaces-sdk
```

Where */full/path/to/pfaces-sdk* is the complete path to the pFaces-SDK installed in the machine. Now navigate to the created repo folder and build PIRK:

```
$ cd pFaces-PIRK
$ make
```

# **Getting Started**

Now, you have PIRK installed and ready to be used. You might now run a given example or build your own.

## **File structure of PIRK**

- [examples](/examples): the folder contains pre-designed examples.
- [interface](/interface): the folder contains the Matlab interface to access the files generated by PIRK.
- [kernel](/kernel): the folder C++ source codes of PIRK.
- [kernel-pack](/kernel-pack): the folder contains the OpenCL codes of the PIRK and will hold the binaries of the loadable kernel of PIRK.
- [tools](/tools): some independent PIRK-related tools the that can be used to test the dynamics of the systems.

## **Running an example**

<img align="right" src="/doc/media/pirk_lane_cnage.bmp" alt="car_manuever" width="21%" height="21%">

Navigate to any of the examples in the directory [/examples](/examples). Within each example, one or more *.cfg* files are provided. 
Such config files tell PIRK about the system being considered and the requirements PIRK should consider when computing the reach sets.

Say you navigated to the example in [/examples/ex_vehicle7d](/examples/ex_vehicle7d). This examples is provided to compute the reach pipe of an autonomous vehicle making a lane-change manuever in the highway.
To run this example, we launch PIRK with the config file [vehicle.cfg](/examples/ex_vehicle7d/vehicle.cfg). Run the following command from any terminal running on the example's folder:

```
pfaces -CG -d 1 -k pirk.cpu@../../kernel-pack -cfg ./vehicle.cfg -p
```

where **pfaces** calls pFaces launcher, "-CGH -d 1" asks pFaces to run on the first device of all available devices, 
"-k pirk@../../kernel-pack" tells pFaces about PIRK and where it is located, 
"-cfg vehicle.cfg" asks pFaces to hand the configuration file *vehicle.cfg* to PIRK, and 
"-p" asks pFaces to collect profiling information. 
Make sure to replace each / with \ in case you are using Windows command line.

pFaces will take some time (depending on your HW) to solve the reachability problem. The output will be stored in a file *vehicle.raw* which contains the reach pipe of this system. 

We developed a Matlab-interface so that Matlab users can load and use the files generated from PIRK. If you have Matlab installed, open it and navigate to this example's folder. Running the Matlab script file *simulate.m* will use the Matlab-interface to load and plot the reach sets stored in the output file. The reach pipe should loop like the image on the right side.


## **Building your own example**

We recommend copying and modifying one of the provided examples to avoid syntactical mistakes. An example in PIRK is mainly some text files:

- A configuration file (.cfg) describing the example.
- A file (dynamics.cl) describing the dynamical system being considered.
- A file (bounds.cl) setting the initial hyper-interval for states and inputs.
- Based on the method chosen, one or more additional files may be required.


### **The configuration files**
A configuration file (.cfg) corresponds to a case describing a reachability analysis problem. Config files are text files with scopes and contents on the form: 'scope_name { contents }', where the contents is a list of semicolon-delimited key="value" pairs. The following is an example of a scope with contents:

    country = "Egypt";
    city {
	    name = "Cairo";
        population = "9.5 million";
    }

Some keys does not require parent scopes. All values need to be enclosed with double quotes. Now, take a quick look to this [config](/examples/ex_toy_safety/toy2d.cfg) file to get to know about the scopes/contents used in PIRK's config files. The following are the all the keys that can be used in PIRK. 

- **project_name**: a key to describe the name of the project and will be used as a name for the output file.

- **data**: describes the used data model and should be currently set to "raw". Later, we plan to support more data types with compressions to save memory.

- **method_choice**: an integer [1-4] that describes the method used to compute the reach sets. The value can be any of:

    1: (GB) Growth/Contraction Matrix,

    2: (CTMM) Continious-time mixed monotonicity,

    3: (MC) Monte-carlo based simulation, or

    4: (MC_hd) Monte-carlo based simulation (High Definition).


- **mem_efficient**: a true/false value to enable/disable the memory efficient versions of the implemented algorithms. It is currently supported for the GB method. It should be set to *"false"* for other methods.

- **record_pipe**: a true/false value to enable/disable the recording of the reach pipe. When set, an additional output file will be saved for the reach pipe.

- **initial_time**: initial value for the time.

- **final_time**: final value for the time.

- **step_size**: time quantization step.

- **states.dim**: The dimension of the state set (number of state variables).

- **inputs.dim**: The dimension of the input set (number of input variables).


### **System Dynamics and State/Input Bounds**

The dynamics of the system is described in the (dynamics.cl) file. The file should contain C-language code and a callback function with the following signature:

    float dynamics_element_global(__global float* x, __global float* u, float t, unsigned int i);

where *x* and *u* are the supplied state and input vectors at time *t*. The function should return the RHS value of the system's differential equation with respect to the state variable number *i*. *i* will take values from *0* to *N-1* where *N* is the number of state variables.

The computation of the reach set starts with a pre-defined hyper-rectangle (a.k.a. hyper-interval) over the states and inputs sets. This should be supplied by the user in the file (bounds.cl) which should contain four callback functions with the following signatures:

    float initial_state_lower_bound(unsigned int i);
    float initial_state_upper_bound(unsigned int i);
    float input_lower_bound(unsigned int i);
    float input_upper_bound(unsigned int i);

where each function receives *i*, asking for the *i*th component of the lower (resp. upper) bound value of the initial state (resp. input) set. 

There is no need to rebuild PIRK anytime you modify those files or create new examples. PIRK simply loads and injects the files into the OpenCL kernel that is sent to pFaces. pFaces then takes care of the online compilation of all OpenCL codes. 

### **Method-specific Requirements**

### *For the method (1: GB)*

Apart from setting *method_choice* to *"1"*, users need to specify the growth/contraction matrix. A separate file (growth_bound_matrix.cl) must be provided and it should contain a callback function with the following signature:

    float growth_bound_matrix(int i, int j);

which provides the value in the growth/contraction matrix for the *i*th row and *j*th column.

### *For the method (2: CTMM)*

Apart from setting *method_choice* to *"2"*, users need to specify the bounds of the Jacobian. A separate file (jacobian_bounds.cl) must be provided and it should contain a callback functions with the following signatures:

    float state_jacobian_lower_bound(unsigned int i, unsigned int j);
    float state_jacobian_upper_bound(unsigned int i, unsigned int j);


Both functions provide the lower (resp. upper) value in the Jacobian matrix for the *i*th row and *j*th column.

### *For the methods (3: MC, 4:MC_hd)*

Apart from setting *method_choice* to *"3"* (resp. *"4"*), users need to specify the number of simulations to be done. Each simulation will pick, randomly, an initial state vector and input vector, and simulate the dynamics based on them. The reach set will be the final set enclosing the reach states from all simulations.

To specify the number of simulation (e.g., 1000 simulations), the following configuration must be set in the config file:

    nsamples = "1000";

The required number of samples can be computed using the formula: 

    nsamples = ceil((2*n/epsilon)*log(2*n/delta)), 

where n is the state dimension and epsilon=delta=0.05 are parameters to control the probabilistic guarantee. 


## **Authors**

- [**Mahmoud Khaled**](http://www.mahmoud-khaled.com)*.
- [**Alex Devonport**](https://people.eecs.berkeley.edu/~arcak/people.html)*.
- [**Mjid Zamani**](https://www.colorado.edu/cs/majid-zamani).
- [**Murat Arcak**](https://www2.eecs.berkeley.edu/Faculty/Homepages/arcak.html).

*: Both authors have the same contribution.

## **Publications**

- A. Devonport$, M. Khaled, M. Arcak, M. Zamani. PIRK: Scalable Interval Reachability Analysis for High-Dimensional Nonlinear Systems. 32nd Conference on Computer Aided Verification (CAV), July 2020.

Please cite the tool paper as follows:

    @inproceedings{PIRK,
        title = {PIRK: Scalable Interval Reachability Analysis for High-Dimensional Nonlinear Systems},
        author = {Devonport, Alex and Khaled, Mahmoud and Arcak, Murat and Zamani, Majid},
        booktitle = {Proc. 32nd International Conference on Computer Aided Verification (CAV)},
        publisher = {Springer},
        series = {LNCS},
        year = {2020}
    }



## **License**

See the [LICENSE](LICENSE) file for details
