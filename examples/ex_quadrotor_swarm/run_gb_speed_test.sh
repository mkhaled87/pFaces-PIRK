rm *.raw
rm results.txt

pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=12,inputs.dim=12" | tee ./results.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=120,inputs.dim=120" | tee -a ./results.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=1200,inputs.dim=1200" | tee -a ./results.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=12000,inputs.dim=12000" | tee -a ./results.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=120000,inputs.dim=120000" | tee -a ./results.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=1200000,inputs.dim=1200000" | tee -a ./results.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=12000000,inputs.dim=12000000" | tee -a ./results.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=120000000,inputs.dim=120000000" | tee -a ./results.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=1200000000,inputs.dim=1200000000" | tee -a ./results.txt
