%% Reachable set over-approximation based on a contraction/growth bound of a continuous-time system
% The over-approximation (related to the notion of componentwise 
% contraction from source paper 1) is obtained by reformulating the 
% definition of the growth bound from Definition VIII.2 in source paper 2.
% 3 methods to provide or obtain the growth bound are currently implemented
%   1: Take growth bound from user-provided file (requires Input_files/UP_Growth_Bound_Function.m)
%   2: Create a growth bound function from user-provided contraction matrix (requires Input_files/UP_Contraction_Matrix.m)
%   3: Create a growth bound function from the contraction matrix extracted from user-provided Jacobian bounds (requires Input_files/UP_Jacobian_Bounds.m) 
%   Methods 2 and 3 require the dynamics to be defined with additive input

% Source paper 1:
% T. Kapela and P. Zgliczynski, "A Lohner-type algorithm for control 
% systems and ordinary differential inclusions". Discrete & Continuous 
% Dynamical Systems, Series B, v. 11(2), pp. 365-385, 2009.
% DOI: 10.3934/dcdsb.2009.11.365 

% Source paper 2 (particular case for time-invariant systems):
% G. Reissig, A. Weber and M. Rungger, "Feedback refinement relations for 
% the synthesis of symbolic controllers". IEEE Transactions on Automatic 
% Control v. 62(4), pp. 1781-1796, 2017. DOI: 10.1109/TAC.2016.2593947

% List of inputs
%   t_init: initial time
%   t_final: time at which the reachable set is approximated
%   [x_low,x_up]: interval of initial states (at time t_init)
%   [p_low,p_up]: interval of allowed input values
%   GB_handle: function handle of the growth bound 
%       inputs: positive time, positive state vector, positive input vector
%       output: positive state vector (growth or contraction of the system)

% List of outputs
%   [succ_low,succ_up]: interval over-approximation of the reachable set (at time t_final)

% Authors:  
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 13th of October 2018

function [succ_low,succ_up] = OA_2_CT_Contraction_growth_Bound(t_init,t_final,x_low,x_up,p_low,p_up,GB_handle)
%% Parameters of the initial state and input intervals
state_center = (x_low+x_up)/2;
state_half_width = (x_up-x_low)/2;
input_center = (p_low+p_up)/2;
input_half_width = (p_up-p_low)/2;

%% Parameters of the over-approximation interval

% Successor of the system starting in init_center with inputs equal to 0
[~,x_traj] = ode45(@(t,x) System_description(t,x,input_center),[t_init,t_final],state_center);
OA_center = x_traj(end,:)';

% Size of the over-approximation, using the growth bound
OA_half_width = GB_handle(t_final-t_init,state_half_width,input_half_width);

% Reachable set over-approximation
succ_low = OA_center - OA_half_width;
succ_up = OA_center + OA_half_width;
