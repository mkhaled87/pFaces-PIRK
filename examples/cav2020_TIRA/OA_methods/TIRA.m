%% Hub function serving as interface between the reachability problem definition and the library of over-approximation methods available in folder ./OA_methods
% This function gathers the call of all over-approximation methods, each
% preceded by the tests of their requirements.
% If a specific method is requested by the user (either as the last
% argument of this function call, or defined in Solver_parameters.m), the
% function only checks the requirements for this method and then calls the
% over-approximation function (or returns an error if the requirements are
% not satisfied).
% Otherwise, the function applies the first over-approximation method whose
% requirements are met (in the order detailed below).

% List of inputs
%   time_vector: time information for the reachability analysis  
%       1D vector for discrete-time system: time_vector=t_init
%       2D vector for continuous-time system: time_vector=[t_init,t_final]
%   [x_low,x_up]: interval of initial states (at time t_init)
%   [p_low,p_up]: interval of allowed input values

% Optional input
%   OA_method: integer to request a specific over-approximation method
%       if not provided, checks if it is defined in Solver_parameters.m
%       if not defined in Solver_parameters.m either, the file picks the
%       first method whose requirements are met in the following order:
%       1 - Continuous-time monotonicity (skipped if OA_method not provided)
%       2 - Continuous-time componentwise contraction and growth bound
%       3 - Continuous-time mixed-monotonicity
%       4 - Continuous-time sampled-data mixed-monotonicity
%       5 - Discrete-time mixed-monotonicity

% List of outputs
%   [succ_low,succ_up]: interval over-approximation of the reachable set 
%       after one step for discrete-time system
%       or at time t_final for continuous-time system

% Authors:  
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 6th of February 2019

function [succ_low,succ_up] = TIRA(time_vector,x_low,x_up,p_low,p_up,OA_method)
n_x = length(x_low);

%% Extract from Solver_parameters.m the over-approximation method choice if not provided as input argument of this function
run('Solver_parameters.m')
if nargin < 6
    OA_method = parameters.OA_method;         
end

%% Extract time information
if length(time_vector) == 1
    % 1D vector: discrete-time system (time_vector = t_init)
    t_init = time_vector;
    t_final = NaN;
elseif length(time_vector) == 2
    % 2D vector: continuous-time system (time_vector = [t_init,t_final])
    t_init = time_vector(1);
    t_final = time_vector(2);
    if t_final == t_init
        % Test if the time range is a single time instant
        fprintf('The initial and final times are equals: the reachable set is the interval of initial states\n')
        succ_low = x_low;
        succ_up = x_up;
        return
    elseif t_final < t_init
        % Test if the time range is not properly defined 
        error('Inconsistent time range provided (t_final < t_init)')
    end
else
    error('time_vector can only contain 1 (for discrete-time system) or 2 elements (for continuous-time system)')
end

%% Check if the system is defined
system_eval = System_description(t_init,x_low,p_low);
assert(~any(isnan(system_eval)),'The considered system needs to be defined in System_description.m')

%% Check consistency of user-provided intervals
assert(all(x_low<=x_up),'Inconsistent interval of initial states provided: need x_low <= x_up')
assert(all(p_low<=p_up),'Inconsistent interval of inputs provided: need p_low <= p_up')

%% Check if over-approximation of the reachable set can be skipped
if all(isequal(x_low,x_up)) && all(isequal(p_low,p_up))
    % Both interval contain a single point: simply compute the successor
    fprintf('Provided intervals are singletons: exact reachable set is a singleton too\n')
    if isnan(t_final)
        % Discrete-time successor
        succ_low = System_description(t_init,x_low,p_low);
        succ_up = succ_low;
    else
        % Continuous-time successor
        [~,x_traj] = ode45(@(t,x) System_description(t,x,p_low),[t_init,t_final],x_low);
        succ_low = x_traj(end,:)';
        succ_up = succ_low;
    end
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Continuous-time methods %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If OA_method is not defined (NaN), we check the available methods in the
% following order (from the most to the least restrictive):
% - Componentwise contraction/growth bound
% - Mixed-monotonicity
% - Sampled-data mixed-monotonicity

%% Reachable set over-approximation based on the Jacobian signs, using continuous-time monotonicity
% This method is only checked if user specifically asks for it in OA_method
% (by construction, it is encompassed in the less scalable OA_method=3)
% Requirements:
% - Continuous-time system.
% - User-provided matrices of the Jacobian signs or Jacobian bounds.
% - If Jacobian bounds: they need to be sign-stable (checked below).
% - Jacobian signs need to have a specific structure (checked below)

bool_skip_CTM = 0;
if ~isnan(t_final) && OA_method == 1
    tic_CTM = tic;
    fprintf('\nChecking conditions for continuous-time monotonicity method...\n')
    
    % Check Input_files/UP_Jacobian_Signs.m
    [J_x_signs,J_p_signs] = UP_Jacobian_Signs(t_init,t_final,x_low,x_up,p_low,p_up);

    if any(isnan(J_x_signs(~logical(eye(n_x))))) || any(isnan(J_p_signs(:)))
        % If the Jacobian signs are not defined,            
        % Check Input_files/UP_Jacobian_Bounds.m
        [J_x_low,J_x_up,J_p_low,J_p_up] = UP_Jacobian_Bounds(t_init,t_final,x_low,x_up,p_low,p_up);
        if any(isnan(J_x_low(~logical(eye(n_x))))) || any(isnan(J_x_up(~logical(eye(n_x))))) || any(isnan(J_p_low(:))) || any(isnan(J_p_up(:)))
            % If the Jacobian bounds are not defined
            if OA_method == 1
                % Return an error if this method was specifically requested
                error('%s (OA_method=%d), but:\n%s\n%s', ...
                      'Continuous-time monotonicitiy approach selected', OA_method, ...
                      ' - Jacobian signs are not defined in Input_files/UP_Jacobian_Signs.m', ...
                      ' - Jacobian bounds are not defined in Input_files/UP_Jacobian_Bounds.m')
            else
                fprintf('Neither Jacobian signs nor bounds are provided.\n')
                % Flag to go to the next method if OA_method was undefined
                bool_skip_CTM = 1;
            end
        else
            fprintf('Read Jacobian bounds from Input_files/UP_Jacobian_Bounds.m\n')
            
            % Check consistency of user-provided intervals
            assert(all(J_x_low(~logical(eye(n_x)))<=J_x_up(~logical(eye(n_x)))),'Inconsistent bounds of the state Jacobian provided: need J_x_low <= J_x_up')
            assert(all(J_p_low(:)<=J_p_up(:)),'Inconsistent bounds of the input Jacobian provided: need J_p_low <= J_p_up')
            
            % Check sign-stability of the Jacobians bounds if they are defined
            if all(J_x_low(~logical(eye(n_x)))>=0 | J_x_up(~logical(eye(n_x)))<=0) && all(J_p_low(:)>=0 | J_p_up(:)<=0)
                % If sign-stable, extract the corresponding signs
                J_x_signs = (J_x_up>0) - (J_x_low<0);
                J_p_signs = (J_p_up>0) - (J_p_low<0);
                fprintf('Jacobian matrices are sign-stable.\n')
            elseif OA_method == 1
                % Return an error if this method was specifically requested
                error('%s (OA_method=%d), but:\n%s', ...
                      'Continuous-time monotonicitiy approach selected', OA_method, ...
                      ' - Jacobian bounds defined in Input_files/UP_Jacobian_Bounds.m are not sign-stable')
            else
                fprintf('Jacobian signs are not provided, and Jacobian bounds are not sign-stable.\n')
                % Flag to go to the next method if OA_method was undefined
                bool_skip_CTM = 1;
            end
        end
    else
        fprintf('Read Jacobian signs from Input_files/UP_Jacobian_Signs.m\n')
    end

    % Only check the monotonicity condition if Jacobian signs are provided
    if ~bool_skip_CTM
        % Continuous-time monotonicity has no condition on diag(J_x_signs)
        % To avoid leaving NaN diagonal elements, replace diagonal by zeros
        J_x_signs_no_nan = J_x_signs;
        J_x_signs_no_nan(1:n_x+1:end) = 0;

        % Check if Jacobian sign matrices correspond to a monotone system
        [is_monotone,partial_order_x,partial_order_p] = Monotonicity_sign_conditions(J_x_signs_no_nan,J_p_signs);
        if is_monotone
            fprintf('Jacobian signs satisfy the monotonicity condition.\n')
            fprintf('Call of the over-approximation method ...\n')
            % Call over-approximation method
            [succ_low,succ_up] = OA_1_CT_Monotonicity(t_init,t_final,x_low,x_up,p_low,p_up,partial_order_x,partial_order_p);
            toc(tic_CTM)
            return
        elseif OA_method == 1
            % Return an error if this method was specifically requested
            error('%s (OA_method=%d), but:\n%s', ...
                  'Continuous-time monotonicitiy approach selected', OA_method, ...
                  ' - provided Jacobian matrices do not correspond to a monotone system')
        else
            fprintf('Sign structure of the Jacobian matrices does not satisfy the monotonicity condition.\n')
        end
    end
    
    toc(tic_CTM)
end

%% Reachable set over-approximation based on componentwise contraction and a growth bound
% Requirements:
% - Continuous-time system.
% - User-provided growth bound function, 
% - or user-provided contraction matrix (or scalar), or bounds of the state Jacobian.
%       The last 2 cases also requires dynamics with additive input: 
%       System_description(t,x,p)=System_description(t,x,0)+p 
%       (checked below)

if ~isnan(t_final) && (isnan(OA_method) || OA_method == 2)
    tic_GB = tic;
    fprintf('\nChecking conditions for continuous-time method based on componentwise contraction or growth bounds...\n')
    
    % Check the requirements of growth bound method
    % and if satisfied, extract a growth bound function handle
    % from the corresponding submethod
    % Obtain a growth bound function handle (if possible)
    [GB_handle,bool_skip_CTGB] = Growth_bound_choice(t_init,t_final,x_low,x_up,p_low,p_up);
    
    % Only apply the over-approximation method if one of the submethod was
    % successful (i.e. if a growth bound handle was successfully obtained)
    if ~bool_skip_CTGB
        fprintf('Call of the over-approximation method ...\n')
        % Call over-approximation method
        [succ_low,succ_up] = OA_2_CT_Contraction_growth_Bound(t_init,t_final,x_low,x_up,p_low,p_up,GB_handle);
        toc(tic_GB)
        return
    elseif OA_method == 2
        % Otherwise return an error if this specific method was requested
        if bool_skip_CTGB == 1
            error('%s (OA_method=%d), but:\n%s\n%s', ...
                  'Continuous-time contraction/growth bound approach selected', OA_method, ...
                  ' - growth bound function is not defined in Input_files/UP_Growth_Bound_Function.m', ...
                  ' - the dynamics do not have additive input: dx/dt=f(t,x,p)~=f(t,x,0)+p')
        else
            error('%s (OA_method=%d), but:\n%s\n%s\n%s', ...
                  'Continuous-time contraction/growth bound approach selected', OA_method, ...
                  ' - growth bound function is not defined in Input_files/UP_Growth_Bound_Function.m', ...
                  ' - contraction matrix (or scalar) is not defined in Input_files/UP_Contraction_Matrix.m', ...
                  ' - Jacobian bounds are not defined in Input_files/UP_Jacobian_Bounds.m')
        end
    end
    
    toc(tic_GB)
end

%% Reachable set over-approximation based on the Jacobian bounds, using continuous-time mixed-monotonicity
% Requirements:
% - Continuous-time system.
% - User-provided matrices of the Jacobian bounds or Jacobian signs.

bool_skip_CTMM = 0;
if ~isnan(t_final) && (isnan(OA_method) || OA_method == 3)
    tic_CTMM = tic;
    fprintf('\nChecking conditions for continuous-time mixed-monotonicity method...\n')
    
    % Check Input_files/UP_Jacobian_Bounds.m
    [J_x_low,J_x_up,J_p_low,J_p_up] = UP_Jacobian_Bounds(t_init,t_final,x_low,x_up,p_low,p_up);
    if any(isnan(J_x_low(~logical(eye(n_x))))) || any(isnan(J_x_up(~logical(eye(n_x))))) || any(isnan(J_p_low(:))) || any(isnan(J_p_up(:)))
        % If the Jacobian bounds are not defined,
        % Check Input_files/UP_Jacobian_Signs.m
        [J_x_signs,J_p_signs] = UP_Jacobian_Signs(t_init,t_final,x_low,x_up,p_low,p_up);
        if any(isnan(J_x_signs(~logical(eye(n_x))))) || any(isnan(J_p_signs(:)))
            % If the Jacobian signs are not defined either
            if OA_method == 3
                % Return an error if this method was specifically requested
                error('%s (OA_method=%d), but:\n%s\n%s', ...
                      'Continuous-time mixed-monotonicitiy approach selected', OA_method, ...
                      ' - Jacobian bounds are not defined in Input_files/UP_Jacobian_Bounds.m', ...
                      ' - Jacobian signs are not defined in Input_files/UP_Jacobian_Signs.m')
            else
                fprintf('Neither Jacobian bounds nor signs are provided.\n')
                % Flag to go to the next method if OA_method was undefined
                bool_skip_CTMM = 1;
            end
        else
            % If sign matrices are defined, convert them into simple bounds
            % [1,1] if positive, [-1,-1] if negative, [0,0] otherwise
            J_x_low = (J_x_signs>0) - (J_x_signs<0);
            J_x_up = J_x_low;
            J_p_low = (J_p_signs>0) - (J_p_signs<0);
            J_p_up = J_p_low;
            fprintf('Read Jacobian signs from Input_files/UP_Jacobian_Signs.m\n')
        end
    else
        fprintf('Read Jacobian bounds from Input_files/UP_Jacobian_Bounds.m\n')
    end
    
    % Only apply the over-approximation method if we have Jacobian bounds
    if ~bool_skip_CTMM
        fprintf('Call of the over-approximation method ...\n')
        % Call over-approximation method
        [succ_low,succ_up] = OA_3_CT_Mixed_Monotonicity(t_init,t_final,x_low,x_up,p_low,p_up,J_x_low,J_x_up,J_p_low,J_p_up);
        toc(tic_CTMM)
        return
    end

    toc(tic_CTMM)
end

%% Reachable set over-approximation based on sensitivity bounds of a continuous-time system, using sampled-data mixed-monotonicity
% Requirements:
% - Continuous-time system.
% - Input p constant over the considered time range [t_init,t_final].
% Optional user-provided inputs:
% - Sensitivity signs or bounds (then apply over-approximation directly)
% - Jacobian bounds (for interval arithmetics submethod)
% - Jacobian functions (for one of the sampling/falsification submethod)
% If no optional input is provided:
% - can apply sampling/falsification submethods using Euler approximations

if ~isnan(t_final) && (isnan(OA_method) || OA_method == 4)
    fprintf('\nChecking conditions for continuous-time method based on sensitivity bounds...\n')
    fprintf('**Warning** Sensitivity-based method over-approximates the reachable set only for constant input functions.\n')
    
    % Extract or compute sensitivity bounds 
    % (submethod used depends on the available user-provided inputs)
    [S_x_low,S_x_up,S_p_low,S_p_up] = Sensitivity_bounds_choice(t_init,t_final,x_low,x_up,p_low,p_up);
    
    % Call over-approximation method
    fprintf('Call of the over-approximation method ...\n')
    tic_SDMM = tic;
    [succ_low,succ_up] = OA_4_CT_Sampled_data_MM(t_init,t_final,x_low,x_up,p_low,p_up,S_x_low,S_x_up,S_p_low,S_p_up);
    toc(tic_SDMM)
    return
end

%% Reachable set approximation based on Monte Carlo sampling of the transition function

if ~isnan(t_final) && (isnan(OA_method) || OA_method == 6)
    fprintf('**Warning** Monte Carlo method estimates the reachable set only for constant input functions.\n')
    fprintf('Call of the over-approximation method ...\n')
    tic_MC = tic;
    [succ_low,succ_up] = OA_6_probabilistic_MCS(t_init,t_final,x_low,x_up,p_low,p_up, parameters.montecarlo_epsilon, parameters.montecarlo_delta);
    toc(tic_MC)
    return
end



%%%%%%%%%%%%%%%%%%%%%%%%%
% Discrete-time methods %
%%%%%%%%%%%%%%%%%%%%%%%%%

%% Reachable set over-approximation based on the Jacobian bounds, using discrete-time mixed-monotonicity
% Requirements:
% - Discrete-time system.
% - User-provided matrices of the Jacobian bounds or Jacobian signs.

bool_skip_DTMM = 0;
if isnan(t_final) && (isnan(OA_method) || OA_method == 5)
    tic_DTMM = tic;
    fprintf('\nChecking conditions for discrete-time mixed-monotonicity method...\n')
    
    % Check Input_files/UP_Jacobian_Bounds.m
    [J_x_low,J_x_up,J_p_low,J_p_up] = UP_Jacobian_Bounds(t_init,t_final,x_low,x_up,p_low,p_up);
    if any(isnan(J_x_low(:))) || any(isnan(J_x_up(:))) || any(isnan(J_p_low(:))) || any(isnan(J_p_up(:)))
        % If the Jacobian bounds are not defined,
        % Check Input_files/UP_Jacobian_Signs.m
        [J_x_signs,J_p_signs] = UP_Jacobian_Signs(t_init,t_final,x_low,x_up,p_low,p_up);
        if any(isnan(J_x_signs(:))) || any(isnan(J_p_signs(:)))
            % If the Jacobian signs are not defined either
            if OA_method == 5
                % Return an error if this method was specifically requested
                error('%s (OA_method=%d), but:\n%s\n%s', ...
                      'Discrete-time mixed-monotonicitiy approach selected', OA_method, ...
                      ' - Jacobian bounds are not defined in Input_files/UP_Jacobian_Bounds.m', ...
                      ' - Jacobian signs are not defined in Input_files/UP_Jacobian_Signs.m')
            else
                fprintf('Neither Jacobian bounds nor signs are provided.\n')
                % Flag to go to the next method if OA_method was undefined
                bool_skip_DTMM = 1;
            end
        else
            % If sign matrices are defined, convert them into simple bounds
            % [1,1] if positive, [-1,-1] if negative, [0,0] otherwise
            J_x_low = (J_x_signs>0) - (J_x_signs<0);
            J_x_up = J_x_low;
            J_p_low = (J_p_signs>0) - (J_p_signs<0);
            J_p_up = J_p_low;
            fprintf('Read Jacobian signs from Input_files/UP_Jacobian_Signs.m\n')
        end
    else
        fprintf('Read Jacobian bounds from Input_files/UP_Jacobian_Bounds.m\n')
    end
    
    % Only apply the over-approximation method if we have Jacobian bounds
    if ~bool_skip_DTMM
        fprintf('Call of the over-approximation method ...\n')
        % Call over-approximation method
        [succ_low,succ_up] = OA_5_DT_Mixed_Monotonicity(t_init,x_low,x_up,p_low,p_up,J_x_low,J_x_up,J_p_low,J_p_up);
        toc(tic_DTMM)
        return
    end

    toc(tic_DTMM)
end

%% Error message if we reach the end of this file (this should not be possible)
error('None of the over-approximation methods could be applied.')
