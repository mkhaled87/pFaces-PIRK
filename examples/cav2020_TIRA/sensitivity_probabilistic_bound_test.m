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
% system_choice = 1;      % Unicycle
% system_choice = 2;      % Traffic diverge 3 links
 system_choice = 3;      % Ship
% system_choice = 4;      % Traffic diverge 3 links (discrete-time)
% system_choice = 5;      % Temperature variations in circular building (discrete time)
% system_choice = 6;      % Time-varying continuous-time system
% system_choice = 7;      % Bicycle
% system_choice = 8;      % Protein interaction
% system_choice = 9;      % Traffic diverge n_x links

%% Definition of the reachability problem (for each example system)
global u        % Some systems need an external control input

% To find a description of each of these systems (and references), 
% look at their corresponding definitions in System_description.m.
switch system_choice
    case 1
        %% Unicycle
        % Interval of initial states (defined by two column vectors)
        x_up = [33;20;pi];
        x_low = [0;0;-pi];
        n_x = length(x_up);
        
        % Control
        u = [0.25;0.15];
        
        % Interval of allowed input values (defined by two column vectors)
        p_up = [0.05;0.05;0.03];
        p_low = -p_up;
        n_p = length(p_up);

        % Time interval
        t_init = 0;         % Initial time
        t_final = 4;        % Final time
        
    case 2
        %% Traffic diverge 3 link
        % Defined as a system with additive input: dx=f(t,x)+p
        
        T = 30; % Time step
        
        % Interval of initial states (defined by two column vectors)
        x_low = [150;180;100];   % for the min(*,*,*,*) not to be always the same term 
        x_up = [200;300;220];
        n_x = length(x_low);

        % Interval of allowed input values (defined by two column vectors)
        p_low = [40;0;0]/T;
        p_up = [60;0;0]/T;
        n_p  = length(p_low);

        % Time interval
        t_init = 0;         % Initial time
        t_final = t_init + T;        % Final time

    case 3
        %% Ship
        % State space (only to pick initial conditions)
        X_max = [10;10;pi;0.15;0.05;0.2];
        X_min = [-10;-10;-pi;0.05;-0.05;-0.2];
        n_x = length(X_max);
        x_low = X_min + rand(n_x,1).*(X_max-X_min);
        x_up = min(X_max,x_low + rand(n_x,1).*(X_max-X_min));

        % Control input space
        p_up = [0.15;pi];      
        p_low = [0.05;-pi];     
        n_p  = length(p_up);

        % Time interval
        t_init = 0;         % Initial time
        t_final = 5;        % Final time
        
    case 4
        %% Traffic diverge 3 link (discrete-time)
        % Interval of initial states (defined by two column vectors)
        x_low = [150;180;100];   % for the min(*,*,*,*) not to be always the same term
        x_up = [200;300;220];
        n_x = length(x_low);

        % Interval of allowed input values (defined by two column vectors)
        p_low = 40;         % ud= [d1]
        p_up = 60;
        n_p  = length(p_low);

        % Time interval
        t_init = 0;         % Initial time
        t_final = 0;
        bool_discrete_time = 1;

    case 5
        %% Temperature variations in circular building (discrete time)
        % Interval of initial states (defined by two column vectors)
        x_low = [18;20;20;19;21;17];
        x_up = [19;20;21;21;22;19];
        n_x = length(x_low);

        % Interval of allowed input values (defined by two column vectors)
        heater_max = 0.6;   % <=0.6 to have a monotone system ; >0.6 for a general system (non-monotone, non sign-stable)
        p_low = zeros(n_x,1);
        p_up = heater_max*ones(n_x,1);
        n_p  = length(p_low);

        % Time interval
        t_init = 0;         % Initial time
        bool_discrete_time = 1;
        t_final = 0; % shouldn't matter

    case 6
        %% Time-varying system
        x_low = [1;2;3];
        x_up = [2;4;4];
        n_x = length(x_low);

        p_up = 4*ones(n_x,1);
        p_low = -p_up;
        n_p  = length(p_low);
        
        % Time interval
        t_init = 1;
        t_final = 2;

    case 7
        %% Bicycle
        % Interval of initial states (defined by two column vectors)
        x_up = [10;10;pi];
        x_low = [0;0;-pi];
        n_x = length(x_up);

        % Control
        u = [0; 0];

        % Input (disturbance)
        p_up = 0.3*ones(n_x,1);
        p_low = -p_up;
        n_p  = length(p_low);
        
        % Time interval
        t_init = 0;
        t_final = 2;

    case 8
        %% Protein interaction
        x_low = [0;0];
        x_up = [1;1];
        n_x = length(x_low);

        p_up = 0;
        p_low = 0;
        n_p  = length(p_low);

        t_init = 0;
        t_final = 1;
        
    case 9
        %% Traffic diverge n_x-link
        % Defined as a system with additive input: dx=f(t,x)+p
        
        % Number of links in traffic network (needs to be >=5)
        n_x = 99;

        T = 30; % Time step

        % Interval of initial states (defined by two column vectors)
        x_low = 100*ones(n_x,1);
        x_up = 200*ones(n_x,1);

        % Interval of allowed input values (defined by two column vectors)
        p_low = zeros(n_x,1);
        p_low(1) = 40/T;
        p_up = zeros(n_x,1);
        p_up(1) = 60/T;
        n_p  = length(p_low);

        % Time interval
        t_init = 0;         % Initial time
        t_final = t_init + T;        % Final time
end

% compute the probabilistic bound
delta = 0.05;
epsilon = 0.05;
% compute number of samples needed for desired confidence
% sample number from Tempo
%n_samples_needed = ceil(log(1/delta)/(log(1/(1-eps))));
% sample number from direct application of Chernoff bound
n_samples_needed = ceil(log(2/delta)/(2*eps^2));
fprintf('Need %d samples to compute probabilistic bound\n', n_samples_needed)
solver_choice = 2; % ODE45 on sensitivity ODE using explicit Jacobian function (requires Input_files/UP_Jacobian_Function.m)
[S_x,S_p] = Sensitivity_sampling(t_init,t_final,x_low,x_up,p_low,p_up,solver_choice,sampling_pairs);


%% Compute successors from random initial states and disturbances
sample_succ_number = 10000;
fprintf('\nCompute successors from %d random initial states and inputs ...\n', sample_succ_number)
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

ne = 0;  % number of samples exceeding bound
for j=1:sample_succ_number
    ssi = rand_succ(:,j);
    if any(ssi > succ_up) || any(ssi < succ_low)
        ne = ne + 1;
    end
end

fraction_violating = ne / sample_succ_number;
fprintf('Of the %d sampled successors, %d exceeded the bound\n', sample_succ_number, ne)
fprintf('Fraction of random samples violating bound: %g\n', fraction_violating)
if fraction_violating <= epsilon
    disp('Probabilistic bound satisfied')
else
    disp('Probabilistic bound NOT satisfied!')
end

