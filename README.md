# **PIRK**: Parallel Computation of Reachable Sets for General Nonlinear Systems  

PIRK is a tool to efficiently compute reachable sets for general nonlinear systems of *extremely high dimensions*.
It introduces three parallel algorithms for computing interval approximations of forward reachable sets, based on component-wise contraction properties, mixed monotonicity, and Monte Carlo-based approaches.
It utilize the acceleration ecosystem [pFaces](http://www.parallall.com/pfaces) to target HPC platforms for computing the reachable sets. PIRK has been tested on several systems, with state dimensions ranging from ten up to 4 billion.
The scalability of PIRK's parallel implementations is found to be highly favorable.

PIRK can be used to:
- Compute the reachable sets (or pipes) for high-dimensional nonlinear systems. For instance, in the provided examples [n-links traffic network](/examples/ex_n_links/) and [Quadrotor swarm](/examples/ex_quadrotor_swarm/), PIRK can compute the reachable sets for systems with up to 4 billion state variables.

- Efficientlt verify the behaviour of systems. Given a fixed time-window and input sequence, PIRK calcualtes, efficienty, the reach pipe of the of the system in hand. This can be verify that the behaviour of the system will not violate the design specification. For instance, in the provided [BMW 320i exampe](/examples/ex_vehicle7d/), pirk computes in milliseconds the reach pipe of the vehicle in planned lane-change maneuver, which helps veriify that that the autonomously-driven car will not crash into the car in front of it. The reacch pipe is shown in the following imaghe:



# **Installation**

## **Prerequisites**

### pFaces

You first need to have have [pFaces](http://www.parallall.com/pfaces) installed and working. 
Test the installation of pFaces and make sure it recognizes the parallel hardware in your machine by running the following command:

```
pfaces -CGH -l
```

where **pfaces** calls pFaces launcher as installed in your machine. This should list all available HW configurations attached to your machine and means you are ready to work with PIRK.

### Build tools

PIRK is given as source code that need to be built one time. 
This requires a modern C/C++ compiler such as:

- For windows: Microsoft Visual Studio (2019 is recommended);
- For Linu/MacOS: GCC/G++.

## **Building PIRK**

If you will be using Windows, open the provided VisualStudio-solution file [pFaces-PIRK.sln](pFaces-PIRK.sln) and build it using the **Release (x64)** configuration. Building with Debug configuration will result in a slower operation and requires having the debug binaries of pFaces.

If you will be using Linux or MacOS, assuming you have a GIT client, simply run the following command to clone this repo:

```
$ git clone --depth=1 https://github.com/mkhaled87/pFaces-PIRK
```

PIRK requires to link with pFaces SDK, which should be already installed with pFaces. 
The environment variable **PFACES_SDK_ROOT** should point to pFaces SDK root directory. 
Make sure you have the environment variable **PFACES_SDK_ROOT** pointing to the full absolute pFaces SDK forlder. 
If not, do it as follows:

```
$ export PFACES_SDK_ROOT=/full/path/to/pfaces-sdk
```

Now navigate to the created repo folder and build PIRK:

```
$ cd pFaces-PIRK
$ make
```

## **Getting Started**

Now, you have PIRK installed and ready to be used. You might now run a given example or build your own.

### **File structure of PIRK**

- [examples](/examples): the folder contains pre-designed examples.
- [interface](/interface): the folder contains the Matlab interface to access the files genrated by PIRK.
- [kernel](/kernel): the folder C++ source codes of PIRK.
- [kernel-pack](/kernel-pack): the folder contains the OpenCL codes of the PIRK and will hold the binaries of the loadable kernel of PIRK.

### **Running an example**

Navigate to any of the examples in the directoy [/examples](/examples). Within each example, one or more .cfg files are provided. 
Config files tells PIRK about the system underconsideration and the requirements it should consider when desiging a controller for the system.

Say you navigated to the example in [/examples/ex_n_link](/examples/ex_n_link) 
and you want to launch PIRK with the config file [ex_n_link.cfg](/examples/ex_n_link/ex_n_link.cfg), 
then run the following command from any terminal located in the example foder:

```
pfaces -CGH -d 1 -k pirk@../../kernel-pack -cfg ex_n_link.cfg -p
```

where **pfaces** calls pFaces launcher, "-CGH -d 1" asks pFaces to run PIRK in the first device of all avaialble deveices, 
"-k pirk@../../kernel-pack" tells pFaces about PIRK and where it is located, 
"-cfg toy2d.cfg" asks pFaces to hand the configuration file to PIRK, and 
"-p" asks pFaces to collect profiling information. 
Make sure to replace each / with \ in case you are using Windows command line.

### **Building your own example**

We recommend copying and modifing one of the provided examples to avoid syntactical mistakes.

## **The configuration files system parameters**

### **The configuration files**
Each configuration file corresponds to a case describing a stochastic system and the requirements to be used to synthesize a controller for it. Config files are text files with scopes 'scope_name { contents }', where the contents is a list of ;-demilited key="value" pairs. Take a look to this [config](/examples/ex_toy_safety/toy2d.cfg) file for an example. The following are the keys that can be used in PIRK. Note that values need to be enclosed woith double quotes.

- **project_name**: a to describe the name of the project (the case) and will be used as name for output files.
- **data**: describes the used data model and should be currently set to "raw".
- bla bla aout other config files parts


### **System parametrs**
Tell the users about those openCl files for with they need to put functions for the bounds and .....


## **Authors**

- [**Alex Devonport**](http://www.hyconsys.com/members/mzamani).
- [**Mahmoud Khaled**](http://www.mahmoud-khaled.com).


## **License**

See the [LICENSE](LICENSE) file for details
