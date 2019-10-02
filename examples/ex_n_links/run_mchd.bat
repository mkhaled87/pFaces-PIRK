del *.raw
del out.txt

pfaces -C -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -d 1 -p -co "method_choice=4" > out.txt

pause