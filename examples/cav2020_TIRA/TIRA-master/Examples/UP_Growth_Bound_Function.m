%% User-provided growth bound function handle 
% To be used in OA_methods/OA_2_CT_Contraction_growth_Bound.m
% The main requirements on its definition for the over-approximation to be 
% applicable are provided at the end of this  file, or in more details in 
% the paper below.

% Source paper:
% G. Reissig, A. Weber and M. Rungger, "Feedback refinement relations for 
% the synthesis of symbolic controllers". IEEE Transactions on Automatic 
% Control v. 62(4), pp. 1781-1796, 2017. DOI: 10.1109/TAC.2016.2593947

% List of inputs
%   t_init: initial time
%   t_final: time at which the reachable set is approximated
%   [x_low,x_up]: interval of initial states (at time t_init)
%   [p_low,p_up]: interval of allowed input values

% List of outputs
%   GB_handle: function handle of the growth bound
%       inputs: positive time, positive state vector, positive input vector
%       output: positive state vector (growth or contraction of the system)

% Authors:  
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 13th of October 2018

function GB_handle = UP_Growth_Bound_Function(t_init,t_final,x_low,x_up,p_low,p_up)
n_x = length(x_low);
n_p = length(p_low);

%% Default values as NaN (not a number)
GB_handle = @(t,x,p) NaN(n_x,1);

%% User-provided growth bound handle

% Requirements on the definition of GB_handle
% (using componentwise inequalities)
%   1) GB_handle is a function handle from R+*R+^n_x*R+^n_p to R+^n_x

%   2) x>=x', p>=p' => GB_handle(t,x,p)>=GB_handle(t,x',p')

%   3) Let x(t_final;t_init,x0,p) be the solution of System_description(t,x,p)
%   at time t_final, starting from x0 at t_init and with constant input p.
%   Let x0_c and p_c be the centers of [x_low,x_up] and [p_low,p_up].
%   Then we need, for all x0 in [x_low,x_up] and p in [p_low,p_up]:
%   abs(x(t_final;t_init,x0,p)-x(t_final;t_init,x0_c,p_c))
%       <= GB_handle(t_final-t_init,abs(x0-x0_c),abs(p-p_c))


% GB_handle = @(t,x,p) ...

global system_choice

switch system_choice
    case 11
        %% Pursuer-evader game with 2 Dubin's vehicles (continuous-time)
        
        % Input influence on dynamics, assuming [p_low,p_up] is centered on 0
        p_tilde = [0;0;0;p_up(1);p_up(1);p_up(2)];

        % Check Input_files/UP_Jacobian_Bounds.m
        input_center = (p_low+p_up)/2;
        [J_x_low,J_x_up,~,~] = UP_Jacobian_Bounds(t_init,t_final,x_low,x_up,input_center,input_center);

        % Contraction matrix
        C = max(abs(J_x_low),abs(J_x_up));   % Off-diagonal elements: upper bound on the absolute values
        C(1:n_x+1:end) = diag(J_x_up);       % Diagonal elements: take Jacobian upper bound directly

        % Use this matrix to create a growth bound    
        GB_handle = @(t,x,p) expm(C*t)*x + integral(@(s) expm(C*s)*p_tilde,0,t,'ArrayValued',true);
end
        
