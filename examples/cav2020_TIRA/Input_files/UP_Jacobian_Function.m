%% User-provided description of the Jacobian functions
% Jacobian definitions:
%   to states:  J_x(t) = d(System_description(t,x,p))/dx
%   to inputs:  J_p(t) = d(System_description(t,x,p))/dp

% List of inputs
%   t_init: initial time
%   t: current time (for continuous-time system only)
%       for discrete-time system, a dummy value can be provided
%   x: current state
%   p: current input

% List of outputs
%   J_x: evaluation of the current Jacobian with respect to the state
%   J_p: evaluation of the current Jacobian with respect to the input

% Authors:  
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 13th of October 2018

function [J_x,J_p] = UP_Jacobian_Function(t_init,t,x,p)
n_x = length(x);
n_p  = length(p);

%% Default values as NaN (not a number)
J_x = NaN(n_x);
J_p = NaN(n_x,n_p);

%% User-provided Jacobian functions depending on inputs: t_init,t,x,p

% If System_description.m has no input variable 'p', uncomment below:
% J_p = zeros(n_x,n_p);



