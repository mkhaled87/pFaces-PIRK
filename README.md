# **PIRK**: Parallel Computation of Reachable Sets for General Nonlinear Systems  

Bla bla about reachability analysis ....
**PIRK** is introduced as a software tool, implemented as a kernel on top of the acceleration ecosystem [pFaces](http://www.parallall.com/pfaces), 
for computing the reachable sets of dynamical systems provided as nonlinear diffeential equations.

PIRK is used to:

- bla bla bla

- bla bla bla

In PIRK, scalable parallel algorithms are designed to ....
They are implemented on top of pFaces as a kernel that supports parallel execution within CPUs, GPUs and hardware accelerators (HWAs). 

# **Installation**

## **Prerequisites**

### pFaces

You first need to have have [pFaces](http://www.parallall.com/pfaces) installed and working. 
Test the installation of pFaces and make sure it recognizes the parallel hardware in your machine by running the following command:

```
pfaces -CGH -l
```

where **pfaces** calls pFaces launcher as installed in your machine. This should list all available HW configurations attached to your machine and means you are ready to work with AMYTISS.

```
pfaces -CGH -l
```

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