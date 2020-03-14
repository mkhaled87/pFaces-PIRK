%% User-provided contraction matrix for the definition of a growth bound
% The growth bound is defined in Utilities/Growth_bound_choice.m
% and then used in OA_methods/OA_2_CT_Contraction_growth_Bound.m
% The main requirements on the definition of the matrix and on the system
% definition for the over-approximation to be applicable are provided at
% the end of this file, or in more details in the paper below.

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

% List of outputs
%   C: n_x*n_x contraction matrix, or scalar contraction factor

% Authors:  
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 13th of October 2018

function C = UP_Contraction_Matrix(t_init,t_final,x_low,x_up,p_low,p_up)
n_x = length(x_low);
n_p = length(p_low);

%% Default values as NaN (not a number)
C = NaN(n_x);

%% User-provided contraction matrix (or scalar) C

% Requirements on the definition of C
%   Denoting as p_c the center of [p_low,p_up], and considering the system 
%   with constant input p_c: f(t,x) = System_description(t,x,p_c)
%       C(i,i) >= d(f_i(t,x))/dx_i   (for all t, x, i)
%       C(i,j) >= abs(d(f_i(t,x))/dx_j)   (for all t, x, i, j~=i)
%   If C is scalar, it needs to be an upper bound of the matrix measure of
%       the state Jacobian d(System_description(t,x,p_c))/dx.
%       For a n*n matrix A, its matrix measure is the limit (as h decreases
%       to 0) of (norm(eye(n)+h*A)-1)/h

% Requirement that will be checked in file Utilities/Growth_bound_choice.m
%   Dynamics with additive input:
%       System_description(t,x,p) == System_description(t,x,0) + p
%   size(C) == [n_x,n_x] or size(C) == [1,1]

global system_choice
global u        % Some systems need an external control input

switch system_choice
    case 6
        %% Time-varying system (continuous-time)
        % dx = A(t)*x+p
        a = 0.8;
        C = [1 1 a;0 1 1;0 0 1];
        
    case 7
        %% Bicycle (continuous-time)
        C = zeros(3);
        C(1:2,3) = abs(u(1)*sqrt(tan(u(2))^2/4+1));
               
end
