del *.raw
del out.txt

echo "Running for 1 drone" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quad_apf.cfg -d 1 -p -co "save_result=false,method_choice=1,states.dim=12,inputs.dim=12,row_max=12" >> out.txt

echo "Running for 10 drones" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quad_apf.cfg -d 1 -p -co "save_result=false,method_choice=1,states.dim=120,inputs.dim=120,row_max=120" >> out.txt

echo "Running for 100 drones" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quad_apf.cfg -d 1 -p -co "save_result=false,method_choice=1,states.dim=1200,inputs.dim=1200,row_max=1200" >> out.txt

echo "Running for 1000 drones" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quad_apf.cfg -d 1 -p -co "save_result=false,method_choice=1,states.dim=12000,inputs.dim=12000,row_max=12000" >> out.txt

echo "Running for 10000 drones" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quad_apf.cfg -d 1 -p -co "save_result=false,method_choice=1,states.dim=120000,inputs.dim=120000,row_max=120000" >> out.txt

echo "Running for 100000 drones" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quad_apf.cfg -d 1 -p -co "save_result=false,method_choice=1,states.dim=1200000,inputs.dim=1200000,row_max=1200000" >> out.txt

echo "Running for 1000000 drones" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quad_apf.cfg -d 1 -p -co "save_result=false,method_choice=1,states.dim=12000000,inputs.dim=12000000,row_max=12000000" >> out.txt

echo "Running for 10000000 drones" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quad_apf.cfg -d 1 -p -co "save_result=false,method_choice=1,states.dim=120000000,inputs.dim=120000000,row_max=120000000" >> out.txt

echo "Running for 100000000 drones" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_quad_apf.cfg -d 1 -p -co "save_result=false,method_choice=1,states.dim=1200000000,inputs.dim=1200000000,row_max=1200000000" >> out.txt