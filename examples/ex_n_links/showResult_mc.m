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
posts = zeros(nsamples,n_links);
for k=0:nsamples-1    
    for j=0:n_links-1
        flat_idx = k*n_links + j;
        posts(k+1,j+1) = posts_file.getElement(flat_idx);
    end
    disp(['MC Sample #' num2str(k+1) ': ' num2str(posts(k+1,:), '%3.3f\t')]);
end
reachlb = posts(1,:);
reachub = posts(1,:);
for k=1:nsamples
    for j=1:n_links
        if(posts(k,j) < reachlb(j))
            reachlb(j) = posts(k,j);
        end
        if(posts(k,j) > reachub(j))
            reachub(j) = posts(k,j);
        end        
    end
end    
disp(['reachlb: ' num2str(reachlb, '%3.3f\t')]);
disp(['reachub: ' num2str(reachub, '%3.3f\t')]);







