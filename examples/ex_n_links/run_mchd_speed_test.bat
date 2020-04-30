del *.raw
del results_mchd.txt

echo "Running for 1 links" >> results_mchd.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=10,inputs.dim=10,nsamples=2397" >> results_mchd.txt

echo "Running for 100 links" >> results_mchd.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=100,inputs.dim=100,nsamples=33177" >> results_mchd.txt

echo "Running for 1000 links" >> results_mchd.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=1000,inputs.dim=1000,nsamples=423866" >> results_mchd.txt

echo "Running for 10000 links" >> results_mchd.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=10000,inputs.dim=10000,nsamples=5159688" >> results_mchd.txt

echo "Running for 100000 links" >> results_mchd.txt
call pfaces -CG -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "save_result=false,method_choice=4,states.dim=100000,inputs.dim=100000,nsamples=60807220" >> results_mchd.txt