del *.raw
del results_gb.txt

echo "Running for 1 links" >> results_gb.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=10,inputs.dim=10" >> results_gb.txt

echo "Running for 100 links" >> results_gb.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=100,inputs.dim=100" >> results_gb.txt

echo "Running for 1000 links" >> results_gb.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=1000,inputs.dim=1000" >> results_gb.txt

echo "Running for 10000 links" >> results_gb.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=10000,inputs.dim=10000" >> results_gb.txt

echo "Running for 100000 links" >> results_gb.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=100000,inputs.dim=100000" >> results_gb.txt

echo "Running for 1000000 links" >> results_gb.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=1000000,inputs.dim=1000000" >> results_gb.txt

echo "Running for 10000000 links" >> results_gb.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=10000000,inputs.dim=10000000" >> results_gb.txt

echo "Running for 100000000 links" >> results_gb.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=100000000,inputs.dim=100000000" >> results_gb.txt

echo "Running for 1000000000 links" >> results_gb.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=1000000000,inputs.dim=1000000000" >> results_gb.txt

echo "Running for 2000000000 links" >> results_gb.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=2000000000,inputs.dim=2000000000" >> results_gb.txt

echo "Running for 3000000000 links" >> results_gb.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=3000000000,inputs.dim=3000000000" >> results_gb.txt

echo "Running for 4000000000 links" >> results_gb.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,mem_efficient=true,method_choice=1,states.dim=4000000000,inputs.dim=4000000000" >> results_gb.txt