%% Over-approximation of the sensitivity bounds using interval arithmetics
% Requires user-provided Jacobian bounds in Input_files/UP_Jacobian_Bounds

% Source paper 1 (interval arithmetics for time-varying linear systems):
% M. Althoff, O. Stursberg and M. Buss, "Reachability analysis of linear 
% systems with uncertain parameters and inputs". 46th IEEE Conference on 
% Decision and Control, pp. 726-732, 2007. DOI: 10.1109/CDC.2007.4434084

% Source paper 2 (application of paper 1 to the sensitivity systems):
% P.-J. Meyer, S. Coogan and M. Arcak, "Sampled-data reachability analysis 
% using sensitivity and mixed-monotonicity". IEEE Control Systems Letters,
% v. 2(4), pp. 761-766, 2018. DOI: 10.1109/LCSYS.2018.2848280

% Source paper 3 (definition of basic operations for interval arithmetics):
% L. Jaulin, M. Kieffer, O. Didrit and E. Walter, "Applied interval 
% analysis: with examples in parameter and state estimation, robust control
% and robotics". Springer Science & Business Media, v. 1, 2001.

% List of inputs
%   t_init: initial time
%   t_final: time at which the reachable set is approximated
%   [x_low,x_up]: interval of initial states (at time t_init)
%   [p_low,p_up]: interval of allowed input values
%   [J_x_low,J_x_up]: bounds of the Jacobian with respect to the state
%   [J_p_low,J_p_up]: bounds of the Jacobian with respect to the input
%   taylor_order: (optional) integer to impose a minimum order of the Taylor series

% List of outputs
%   [S_x_low,S_x_up]: bounds of the sensitivity of successors (at time t_final) to variations of initial states (at time t_init)
%   [S_p_low,S_p_up]: bounds of the sensitivity of successors (at time t_final) to variations of inputs

% Authors:  
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 13th of October 2018

function [S_x_low,S_x_up,S_p_low,S_p_up] = Sensitivity_interval_arithmetics(t_init,t_final,x_low,x_up,p_low,p_up,J_x_low,J_x_up,J_p_low,J_p_up,taylor_order)
n_x = length(x_low);
n_p  = length(p_low);
T = t_final-t_init;     % Width of the time step

% Check consistency of user-provided intervals
assert(all(J_x_low(:)<=J_x_up(:)),'Inconsistent bounds of the state Jacobian provided: need J_x_low <= J_x_up')
assert(all(J_p_low(:)<=J_p_up(:)),'Inconsistent bounds of the input Jacobian provided: need J_p_low <= J_p_up')

% Extract from Solver_parameters.m the parameters for Taylor series truncation
run('Solver_parameters.m')
if nargin < 11      % Only read 'taylor_order' from Solver_parameters.m if it is not provided as an input argument of this function
    taylor_order = parameters.taylor_order;         % Initial order for the truncation of the Taylor series (may be interatively increased if the results are not satisfactory)
end
taylor_tolerance = parameters.taylor_tolerance;     % Stopping condition: max relative error allowed between two iterations
taylor_increment = parameters.taylor_increment;     % Taylor order increase at each iteration

% Increase Taylor order if it is too low for the computations to hold
taylor_order = max(taylor_order,floor(Interval_matrix_norm(J_x_low,J_x_up)*T-2) + 1);

% Display the Taylor order to be initially used
fprintf('Computation of the sensitivity bounds based on Interval Arithmetics using truncated Taylor series at order: ')
tic_IA = tic;

%% Iterative computation of the sensitivity values with increasing Taylor orders until convergence
% To skip this (do a single iteration), set: 'parameters.taylor_tolerance = NaN' in Solver_parameters.m 

% Initialization of the sensitivity with respect to initial conditions
if isequal(x_low,x_up)
    % No computation is needed if [x_low,x_up] contains a single value
    S_x_low = zeros(n_x);
    S_x_up = zeros(n_x);
else
    [S_x_low,S_x_up] = Sensitivity_state(T,taylor_order,J_x_low,J_x_up);
end

% Initialization of the sensitivity with respect to inputs
if isequal(p_low,p_up)
    % No computation is needed if [p_low,p_up] contains a single value
    S_p_low = zeros(n_x,n_p);
    S_p_up = zeros(n_x,n_p);
else
    [S_p_low,S_p_up] = Sensitivity_input(T,taylor_order,J_x_low,J_x_up,J_p_low,J_p_up);
end

% Initialization of the internal variables for the loop update
S_x_low_prev = zeros(n_x);
S_x_up_prev = zeros(n_x);
S_p_low_prev = zeros(n_x,n_p);
S_p_up_prev = zeros(n_x,n_p);

% Loop stops when all sensitivities have not changed more than tolerance
% or if taylor_tolerance is undefined (NaN)
while ~isnan(taylor_tolerance) && ...
      (~all(all((abs(S_x_low_prev-S_x_low) <= abs(S_x_low)*taylor_tolerance) & ...
                (abs(S_x_up_prev-S_x_up) <= abs(S_x_up)*taylor_tolerance))) || ...
       ~all(all((abs(S_p_low_prev-S_p_low) <= abs(S_p_low)*taylor_tolerance) & ...
                (abs(S_p_up_prev-S_p_up) <= abs(S_p_up)*taylor_tolerance))))
    % Update previous sensitivity values
    S_x_low_prev = S_x_low;
    S_x_up_prev = S_x_up;
    S_p_low_prev = S_p_low;
    S_p_up_prev = S_p_up;
    
    % Increase Taylor order
    taylor_order = taylor_order + taylor_increment;
    
    % Compute new sensitivity values (only if necessary)
    if ~isequal(x_low,x_up)
        [S_x_low,S_x_up] = Sensitivity_state(T,taylor_order,J_x_low,J_x_up);
    end
    if ~isequal(p_low,p_up)
        [S_p_low,S_p_up] = Sensitivity_input(T,taylor_order,J_x_low,J_x_up,J_p_low,J_p_up);
    end
end

% Display the Taylor order really used
fprintf('%d\n',taylor_order)
toc(tic_IA)

end


%% Computes the interval matrix over-approximating the sensitivity matrix with respect to initial conditions
% Use interval arithmetics to solve the set-valued system;
% dS_x/dt = J_x*S_x, initialized with the identity matrix.
% See source paper 2 for the problem definition and result statement
% and source paper 1 for the technical details of the computations below.
% List of inputs
%   T: time step
%   taylor_order: truncation order of the Taylor series
%   [J_x_LB,J_x_UB]: bounds of the Jacobian with respect to the state
% List of outputs
%   [S_x_low,S_x_up]: bounds of the sensitivity of successors to variations of initial states
function [S_x_low,S_x_up] = Sensitivity_state(T,taylor_order,J_x_LB,J_x_UB)
n_x = size(J_x_LB,1);

% Recursive definition of the truncated Taylor series for the interval matrix exponential exp(J_x*T)
% Initialization of a single element in the sum (J_x*T)^i/i!
temp_LB = eye(n_x);
temp_UB = eye(n_x);
% Initialization of the sum (for order 0)
sum_LB = eye(n_x);
sum_UB = eye(n_x);
% Loop from 1 to taylor_order for the computation and sum of terms (J_x*T)^i/i!
for i = 1:taylor_order
    % Computation of the new term (J_x*T)^i/i! based on the one at i-1
    [temp_LB,temp_UB] = Interval_matrix_product(temp_LB,temp_UB,J_x_LB*T/i,J_x_UB*T/i);
    % Update of the sum
    [sum_LB,sum_UB] = Interval_matrix_sum(sum_LB,sum_UB,temp_LB,temp_UB);
end

% Over-approximation of the remaining orders > taylor_order
Jacobian_norm = Interval_matrix_norm(J_x_LB,J_x_UB)*T;
epsilon = Jacobian_norm/(taylor_order+2); 
E_UB = 1/(1-epsilon);
for i = 1:(taylor_order+1)
    E_UB = E_UB*Jacobian_norm/i;
end
E_UB = ones(n_x)*E_UB;
E_LB = -E_UB;

% Final sensitivity bounds
[S_x_low,S_x_up] = Interval_matrix_sum(sum_LB,sum_UB,E_LB,E_UB);
end

%% Computes the interval matrix over-approximating the sensitivity matrix with respect to constant inputs
% Use interval arithmetics to solve the set-valued system: 
% dS_p/dt = J_x*S_p + J_p, initialized with the zero matrix.
% See source paper 2 for the problem definition and result statement
% and source paper 1 for the technical details of the computations below.
% List of inputs
%   T: time step
%   taylor_order: truncation order of the Taylor series
%   [J_x_LB,J_x_UB]: bounds of the Jacobian with respect to the state
%   [J_p_LB,J_p_UB]: bounds of the Jacobian with respect to the input
% List of outputs
%   [S_p_low,S_p_up]: bounds of the sensitivity of successors to variations of inputs
function [S_p_low,S_p_up] = Sensitivity_input(T,taylor_order,J_x_LB,J_x_UB,J_p_LB,J_p_UB)
[n_x,~] = size(J_p_LB);

% Recursive definition of the truncated Taylor serie
% Initialization of a single element in the sum
temp_LB = eye(n_x);
temp_UB = eye(n_x);
% Initialization of the sum (for order 0)
sum_LB = eye(n_x);
sum_UB = eye(n_x);
% Loop from 1 to taylor_order for the computation and sum of each term
for i = 1:taylor_order
    % Computation of the i-th term based on the one at i-1
    [temp_LB,temp_UB] = Interval_matrix_product(temp_LB,temp_UB,J_x_LB*T/(i+1),J_x_UB*T/(i+1));
    % Update of the sum
    [sum_LB,sum_UB] = Interval_matrix_sum(sum_LB,sum_UB,temp_LB,temp_UB);
end

% Over-approximation of the remaining orders > taylor_order
Jacobian_norm = Interval_matrix_norm(J_x_LB,J_x_UB)*T;
epsilon = Jacobian_norm/(taylor_order+2);
E_UB = 1/(1-epsilon);
for i = 1:(taylor_order+1)
    E_UB = E_UB*Jacobian_norm/i;
end
E_UB = ones(n_x)*E_UB;
E_LB = -E_UB;

% Final sensitivity bounds
[S_p_low,S_p_up] = Interval_matrix_sum(sum_LB,sum_UB,E_LB,E_UB);
[S_p_low,S_p_up] = Interval_matrix_product(S_p_low,S_p_up,T*J_p_LB,T*J_p_UB);
end

%% Infinity norm definition for an interval matrix
% Inputs. [A_LB,A_UB]: interval matrix A
% Output. inf_norm: infinity norm of interval matrix A
function inf_norm = Interval_matrix_norm(A_LB,A_UB)
inf_norm = norm(max(abs(A_LB),abs(A_UB)),Inf);
end

%% Sum of two interval matrices A+B
% Inputs. [A_LB,A_UB], [B_LB,B_UB]: two interval matrices A and B
% Outputs. [sum_LB,sum_UB]: interval matrix for the sum A+B
function [sum_LB,sum_UB] = Interval_matrix_sum(A_LB,A_UB,B_LB,B_UB)
sum_LB = A_LB+B_LB;
sum_UB = A_UB+B_UB;
end

%% Product of two interval matrices A*B
% Inputs. [A_LB,A_UB], [B_LB,B_UB]: two interval matrices A and B
% Outputs. [prod_LB,prod_UB]: interval matrix for the product A*B
function [prod_LB,prod_UB] = Interval_matrix_product(A_LB,A_UB,B_LB,B_UB)
prod_LB = zeros(size(A_LB,1),size(B_LB,2));
prod_UB = zeros(size(A_LB,1),size(B_LB,2));
for i = 1:size(A_LB,1)  % lines of A
    for j = 1:size(B_LB,2)  % columns of B
        prod_LB(i,j) = sum(min([A_LB(i,:)'.*B_LB(:,j) A_UB(i,:)'.*B_LB(:,j) A_LB(i,:)'.*B_UB(:,j) A_UB(i,:)'.*B_UB(:,j)],[],2));
        prod_UB(i,j) = sum(max([A_LB(i,:)'.*B_LB(:,j) A_UB(i,:)'.*B_LB(:,j) A_LB(i,:)'.*B_UB(:,j) A_UB(i,:)'.*B_UB(:,j)],[],2));
    end
end
end

%% Power operator of an interval matrix A^n
% Input. [A_LB,A_UB]: interval matrix A
% Input. n: power integer
% Outputs. [power_LB,power_UB]: interval matrix for A^n
function [power_LB,power_UB] = Interval_matrix_power(A_LB,A_UB,n)
if  n == 1  % A^1 = A
    power_LB = A_LB;
    power_UB = A_UB;
else        % A^n = A^(n-1)*A
    [temp_LB,temp_UB] = Interval_matrix_power(A_LB,A_UB,n-1);
    [power_LB,power_UB] = Interval_matrix_product(temp_LB,temp_UB,A_LB,A_UB);
    
    % A*A^(n-1) and A^(n-1)*A yield different results for n>2,
    % but both are guaranteed to over-approximate the real value of A^n
    % To use A^n = A*A^(n-1), replace the last line by the following:
%     [power_LB,power_UB] = Interval_matrix_product(A_LB,A_UB,temp_LB,temp_UB);
end
end
