%% Choice of over-approximation methods, submethods and definition of their internal parameters
% All variables defined here are stored in the structure 'parameter', which
% is partially read in the relevant functions.
% The user can modify any of the variables defined in this file:
%  - either to ask for a specific over-approximation method or submethod
%  - or to change the internal parameters of these methods.

% Authors:  
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 6th of February 2019

%% Choice of the over-approximation method
%   1: using the monotonicity property (for continuous-time monotone systems) 
%       This choice will check if the system is monotone, then apply an
%       over-approximation method specific to monotone systems.
%       Pick option 3 for a slightly slower version but which does not
%       require checking the monotonicity satisfaction, yet will still
%       provide the same results if the system is indeed monotone.
%   2: using a contraction/growth bound function (for continuous-time monotone systems) 
%   3: using an extented definition of the mixed-monotonicity property to any system with bounded Jacobian matrices (for continuous-time systems) 
%   4: using a sampled-data version of mixed-monotonicity, relying on bounds on the sensitivity matrices of the system (for continuous-time systems with constant inputs over the considered time range)
%   5: using an extented definition of the mixed-monotonicity property to any system with bounded Jacobian matrices (for discrete-time systems)
%   6: Using only the given system dynamics to perform Monte Carlo sampling of the transition function
%   NaN: let the function TIRA.m select the best available method based on system properties and provided files in './Input_files' folder
parameters.OA_method = 2;

    %% (2): Contraction/Growth bound method choice

    % How is the growth bound obtained?
    %   1: Take growth bound from user-provided file (requires Input_files/UP_Growth_Bound_Function.m)
    %   2: Create a growth bound function from user-provided contraction matrix (requires Input_files/UP_Contraction_Matrix.m)
    %   3: Create a growth bound function from the contraction matrix extracted from user-provided Jacobian bounds (requires Input_files/UP_Jacobian_Bounds.m) 
    %   NaN: let the function Growth_bound_choice.m select the best available method (in the above order) based on provided files in './Input_files' folder
    parameters.growth_bound_method = NaN;

    %% (4): Sampled-data mixed-monotonicity: parameters and solver choice

    % How are bounds on the sensitivity matrices obtained?
    %	1: Read sensitivity bounds from user-provided files (requires either Input_files/UP_Sensitivity_Bounds.m or Input_files/UP_Sensitivity_Signs.m)
    %	2: Interval Arithmetics (requires Input_files/UP_Jacobian_Function.m)
    %	0: Sampling and falsification 
    %   NaN: let the function Sensitivity_Bounds.m select the best available method based on provided files in './Input_files' folder (default if no file is provided: 0) 
    parameters.sensitivity_bounds_method = NaN;

        %% (4-2): Interval arithmetics
        
        % Parameters of the interval arithmetics method in Sensitivity_Interval_Arithmetics.m
        parameters.taylor_order = 100;      % Initial order for the truncation of the Taylor series (may be interatively increased if the results are not satisfactory)
        parameters.taylor_tolerance = 1e-3; % Stopping condition: max relative error allowed between two iterations (to do a single iteration, set: taylor_tolerance = NaN)
        parameters.taylor_increment = 100;  % Taylor order increase at each iteration

        %% (4-0): Sampling and falsification 

        % Three solvers of the sensitivity equations are possible:
        %   0: Euler method on the sensitivity definition
        %   1: Euler method on Jacobian + ODE45 on sensitivity ODE
        %   2: ODE45 on sensitivity ODE using explicit Jacobian function (requires Input_files/UP_Jacobian_Function.m)
        %   NaN: let the function Sensitivity_Bounds.m select the best available solver based on provided files in './Input_files' folder (default if no file is provided: 0) 
        parameters.sampling_sensitivity_solver = NaN;

        % Parameters of the sampling method in Sensitivity_sampling.m
        parameters.sampling_pairs = NaN;             % Number of sample pairs in [x_low,x_up]*[p_low,p_up] for which sensitivities are evaluated
            % Set 'sampling_pairs = NaN' to let the sampling function pick a default value (sampling_per_dimension per state and input dimensions: sampling_per_dimension^(n_x+n_p)) 
            % Set 'sampling_pairs = 1' to skip the sampling and only do falsification
        parameters.sampling_per_dimension = 2;       % Used to define the default number of sample pairs in function Sensitivity_sampling.m when 'sampling_pairs = NaN'

        % Parameters of the falsification method in Sensitivity_falsification.m
        parameters.falsification_max_iter = Inf;     % Max number of falsification iterations ('Inf' for infinite, '0' to completely skip the falsification)

            %% (4-0-0) and (4-0-1): Sensitivity solvers relying on Euler approximations of either Sensitivity or Jacobian matrices
            
            % Parameters for Euler approximations in Sensitivity_solver.m
            parameters.euler_epsilon = 1e-4;         % Initial step size
            parameters.euler_tolerance = 1e-10;      % Error tolerance between iterations (stopping condition of the loop) 
            parameters.euler_max_iter = 4;           % Max number of iterations (each iteration devides the step by 2)
        
        %% (6): Direct Monte Carlo method
        parameters.montecarlo_epsilon = 0.05;  % Probabilistic guarantee accuracy parameter: Reachable set will contain 1-epsilon of the probability measure
        parameters.montecarlo_delta = 0.05;    % Probabilistic guarantee confidence parameter: Reachable set will satisfy the epsilon guarantee with probability 1-delta

%% Default values
% parameters.OA_method = NaN;
% parameters.growth_bound_method = NaN;
% parameters.sensitivity_bounds_method = NaN;
% parameters.taylor_order = 100;      
% parameters.taylor_tolerance = 1e-3; 
% parameters.taylor_increment = 100;  
% parameters.sampling_sensitivity_solver = NaN;
% parameters.sampling_pairs = NaN;            
% parameters.sampling_per_dimension = 3;      
% parameters.falsification_max_iter = Inf;   
% parameters.euler_epsilon = 1e-4;         
% parameters.euler_tolerance = 1e-10;      
% parameters.euler_max_iter = 4;         
