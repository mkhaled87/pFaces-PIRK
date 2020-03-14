%% User-provided description of the Jacobian functions
% Jacobian definitions:
%   to states:  J_x(t) = d(System_description(t,x,p))/dx
%   to inputs:  J_p(t) = d(System_description(t,x,p))/dp

% List of inputs
%   t_init: initial time
%   t: current time (for continuous-time system only)
%       for discrete-time system, a dummy value can be provided
%   x: current state
%   p: current input

% List of outputs
%   J_x: evaluation of the current Jacobian with respect to the state
%   J_p: evaluation of the current Jacobian with respect to the input

% Authors:  
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 13th of October 2018

function [J_x,J_p] = UP_Jacobian_Function(t_init,t,x,p)
n_x = length(x);
n_p  = length(p);

%% Default values as NaN (not a number)
J_x = NaN(n_x);
J_p = NaN(n_x,n_p);

%% User-provided Jacobian functions depending on inputs: t_init,t,x,p

% If System_description.m has no input variable 'p', uncomment below:
% J_p = zeros(n_x,n_p);

global system_choice
global u        % Some systems need an external control input

switch system_choice
    case 1
        %% Unicycle (continuous-time)
        J_x = [0     0       -u(1)*sin(x(3)); ...
               0     0       u(1)*cos(x(3)); ...
               0     0       0];
        J_p = eye(3);
        
    case 2
        %% Traffic diverge 3 links (continuous-time)
        % Defined as a system with additive input: dx=f(t,x)+p
        J_x = zeros(n_x);

        T = 30;             % time period, in secondes
        v = 0.5;            % free-flow speed, in links/period
        w = 1/6;            % congestion-wave speed, in links/period
        c = 40;             % capacity (max downstream flow), in vehicles/period
        xbar = 320;         % max occupancy when jammed, in vehicles
        
        if v*x(1) <= min([c ; 2*w*(xbar-x(2)) ; 2*w*(xbar-x(3))])
            J_x(:,1) = 1/T*[-v;v/2;v/2];
        elseif 2*w*(xbar-x(2)) <= min([c ; v*x(1) ; 2*w*(xbar-x(3))])
            J_x(:,2) = 1/T*[2*w;-w;-w];
        elseif 2*w*(xbar-x(3)) <= min([c ; v*x(1) ; 2*w*(xbar-x(2))])
            J_x(:,3) = 1/T*[2*w;-w;-w];
        end
        
        if v*x(2) <= c
            J_x(2,2) = J_x(2,2) -v/T;
        end

        if v*x(3) <= c
            J_x(3,3) = J_x(3,3) -v/T;
        end
        
        J_p = [1/T 0 0;0 0 0;0 0 0];
        
    case 3
        %% Ship (continuous-time)
        n_x = length(x);
        n_p = length(p);
        J_x = zeros(n_x);
        J_p = zeros(n_x,n_p);

        % Parameters
        M = [25.8 0 0; ...
             0 33.8 1.0115; ...
             0 1.0115 2.16];
        N = [2 0 0; ...
             0 7 0.1; ...
             0 0.1 0.5];
        k1 = 25;
        k2 = 2.5;
        k3 = 5;

        inv_det_M23 = 1/det(M(2:3,2:3));

        % Constant elements
        J_x(3,6) = 1;
        J_x(4,4) = -k1/M(1,1);
        J_x(5,3) = k2*M(2,3)*inv_det_M23;
        J_x(5,5) = (N(3,2)*M(2,3) - N(2,2)*M(3,3))*inv_det_M23;
        J_x(5,6) = (-N(2,3)*M(3,3) + (k3+N(3,3))*M(2,3))*inv_det_M23;
        J_x(6,3) = -k2*M(2,2)*inv_det_M23;
        J_x(6,5) = (N(2,2)*M(3,2) - N(3,2)*M(2,2))*inv_det_M23;
        J_x(6,6) = (N(2,3)*M(3,2) - (k3+N(3,3))*M(2,2))*inv_det_M23;

        J_p(4,1) = k1/M(1,1);
        J_p(5:6,2) = M(2:3,2:3)\[0;k2];

        % Variable elements
        J_x(1,3) = -x(4)*sin(x(3))-x(5)*cos(x(3));
        J_x(1,4) = cos(x(3));
        J_x(1,5) = -sin(x(3));
        J_x(2,3) = x(4)*cos(x(3))-x(5)*sin(x(3));
        J_x(2,4) = sin(x(3));
        J_x(2,5) = cos(x(3));
        
    case 10
        %% Nonlinear Longitudinal Model of a Quadrotor (continuous-time)
        J_x = zeros(n_x);
        J_p = zeros(n_x,n_p);   % No input variables
        
        % Parameters
        K = 0.89/1.4;
        d0 = 70;
        d1 = 17;

        % State Jacobian
        J_x(1,3) = 1;
        J_x(2,4) = 1;
        J_x(3,5) = u(1)*K*cos(x(5));
        J_x(4,5) = -u(1)*K*sin(x(5));
        J_x(5,6) = 1;
        J_x(6,5:6) = [-d0,-d1];
        
    case 11
        %% Pursuer-evader game with 2 Dubin's vehicles (continuous-time)
        J_x = zeros(n_x);
        J_p = zeros(n_x,n_p);
         
        % State Jacobian
        J_x(1:2,3) = [-u(1)*sin(x(3));u(1)*cos(x(3))];
        J_x(4:5,6) = [-p(1)*sin(x(6));p(1)*cos(x(6))];

        % Input Jacobian
        J_p(4:5,1) = [cos(x(6));sin(x(6))];
        J_p(6,2) = 1;
        
end



