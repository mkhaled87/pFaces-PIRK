%% Extract or create a contraction/growth bound function handle
% The user can either ask for a specific method, or let the function pick
% the best method based on which user-provided files are available in the
% folder ./Input_files

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

% Optional input (read from Solver_parameters.m if not provided)
%   growth_bound_method: (optional) integer to pick the method to obtain the growth bound
%       1: Take growth bound from user-provided file (requires Input_files/UP_Growth_Bound_Function.m)
%       2: Create a growth bound function from user-provided contraction matrix (requires Input_files/UP_Contraction_Matrix.m)
%       3: Create a growth bound function from the contraction matrix extracted from user-provided Jacobian bounds (requires Input_files/UP_Jacobian_Bounds.m) 
%       NaN: let the function select the best available method (in the above order) based on provided files in './Input_files' folder

% List of outputs
%   GB_handle: function handle of the growth bound 
%       inputs: positive time, positive state vector, positive input vector
%       output: positive state vector (growth or contraction of the system)
%   bool_skip_CTGB: flag if none of the existing submethods can be applied
%       1 if no growth bound function provided and dynamics do not have 
%           additive inputs
%       2 otherwise (dynamics have additive inputs but the user provided
%          none of the required input files)

% Authors:  
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 13th of October 2018

function [GB_handle,bool_skip_CTGB] = Growth_bound_choice(t_init,t_final,x_low,x_up,p_low,p_up,growth_bound_method)
n_x = length(x_low);
n_p = length(p_low);
bool_skip_CTGB = 0;

%% Extract from Solver_parameters.m the method choice if not provided as input argument of this function
run('Solver_parameters.m')
if nargin <= 6 
    growth_bound_method = parameters.growth_bound_method;
end

%% Use directly the user-provided growth bound function
if isnan(growth_bound_method) || growth_bound_method == 1
    % Check Input_files/UP_Growth_Bound_Function.m
    GB_handle = UP_Growth_Bound_Function(t_init,t_final,x_low,x_up,p_low,p_up);
    if ~any(isnan(GB_handle(1,ones(n_x,1),ones(n_p,1))))
        % If the function is defined, use it directly
        fprintf('Extract growth bound function handle from Input_files/UP_Growth_Bound_Function.m\n')
        return
    end
    
    % If undefined and user asked for this method: return error message to user
    if growth_bound_method == 1
        error('%s%d, but:\n%s', ...
              'Asked for growth_bound_method=', growth_bound_method, ...
              ' - growth bound function is not defined in Input_files/UP_Growth_Bound_Function.m')
    end
end


% For the other two options below, the system dynamics need to be
% defined with additive input.
% (use tolerance eps(2)=2^(-51) to account for numerical errors)
if n_p~=n_x || ...
   any(abs((System_description(t_final,x_low,p_up)-System_description(t_final,x_low,zeros(n_p,1))) - p_up) > eps(2) | ...
       abs((System_description(t_final,x_low,p_low)-System_description(t_final,x_low,zeros(n_p,1))) - p_low) > eps(2) | ...
       abs((System_description(t_final,x_up,p_up)-System_description(t_final,x_up,zeros(n_p,1))) - p_up) > eps(2) | ...
       abs((System_description(t_final,x_up,p_low)-System_description(t_final,x_up,zeros(n_p,1))) - p_low) > eps(2))
    if isnan(growth_bound_method)
        % If a specific growth_bound_method is not requested,
        % raise a flag that the growth bound method cannot be used
        fprintf('No growth bound function provided and dynamics do not have additive input.\n')
        bool_skip_CTGB = 1;
        GB_handle = NaN;
        return
    else
        % If growth_bound_method is 2 or 3, return an error
        error('%s%d, but:\n%s', ...
              'Asked for growth_bound_method=', growth_bound_method, ...
              ' - system needs to be defined with an additive input: System_description(t,x,p) = System_description(t,x,0) + p')
    end
end

%% Create a growth bound function from user-provided contraction matrix
if isnan(growth_bound_method) || growth_bound_method == 2
    % Check Input_files/UP_Contraction_Matrix.m
    C = UP_Contraction_Matrix(t_init,t_final,x_low,x_up,p_low,p_up);
    if ~any(isnan(C(:))) && (isequal(size(C),[n_x n_x]) || isscalar(C))
        fprintf('Read contraction matrix from Input_files/UP_Contraction_Matrix.m\n')
        
        % Check consistency of user-provided matrix
        assert(all(C(~logical(eye(n_x)))>=0),'The contraction matrix needs non-negative off-diagonal elements.')
        
        % If C is correctly defined, define a growth bound function
        GB_handle = @(t,x,p) expm(C*t)*x + integral(@(s) expm(C*s)*p,0,t,'ArrayValued',true);
        return
    end
    
    % If undefined and user asked for this method: return error message to user
    if growth_bound_method == 2
        error('%s%d, but:\n%s', ...
              'Asked for growth_bound_method=', growth_bound_method, ...
              ' - contraction matrix (or scalar) is not defined in Input_files/UP_Contraction_Matrix.m')
    end
end

%% Create a growth bound function based on a contraction matrix extracted from user-provided Jacobian bounds
% To be usable in the over-approximation using the growth bound associated 
% with this matrix, the bounds on the state Jacobian below need to be
% valid not only for initial states in [x_low,x_up], but also for any state
% reachable over time range [t_init,t_final] by the system with constant
% input equal to the center of the input interval [p_low,p_up]

if isnan(growth_bound_method) || growth_bound_method == 3
    % Check Input_files/UP_Jacobian_Bounds.m
    input_center = (p_low+p_up)/2;
    [J_x_low,J_x_up,~,~] = UP_Jacobian_Bounds(t_init,t_final,x_low,x_up,input_center,input_center);
    if ~any(isnan(J_x_low(:))) && ~any(isnan(J_x_up(:)))
        fprintf('Create contraction matrix from state Jacobian bounds read in Input_files/UP_Jacobian_Bounds.m\n')
        
        % Check consistency of user-provided interval
        assert(all(J_x_low(:)<=J_x_up(:)),'Inconsistent bounds of the state Jacobian provided: need J_x_low <= J_x_up')
        
        % If state Jacobian bounds are defined, 
        % convert them into a contraction matrix
        C = max(abs(J_x_low),abs(J_x_up));   % Off-diagonal elements: upper bound on the absolute values
        C(1:n_x+1:end) = diag(J_x_up);       % Diagonal elements: take Jacobian upper bound directly

        % Use this matrix to create a growth bound    
        GB_handle = @(t,x,p) expm(C*t)*x + integral(@(s) expm(C*s)*p,0,t,'ArrayValued',true);
        return
    end
    
    % If undefined and user asked for this method: return error message to user
    if growth_bound_method == 3
        error('%s%d, but:\n%s', ...
              'Asked for growth_bound_method=', growth_bound_method, ...
              ' - Jacobian bounds are not defined in Input_files/UP_Jacobian_Bounds.m')
    end
end

%% If growth_bound_method was not provided and none of the above method could be applied
% raise a flag that the growth bound method cannot be used
fprintf('None of the required inputs are provided (growth bound function, or contraction matrix, or state Jacobian bounds).\n')
bool_skip_CTGB = 2;
GB_handle = NaN;
