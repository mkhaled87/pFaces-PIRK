del *.raw
del results_gb.txt

echo "Running for 1 drone" >> results_gb.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=12,inputs.dim=12" >> results_gb.txt

echo "Running for 10 drone" >> results_gb.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=120,inputs.dim=120" >> results_gb.txt

echo "Running for 100 drone" >> results_gb.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=1200,inputs.dim=1200" >> results_gb.txt

echo "Running for 1000 drone" >> results_gb.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=12000,inputs.dim=12000" >> results_gb.txt

echo "Running for 10000 drone" >> results_gb.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=120000,inputs.dim=120000" >> results_gb.txt

echo "Running for 100000 drone" >> results_gb.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=1200000,inputs.dim=1200000" >> results_gb.txt

echo "Running for 1000000 drone" >> results_gb.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=12000000,inputs.dim=12000000" >> results_gb.txt

echo "Running for 10000000 drone" >> results_gb.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=120000000,inputs.dim=120000000" >> results_gb.txt

echo "Running for 100000000 drone" >> results_gb.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=1200000000,inputs.dim=1200000000" >> results_gb.txt