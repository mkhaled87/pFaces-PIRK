rm *.raw
rm results_gb.txt

pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=10,inputs.dim=10" | tee ./results_gb.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=100,inputs.dim=100" | tee -a ./results_gb.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=1000,inputs.dim=1000" | tee -a ./results_gb.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=10000,inputs.dim=10000" | tee -a ./results_gb.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=100000,inputs.dim=100000" | tee -a ./results_gb.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=1000000,inputs.dim=1000000" | tee -a ./results_gb.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=10000000,inputs.dim=10000000" | tee -a ./results_gb.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=100000000,inputs.dim=100000000" | tee -a ./results_gb.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=1000000000,inputs.dim=1000000000" | tee -a ./results_gb.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=2000000000,inputs.dim=2000000000" | tee -a ./results_gb.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=3000000000,inputs.dim=3000000000" | tee -a ./results_gb.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=4000000000,inputs.dim=4000000000" | tee -a ./results_gb.txt
