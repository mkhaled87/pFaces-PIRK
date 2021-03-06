%% Monte Carlo-base Reachable Set Estimation for a continuous-time system
% This reachability method produces an interval estimate of the reachable
% set by computing the value of the successor function at a number of
% sample points in the initial set and input set. The number of samples is
% calculated so that the reachable set contains most of the points in the
% reachable set with high probability.
%
% Source paper:
% A. Devonport and M. Arcak, "Data-Driven Reachable Set Computation 
% using Adaptive Gaussian Process Classification and Monte Carlo Methods." 
% arXiv preprint arXiv:1910.02500 (2019).
% Available at https://arxiv.org/abs/1910.02500.

% List of inputs
%   t_init: initial time
%   t_final: time at which the reachable set is approximated
%   [x_low,x_up]: interval of initial states (at time t_init)
%   [p_low,p_up]: interval of allowed input values
% epsilon: probabilistic guarantee accuracy parameter. Reachable set will contain 1-epsilon of the probability measure
% delta: probabilistic guarantee confidence parameter: Reachable set will satisfy the epsilon guarantee with probability 1-delta

function [succ_low, succ_up] = OA_6_probabilistic_MCS(t_init, t_final, x_low, x_up, p_low, p_up, epsilon, delta)

% compute the sample trajectories

n_x = size(x_low,1);
n_p = size(p_low,1);

vcd = 2*(n_x); % VC dimension
n_samples_needed = ceil((vcd/epsilon)*log(vcd/delta));
fprintf('Need %d samples to compute probabilistic bound\n', n_samples_needed)


rand_succ = NaN(n_x,n_samples_needed);
rand_inputs = NaN(n_x,n_samples_needed);
tic
for i = 1:n_samples_needed
    x0 = x_low + rand(n_x,1).*(x_up-x_low);
    rand_inputs(:,i) = x0;
    p = p_low + rand(n_p,1).*(p_up-p_low);
    rand_succ(:,i)= succ(x0, p, t_init, t_final);
end
toc

% successors are stored as column, so we want the max & min among column
succ_low = min(rand_succ,[],2);
succ_up = max(rand_succ,[],2);
end
function xf = succ(x0, p, t0, tf)
% Helper function to compute the successor state. We may have to change
% from using ode45 to something else in the future, so it's wise to factor
% it out here.
    [ts,x_traj] = ode45(@(t,x) System_description(t,x,p),[t0 tf],x0);
    %disp(ts(2)-ts(1))
    xf = x_traj(end,:);
end

