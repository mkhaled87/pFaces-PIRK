rm *.raw
rm results_mchd.txt

pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=10,inputs.dim=10,nsamples=2397" | tee ./results_mchd.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=100,inputs.dim=100,nsamples=33177" | tee -a ./results_mchd.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=1000,inputs.dim=1000,nsamples=423866" | tee -a ./results_mchd.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=10000,inputs.dim=10000,nsamples=5159688" | tee -a ./results_mchd.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=100000,inputs.dim=100000,nsamples=60807220" | tee -a ./results_mchd.txt
