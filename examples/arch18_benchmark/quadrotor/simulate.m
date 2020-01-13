clear all
close all
clc

% add the interface m files
addpath('../../../interface/');

% some cosntants
center_file_name = 'quadrotor.result_gb_center.raw';
radius_file_name = 'quadrotor.result_gb_radius.raw';
center_pipe_file_name = 'quadrotor.result_gb_center_pipe.raw';
radius_pipe_file_name = 'quadrotor.result_gb_radius_pipe.raw';

% print the lower/upper bounds of the reach-set
center_file = pirkDataFile(center_file_name);
radius_file = pirkDataFile(radius_file_name);
states_dim = str2double(center_file.getMetadataElement('states.dim'));
center = zeros(1,states_dim);
radius = zeros(1,states_dim);
for k=1:states_dim
    center(k) = center_file.getElement(k-1);
    radius(k) = radius_file.getElement(k-1);
end
disp(['Center: ' num2str(center, '%3.3f\t')]);
disp(['Radius: ' num2str(radius, '%3.3f\t')]);
lb = center - radius;
ub = center + radius;
disp(['Lower-bound of reach-set: ' num2str(lb, '%3.3f\t')]);
disp(['Upper-bound of reach-set: ' num2str(ub, '%3.3f\t')]);


% plot the pipe
center_pipe_file = pirkDataFile(center_pipe_file_name);
radius_pipe_file = pirkDataFile(radius_pipe_file_name);
initial_time = str2double(center_pipe_file.getMetadataElement('initial_time'));
final_time = str2double(center_pipe_file.getMetadataElement('final_time'));
step_size = str2double(center_pipe_file.getMetadataElement('step_size'));
nsteps = str2double(center_pipe_file.getMetadataElement('nsteps'));
step_idx=0;
lb_t = [];
ub_t = [];
cent_t =[];
for t=initial_time:step_size:(final_time-step_size)
    for s=1:states_dim
        center(s) = center_pipe_file.getElement(states_dim*step_idx + (s-1));
        radius(s) = radius_pipe_file.getElement(states_dim*step_idx + (s-1));
    end
    
    % record x_4 over time
    lb_t = [lb_t (center(3)-radius(3))];
    ub_t = [ub_t (center(3)+radius(3))];
    cent_t = [cent_t center(3)];
    
    step_idx = step_idx+1;
end
t=initial_time:step_size:(final_time-step_size);
plot(t,lb_t, '--b');
hold on
plot(t,cent_t, '*r');
hold on
plot(t,ub_t, '--b');
grid on;




