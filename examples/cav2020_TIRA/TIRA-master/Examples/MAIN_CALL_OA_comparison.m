%% Main file to use for the comparison of the main over-approximation methods on the same system
% This tool computes an interval over-approximation of the finite-time
% reachable set for a continuous-time system \dot x = f(t,x,p) with input p
% based on the intervals of initial states and of input values.
% The main methods compared are: (skipped if they cannot be called)
% - Continuous-time monotonicity
% - Continuous-time contraction/growth bound
% - Continuous-time mixed-monotonicity
% - Continuous-time sampled-data mixed-monotonicity 
%       computing the sensitivity bounds with Interval arithmetics
%       computing the sensitivity bounds with sampling and falsification
% - Discrete-time mixed-monotonicity

% Authors:  
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
%   Murat Arcak, <arcak -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 18th of February 2019

%% Initialization
close all
clear
bool_discrete_time = 0;
% Folder containing the various over-approximation methods
addpath('../OA_methods')   
% Folder containing useful tools and functions
addpath('../Utilities')    

%% Choice of the example system
% To find a description of each of these systems (and references), 
% look at their corresponding definitions in System_description.m.

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

%% Compute successors from random initial states and disturbances
sample_succ_number = 1000;
fprintf('\nCompute successors from %d random initial states and inputs ...\n', sample_succ_number)
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

%% Prepare figures for plotting (x(1)-x(2), x(3)-x(4), ...)
% Only plot if the system has between 2 and 20 dimensions (ie max 10 plots)
plot_dimensions = [];
if n_x > 1 && n_x <= 20
    % Set indices of the subplots
    if ~mod(n_x,2)  
        % Even number of states
        plot_dimensions = [(1:2:n_x)' (2:2:n_x)'];
    else                
        % Odd number of states
        plot_dimensions = [(1:2:n_x-1)' (2:2:n_x)';n_x-1 n_x];
    end
end

%% Plot the actual reachable set (from the random samples)
for i = 1:size(plot_dimensions,1)
    figure(i);
    hold on
    grid on

    % Plot the successors from random initial states
    for j = 1:sample_succ_number
        plot(rand_succ(plot_dimensions(i,1),j),rand_succ(plot_dimensions(i,2),j),'k.');
    end

    % Legend
    xlabel(['$x_',num2str(plot_dimensions(i,1)),'$'],'Interpreter','Latex','FontSize',20)
    ylabel(['$x_',num2str(plot_dimensions(i,2)),'$'],'Interpreter','Latex','FontSize',20)
end

%% Call each over-approximation functions
% (skip it if it cannot be called or returns an error)

% Define the list of considered methods (and associated variables)
methods = {'CT Monotonicity','CT Contraction/growth bound','CT Mixed-monotonicity','CT SDMM (Interval arithmetic)','CT SDMM (Sampling/Falsification)','DT Mixed-monotonicity'};
method_settings = {[1 0],[2 0],[3 0],[4 2],[4 0],[5 0]};    % First interger is the over-approximation methods, second integer is the sampled-data mixed-monotonicity submethod

% (Uncomment the two lines below to skip the sampled-data mixed-monotonicity method with sampling/falsification)
% methods = {'CT Monotonicity','CT Contraction/growth bound','CT Mixed-monotonicity','CT SDMM (Interval arithmetic)','DT Mixed-monotonicity'};
% method_settings = {[1 0],[2 0],[3 0],[4 2],[5 0]}; 

% Set plot colors and styles for compatibility with ACM color guidelines
cs = {[228,26,28]/255, [55,126,184]/255, [77,175,74]/255,...
      [152,78,163]/255, [255,127,0]/255, [255,255,51]/255, [166,86,40]/255};
lss = {'--','-.','-',':','--','-.','-'};
ncs = length(cs);
successful_methods = 0;

global sensitivity_method_setting
OA_time = NaN(length(method_settings),1);
OA_rect_handles = cell(1, size(plot_dimensions, 1));

% Loop over the considered methods
for OA_method_index=1:length(method_settings)
    sensitivity_method_setting = method_settings{OA_method_index}(2);
    try
        tic
        if bool_discrete_time
            % Call for discrete-time systems for one step starting from time t_init
            [succ_low,succ_up] = TIRA(t_init,x_low,x_up,p_low,p_up,method_settings{OA_method_index}(1)); 
        else
            % Call for continuous-time systems over the time range [t_init,t_final]
            [succ_low,succ_up] = TIRA([t_init,t_final],x_low,x_up,p_low,p_up,method_settings{OA_method_index}(1));
        end
        successful_methods = successful_methods + 1;
        OA_time(OA_method_index) = toc;        
    catch ME
        % Skip this method if it cannot be called or returns an error
        fprintf('\n%s method cannot be applied to the considered system\n',methods{OA_method_index})
        continue
    end

    % Plot the over-approximations
    for i = 1:size(plot_dimensions,1)
        figure(i);
        hold on
        grid on            

        % Plot 2D over-approximation interval
        x1_low = succ_low(plot_dimensions(i,1));
        x1_up = succ_up(plot_dimensions(i,1));
        x2_low = succ_low(plot_dimensions(i,2));
        x2_up = succ_up(plot_dimensions(i,2));
        OA_rect_handle = plot([x1_low, x1_low, x1_up, x1_up, x1_low], ...
                              [x2_low, x2_up, x2_up, x2_low, x2_low], ...
                              'DisplayName',methods{OA_method_index}, ...
                              'linewidth', 2,...
                              'linestyle',lss{successful_methods + 1}, ... 
                              'color', cs{successful_methods + 1});
        OA_rect_handles{i} = [OA_rect_handles{i} OA_rect_handle];
        legend(OA_rect_handles{i}, 'location', 'northeast')
    end
end

%% Display computation times
fprintf('\n  Computation times:\n')
for OA_method_index=1:length(method_settings)
    if isnan(OA_time(OA_method_index))
        fprintf('(not applicable):\t%s\n',methods{OA_method_index})
    else
        fprintf('%f seconds:\t%s\n',OA_time(OA_method_index),methods{OA_method_index})
    end
end

%% Save the figure
% systems = {'CT_Unicycle','CT_3_link_traffic_network','CT_Ship','DT_3_link_traffic_network','DT_Circular_building_temperature','CT_Time_varying_system','CT_Bicycle','CT_Protein_interactions','CT_nx_link_traffic_network'};
% print(sprintf('OA_test_%s', systems{system_choice}),'-dpng','-r300')
