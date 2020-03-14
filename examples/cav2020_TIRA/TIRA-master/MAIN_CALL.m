%% Main file to use for a single call of the tool
% This tool computes an interval over-approximation of the finite-time
% reachable set for a continuous-time system dx/dt = f(t,x,p) or
% discrete-time system x^+ = f(t,x,p) with input p, based on the intervals 
% of initial states and of input values.

% Authors:  
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
%   Murat Arcak, <arcak -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 13th of October 2018

%% Initialization
close all
clear
% Folder containing the various over-approximation methods
addpath('OA_methods')   
% Folder containing useful tools and functions
addpath('Utilities')    
% Folder containing user-provided files required by some methods 
% (eg: signs, bounds or functions of the Jacobian or Sensitivity matrices)
addpath('Input_files')  

%% Interval of initial states (defined by two column vectors)
x_low = [0;0];      % Lower bound
x_up = [0;0];       % Upper bound

%% Interval of allowed input values (defined by two column vectors)
% If the system has no input, define: p_low = 0; p_up = 0;
p_low = [0;0];      % Lower bound
p_up = [0;0];       % Upper bound

%% Time interval
t_init = 0;         % Initial time
t_final = 1;        % Final time (for continuous-time systems)

%% Call of the main over-approximation function
% succ_low is the lower bound of the over-approximation interval
% succ_up is the upper bound of the over-approximation interval

% Call for continuous-time systems over the time range [t_init,t_final]
% [succ_low,succ_up] = TIRA([t_init,t_final],x_low,x_up,p_low,p_up);

% Call for discrete-time systems for one step starting from time t_init
% [succ_low,succ_up] = TIRA(t_init,x_low,x_up,p_low,p_up);

%% Optional choice of the over-approximation method to be used

% The optional choice of the over-approximation method can either be done
%   in the file Solver_parameters.m, 
%       then calling the function TIRA as above
%
%   or here, defining the integer 'OA_method' to one of the methods below:
%           1 - Continuous-time monotonicity
%           2 - Continuous-time componentwise contraction and growth bound
%           3 - Continuous-time mixed-monotonicity
%           4 - Continuous-time sampled-data mixed-monotonicity
%           5 - Discrete-time mixed-monotonicity
%       then adding 'OA_method' as the last argument of function TIRA:
%       [succ_low,succ_up] = TIRA([t_init,t_final],x_low,x_up,p_low,p_up,OA_method);
%       [succ_low,succ_up] = TIRA(t_init,x_low,x_up,p_low,p_up,OA_method);

% If it is not provided, function TIRA.m will pick the most
% suitable method that can be used with the additional system descriptions
% provided by the user in the './Input_files' folder.
