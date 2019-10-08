del *.raw
del results_mchd.txt

echo "Running for 1 links" >> results_mchd.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=10,inputs.dim=10" >> results_mchd.txt

echo "Running for 100 links" >> results_mchd.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=100,inputs.dim=100" >> results_mchd.txt

echo "Running for 1000 links" >> results_mchd.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=1000,inputs.dim=1000" >> results_mchd.txt

echo "Running for 10000 links" >> results_mchd.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=10000,inputs.dim=10000" >> results_mchd.txt

echo "Running for 100000 links" >> results_mchd.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=100000,inputs.dim=100000" >> results_mchd.txt

echo "Running for 1000000 links" >> results_mchd.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=1000000,inputs.dim=1000000" >> results_mchd.txt

echo "Running for 10000000 links" >> results_mchd.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=10000000,inputs.dim=10000000" >> results_mchd.txt

echo "Running for 100000000 links" >> results_mchd.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=100000000,inputs.dim=100000000" >> results_mchd.txt

echo "Running for 1000000000 links" >> results_mchd.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=1000000000,inputs.dim=1000000000" >> results_mchd.txt

echo "Running for 2000000000 links" >> results_mchd.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=2000000000,inputs.dim=2000000000" >> results_mchd.txt

echo "Running for 3000000000 links" >> results_mchd.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=3000000000,inputs.dim=3000000000" >> results_mchd.txt

echo "Running for 4000000000 links" >> results_mchd.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=4000000000,inputs.dim=4000000000" >> results_mchd.txt