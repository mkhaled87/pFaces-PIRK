del *.raw
del results_mc.txt

echo "Running for 1 drone" >> results_mc.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=3,states.dim=12,inputs.dim=12,nsamples=2964" >> results_mc.txt

echo "Running for 10 drone" >> results_mc.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=3,states.dim=120,inputs.dim=120,nsamples=40687" >> results_mc.txt

echo "Running for 100 drone" >> results_mc.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=3,states.dim=1200,inputs.dim=1200,nsamples=517390" >> results_mc.txt

echo "Running for 1000 drone" >> results_mc.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=3,states.dim=12000,inputs.dim=12000,nsamples=6279140" >> results_mc.txt

echo "Running for 10000 drone" >> results_mc.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=3,states.dim=120000,inputs.dim=120000,nsamples=73843808" >> results_mc.txt