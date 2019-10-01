clear all
clc

% add the interface m files
addpath('../../interface/');

% some cosntants
n_links = 10;
posts_file_name = 'minimal_kernel.result_mc_posts.raw';

% load the result files
if ~exist(posts_file_name, 'file')    
    error('Please run the example first to generate the files.');
end
posts_file = pirkDataFile(posts_file_name);
nsamples = str2double(posts_file.getMetadataElement('nsamples'));

if(nsamples <= 0)
    error('The results file has no samples. are you running the MC method ?');
end

% collect/show the results
for k=0:nsamples-1
    posts = zeros(1,n_links);
    for j=0:n_links-1
        flat_idx = k*n_links + j;
        posts(j+1) = posts_file.getElement(flat_idx);
    end
    disp(['MC Sample #' num2str(k+1) ': ' num2str(posts, '%3.3f\t')]);
end

