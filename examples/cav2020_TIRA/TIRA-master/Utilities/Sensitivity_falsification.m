%% Falsification approach to iteratively improve the current bounds of the sensitivity matrices
% Defines an optimization problem looking for pairs (x0,p) whose
% sensitivity matrices do not belong to the current sensitivity bounds.
% The problem uses a cost function such that local minima with a negative
% cost value means that the argmin falsifies the current sensitivity
% bounds, which can thus be updated before repeating the falsification.
% Since we only deal with local minima, there may exist falsifying pairs 
% (x0,p) which are not found by the optimization problem.

% Source paper:
% P.-J. Meyer, S. Coogan and M. Arcak, "Sampled-data reachability analysis 
% using sensitivity and mixed-monotonicity". IEEE Control Systems Letters,
% v. 2(4), pp. 761-766, 2018. DOI: 10.1109/LCSYS.2018.2848280

% List of inputs
%   t_init: initial time
%   t_final: time at which the reachable set is approximated
%   [x_low,x_up]: interval of initial states (at time t_init)
%   [p_low,p_up]: interval of allowed input values
%   [S_x_low,S_x_up]: bounds of the sensitivity of successors (at time t_final) to variations of initial states (at time t_init)
%   [S_p_low,S_p_up]: bounds of the sensitivity of successors (at time t_final) to variations of inputs
%   solver_choice:  0 Euler method on the sensitivity definition
%                   1 Euler method on Jacobian + ODE45 on sensitivity ODE
%                   2 ODE45 on sensitivity ODE using explicit Jacobian function (requires Input_files/UP_Jacobian_Function.m)
% List of outputs
%   [S_x_low,S_x_up]: updated bounds for the state sensitivity
%   [S_p_low,S_p_up]: updated bounds for the input sensitivity

% Authors:  
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 13th of October 2018

function [S_x_low,S_x_up,S_p_low,S_p_up] = Sensitivity_falsification(t_init,t_final,x_low,x_up,p_low,p_up,S_x_low,S_x_up,S_p_low,S_p_up,solver_choice)
n_x = length(x_low);

% Extract from Solver_parameters.m the falsification parameters
run('Solver_parameters.m')
falsification_max_iter = parameters.falsification_max_iter;
if falsification_max_iter == 0
    % If falsification_max_iter==0, the falsification loop is skipped
    fprintf('Falsification of the sensitivity bounds skipped (falsification_max_iter = %d)',falsification_max_iter)
    return
end

% Skip falsification if the Optimization Toolbox is unavailable
if ~license('test','Optimization_Toolbox')
    fprintf('Falsification of the sensitivitiy bounds requires the Matlab Optimization Toolbox.\n')
    fprintf('Falsification skipped due to unavailable toolbox.\n')
    return
end

% Display the use of the falsification method
fprintf('Falsification of the sensitivity bounds ... ')
tic_falsification = tic;

% Ignore state or input sensitivity if the corresponding interval is a singleton
needed_sensitivies = 0;         % Default: compute both S_x and S_p
if isequal(x_low,x_up)
    needed_sensitivies = 2;     % Only compute S_p
elseif isequal(p_low,p_up)
    needed_sensitivies = 1;     % Only compute S_x
end

% Get centers of [x_low,x_up] and [p_low,p_up]
x_center = (x_low+x_up)/2;
p_center = (p_low+p_up)/2;

% Disable the display of fmincon results
opt = optimset('Display','off');

% Initialization of the loop parameters
iter = 0;       % number of falsification iterations
min_cost = -1;  % minimum of the cost function (if negative, then sensitivity bounds can be improved)

% Loop until sensitivity bounds cannot be improved further, or falsification_max_iter is reached
while (min_cost + eps(2) < 0) && (iter < falsification_max_iter)      % eps(2)=2^(-51) to account for numerical errors
    iter = iter + 1;
    
    % Define the handle of the cost function taking only [x0;p] as input argument 
    Cost_handle = @(x0_p) Falsification_Cost(x0_p,t_init,t_final,S_x_low,S_x_up,S_p_low,S_p_up,needed_sensitivies,solver_choice);
    
    % Falsification of the sensitivity bounds by minimizing the cost function, initialized at the center of [x_low,x_up]*[p_low,p_up] 
    [x0_p_stack,min_cost] = fmincon(Cost_handle,[x_center;p_center],[],[],[],[],[x_low;p_low],[x_up;p_up],[],opt);

    % If the local minimum has a negative cost, the corresponding sensitivity does not belong to the current bounds
    if min_cost < 0
        % Get the sensitivities of the argmin
        [S_x,S_p] = Sensitivity_solver(t_init,t_final,x0_p_stack(1:n_x),x0_p_stack(n_x+1:end),needed_sensitivies,solver_choice);
        % Update the sensitivity bounds
        S_x_low = min(S_x_low,S_x);
        S_x_up = max(S_x_up,S_x);
        S_p_low = min(S_p_low,S_p);
        S_p_up = max(S_p_up,S_p);
    end
end

% Display the number of falsification iterations and computation time
if iter == 1
    fprintf('no further improvement after %d iteration.\n',iter)
else
    fprintf('no further improvement after %d iterations.\n',iter)
end
toc(tic_falsification)

end


%% Cost function to be used within fmincon for the falsification of the sensitivity bounds
% For this, each element of S_x and S_p is associated to an upside-down 
% absolute value function, translated such that it returns a positive value
% when the sensitivity belongs to its interval, and negative otherwise:
%   S_half_width(i,j) - abs(S(i,j)-S_center(i,j))
% The global cost takes the minimum over all elements of S_x and S_p so
% that it is negative if and only if at least one element of S_x or S_p
% does not lie in the current bounds [S_x_low,S_x_up] or [S_p_low,S_p_up].

% List of inputs
%   x0_p_stack: stacked vector [x0;p] of initial state and input
%   t_init: initial time
%   t_final: time at which the reachable set is approximated
%   [S_x_low,S_x_up]: bounds of the sensitivity of successors (at time t_final) to variations of initial states (at time t_init)
%   [S_p_low,S_p_up]: bounds of the sensitivity of successors (at time t_final) to variations of inputs
%   needed_sensitivies: 0 (default) compute both S_x and S_p
%                       1 if only S_x is needed
%                       2 if only S_p is needed
%   solver_choice:  0 Euler method on the sensitivity definition
%                   1 Euler method on Jacobian + ODE45 on sensitivity ODE
%                   2 ODE45 on sensitivity ODE using explicit Jacobian function (requires Input_files/UP_Jacobian_Function.m)
% List of outputs
%   cost: evaluation of the cost assotiated with the current conditions

function cost = Falsification_Cost(x0_p_stack,t_init,t_final,S_x_low,S_x_up,S_p_low,S_p_up,needed_sensitivies,solver_choice)
[n_x,~] = size(S_p_low);

% Extract initial state and input from stacked vector x0_p_stack
x0 = x0_p_stack(1:n_x);
p = x0_p_stack(n_x+1:end);

% Compute sensitivities for x0 and p
[S_x,S_p] = Sensitivity_solver(t_init,t_final,x0,p,needed_sensitivies,solver_choice);

% Evaluation of the cost assotiated with the current conditions
cost_x = NaN;
cost_p = NaN;
if needed_sensitivies ~= 2
    cost_x = min(min((S_x_up-S_x_low)/2-abs(S_x-(S_x_low+S_x_up)/2)));
end
if needed_sensitivies ~= 1
    cost_p = min(min((S_p_up-S_p_low)/2-abs(S_p-(S_p_low+S_p_up)/2)));
end
cost = min(cost_x,cost_p);
end
