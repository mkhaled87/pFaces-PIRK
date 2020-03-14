%% Reachable set over-approximation for a continuous-time monotone system
% Partial orders on the state and input spaces related to the monotonicity
% property are provided to this function call.
% The extremal state and input values with respect to these partial orders
% are first computed, then used to compute two successors of the
% continuous-time system bounding its reachable set.
%
% This method can only be applied to systems satisfying the monotonicity
% property, which can be checked through the function:
% Utilities/Monotonicity_sign_conditions.m
%
% To avoid check the satisfaction of the monotonicity property, the more
% general over-approximation method 3 can be applied:
% OA_methods/OA_3_CT_Mixed_Monotonicity.m
% and will provide the same results as this function if the system is
% indeed monotone. However, the scalability of method 3 is not as good as
% method 1.

% Source paper
% D. Angeli and E. D. Sontag, "Monotone control systems". IEEE Transactions
% on automatic control, v. 48(10), pp. 1684-1698, 2003.
% DOI:  10.1109/TAC.2003.817920

% List of inputs
%   t_init: initial time
%   t_final: time at which the reachable set is approximated
%   [x_low,x_up]: interval of initial states (at time t_init)
%   [p_low,p_up]: interval of allowed input values
%   partial_order_x, partial_order_p: binary vectors representing partial 
%       orders on the state and input spaces for which the system satisfies
%       the monotonicity property:
%       if partial_order_x(i)=0, use classical inequality on dimension i
%           x(i) is "larger" (w.r.t. partial order) than y(i) if x(i)>=y(i)
%       if partial_order_x(i)=1, use reversed inequality on dimension i
%           x(i) is "larger" (w.r.t. partial order) than y(i) if x(i)<=y(i)

% List of outputs
%   [succ_low,succ_up]: interval over-approximation of the reachable set (at time t_final)

% Authors:  
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 6th of February 2019

function [succ_low,succ_up] = OA_1_CT_Monotonicity(t_init,t_final,x_low,x_up,p_low,p_up,partial_order_x,partial_order_p)

% State extrema with respect to partial_order_x
% (partial order: "x1 <= x2" if (x1-x2).*(-1)^partial_order_x <= 0)
x_low_PO = ~partial_order_x.*x_low + partial_order_x.*x_up;
x_up_PO = partial_order_x.*x_low + ~partial_order_x.*x_up;

% Input extrema with respect to partial_order_p
% (partial order: "p1 <= p2" if (p1-p2).*(-1)^partial_order_p <= 0)
p_low_PO = ~partial_order_p.*p_low + partial_order_p.*p_up;
p_up_PO = partial_order_p.*p_low + ~partial_order_p.*p_up;

% Lower bound of the over-approximation is the successor of the system
% starting from state x_low_PO with constant input p_low_PO
[~,x_traj_low] = ode45(@(t,x) System_description(t,x,p_low_PO),[t_init,t_final],x_low_PO);
succ_low = x_traj_low(end, :)';

% Upper bound of the over-approximation is the successor of the system
% starting from state x_up_PO with constant input p_up_PO
[~,x_traj_up] = ode45(@(t,x) System_description(t,x,p_up_PO),[t_init,t_final],x_up_PO);
succ_up = x_traj_up(end, :)';
