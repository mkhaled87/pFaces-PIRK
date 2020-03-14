%% User-provided function returning bounds on the sensitivity matrices for a continuous-time system
% The user can either provider global bounds, or a function of the input
% arguments (t_init,t_final,x_low,x_up,p_low,p_up) returning local bounds
% Sensitivity definitions:
%   to initial states:  S_x(t_final) = dx(t_final;t_init,x0,p)/dx0
%   to inputs:          S_p(t_final) = dx(t_final;t_init,x0,p)/dp

% List of inputs
%   t_init: initial time
%   t_final: time at which the reachable set is approximated
%   [x_low,x_up]: interval of initial states (at time t_init)
%   [p_low,p_up]: interval of allowed input values

% List of outputs
%   [S_x_low,S_x_up]: bounds of the sensitivity of successors (at time t_final) to variations of initial states (at time t_init)
%   [S_p_low,S_p_up]: bounds of the sensitivity of successors (at time t_final) to variations of inputs

% Authors:  
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 13th of October 2018

function [S_x_low,S_x_up,S_p_low,S_p_up] = UP_Sensitivity_Bounds(t_init,t_final,x_low,x_up,p_low,p_up)
n_x = length(x_low);
n_p  = length(p_low);

%% Default values as NaN (not a number)
S_x_low = NaN(n_x);
S_x_up = NaN(n_x);
S_p_low = NaN(n_x,n_p);
S_p_up = NaN(n_x,n_p);

%% User-provided sensitivity bounds
% Can be either global bounds
% or local bounds depending on inputs: t_init,t_final,x_low,x_up,p_low,p_up

% If System_description.m has no input variable 'p', uncomment below:
% S_p_low = zeros(n_x,n_p);
% S_p_up = zeros(n_x,n_p);



