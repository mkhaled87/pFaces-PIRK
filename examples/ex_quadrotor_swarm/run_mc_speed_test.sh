rm *.raw
rm results_mc.txt

pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=3,states.dim=12,inputs.dim=12,nsamples=2964" | tee ./results_mc.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=3,states.dim=120,inputs.dim=120,nsamples=40687" | tee -a ./results_mc.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=3,states.dim=1200,inputs.dim=1200,nsamples=517390" | tee -a ./results_mc.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=3,states.dim=12000,inputs.dim=12000,nsamples=6279140" | tee -a ./results_mc.txt
pfaces -CG -k pirk.cpu@../../kernel-pack -cfg ./ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=3,states.dim=120000,inputs.dim=120000,nsamples=73843808" | tee -a ./results_mc.txt
