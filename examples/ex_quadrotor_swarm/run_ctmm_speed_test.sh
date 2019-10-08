rm *.raw
rm results_ctmm.txt

pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=2,states.dim=12,inputs.dim=12" | tee ./results_ctmm.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=2,states.dim=120,inputs.dim=120" | tee -a ./results_ctmm.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=2,states.dim=1200,inputs.dim=1200" | tee -a ./results_ctmm.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=2,states.dim=12000,inputs.dim=12000" | tee -a ./results_ctmm.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=2,states.dim=120000,inputs.dim=120000" | tee -a ./results_ctmm.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=2,states.dim=1200000,inputs.dim=1200000" | tee -a ./results_ctmm.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=2,states.dim=12000000,inputs.dim=12000000" | tee -a ./results_ctmm.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=2,states.dim=120000000,inputs.dim=120000000" | tee -a ./results_ctmm.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=2,states.dim=1200000000,inputs.dim=1200000000" | tee -a ./results_ctmm.txt
