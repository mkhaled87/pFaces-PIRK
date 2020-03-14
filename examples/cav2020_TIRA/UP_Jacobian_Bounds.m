%% User-provided function returning bounds on the Jacobian matrices
% The user can either provider global bounds, or a function of the input
% arguments (t_init,t_final,x_low,x_up,p_low,p_up) returning local bounds
% Jacobian definitions:
%   to states:  J_x(t) = d(System_description(t,x,p))/dx
%   to inputs:  J_p(t) = d(System_description(t,x,p))/dp

% List of inputs
%   t_init: initial time
%   t_final: time at which the reachable set is approximated (for continuous-time system only)
%       for discrete-time system, a dummy value can be provided
%   [x_low,x_up]: interval of initial states (at time t_init)
%   [p_low,p_up]: interval of allowed input values

% List of outputs
%   [J_x_low,J_x_up]: bounds of the Jacobian with respect to the state
%   [J_p_low,J_p_up]: bounds of the Jacobian with respect to the input

% Authors:  
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 13th of October 2018

function [J_x_low,J_x_up,J_p_low,J_p_up] = UP_Jacobian_Bounds(t_init,t_final,x_low,x_up,p_low,p_up)
n_x = length(x_low);
n_p  = length(p_low);

%% Default values as NaN (not a number)
J_x_low = NaN(n_x);
J_x_up = NaN(n_x);
J_p_low = NaN(n_x,n_p);
J_p_up = NaN(n_x,n_p);

%% User-provided Jacobian bounds
% Can be either global bounds
% or local bounds depending on inputs: t_init,t_final,x_low,x_up,p_low,p_up

% If System_description.m has no input variable 'p', uncomment below:
% J_p_low = zeros(n_x,n_p);
% J_p_up = zeros(n_x,n_p);

global system_choice
global u        % Some systems need an external control input

switch system_choice
    case 1
        %% Traffic diverge nx-link (needs n_x >= 5)
        % This system corresponds to a traffic flow like this:
        %         ---(x2)---(x4)--- ... ---(x(end-1))
        %        /
        % (x1)---
        %        \
        %         ---(x3)---(x5)--- ... ---(x(end))

        % Parameters
        v = 0.5;            % free-flow speed, in links/period
        w = 1/6;            % congestion-wave speed, in links/period
        b = 3/4;            % fraction of vehicule staying on the network after each link
        T = 30;             % time step for the continuous-time model, in seconds

        % State Jacobian
        J_x_low = zeros(n_x);
        J_x_up = zeros(n_x);
        
        J_x_low(1:3,1:5) = 1/T*[-v 0 0 0 0;0 -(v+w) -w 0 0;0 -w -(v+w) 0 0];
        J_x_up(1:3,1:5) = 1/T*[0 2*w 2*w 0 0;v/2 0 0 w/b 0;v/2 0 0 0 w/b];
        for i=4:(n_x-2)
            J_x_low(i,i) = -(w+v)/T;
            J_x_up(i,i-2) = b*v/T;
            J_x_up(i,i+2) = w/b/T;
        end
        J_x_low(end, end) = -(w+v)/T;
        J_x_low(end-1, end-1) = -(w+v)/T;
        J_x_up(end, end-2) = b*v/T;
        J_x_up(end-1, end-3) = b*v/T;

        % Input Jacobian
        J_p_low = zeros(n_x);
        J_p_low(1,1) = 1;
        J_p_up = J_p_low;
        
    case 2
        %% quadrotor swarm
        f = 1;
        m = 1;
        g = 9.8;
        J_x_low = zeros(n_x);
        J_x_up = zeros(n_x);
        n_quads = floor(n_x / 12);
        for i=0:(n_quads-1)
            bi = 12*i;
            J_x_low(bi+1, bi+7) = 1;
            J_x_low(bi+2, bi+8) = 1;
            J_x_low(bi+3, bi+9) = 1;
            J_x_low(bi+4, bi+10) = 1;
            J_x_low(bi+5, bi+11) = 1;
            J_x_low(bi+6, bi+12) = 1;
            J_x_low(bi+7, bi+4:bi+6) = -f/m;
            J_x_low(bi+8, bi+4:bi+6) = -f/m;
            J_x_low(bi+9, bi+4) = g - f/m;
            J_x_low(bi+9, bi+6) = g - f/m;
            
            J_x_up(bi+1, bi+7) = 1;
            J_x_up(bi+2, bi+8) = 1;
            J_x_up(bi+3, bi+9) = 1;
            J_x_up(bi+4, bi+10) = 1;
            J_x_up(bi+5, bi+11) = 1;
            J_x_up(bi+6, bi+12) = 1;
            J_x_up(bi+7, bi+4:bi+6) = f/m;
            J_x_up(bi+8, bi+4:bi+6) = f/m;
            J_x_up(bi+9, bi+4) = g + f/m;
            J_x_up(bi+9, bi+6) = g + f/m;
        end
        J_p_low = eye(n_x);
        J_p_up = eye(n_x);
end


