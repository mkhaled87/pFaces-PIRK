%% Reachable set over-approximation based on Jacobian bounds of a discrete-time system
% For each state dimension, state and input vectors are obtained based on
% the Jacobian bounds, and are then used to compute two successors of 
% the system bounding the reachable set on this state dimension.
% This method (source paper 1) is a generalization (to any discrete-time 
% system with bounded Jacobian matrices) of the one based on the
% mixed-monotonicity property (source paper 2: for sign-stable Jacobians),
% which is itself a generalization of the monotonicity-based approach
% (source paper 3: sign-stable Jacobians + additional sign constraints).
% This generalization covers both mixed-monotonicity and monotonicity
% approaches as particular cases.

% Source paper 1:
% P.-J. Meyer, S. Coogan and M. Arcak, "Sampled-data reachability analysis 
% using sensitivity and mixed-monotonicity". IEEE Control Systems Letters,
% v. 2(4), pp. 761-766, 2018. DOI: 10.1109/LCSYS.2018.2848280

% Source paper 2:
% S. Coogan and M. Arcak, "Efficient finite abstraction of mixed monotone 
% systems." Proceedings of the 18th International Conference on Hybrid 
% Systems: Computation and Control, pp. 58-67, 2015.
% DOI: 10.1145/2728606.2728607

% Source paper 3:
% M. W. Hirsch and H. Smith, "Monotone maps: a review". Journal of 
% Difference Equations and Applications, v. 11(4-5), pp. 379-398, 2005.
% DOI: 10.1080/10236190412331335445

% List of inputs
%   t_init: initial time
%   [x_low,x_up]: interval of initial states (at time t_init)
%   [p_low,p_up]: interval of allowed input values
%   [J_x_low,J_x_up]: bounds of the state Jacobian
%   [J_p_low,J_p_up]: bounds of the input Jacobian

% List of outputs
%   [succ_low,succ_up]: interval over-approximation of the one-step reachable set for the discrete-time system

% Authors:  
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 13th of October 2018

function [succ_low,succ_up] = OA_5_DT_Mixed_Monotonicity(t_init,x_low,x_up,p_low,p_up,J_x_low,J_x_up,J_p_low,J_p_up)
% State and input dimensions
n_x = length(x_low);
n_p  = length(p_low);

% Check consistency of user-provided intervals
assert(all(J_x_low(:)<=J_x_up(:)),'Inconsistent bounds of the state Jacobian provided: need J_x_low <= J_x_up')
assert(all(J_p_low(:)<=J_p_up(:)),'Inconsistent bounds of the input Jacobian provided: need J_p_low <= J_p_up')

%% Initialization of the auxiliary variables used in the over-approximation
xi_low = zeros(n_x);                % States (one for each dimension) used as lower bounds
xi_up = zeros(n_x);                 % States (one for each dimension) used as upper bounds
comp_state = zeros(n_x);            % Vectors (one for each dimension) used to compensate non sign-stable state Jacobian

pi_low = zeros(n_x,n_p);            % Inputs (one for each dimension) used as lower bounds
pi_up = zeros(n_x,n_p);             % Inputs (one for each dimension) used as upper bounds
comp_input = zeros(n_x,n_p);        % Vectors (one for each dimension) used to compensate non sign-stable input Jacobian

% Lower and upper bounds of the over-approximation 
succ_low = zeros(n_x,1);
succ_up = zeros(n_x,1);

%% Over-approximation loop
% The reachable set is over-approximated independently for each state dimension 
for i = 1:n_x
    
    % Define the state auxiliary variables based on the state Jacobian
    for j = 1:n_x
        % Center of Jacobian interval is positive 
        if (J_x_low(i,j)+J_x_up(i,j))/2 >= 0     
            xi_low(i,j) = x_low(j);
            xi_up(i,j) = x_up(j);
            if J_x_low(i,j) < 0      % Internal not fully positive
                comp_state(i,j) = J_x_low(i,j);
            end
        % Center of Jacobian interval is negative 
        else                
            xi_low(i,j) = x_up(j);
            xi_up(i,j) = x_low(j);
            if J_x_up(i,j) > 0      % Internal not fully negative
                comp_state(i,j) = J_x_up(i,j);
            end
        end
    end
    
    % Define the input auxiliary variables based on the input Jacobian
    for j = 1:n_p
        % Center of Jacobian interval is positive 
        if (J_p_low(i,j)+J_p_up(i,j))/2 >= 0 
            pi_low(i,j) = p_low(j);
            pi_up(i,j) = p_up(j);
            if J_p_low(i,j) < 0      % Internal not fully positive
                comp_input(i,j) = J_p_low(i,j);
            end
        % Center of Jacobian interval is negative 
        else                
            pi_low(i,j) = p_up(j);
            pi_up(i,j) = p_low(j);
            if J_p_up(i,j) > 0      % Internal not fully negative
                comp_input(i,j) = J_p_up(i,j);
            end
        end
    end
    
    % Successor from state xi_low(i,:)' with input pi_low(i,:)'
    xi_low_succ = System_description(t_init,xi_low(i,:)',pi_low(i,:)');
    % Successor from state xi_up(i,:)' with input pi_up(i,:)'
    xi_up_succ = System_description(t_init,xi_up(i,:)',pi_up(i,:)');
    
    % Over-approximation on dimension i
    succ_low(i) = xi_low_succ(i)-comp_state(i,:)*(xi_low(i,:)-xi_up(i,:))'-comp_input(i,:)*(pi_low(i,:)-pi_up(i,:))';
    succ_up(i) = xi_up_succ(i)+comp_state(i,:)*(xi_low(i,:)-xi_up(i,:))'+comp_input(i,:)*(pi_low(i,:)-pi_up(i,:))';
end