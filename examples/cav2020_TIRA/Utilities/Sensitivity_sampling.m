%% Sampling-based approximation of the bounds of the sensitivity matrices
% For a given (or default) number of random pairs (x0,p) in the set 
% [x_low,x_up]*[p_low,p_up], evaluate the corresponding sensitivity values
% and define the sensitivity bounds as the component-wise min and max.
% 3 possible methods are available to evaluate the sensitivity matrices.
% The default method uses an Euler approximation of the partial derivative
% defining the sensitivity.

% Source paper:
% P.-J. Meyer, S. Coogan and M. Arcak, "Sampled-data reachability analysis 
% using sensitivity and mixed-monotonicity". IEEE Control Systems Letters,
% v. 2(4), pp. 761-766, 2018. DOI: 10.1109/LCSYS.2018.2848280

% List of inputs
%   t_init: initial time
%   t_final: time at which the reachable set is approximated
%   [x_low,x_up]: interval of initial states (at time t_init)
%   [p_low,p_up]: interval of allowed input values
%   solver_choice:  0 Euler method on the sensitivity definition
%                   1 Euler method on Jacobian + ODE45 on sensitivity ODE
%                   2 ODE45 on sensitivity ODE using explicit Jacobian function (requires Input_files/UP_Jacobian_Function.m)
%   sampling_pairs: (optional) number of pairs in [x_low,x_up]*[p_low,p_up] for which sensitivities are evaluated

% List of outputs
%   [S_x_low,S_x_up]: bounds of the sensitivity of successors (at time t_final) to variations of initial states (at time t_init)
%   [S_p_low,S_p_up]: bounds of the sensitivity of successors (at time t_final) to variations of inputs

% Authors:  
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 13th of October 2018

function [S_x_low,S_x_up,S_p_low,S_p_up] = Sensitivity_sampling(t_init,t_final,x_low,x_up,p_low,p_up,solver_choice,sampling_pairs)
n_x = length(x_low);
n_p  = length(p_low);

% Ignore state or input sensitivity if the corresponding interval is a singleton
needed_sensitivies = 0;         % Default: compute both S_x and S_p
if isequal(x_low,x_up)
    needed_sensitivies = 2;     % Only compute S_p
elseif isequal(p_low,p_up)
    needed_sensitivies = 1;     % Only compute S_x
end

% Set default number of sample pairs (x0,p) if not provided
if nargin <= 7
    % Use value of 'sampling_pairs' from Solver_parameters.m if provided 
    run('Solver_parameters.m')
    sampling_pairs = parameters.sampling_pairs;
    
    % Otherwise, set it to sampling_per_dimension^(n_x+n_p)
    if isnan(sampling_pairs)
        sampling_per_dimension = parameters.sampling_per_dimension;
        
        % Ignore n_x or n_p if the corresponding interval is a singleton
        sampling_pairs = 1;
        if ~isequal(x_low,x_up)
            sampling_pairs = sampling_pairs*sampling_per_dimension^n_x;
        end
        if ~isequal(p_low,p_up)
            sampling_pairs = sampling_pairs*sampling_per_dimension^n_p;
        end
    end
end

% Display the number of sample pairs
fprintf('Approximation of the sensitivity bounds based on %d state-input pair samples ...\n',sampling_pairs)
tic_sampling = tic;

% Initialization of the sensitivity bounds
S_x_low = NaN(n_x);
S_x_up = NaN(n_x);
S_p_low = NaN(n_x,n_p);
S_p_up = NaN(n_x,n_p);

% Update of the bounds for each sample pair (x0,p)
for i = 1:sampling_pairs
    % Pick a random pair (x0,p) in [x_low,x_up]*[p_low,p_up]
    x0 = x_low + rand(n_x,1).*(x_up-x_low);
    p = p_low + rand(n_p,1).*(p_up-p_low);
    
    % Obtain the corresponding sensitivity values
    [S_x,S_p] = Sensitivity_solver(t_init,t_final,x0,p,needed_sensitivies,solver_choice);
    
    % Update the sensitivity bounds
    S_x_low = min(S_x_low,S_x);
    S_x_up = max(S_x_up,S_x);
    S_p_low = min(S_p_low,S_p);
    S_p_up = max(S_p_up,S_p);
end
toc(tic_sampling)
