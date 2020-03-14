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
% Date: 18th of February 2019

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
        %% Unicycle (continuous-time)
        % A simple example of a non-holonomic system
        % This system represents a point mass moving in the plane
        % The speed of the point and its angular velocity can be controlled
        
        % states:
        %     x(1), x(2): planar (x,y) coordinates of the unicycle
        %     x(3): unicycle facing angle
        
        % control:
        %     u(1): unicycle speed
        %     u(2): unicycle angular velocity
        
        % inputs:
        %     p: disturbance inputs to the three states
        
        dx = [u(1)*cos(x(3))+p(1); ...
              u(1)*sin(x(3))+p(2); ...
              u(2)+p(3)];

    case 2
        %% Traffic diverge 3 link (continuous-time)
        % Defined as a system with additive input: dx=f(t,x)+p
        % This system is a simplified representation of the flow of traffic
        % through a three-way intersection, using the cell transmission
        % model. Here, x represents the traffic flow, in vehicles/period,
        % and the links are organized as follows:
        %           /-----(2)---
        %   (1)-----|
        %           \-----(3)---
        % Vehicles move from link 1 to links 2 and 3, making this a
        % "diverge" link. A more detailed description of this model is
        % available in 
        % P.-J. Meyer, S. Coogan and M. Arcak, "Sampled-data reachability 
        % analysis using sensitivity and mixed-monotonicity". IEEE Control 
        % Systems Letters, v. 2(4), pp. 761-766, 2018. 
        % DOI: 10.1109/LCSYS.2018.2848280
        
        % states:
        %     x(i): traffic flow through the i-th link
        
        % inputs:
        %     p(1): traffic flow injected into the first link
        %     p(i) = 0 for all i>1 
        %        note: although the actual input is one-dimensional, we
        %        model inputs (equal to 0) for each link so that the
        %        dynamics take the addditive input form dx=f(t,x)+p, for
        %        the contraction/growth bound method to be applicable.
        
        % Parameters
        T = 30;             % time period, in secondes
        v = 0.5;            % free-flow speed, in links/period
        w = 1/6;            % congestion-wave speed, in links/period
        c = 40;             % capacity (max downstream flow), in vehicles/period
        xbar = 320;         % max occupancy when jammed, in vehicles
        
        dx = 1/T*[-min([c ; v*x(1) ; 2*w*(xbar-x(2)) ; 2*w*(xbar-x(3))]); ...
                  min([c/2 ; v*x(1)/2 ; w*(xbar-x(2)) ; w*(xbar-x(3))])-min(c , v*x(2)); ...
                  min([c/2 ; v*x(1)/2 ; w*(xbar-x(2)) ; w*(xbar-x(3))])-min(c , v*x(3))] ...
             + p;
        
    case 3
        %% Ship (continuous-time)
        % A cousin of the unicycle system, the ship system represents the
        % motion of a ship over water. This system is underactuated:
        % it has three dimensions with interesting kinematics, but it only
        % has direct control over two of them.
        % A more detailed description of this model is available in
        % Thor I. Fossen, Morten Breivik and Roger Skjetne, "Line-of-sight 
        % path following of underactuated marine craft". 6th IFAC 
        % Conference on Manoeuvring and Control of Marine Craft, v. 36(21),
        % pp. 211-216, 2003. DOI: 10.1016/S1474-6670(17)37809-6
        
        % states:
        %     x(1): x-coordinate on the water
        %     x(2): y-coordinate on the water
        %     x(3): heading of the ship, with x(3)=0 when it's 
        %           facing (x(1),x(2))=(1,0) 
        %     x(4): forward velocity relative to ship's heading (surge rate)
        %     x(5): lateral velocity relative to ship's heading (sway rate)
        %     x(6): angular velocity relative to ship's heading (yaw rate)
        
        % inputs:
        %     p(1): surge velocity forcing term
        %     p(2): yaw velocity forcing term
        
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

        % Closed-loop dynamics
        dx = [x(4)*cos(x(3)) - x(5)*sin(x(3)); ...
              x(4)*sin(x(3)) + x(5)*cos(x(3)); ...
              x(6); ...
              (p(1)-x(4))*k1/M(1,1); ...
              M(2:3,2:3)\([0;k2*(p(2)-x(3))-k3*x(6)] - N(2:3,2:3)*[x(5);x(6)])];
          
    case 4
        %% Traffic diverge 3 link (discrete-time)
        % This system is a simplified representation of the flow of traffic
        % through a three-way intersection, using the cell transmission
        % model. Here, x represents the traffic flow, in vehicles/period,
        % and the links are organized as follows:
        %           /-----(2)---
        %   (1)-----|
        %           \-----(3)---
        % Vehicles move from link 1 to links 2 and 3, making this a
        % "diverge" link. 
        % A more detailed description of this model is available in:
        % Samuel Coogan and Murat Arcak, "A Benchmark Problem in 
        % Transportation Networks". arxiv:1803.00367
        
        % states:
        %     x(i): traffic flow through the i-th link
        
        % inputs:
        %     p: traffic flow injected into the first link

        
        % Parameters
        v = 0.5;            % free-flow speed, in links/period
        w = 1/6;            % congestion-wave speed, in links/period
        c = 40;             % capacity (max downstream flow), in vehicles/period
        xbar = 320;         % max occupancy when jammed, in vehicles

        % Discrete-time successor
        dx = x + [p-min([c ; v*x(1) ; 2*w*(xbar-x(2)) ; 2*w*(xbar-x(3))]); ...
                  min([c/2 ; v*x(1)/2 ; w*(xbar-x(2)) ; w*(xbar-x(3))])-min(c , v*x(2)); ...
                  min([c/2 ; v*x(1)/2 ; w*(xbar-x(2)) ; w*(xbar-x(3))])-min(c , v*x(3))];

    case 5
        %% Temperature variations in circular building (discrete-time)
        % This system models the temperature of a circular building divided
        % into N >= 3 rooms, each equipped with a heater.
        % A more detailed description is available in:
        % Giordano Pola, Pierdomenico Pepe and Maria D. Di Benedetto, 
        % "Decentralized supervisory control of networks of nonlinear 
        % control systems". IEEE Transactions on Automatic Control, 
        % v. 63(9), pp. 2803 - 2817, 2017. DOI:  10.1109/TAC.2017.2775962
        
        % states:
        %     x(i): Temperature of the i-th room.
        
        % Input
        %     p(i): Heater power (in [0,1]) for the i-th room.
        
        % Parameters
        a = 0.45;
        b = 0.045;
        c = 0.09;
        Te = -1;    % Outside temperature
        Th = 50;    % Heater temperature
        
        % System description (in each room, the temperature variations are)
        % T(i) <-- T(i) + a*(T(i+1) + T(i-1) - 2T(i)) + b*(Te - T(i)) + c*(Th - T(i))*p(i)
        n_x = length(x);
        dx = ((1-2*a-b)*eye(n_x)+a*(circshift(eye(n_x),1)+circshift(eye(n_x),-1)))*x +b*Te*ones(n_x,1) + c*Th*p - c*x.*p;
        
    case 6
        %% Time-varying system (continuous-time)
        % This is a simple linear periodic time-varying system, 
        % without a particular physical interpretation attached to it.
        % dx = A(t)*x+p
        
        % states:
        %     x(1), x(2): nonphysical
        
        % inputs: 
        %     p: disturbance inputs to the two states
        
        a = 0.8;
        A = [sin(t) cos(t) a;0 sin(t) cos(t);0 0 sin(t)];
        dx = A*x+p;
        
    case 7
        %% Bicycle (continuous-time)
        % Another cousin of the unicycle system, the Bicycle system models 
        % the planar motion of a vehicle with two wheels.
        % For a more detailed description of this model, see:
        % Majid Zamani, Giordano Pola, Manuel Mazo and Paulo Tabuada,
        % "Symbolic models for nonlinear control systems without stability 
        % assumptions". IEEE Transactions on Automatic Control, v. 57(7), 
        % pp. 1804-1809, 2012. DOI: 10.1109/TAC.2011.2176409
        
        % states:
        %     x(1), x(2): planar (x,y) coordinates of the bicycle
        %     x(3): heading of the bicycle.
        
        % control:
        %     u(1): bicycle forward velocity.
        %     u(2): bicycle angular velocity.
        
        % inputs:
        %     p: disturbance inputs to the three states

        a = atan(tan(u(2))/2);
        dx = [u(1)*cos(a+x(3))/cos(a);u(1)*sin(a+x(3))/cos(a);u(1)*tan(u(2))] + p;

    case 8
        %% Protein interaction (continuous-time)
        % This system is a simplified model of a positive feedback
        % interaction between protein and mRNA. In this case, the protein
        % encoded by a gene stimulates transcription through the nonlinear
        % term below. The salient features of this system are that it is 
        % monotone, and that for a and b values where a*b<0.5 the system 
        % exhibits a "bistable switch" behaviour, where trajectories will 
        % go to one of two stable attractors.
        
        % For a detailed discussion of protein kinematics models of this
        % kind, see the book:
        % Lee A. Segel, "Modeling dynamic phenomena in molecular and 
        % cellular biology". Cambridge University Press, 1984.
        
        % states:
        %    x(1): protein concentration
        %    x(2): mRNA concentration
        
        % inputs: none.
        
        a = 1;   % protein decay rate
        b = 0.3; % mRNA decay rate
        dx = [-a*x(1)+x(2);x(1)^2/(1+x(1)^2)-b*x(2)];

    case 9
        %% Traffic diverge nx-link (continuous-time ; needs n_x >= 5)
        % This system is a simplified representation of the flow of traffic
        % through a three-way "diverge" intersection, (vehicles in link 1
        % are evenly split between links 2 and 3), continuing with two
        % branches of additional downward links from links 2 and 3.
        % Here, x represents the traffic flow, in vehicles/period,
        % and the links are organized as follows:
        %           /-----(2)---(4)--- ... ---(nx-1)
        %   (1)----<
        %           \-----(3)---(5)--- ... ---(nx) 
        % A more detailed description of this system is available in
        % P.-J. Meyer, S. Coogan and M. Arcak, "Sampled-data reachability 
        % analysis using sensitivity and mixed-monotonicity". IEEE Control 
        % Systems Letters, v. 2(4), pp. 761-766, 2018. 
        % DOI: 10.1109/LCSYS.2018.2848280
        
        % states:
        %     x(i): traffic flow through the i-th link
        
        % inputs:
        %     p(1): traffic flow injected into the first link
        %     p(i) = 0 for all i>1 
        %        note: although the actual input is one-dimensional, we
        %        model inputs (equal to 0) for each link so that the
        %        dynamics take the addditive input form dx=f(t,x)+p, for
        %        the contraction/growth bound method to be applicable.

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
        
    case 10
        %% Nonlinear Longitudinal Model of a Quadrotor (continuous-time)
        % This model represents a quadrotor evolving in the plane (thus
        % neglecting the depth)
        
        % states:
        %     x(1), x(2): horizontal and vertical positions
        %     x(3), x(4): horizontal and vertical velocities
        %     x(5), x(6): angular position and velocity
        
        % control:
        %     u(1): main thrust
        %     u(2): side thrust

        % Parameters
        K = 0.89/1.4;
        d0 = 70;
        d1 = 17;
        n0 = 55;
        g = 9.81;
        
        % Continuous-time model
        dx = [x(3); ...
              x(4); ...
              u(1)*K*sin(x(5)); ...
              u(1)*K*cos(x(5))-g; ...
              x(6); ...
              -d0*x(5)-d1*x(6)+n0*u(2)];
          
    case 11
        %% Pursuer-evader game with 2 Dubin's vehicles (continuous-time)
        % Stack of 2 unicycle models as in case 1, 
        % but where the inputs of the first unicycle are controlled
        % while those of the second one are disturbances

        % states:
        %     x(1), x(2): planar (x,y) coordinates of the unicycle 1
        %     x(3): unicycle 1 facing angle
        %     x(4), x(5): planar (x,y) coordinates of the unicycle 2
        %     x(6): unicycle 2 facing angle
        
        % control:
        %     u(1): unicycle 1 speed
        %     u(2): unicycle 1 angular velocity
        
        % inputs:
        %     p(1): unicycle 2 speed
        %     p(2): unicycle 2 angular velocity
        
        dx = [u(1)*cos(x(3)); ...
              u(1)*sin(x(3)); ...
              u(2); ...
              p(1)*cos(x(6)); ...
              p(1)*sin(x(6)); ...
              p(2)];
          
    case 12
        %% Simple oscillator model (continuous-time)
        % The trajectories of this system are circles centered on 0 (when
        % the input p is [0;0])
        
        % states:
        %     x(1), x(2): nonphysical
        
        % inputs: 
        %     p: disturbance inputs to the two states
        
        dx = [x(2);-x(1)]+p;
        
end
