del *.raw
del out.txt

echo "Running for 1 drone" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=3,states.dim=12,inputs.dim=12" >> out.txt

echo "Running for 10 drone" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=3,states.dim=120,inputs.dim=120" >> out.txt

echo "Running for 100 drone" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=3,states.dim=1200,inputs.dim=1200" >> out.txt

echo "Running for 1000 drone" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=3,states.dim=12000,inputs.dim=12000" >> out.txt

echo "Running for 10000 drone" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=3,states.dim=120000,inputs.dim=120000" >> out.txt

echo "Running for 100000 drone" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=3,states.dim=1200000,inputs.dim=1200000" >> out.txt

echo "Running for 1000000 drone" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=3,states.dim=12000000,inputs.dim=12000000" >> out.txt

echo "Running for 10000000 drone" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=3,states.dim=120000000,inputs.dim=120000000" >> out.txt

echo "Running for 100000000 drone" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quadrotor_swarm.cfg -d 1 -p -co "save_result=false,method_choice=3,states.dim=1200000000,inputs.dim=1200000000" >> out.txt