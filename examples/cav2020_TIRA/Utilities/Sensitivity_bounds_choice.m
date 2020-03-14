%% Compute interval matrices bounding the possible values of each sensitivity matrix
% The user can either ask for a specific method, or let the function pick
% the best method based on which user-provided files are available in the
% folder ./Input_files
% For the sampling and falsification method, the user can also specify
% which solver to use to evaluate the sensitivity values.

% List of inputs
%   t_init: initial time
%   t_final: time at which the reachable set is approximated
%   [x_low,x_up]: interval of initial states (at time t_init)
%   [p_low,p_up]: interval of allowed input values

% List of optional inputs (read from Solver_parameters.m if not provided)
%   sensitivity_bounds_method: (optional) integer to pick the method to obtain the sensitivity bounds
%       1: Read sensitivity bounds from user-provided files (requires either Input_files/UP_Sensitivity_Bounds.m or Input_files/UP_Sensitivity_Signs.m)
%       2: Interval Arithmetics (requires Input_files/UP_Jacobian_Function.m)
%       0: Sampling and falsification
%       NaN: let the function select the best available method based on provided files in './Input_files' folder (default if no file is provided: 0) 
%   sampling_sensitivity_solver: (optional) integer to pick the solver used to evaluate sensitivity values within the sampling and falsitication methods
%       0: Euler method on the sensitivity definition
%       1: Euler method on Jacobian + ODE45 on sensitivity ODE
%       2: ODE45 on sensitivity ODE using explicit Jacobian function (requires Input_files/UP_Jacobian_Function.m)
%       NaN: let the function select the best available solver based on provided files in './Input_files' folder (default if no file is provided: 0) 

% List of outputs
%   [S_x_low,S_x_up]: bounds of the sensitivity of successors (at time t_final) to variations of initial states (at time t_init)
%   [S_p_low,S_p_up]: bounds of the sensitivity of successors (at time t_final) to variations of inputs

% Authors:  
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 13th of October 2018

function [S_x_low,S_x_up,S_p_low,S_p_up] = Sensitivity_bounds_choice(t_init,t_final,x_low,x_up,p_low,p_up,sensitivity_bounds_method,sampling_sensitivity_solver)
%% Extract from Solver_parameters.m the method choices if not provided as input arguments of this function
run('Solver_parameters.m')
if nargin <= 6 
    sensitivity_bounds_method = parameters.sensitivity_bounds_method;
end
if nargin <= 7
    sampling_sensitivity_solver = parameters.sampling_sensitivity_solver;
end

%% Hierarchy of the methods to obtain sensitivity bounds

% If sensitivity_bounds_method is not defined (NaN), we use the following order:
%   Read from user-provided files (requires either Input_files/UP_Sensitivity_Bounds.m or Input_files/UP_Sensitivity_Signs.m)
%   Interval arithmetics method (requires user-provided file Input_files/UP_Sensitivity_Signs.m)
%   Sampling and falsification method
%       using sensitivity solver (sampling_sensitivity_solver=2) with explicit Jacobian function (if Input_files/UP_Jacobian_Function.m is provided)
%       using Euler approximation of the sensitivity (sampling_sensitivity_solver=0) otherwise 

% If sensitivity_bounds_method is provided by the user, we check if the
% requirements associated with the chosen method are fullfiled, and return
% an error message otherwise.

%% Read sensitivity bounds from a user-provided file
if isnan(sensitivity_bounds_method) || sensitivity_bounds_method == 1
    % Check Input_files/UP_Sensitivity_Bounds.m
    [S_x_low,S_x_up,S_p_low,S_p_up] = UP_Sensitivity_Bounds(t_init,t_final,x_low,x_up,p_low,p_up);
    if ~any(isnan(S_x_low(:))) && ~any(isnan(S_x_up(:))) && ~any(isnan(S_p_low(:))) && ~any(isnan(S_p_up(:)))
        % If all 4 bounds are defined, use them directly
        fprintf('Read sensitivity bounds from Input_files/UP_Sensitivity_Bounds.m\n')
        return
    end

    % Check Input_files/UP_Sensitivity_Signs.m
    [S_x_signs,S_p_signs] = UP_Sensitivity_Signs(t_init,t_final,x_low,x_up,p_low,p_up);
    if ~any(isnan(S_x_signs(:))) && ~any(isnan(S_p_signs(:)))
        % If sign matrices are defined, convert them into simple bounds
        % [1,1] if positive, [-1,-1] if negative, [0,0] otherwise
        S_x_low = (S_x_signs>0) - (S_x_signs<0);
        S_x_up = S_x_low;
        S_p_low = (S_p_signs>0) - (S_p_signs<0);
        S_p_up = S_p_low;
        fprintf('Read sensitivity signs from Input_files/UP_Sensitivity_Signs.m\n')
        return
    end

    % If both are undefined and user asked for this method: return error message to user
    if sensitivity_bounds_method == 1
        error('%s (sensitivity_bounds_method=%d), but:\n%s\n%s', ...
              'Asked to read sensitivity bounds from user-provided files', sensitivity_bounds_method, ...
              ' - sensitivity bounds are not defined in Input_files/UP_Sensitivity_Bounds.m', ...
              ' - sensitivity signs are not defined in Input_files/UP_Sensitivity_Signs.m')
    end
end

%% Interval arithmetics
if isnan(sensitivity_bounds_method) || sensitivity_bounds_method == 2
    % Check Input_files/UP_Jacobian_Bounds.m
    [J_x_low,J_x_up,J_p_low,J_p_up] = UP_Jacobian_Bounds(t_init,t_final,x_low,x_up,p_low,p_up);
    if ~any(isnan(J_x_low(:))) && ~any(isnan(J_x_up(:))) && ~any(isnan(J_p_low(:))) && ~any(isnan(J_p_up(:)))
        % If the Jacobian bounds are defined and the user did not explicitely ask for this method (picked by default due to UP_Jacobian_Bounds.m being defined) 
        if isnan(sensitivity_bounds_method)
            % Inform the user of possible alternative if the obtained results are too conservative 
            fprintf(['\n**Warning** Interval arithmetics method is used because UP_Jacobian_Bounds.m is defined).\n' ...
                     'If the final reachability results seem too conservative, consider the alternative approach using sampling and falsification,\n' ...
                     'by specifying sensitivity_bounds_method=0 in the call of the function Sensitivity_Bounds.\n' ...
                     'The sampling approach has a longer computation and lacks formal guarantees of reachable set over-approximation,\n' ...
                     'but it usually provides much tighter bounds on the reachable set.\n\n'])
        end
        
        % Then over-approximate the sensitivity bounds using interval arithmetics
        [S_x_low,S_x_up,S_p_low,S_p_up] = Sensitivity_interval_arithmetics(t_init,t_final,x_low,x_up,p_low,p_up,J_x_low,J_x_up,J_p_low,J_p_up);
        return
    elseif sensitivity_bounds_method == 2
        % If Jacobian bounds are undefined and user asked for this method: return error message to user
        error('%s (sensitivity_bounds_method=%d), but:\n%s', ...
              'Asked to use interval arithmetics to compute sensitivity bounds', sensitivity_bounds_method, ...
              ' - Jacobian bounds are not defined in Input_files/UP_Jacobian_Bounds.m')
    end
end

%% Sampling and falsification (default)
fprintf('Compute sensitivity bounds with the sampling and falsification method.\n')
% 3 solvers of the sensitivity equations are possible
%   0: Euler method on the sensitivity definition
%   1: Euler method on Jacobian + ODE45 on sensitivity ODE
%   2: ODE45 on sensitivity ODE using explicit Jacobian function (requires Input_files/UP_Jacobian_Function.m)

% If the user asked to use the sensitivity solver 2 or did not specify which solver to use 
if isnan(sampling_sensitivity_solver) || sampling_sensitivity_solver == 2
    % Check Input_files/UP_Jacobian_Function.m
    [J_x,J_p] = UP_Jacobian_Function(t_init,t_init,x_low,p_low);
    if ~any(isnan(J_x(:))) && ~any(isnan(J_p(:)))
        % If the Jacobian function is defined, use solver 2
        sampling_sensitivity_solver = 2;
    elseif sampling_sensitivity_solver == 2
        % If the Jacobian function is not defined and user asked for this solver, return an error
        error('%s %d %s (sensitivity_bounds_method=%d), but:\n%s', ...
              'Asked to use sensitivity solver', sampling_sensitivity_solver, ...
              'within the sampling and falsification method', sensitivity_bounds_method, ...
              ' - Jacobian functions are not defined in Input_files/UP_Jacobian_Function.m')
    else
        % Otherwise, pick sensitivity solver 0 by default
        sampling_sensitivity_solver = 0;
    end
end

% The remaining cases have no file requirement to be checked

switch sampling_sensitivity_solver
    case 1
        fprintf('Sensitivity solver used: solve sensitivity ODE with Euler approximation of Jacobians.\n')
    case 2
        fprintf('Sensitivity solver used: solve sensitivity ODE with user-provided Jacobian function.\n')
    otherwise
        fprintf('Sensitivity solver used: Euler approximation of sensitivity definition.\n')
end

% Call the sampling and falsification function
[S_x_low,S_x_up,S_p_low,S_p_up] = Sensitivity_sampling(t_init,t_final,x_low,x_up,p_low,p_up,sampling_sensitivity_solver);
[S_x_low,S_x_up,S_p_low,S_p_up] = Sensitivity_falsification(t_init,t_final,x_low,x_up,p_low,p_up,S_x_low,S_x_up,S_p_low,S_p_up,sampling_sensitivity_solver);
