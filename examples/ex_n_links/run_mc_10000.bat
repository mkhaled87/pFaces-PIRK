del *.raw
del out.txt

pfaces -C -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "method_choice=3,states.dim=10000,inputs.dim=10000,nsamples=5159688" > mc10000.txt

pause