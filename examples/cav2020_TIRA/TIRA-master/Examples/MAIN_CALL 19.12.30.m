%% Main file to use for a single call of the tool
% This tool computes an interval over-approximation of the finite-time
% reachable set for a continuous-time system dx/dt = f(t,x,p) or
% discrete-time system x^+ = f(t,x,p) with input p, based on the intervals 
% of initial states and of input values.

% Authors:  
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
%   Murat Arcak, <arcak -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 6th of February 2019

%% Initialization
close all
clear
bool_discrete_time = 0;
% Folder containing the various over-approximation methods
addpath('../OA_methods')   
% Folder containing useful tools and functions
addpath('../Utilities')    

%% Choice of the example system
global system_choice
% system_choice = 1;      % Unicycle (continuous-time)
system_choice = 2;      % Traffic diverge 3 link (continuous-time)
% system_choice = 3;      % Ship (continuous-time)
% system_choice = 4;      % Traffic diverge 3 links (discrete-time)
% system_choice = 5;      % Temperature variations in circular building (discrete time)
% system_choice = 6;      % Time-varying system (continuous-time)
% system_choice = 7;      % Bicycle (continuous-time)
% system_choice = 8;      % Protein interaction (continuous-time)
% system_choice = 9;      % Traffic diverge n_x links (continuous-time)
% system_choice = 10;     % Longitudinal Quadrotor Model (continuous-time)
% system_choice = 11;     % 2 unicycles pursuer-evader (continuous-time)
% system_choice = 12;     % Simple oscillator (continuous-time)

%% Optional submethod choice for the sampled-data mixed-monotonicity method
global sensitivity_method_setting
sensitivity_method_setting = NaN;

%% Definition of the reachability problem (for each example system)
global u        % Some systems need an external control input
switch system_choice
    case 1
        %% Unicycle (continuous-time)
        % Interval of initial states (defined by two column vectors)
        x_up = [1;1;pi/8];
        x_low = [0;0;-pi/8];
        n_x = length(x_up);
        
        % Control
        u = [0.25;0.15];
        
        % Interval of allowed input values (disturbances)
        p_up = [0.05;0.05;0.03];
        p_low = -p_up;
        n_p = length(p_up);

        % Time interval
        t_init = 0;         % Initial time
        t_final = 4;        % Final time
        
    case 2
        %% Traffic diverge 3 link (continuous-time)
        % Defined as a system with additive input: dx=f(t,x)+p
        
        T = 30; % Time step
        
        % Interval of initial states (defined by two column vectors)
        x_low = [150;180;100];
        x_up = [200;300;220];
        n_x = length(x_low);

        % Interval of allowed input values (input flow into link 1)
        p_low = [40;0;0]/T;
        p_up = [60;0;0]/T;
        n_p  = length(p_low);

        % Time interval
        t_init = 0;                 % Initial time
        t_final = t_init + T;       % Final time

    case 3
        %% Ship (continuous-time)
        % Interval of initial states (defined by two column vectors)
        x_up = [1;1;pi/8;0.15;0.05;0.2];
        x_low = [0;0;-pi/8;0.05;-0.05;-0.2];
        n_x = length(x_low);

        % Interval of allowed input values (velocity/heading setpoints)
        p_up = [0.1;pi/2];
        p_low = [0.1;pi/2];
        n_p  = length(p_up);

        % Time interval
        t_init = 0;         % Initial time
        t_final = 5;        % Final time
        
    case 4
        %% Traffic diverge 3 link (discrete-time)
        % Interval of initial states (defined by two column vectors)
        x_low = [150;180;100];
        x_up = [200;300;220];
        n_x = length(x_low);

        % Interval of allowed input values (input flow into link 1)
        p_low = 40;
        p_up = 60;
        n_p  = length(p_low);

        % Time interval
        t_init = 0;         % Initial time
        bool_discrete_time = 1;

    case 5
        %% Temperature variations in circular building (discrete time)
        % Interval of initial states (defined by two column vectors)
        x_low = [18;20;20;19;21;17];
        x_up = [19;20;21;21;22;19];
        n_x = length(x_low);

        % Interval of allowed input values (heater control)
        heater_max = 0.6;   % <=0.6 to have a monotone system ; >0.6 for a general system (non-monotone, non sign-stable)
        p_low = zeros(n_x,1);
        p_up = heater_max*ones(n_x,1);
        n_p  = length(p_low);

        % Time interval
        t_init = 0;         % Initial time
        bool_discrete_time = 1;

    case 6
        %% Time-varying system (continuous-time)
        % Interval of initial states (defined by two column vectors)
        x_low = [1;2;3];
        x_up = [2;4;4];
        n_x = length(x_low);

        % Interval of allowed input values (defined by two column vectors)
        p_up = 4*ones(n_x,1);
        p_low = -p_up;
        n_p  = length(p_low);
        
        % Time interval
        t_init = 1;
        t_final = 2;

    case 7
        %% Bicycle (continuous-time)
        % Interval of initial states (defined by two column vectors)
        x_up = [1;1;pi/8];
        x_low = [0;0;-pi/8];
        n_x = length(x_up);

        % Control
        u = [0.25;0.15];

        % Interval of allowed input values (disturbances)
        p_up = 0.3*ones(n_x,1);
        p_low = -p_up;
        n_p  = length(p_low);
        
        % Time interval
        t_init = 0;
        t_final = 2;

    case 8
        %% Protein interaction (continuous-time)
        % Interval of initial states (defined by two column vectors)
        x_low = [0;0];
        x_up = [1;1];
        n_x = length(x_low);

        % Interval of allowed input values
        % (system has no input: set both p_up and p_low to 0)
        p_up = 0;
        p_low = 0;
        n_p  = length(p_low);

        % Time interval
        t_init = 0;
        t_final = 1;
        
    case 9
        %% Traffic diverge nx-link (continuous-time ; needs n_x >= 5)
        % Defined as a system with additive input: dx=f(t,x)+p
        
        % Number of links in traffic network (needs to be >=5)
        n_x = 99;

        T = 30; % Time step

        % Interval of initial states (defined by two column vectors)
        x_low = 100*ones(n_x,1);
        x_up = 200*ones(n_x,1);

        % Interval of allowed input values (input flow into link 1)
        p_low = zeros(n_x,1);
        p_low(1) = 40/T;
        p_up = zeros(n_x,1);
        p_up(1) = 60/T;
        n_p  = length(p_low);

        % Time interval
        t_init = 0;         % Initial time
        t_final = t_init + T;        % Final time
        
    case 10
        %% Nonlinear Longitudinal Model of a Quadrotor (continuous-time)
        % Parameters
        K = 0.89/1.4;
        g = 9.81;

        % State constraints
        X_up = [1.7;2;0.8;1;pi/12;pi/2];
        X_low = [-1.7;0.3;-0.8;-1;-pi/12;-pi/2];
        
        % Interval of initial states (defined by two column vectors)
        x_up = [0.2;1.2;0.3;0.1;pi/20;pi/10];
        x_low = [-0.2;1;0.1;-0.2;0;-pi/10];
        n_x = length(x_low);
        
        % Control
        u_up = [1.5+g/K;pi/12];
        u_low = [-1.5+g/K;-pi/12];
        u = u_low + rand(size(u_low)).*(u_up-u_low);
        
        % Interval of allowed input values
        % (system has no input: set both p_up and p_low to 0)
        p_up = zeros(n_x,1);
        p_low = zeros(n_x,1);
        n_p  = length(p_low);
        
        % Time interval
        t_init = 0;         % Initial time
        t_final = 1;        % Final time
        
    case 11
        %% Pursuer-evader game with 2 Dubin's vehicles (continuous-time)
        % Interval of initial states (defined by two column vectors)
        x_up = [1;1;pi/8;2.5;2.5;3*pi/8];
        x_low = [0;0;-pi/8;2;2;pi/4];
        n_x = length(x_up);
        
        % Control
        u = [0.25;0.15];
        
        % Interval of allowed input values (disturbances)
        p_up = [0.5;0.3];
        p_low = -p_up;
        n_p = length(p_up);

        % Time interval
        t_init = 0;         % Initial time
        t_final = 1;        % Final time
        
    case 12
        %% Simple oscillator model (continuous-time)
        % Interval of initial states (defined by two column vectors)
        x_low = [0;0];
        x_up = [1;1];
        n_x = length(x_low);

        % Interval of allowed input values
        % (system has no input: set both p_up and p_low to 0)
        p_up = [0;0];
        p_low = [0;0];
        n_p  = length(p_low);

        % Time interval
        t_init = 0;
        t_final = 1;
        
end

%% Call of the main over-approximation function
% succ_low is the lower bound of the over-approximation interval
% succ_up is the upper bound of the over-approximation interval

if bool_discrete_time
    % Call for discrete-time systems for one step starting from time t_init
    [succ_low,succ_up] = TIRA(t_init,x_low,x_up,p_low,p_up);
else
    % Call for continuous-time systems over the time range [t_init,t_final]
    [succ_low,succ_up] = TIRA([t_init,t_final],x_low,x_up,p_low,p_up);
end

%% Optional choice of the over-approximation method to be used

% The optional choice of the over-approximation method can either be done
%   in the file Solver_parameters.m, 
%       then calling the function TIRA as above
%
%   or here, defining the integer 'OA_method' to one of the methods below:
%           1 - Continuous-time monotonicity
%           2 - Continuous-time componentwise contraction and growth bound
%           3 - Continuous-time mixed-monotonicity
%           4 - Continuous-time sampled-data mixed-monotonicity
%           5 - Discrete-time mixed-monotonicity
%       then adding 'OA_method' as the last argument of function TIRA:
%       [succ_low,succ_up] = TIRA([t_init,t_final],x_low,x_up,p_low,p_up,OA_method);
%       [succ_low,succ_up] = TIRA(t_init,x_low,x_up,p_low,p_up,OA_method);

% If it is not provided, function TIRA.m will pick the most
% suitable method that can be used with the additional system descriptions
% provided by the user in the './Input_files' folder.

%% Compute successors from random initial states and disturbances
sample_succ_number = 1000;
fprintf('\nCompute successors from %d random initial states and parameters ...\n', sample_succ_number)
tic
rand_succ = NaN(n_x,sample_succ_number);
for i = 1:sample_succ_number
    x0 = x_low + rand(n_x,1).*(x_up-x_low);
    p = p_low + rand(n_p,1).*(p_up-p_low);
    if bool_discrete_time
        rand_succ(:,i) = System_description(t_init,x0,p);
    else
        [~,x_traj] = ode45(@(t,x) System_description(t,x,p),[t_init t_final],x0);
        rand_succ(:,i) = x_traj(end,:)';
    end
end
toc

%% Plot the reachable set and over-approximations
% Only plot if the system has between 2 and 20 dimensions (ie max 10 plots)
if n_x > 1 && n_x <= 20         
    % Set indices of the subplots
    if ~mod(n_x,2)  
        % Even number of states
        plot_dimensions = [(1:2:n_x)' (2:2:n_x)'];
    else                
        % Odd number of states
        plot_dimensions = [(1:2:n_x-1)' (2:2:n_x)';n_x-1 n_x];
    end
    
    % Subplots
    for i = 1:size(plot_dimensions,1)
        figure
        hold on
        grid on

        % Plot the successors from random initial states
        for j = 1:sample_succ_number
            plot(rand_succ(plot_dimensions(i,1),j),rand_succ(plot_dimensions(i,2),j),'k.');
        end

        % Over-approximation interval
        handle_OA_IA = rectangle('Position',[succ_low(plot_dimensions(i,:))' (succ_up(plot_dimensions(i,:))-succ_low(plot_dimensions(i,:)))']);
        set(handle_OA_IA,'edgecolor',[0 0.5 0],'linewidth',2)

        % Legend
        xlabel(['$x_',num2str(plot_dimensions(i,1)),'$'],'Interpreter','Latex','FontSize',20)
        ylabel(['$x_',num2str(plot_dimensions(i,2)),'$'],'Interpreter','Latex','FontSize',20)
    end
end
