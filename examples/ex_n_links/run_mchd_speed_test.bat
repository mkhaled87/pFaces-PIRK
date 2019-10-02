del *.raw
del out.txt

echo "Running for 1 links" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=10,inputs.dim=10" >> out.txt

echo "Running for 100 links" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=100,inputs.dim=100" >> out.txt

echo "Running for 1000 links" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=1000,inputs.dim=1000" >> out.txt

echo "Running for 10000 links" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=10000,inputs.dim=10000" >> out.txt

echo "Running for 100000 links" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=100000,inputs.dim=100000" >> out.txt

echo "Running for 1000000 links" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=1000000,inputs.dim=1000000" >> out.txt

echo "Running for 10000000 links" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=10000000,inputs.dim=10000000" >> out.txt

echo "Running for 100000000 links" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=100000000,inputs.dim=100000000" >> out.txt

echo "Running for 1000000000 links" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=1000000000,inputs.dim=1000000000" >> out.txt

echo "Running for 2000000000 links" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=2000000000,inputs.dim=2000000000" >> out.txt

echo "Running for 3000000000 links" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=3000000000,inputs.dim=3000000000" >> out.txt

echo "Running for 4000000000 links" >> out.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=4000000000,inputs.dim=4000000000" >> out.txt