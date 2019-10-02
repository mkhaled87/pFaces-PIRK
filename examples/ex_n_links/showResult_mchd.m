clear all
clc

% add the interface m files
addpath('../../interface/');

% some cosntants
n_links = 10;
reachlb_file_name = 'minimal_kernel.result_mchd_reachlb.raw';
reachub_file_name = 'minimal_kernel.result_mchd_reachub.raw';

% load the result files
if ~exist(reachlb_file_name, 'file') || ~exist(reachub_file_name, 'file')
    error('Please run the example first to generate the files.');
end
reachlb_file = pirkDataFile(reachlb_file_name);
nsamples = str2double(reachlb_file.getMetadataElement('nsamples'));

reachub_file = pirkDataFile(reachub_file_name);


if(nsamples <= 0)
    error('The results file has no samples. are you running the MC method ?');
end

disp(['This MC method used ' num2str(nsamples) ' simulations']);

% collect/show the results
reachlb = zeros(1,n_links);
reachub = zeros(1,n_links);
for j=0:n_links-1
    reachlb(j+1) = reachlb_file.getElement(j);
    reachub(j+1) = reachub_file.getElement(j);
end
disp(['reachlb: ' num2str(reachlb, '%3.3f\t')]);
disp(['reachub: ' num2str(reachub, '%3.3f\t')]);


