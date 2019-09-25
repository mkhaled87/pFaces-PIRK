clear all
clc

% add the interface m files
addpath('../../interface/');

% some cosntants
n_links = 10;
center_file_name = 'minimal_kernel.result_gb_center.raw';
radius_file_name = 'minimal_kernel.result_gb_radius.raw';

% load the result files
if ~exist(center_file_name, 'file') || ...
    ~exist(radius_file_name, 'file')
    
    error('Please run the example first to generate the files.');
end
center_file = pirkDataFile(center_file_name);
radius_file = pirkDataFile(radius_file_name);

% collect the results
center = zeros(1,n_links);
radius = zeros(1,n_links);
for k=1:n_links
    center(k) = center_file.getElement(k-1);
    radius(k) = radius_file.getElement(k-1);
end

% print the lower/upper bounds of the reach-set
disp(['Center: ' num2str(center, '%3.3f\t')]);
disp(['Radius: ' num2str(radius, '%3.3f\t')]);
lb = center - radius;
ub = center + radius;
disp(['Lower-bound of reach-set: ' num2str(lb, '%3.3f\t')]);
disp(['Upper-bound of reach-set: ' num2str(ub, '%3.3f\t')]);

