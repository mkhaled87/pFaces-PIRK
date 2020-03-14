%% User-provided function returning the signs of the sensitivity matrices for a continuous-time system
% The user can either provider global signs, or a function of the input
% arguments (t_init,t_final,x_low,x_up,p_low,p_up) returning local signs
% Sensitivity definitions:
%   to initial states:  S_x(t_final) = dx(t_final;t_init,x0,p)/dx0
%   to inputs:          S_p(t_final) = dx(t_final;t_init,x0,p)/dp

% List of inputs
%   t_init: initial time
%   t_final: time at which the reachable set is approximated
%   [x_low,x_up]: interval of initial states (at time t_init)
%   [p_low,p_up]: interval of allowed input values

% List of outputs
%   S_x_signs: sign of the sensitivity of successors (at time t_final) to variations of initial states (at time t_init)
%   S_p_signs: sign of the sensitivity of successors (at time t_final) to variations of inputs

% Authors:  
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 13th of October 2018

function [S_x_signs,S_p_signs] = UP_Sensitivity_Signs(t_init,t_final,x_low,x_up,p_low,p_up)
n_x = length(x_low);
n_p  = length(p_low);

%% Default values as NaN (not a number)
S_x_signs = NaN(n_x);
S_p_signs = NaN(n_x,n_p);

%% User-provided sensitivity signs
% Can be either global signs
% or local signs depending on inputs: t_init,t_final,x_low,x_up,p_low,p_up

% If System_description.m has no input variable 'p', uncomment below:
% S_p_signs = zeros(n_x,n_p);







