%% Decomposition function of a general system with bounded Jacobians inspired by the method used for mixed-monotone systems.
% This definition can be used in the over-approximation methods based on
% mixed-monotonicity for both continuous-time and discrete-time systems.
% However, the current implementation of the discrete-time method uses an
% alternative approach which does not rely on this decomposition function.

% Source paper 1 (generalization of continuous-time mixed-monotonicity)
% L. Yang, O. Mickelin and N. Ozay, " On sufficient conditions for mixed 
% monotonicity". ArXiv preprint, https://arxiv.org/abs/1803.04528

% Source paper 2 (reachability analysis based on this generalization)
% P.-J. Meyer and D. V. Dimarogonas, " Hierarchical decomposition of LTL 
% synthesis problem for mixed-monotone control systems". ArXiv preprint,
% https://arxiv.org/abs/1712.06014

% Source paper 3 (particular case for discrete-time system with sign-stable Jacobians)
% S. Coogan and M. Arcak, "Efficient finite abstraction of mixed monotone 
% systems." Proceedings of the 18th International Conference on Hybrid 
% Systems: Computation and Control, pp. 58-67, 2015.
% DOI: 10.1145/2728606.2728607

% List of inputs
%   t: current time
%   x1,x2: states
%   p1,p2: inputs
%   [J_x_low,J_x_up]: bounds of the state Jacobian
%   [J_p_low,J_p_up]: bounds of the input Jacobian

% List of outputs
%   g: evaluation of the decomposition function g(t,x1,x2,p1,p2) in R^n_x
%       for the Jacobian bounds [J_x_low,J_x_up] and [J_p_low,J_p_up]

% Authors:  
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 6th of February 2019

function g = MM_decomposition_function(t,x1,x2,p1,p2,J_x_low,J_x_up,J_p_low,J_p_up)
% State and input dimensions
n_x = length(x1);
n_p  = length(p1);

%% Define the decomposition function g(t,x1,x2,p1,p2) in R^n_x
g = zeros(n_x,1);      % Initialization of the decomposition function

% The decomposition function is defined independently for each state dimension 'i' 
for i = 1:n_x
    
    % Initialization of the auxiliary variables used in the i-th element of the decomposition function
    x_i = zeros(n_x,1);                   % State used in the i-th element of the decomposition function
    comp_state = zeros(1,n_x);            % Row vector used to compensate non sign-stable state Jacobian
    
    p_i = zeros(n_p,1);                   % Input used in the i-th element of the decomposition function
    comp_input = zeros(1,n_p);            % Row vector used to compensate non sign-stable state Jacobian

    % Define the state auxiliary variables based on the state Jacobian
    for j = 1:n_x
        % Diagonal terms
        if i==j
            x_i(j) = x1(j);
        % Center of Jacobian interval is positive 
        elseif (J_x_low(i,j)+J_x_up(i,j))/2 >= 0     
            x_i(j) = x1(j);
            if J_x_low(i,j) < 0      % Internal not fully positive
                comp_state(j) = -J_x_low(i,j);
            end
        % Center of Jacobian interval is negative 
        else                
            x_i(j) = x2(j);
            if J_x_up(i,j) > 0      % Internal not fully negative
                comp_state(j) = J_x_up(i,j);
            end
        end
    end

    % Define the input auxiliary variables based on the input Jacobian
    for j = 1:n_p
        % Center of Jacobian interval is positive 
        if (J_p_low(i,j)+J_p_up(i,j))/2 >= 0 
            p_i(j) = p1(j);
            if J_p_low(i,j) < 0      % Internal not fully positive
                comp_input(j) = -J_p_low(i,j);
            end
        % Center of Jacobian interval is negative 
        else                
            p_i(j) = p2(j);
            if J_p_up(i,j) > 0      % Internal not fully negative
                comp_input(j) = J_p_up(i,j);
            end
        end
    end
    
    % Define the i-th element of the decomposition function
    system_eval = System_description(t,x_i,p_i);
    g(i) = system_eval(i) + comp_state*(x1-x2) + comp_input*(p1-p2);
    
end
