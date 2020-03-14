%% Compute the sensitivity matrices at t_final for initial state x0 and constant input p
% The default method (0) takes an Euler approximation of the partial
% derivative definitions of the sensitivities.
% The user can ask to apply one of the two alternative methods, where we
% solve (with ODE45) the time-varying linear ODEs defining the dynamics of
% the sensitivities. The matrices of these ODEs are the Jacobians.
% Method (1) defines these ODEs with Euler approximations of the Jacobians.
% Method (2) defines these ODEs by reading the Jacobian values from the
% user-provided function Input_files/UP_Jacobian_Function.m

% Source paper 1 (ODE for the sensitivity to initial states):
% A. Donzé and O. Maler, "Systematic simulation using sensitivity 
% analysis." International Workshop on Hybrid Systems: Computation and 
% Control. Springer, Berlin, Heidelberg, pp. 174-189, 2007. 
% DOI: 10.1007/978-3-540-71493-4_16

% Source paper 2 (ODE for the sensitivity to inputs):
% H. K. Khalil, "Nonlinear systems". Pearson, third edition, 2001.

% List of inputs
%   t_init: initial time
%   t_final: time at which the reachable set is approximated
%   x0: initial state (at time t_init)
%   p: constant input value over the time range [t_init,t_final]

% List of optional inputs (first one is required if second one is provided)
%   needed_sensitivies: 0 (default) compute both S_x and S_p
%                       1 if only S_x is needed
%                       2 if only S_p is needed
%   solver_choice:  0 Euler method on the sensitivity definition
%                   1 Euler method on Jacobian + ODE45 on sensitivity ODE
%                   2 ODE45 on sensitivity ODE using explicit Jacobian function (requires Input_files/UP_Jacobian_Function.m)

% List of outputs
%   S_x: sensitivity of successors (at time t_final) to variations of initial states (at time t_init)
%   S_p: sensitivity of successors (at time t_final) to variations of inputs

% Authors:  
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 13th of October 2018

function [S_x,S_p] = Sensitivity_solver(t_init,t_final,x0,p,needed_sensitivies,solver_choice)
n_x = length(x0);
n_p = length(p);

% Initialization of the sensitivity matrices
S_x = zeros(n_x);
S_p = zeros(n_x,n_p);

% Extract from Solver_parameters.m the parameters for Euler approximations
run('Solver_parameters.m')
euler_epsilon = parameters.euler_epsilon;         % Initial step size
euler_tolerance = parameters.euler_tolerance;     % Error tolerance between iterations (stopping condition of the loop) 
euler_max_iter = parameters.euler_max_iter;       % Max number of iterations (each iteration devides the step by 2)

% Set default values if the optional input arguments are not provided
if nargin < 5 || ~ismember(needed_sensitivies,[1,2])
    needed_sensitivies = 0;
end
if nargin < 6 || ~ismember(solver_choice,[1,2])
    solver_choice = 0;
end
% To avoid checking it at each call of this function, we assume that for 
% "solver_choice = 2", we have checked in a parent function that the 
% Jacobian function in Input_files/UP_Jacobian_Function.m  has been 
% provided by the user. This can be done by checking if the outputs of 
% UP_Jacobian_Function are not NaN matrices.
% Otherwise we need to pick the default "solver_choice = 0".


% Solver choice to obtain the sensitivity matrices at t_final
switch solver_choice
    case 1
        %% Solve time-varying linear ODEs representing the sensitivity evolution, and whose matrices are the Jacobians evaluated through Euler approximations

        % Solve system over [t_init,t_final]
        ode_solution = ode45(@(t,x) System_description(t,x,p),[t_init,t_final],x0);

        % Solve state sensitivity equation dS_x(t)/dt=J_x(t)*S_x(t)
        if needed_sensitivies ~= 2
            [~,S_x_traj] = ode45(@(t,S_x) Sensitivity_system_state(t,S_x,ode_solution,p,euler_epsilon,euler_tolerance,euler_max_iter),[t_init,t_final],reshape(eye(n_x),n_x*n_x,1));
            S_x = reshape(S_x_traj(end,:),n_x,n_x);
        end

        % Solve input sensitivity equation dS_p(t)/dt=J_x(t)*S_p(t)+J_p(t)
        if needed_sensitivies ~= 1
            [~,S_p_traj] = ode45(@(t,S_p) Sensitivity_system_input(t,S_p,ode_solution,p,euler_epsilon,euler_tolerance,euler_max_iter),[t_init,t_final],zeros(n_x*n_p,1));
            S_p = reshape(S_p_traj(end,:),n_x,n_p);
        end

    case 2
        %% Solve time-varying linear ODEs representing the sensitivity evolution, and whose matrices are the Jacobians read from UP_Jacobian_Function.m
        % This method requires user-provided Jacobian function in Input_files/UP_Jacobian_Function.m
        
        % Solve system over [t_init,t_final]
        ode_solution = ode45(@(t,x) System_description(t,x,p),[t_init,t_final],x0);
        
        % Defined a handle for the user-provided Jacobian function
        Handle_Jacobians = @(t,x,p) UP_Jacobian_Function(t_init,t,x,p);
        
        % Solve state sensitivity equation dS_x(t)/dt=J_x(t)*S_x(t)
        if needed_sensitivies ~= 2
            [~,S_x_traj] = ode45(@(t,S_x) Sensitivity_system_state(t,S_x,ode_solution,p,Handle_Jacobians),[t_init,t_final],reshape(eye(n_x),n_x*n_x,1));
            S_x = reshape(S_x_traj(end,:),n_x,n_x);
        end
        
        % Solve input sensitivity equation dS_p(t)/dt=J_x(t)*S_p(t)+J_p(t)
        if needed_sensitivies ~= 1
            [~,S_p_traj] = ode45(@(t,S_p) Sensitivity_system_input(t,S_p,ode_solution,p,Handle_Jacobians),[t_init,t_final],zeros(n_x*n_p,1));
            S_p = reshape(S_p_traj(end,:),n_x,n_p);
        end
        
    otherwise
        %% Euler approximation of the sensitivity definitions (default)
        % Approximate the sensitivities from their partial derivative definitions: 
        % S_x(t_final) = dx(t_final;t_init,x0,p)/dx0
        % S_p(t_final) = dx(t_final;t_init,x0,p)/dp

        % Sensitivity to variations of initial states
        if needed_sensitivies ~= 2
            % Define function handle taking initial state as argument and returning the successor of the system at time t_final
            function_handle = @(x_arg) deval(ode45(@(t,x) System_description(t,x,p),[t_init,t_final],x_arg),t_final);
            % Euler approximation of the state sensitivity matrix
            S_x = Derivative_Euler_approximation(x0,function_handle,euler_epsilon,euler_tolerance,euler_max_iter);
        end

        % Sensitivity to variations of inputs
        if needed_sensitivies ~= 1
            % Define function handle taking the input as argument and returning the successor of the system at time t_final
            function_handle = @(p_arg) deval(ode45(@(t,x) System_description(t,x,p_arg),[t_init,t_final],x0),t_final);
            % Euler approximation of the input sensitivity matrix
            S_p = Derivative_Euler_approximation(p,function_handle,euler_epsilon,euler_tolerance,euler_max_iter);
        end
end

end


%% Dynamical system of the sensitivity to variations of the initial states
% dS_x(t)/dt=J_x(t)*S_x(t)

% List of inputs
%   t: current time
% 	S_x: current state sensitivity, as a [n_x*n_x,1] vector
%   ode_solution: solution structure for a trajectory of the system
%   p: current input value
%   varargin: 1 or 3 input arguments, depending on the method used to
%       evaluate the current Jacobian value
%       1 argument: Handle_Jacobians = @(t,x,p) UP_Jacobian_Function(t_init,t,x,p), returns [J_x,J_p] at time t
%       3 arguments: euler_epsilon, euler_tolerance, euler_max_iter (parameter for Euler approximation)
% List of outputs
%   S_x_dot: derivative of the state sensitivity, as a [n_x*n_x,1] vector

function S_x_dot = Sensitivity_system_state(t,S_x,ode_solution,p,varargin)
n_x = sqrt(size(S_x,1));

% Interpolate nominal trajectory at time t
x_interp = deval(ode_solution,t);

% Check how the current Jacobian J_x(t) is obtained (based on number of input arguments)
switch length(varargin)
    case 1
        % Use the user-provided function Input_files/UP_Jacobian_Function.m
        Handle_Jacobians = varargin{1};
        % Extract Jacobian value for the current conditions
        [J_x,~] = Handle_Jacobians(t,x_interp,p);
    case 3
        % Use an Euler approximation of the Jacobian matrix
        euler_epsilon = varargin{1};        % Initial step size
        euler_tolerance = varargin{2};      % Error tolerance between iterations (stopping condition of the loop) 
        euler_max_iter = varargin{3};       % Max number of iterations (each dividing the step by 2)
        % Euler approximation of the current Jacobian value
        J_x = Derivative_Euler_approximation(x_interp,@(x) System_description(t,x,p),euler_epsilon,euler_tolerance,euler_max_iter);
    otherwise
        error('Wrong number of input arguments provided to function Sensitivity_system_state')
end

% Linear system, with S_x_dot and S_x as [n_x*n_x,1] vectors (instead of matrices)
J_vector = [];
for i = 1:n_x
    J_vector = blkdiag(J_vector,J_x);
end
S_x_dot = J_vector*S_x;
end


%% Dynamical system of the sensitivity to variations of the inputs
% dS_p(t)/dt=J_x(t)*S_p(t)+J_p(t)

% List of inputs
%   t: current time
% 	S_p: current input sensitivity, as a [n_x*n_p,1] vector
%   ode_solution: solution structure for a trajectory of the system
%   p: current input value
%   varargin: 1 or 3 input arguments, depending on the method used to
%       evaluate the current Jacobian value
%       1 argument: Handle_Jacobians = @(t,x,p) UP_Jacobian_Function(t_init,t,x,p), returns [J_x,J_p] at time t
%       3 arguments: euler_epsilon, euler_tolerance, euler_max_iter (parameter for Euler approximation)
% List of outputs
%   S_p_dot: derivative of the input sensitivity, as a [n_x*n_p,1] vector

function S_p_dot = Sensitivity_system_input(t,S_p,ode_solution,p,varargin)
n_p = length(p);
n_x = length(S_p)/n_p;

% Interpolate nominal trajectory at time t
x_interp = deval(ode_solution,t);

% Check how the current Jacobians J_x(t) and J_p(t) are obtained (based on number of input arguments)
switch length(varargin)
    case 1
        % Use the user-provided function Input_files/UP_Jacobian_Function.m
        Handle_Jacobians = varargin{1};
        % Extract Jacobian value for the current conditions
        [J_x,J_p] = Handle_Jacobians(t,x_interp,p);
    case 3
        % Use an Euler approximation of the Jacobian matrices
        euler_epsilon = varargin{1};        % Initial step size
        euler_tolerance = varargin{2};      % Error tolerance between iterations (stopping condition of the loop) 
        euler_max_iter = varargin{3};       % Max number of iterations (each dividing the step by 2)
        % Euler approximation of the current Jacobian values
        J_x = Derivative_Euler_approximation(x_interp,@(x) System_description(t,x,p),euler_epsilon,euler_tolerance,euler_max_iter);
        J_p = Derivative_Euler_approximation(p,@(p) System_description(t,x_interp,p),euler_epsilon,euler_tolerance,euler_max_iter);
    otherwise
        error('Wrong number of input arguments provided to function Sensitivity_system_input')
end

% Linear system, with S_p_dot and S_p as [n_x*n_p,1] vectors (instead of matrices)
J_x_vector = [];
for i = 1:n_p
    J_x_vector = blkdiag(J_x_vector,J_x);
end
S_p_dot = J_x_vector*S_p + reshape(J_p,n_x*n_p,1);
end


%% Euler approximation of a partial derivative matrix (Jacobian or Sensitivity)
% Consider the variations of function_handle with respect to the variations
% of its input argument, evaluated at input_point.

% List of inputs
%   input_point: point around which the derivative is evaluated
% 	function_handle: function whose derivative is computed
%   euler_epsilon: initial step size of the Euler approximation
%   euler_tolerance: error tolerance (stopping condition of the loop)
%   euler_max_iter: max number of iterations (each dividing the step by 2)
% List of outputs
%   derivative: approximation of the partial derivative matrix

function derivative = Derivative_Euler_approximation(input_point,function_handle,euler_epsilon,euler_tolerance,euler_max_iter)

% Evaluation of the function at the desired input point
function_eval = function_handle(input_point);

% Initialization of useful variables
size_input = length(input_point);
size_output = length(function_eval);
Identity = eye(size_input);
derivative = NaN(size_output,size_input);

% Compute each column of the partial derivative matrix
for j = 1:size_input
    % Initialization of the loop iteratively improving the approximation
    iter = 1;
    column_current = zeros(size_output,1);
    column_prev = ones(size_output,1);
    step = euler_epsilon;
    
    % Loop until two successive approximation are sufficiently close
    while norm(column_current-column_prev)>euler_tolerance && iter<=euler_max_iter
        % Save previous approximation
        column_prev = column_current;
        % Compute new approximation
        column_current = (function_handle(input_point+step*Identity(:,j))-function_eval)/step;
        % Increase the iteration counter
        iter = iter+1;
        % Divide the step size by 2
        step = step/2;
    end
    
    % The last approximation is stored in the j-th column
    derivative(:,j) = column_current;
end
end
