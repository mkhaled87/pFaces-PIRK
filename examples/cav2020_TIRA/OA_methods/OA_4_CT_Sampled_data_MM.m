%% Reachable set over-approximation based on sensitivity bounds of a continuous-time system
% The sensitivities represent the matrices of partial derivatives of the
% finite-time successors of the system with respect to either the initial
% state or the input (assumed constant over the considered time range).
% For each state dimension, state and input vectors are obtained based on
% the sensitivity values, and are then used to compute two  successors of 
% the system bounding the reachable set on this state dimension.
% This method is equivalent to the one based on discrete-time
% mixed-monotonicity, applied to the sampled-data version of the 
% continuous-time system. The bounded Jacobian condition for discrete-time
% mixed-monotonicity are then translated to bounded sensitivity matrices.

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

% List of outputs
%   [succ_low,succ_up]: interval over-approximation of the reachable set (at time t_final)

% Authors:  
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 13th of October 2018

function [succ_low,succ_up] = OA_4_CT_Sampled_data_MM(t_init,t_final,x_low,x_up,p_low,p_up,S_x_low,S_x_up,S_p_low,S_p_up)
% State and input dimensions
n_x = length(x_low);
n_p  = length(p_low);

% Check consistency of user-provided intervals
assert(all(S_x_low(:)<=S_x_up(:)),'Inconsistent bounds of the state sensitivity provided: need S_x_low <= S_x_up')
assert(all(S_p_low(:)<=S_p_up(:)),'Inconsistent bounds of the input sensitivity provided: need S_p_low <= S_p_up')

%% Initialization of the auxiliary variables used in the over-approximation
xi_low = zeros(n_x);                % States (one for each dimension) used as lower bounds
xi_up = zeros(n_x);                 % States (one for each dimension) used as upper bounds
comp_state = zeros(n_x);            % Vectors (one for each dimension) used to compensate non sign-stable sensitivity of the states 

pi_low = zeros(n_x,n_p);            % Inputs (one for each dimension) used as lower bounds
pi_up = zeros(n_x,n_p);             % Inputs (one for each dimension) used as upper bounds
comp_input = zeros(n_x,n_p);        % Vectors (one for each dimension) used to compensate non sign-stable sensitivity of the inputs 

% Lower and upper bounds of the over-approximation 
succ_low = zeros(n_x,1);
succ_up = zeros(n_x,1);

%% Over-approximation loop
% The reachable set is over-approximated independently for each state dimension 
for i = 1:n_x
    
    % Define the state auxiliary variables based on the sensitivity with respect to the initial state
    for j = 1:n_x
        % Center of sensitivity interval is positive 
        if (S_x_low(i,j)+S_x_up(i,j))/2 >= 0     
            xi_low(i,j) = x_low(j);
            xi_up(i,j) = x_up(j);
            if S_x_low(i,j) < 0      % Internal not fully positive
                comp_state(i,j) = S_x_low(i,j);
            end
        % Center of sensitivity interval is negative 
        else                
            xi_low(i,j) = x_up(j);
            xi_up(i,j) = x_low(j);
            if S_x_up(i,j) > 0      % Internal not fully negative
                comp_state(i,j) = S_x_up(i,j);
            end
        end
    end
    
    % Define the input auxiliary variables based on the sensitivity with respect to the input
    for j = 1:n_p
        % Center of sensitivity interval is positive 
        if (S_p_low(i,j)+S_p_up(i,j))/2 >= 0   
            pi_low(i,j) = p_low(j);
            pi_up(i,j) = p_up(j);
            if S_p_low(i,j) < 0      % Internal not fully positive
                comp_input(i,j) = S_p_low(i,j);
            end
        % Center of sensitivity interval is negative 
        else                
            pi_low(i,j) = p_up(j);
            pi_up(i,j) = p_low(j);
            if S_p_up(i,j) > 0      % Internal not fully negative
                comp_input(i,j) = S_p_up(i,j);
            end
        end
    end
    
    % Trajectory from initial state xi_low(i,:)' with input pi_low(i,:)'
    [~,xi_low_traj] = ode45(@(t,x) System_description(t,x,pi_low(i,:)'),[t_init,t_final],xi_low(i,:)');
    % Trajectory from initial state xi_up(i,:)' with input pi_up(i,:)'
    [~,xi_up_traj] = ode45(@(t,x) System_description(t,x,pi_up(i,:)'),[t_init,t_final],xi_up(i,:)');
    
    % Over-approximation on dimension i
    succ_low(i) = xi_low_traj(end,i)-comp_state(i,:)*(xi_low(i,:)-xi_up(i,:))'-comp_input(i,:)*(pi_low(i,:)-pi_up(i,:))';
    succ_up(i) = xi_up_traj(end,i)+comp_state(i,:)*(xi_low(i,:)-xi_up(i,:))'+comp_input(i,:)*(pi_low(i,:)-pi_up(i,:))';
end