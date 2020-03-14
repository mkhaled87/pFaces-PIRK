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
bool_discrete_time = 0;
% Folder containing the various over-approximation methods
 addpath('../OA_methods')   
% % Folder containing useful tools and functions
 addpath('../Utilities')    

%% Choice of the example system
global system_choice
 system_choice = 1;      % Traffic diverge n_x links
% system_choice = 2;      % quadrotor swarm

%% Optional submethod choice for the sampled-data mixed-monotonicity method
global sensitivity_method_setting
sensitivity_method_setting = NaN;

%% Definition of the reachability problem (for each example system)
global u        % Some systems need an external control input
switch system_choice        
    case 1
        %% Traffic diverge n_x-link
        % Defined as a system with additive input: dx=f(t,x)+p

        % Number of links in traffic network (needs to be >=5)
        n_x = 10;

        T = 30; % Time step

        % Interval of initial states (defined by two column vectors)
        x_low = 100*ones(n_x,1);
        x_up = 200*ones(n_x,1);

        % Interval of allowed input values (defined by two column vectors)
        p_low = zeros(n_x,1);
        p_low(1) = 40/T;
        p_up = zeros(n_x,1);
        p_up(1) = 60/T;
        n_p  = length(p_low);

        % Time interval
        t_init = 0;         % Initial time
        t_final = t_init + T;        % Final time
        
    case 2
        %% Quadrotor swarm
        n_quads = 1;
        n_x = 12*n_quads;
        n_p = 12*n_quads;
        T = 10;
        x_low_one_quad = [-0.4; -0.4; -0.4; -0.1; -0.1; -0.1; -0.4; -0.4; -0.4; 0; 0; 0];
        x_low = repmat(x_low_one_quad, n_quads, 1);
        x_up_one_quad = [0.4; 0.4; 0.4; 0.1; 0.1; 0.1; 0.4; 0.4; 0.4; 0; 0; 0];
        x_up = repmat(x_up_one_quad, n_quads, 1);
        p_low_one_quad = [0; 0; 0; 0; 0; 0; 0; 0; 0; -0.5; -0.5; -0.5];
        p_low = repmat(p_low_one_quad, n_quads, 1);
        p_up_one_quad = [0; 0; 0; 0; 0; 0; 0; 0; 0; 0.5; 0.5; 0.5];
        p_up = repmat(p_up_one_quad, n_quads, 1);
        t_init = 0;
        t_final = t_init + T;
end

%% Call of the main over-approximation function
% succ_low is the lower bound of the over-approximation interval
% succ_up is the upper bound of the over-approximation interval

if bool_discrete_time
    % Call for discrete-time systems for one step starting from time t_init
    [succ_low,succ_up] = TIRA(t_init,x_low,x_up,p_low,p_up);
else
    % Call for continuous-time systems over the time range [t_init,t_final]
    [succ_low,succ_up] = TIRA([t_init,t_final],x_low,x_up,p_low,p_up);

end

disp('done')
