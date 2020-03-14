%% Descripion of the time-varying system with input
% either continuous-time dynamics: dx/dt = f(t,x,p)
% or discrete-time successor: x^+ = f(t,x,p)

% List of inputs
%   t: time
%   x: state
%   p: input value

% List of outputs
%   dx: 
%    continuous-time: vector field evaluated at time t, state x and input p
%    discrete-time: one-step successor from state x at time t with input p  

% Authors:  
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 13th of October 2018

function dx = System_description(t,x,p)

%% Default value as NaN vector (not a number)
n_x = length(x);
dx = NaN(n_x,1);

%% User-provided system description
% For continuous-time system: dx is the time derivative dx/dt
% For discrete-time system: dx is the one-step successor x^+
global system_choice
global u        % Some systems need an external control input

switch system_choice
    case 1
        %% Traffic diverge nx-link (needs n_x >= 5)
        % This system is a simplified representation of the flow of traffic
        % through a three-way intersection, using the cell transmission
        % model. Here, x represents the traffic flow, in vehicles/period,
        % and the links are organized as follows:
        %           /-----(2)---(4)--- ... ---(nx-1)
        %   (1)----<
        %           \-----(3)---(5)--- ... ---(nx) 
        % Vehicles move from link 1 to the remaining links, making this a
        % "diverge" junction.
        % A more detailed description of this system is available in
        % Meyer et al., "TIRA: Toolbox for Interval Reachability Analysis".
        
        % inputs:
        %     p: traffic flow injected into the first link
        %        note: although the input is one-dimensional for this
        %        system, we have modeled it as having the same dimension as
        %        the state so that the growth bound method can be applied
        %        to the system. We compensate by forcing all input terms
        %        but the first (i.e. the real one) to be zero.

        % Parameters
        v = 0.5;            % free-flow speed, in links/period
        w = 1/6;            % congestion-wave speed, in links/period
        c = 40;             % capacity (max downstream flow), in vehicles/period
        xbar = 320;         % max occupancy when jammed, in vehicles
        b = 3/4;            % fraction of vehicule staying on the network after each link
        T = 30;             % time step for the continuous-time model
        
        % Continuous-time model
        dx = zeros(n_x,1);
        dx(1) = 1/T*(-min([c ; v*x(1) ; 2*w*(xbar-x(2)) ; 2*w*(xbar-x(3))]));
        dx(2) = 1/T*(min([c/2 ; v*x(1)/2 ; w*(xbar-x(2)) ; w*(xbar-x(3))]) - min([c ; v*x(2) ; w/b*(xbar-x(4))]));
        dx(3) = 1/T*(min([c/2 ; v*x(1)/2 ; w*(xbar-x(2)) ; w*(xbar-x(3))]) - min([c ; v*x(3) ; w/b*(xbar-x(5))]));
        for i = 4:(n_x-2)
            dx(i) = 1/T*(b*min([c ; v*x(i-2) ; w*(xbar-x(i))])-min([c ; v*x(i) ; w/b*(xbar-x(i+2))]));
        end
        dx(end-1) = 1/T*(b*min([c ; v*x(end-3) ; w*(xbar-x(end-1))]) - min([c ; v*x(end-1)]));
        dx(end) = 1/T*(b*min([c ; v*x(end-2) ; w*(xbar-x(end))]) - min([c ; v*x(end)]));
        dx = dx + p;  % Model with additive input (only p(1) is non-zero)
        %disp(dx(end-1))
        
    case 2
        %% quadrotor swarm
        n_quads = floor(n_x / 12);
        f = 1;
        m = 1;
        g = 9.8;
        for i=1:(n_x)
            w = i - mod(i,12); 
            switch mod(i,12)
                case 1
                    dx(i) = x(i+ 6);
                case 2
                    dx(i) = x(i+ 6);
                case 3
                    dx(i) = x(i+ 6);
                case 4
                    dx(i) = x(i+ 6);
                case 5
                    dx(i) = x(i+ 6);
                case 6
                    dx(i) = x(i+ 6);
                case 7
                    dx(i) = (f/m) * (-cos(x(w+4))*sin(x(w+5))*cos(x(w+6)) - sin(x(w+4))*sin(x(w+6)));
                case 8
                    dx(i) = (f/m) * (-cos(x(w+4))*sin(x(w+5))*sin(x(w+6)) + sin(x(w+4))*cos(x(w+6)));
                case 9
                    dx(i) = g - (f/m)*cos(x(w+4))*cos(x(w+5));
                case 10
                    dx(i) = 0;
                case 11
                    dx(i) = 0;
                case 0
                    dx(i) = 0;
            end
        end
        dx = dx + p;
        
end
