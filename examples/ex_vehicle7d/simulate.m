clear all
close all
clc

% add the interface m files
addpath('../../interface/');

% some cosntants
center_file_name = 'vehicle.result_gb_center.raw';
radius_file_name = 'vehicle.result_gb_radius.raw';
center_pipe_file_name = 'vehicle.result_gb_center_pipe.raw';
radius_pipe_file_name = 'vehicle.result_gb_radius_pipe.raw';

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
for t=initial_time:step_size:(final_time-step_size)
    for s=1:states_dim
        center(s) = center_pipe_file.getElement(states_dim*step_idx + (s-1));
        radius(s) = radius_pipe_file.getElement(states_dim*step_idx + (s-1));
    end
    
    hr_lb = [(center(1)-radius(1)) (center(2)-radius(2))];
    hr_ub = [(center(1)+radius(1)) (center(2)+radius(2))];
    hr = [hr_lb; hr_ub];
    plot_rect(hr, 'blue', 1);
    step_idx = step_idx+1;
end
end_road = 50; 
axis([0 12 0 end_road])
set(gcf, 'Position',  [0, 0, 240, 800])
line([0.05 0.05],[0 end_road], 'LineWidth',3, 'Color','black', 'LineStyle','-')
line([4.0 4.0],[0 end_road], 'LineWidth',2, 'Color','black', 'LineStyle','--')
line([8.0 8.0],[0 end_road], 'LineWidth',2, 'Color','black', 'LineStyle','--')
line([11.95 11.95],[0 end_road], 'LineWidth',3, 'Color','black', 'LineStyle','-')
plot_rect([5 7 25 30], 'red', 1);


function [] = plot_rect(hr, rect_color, line_size)
    rectangle('Position',[hr(1) hr(3) (hr(2)-hr(1)) (hr(4)-hr(3))], 'FaceColor', rect_color ,'LineWidth',line_size);
end




