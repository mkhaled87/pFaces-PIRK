del *.raw
del out.txt

pfaces -C -k pirk.cpu@..\..\kernel-pack -cfg .\ex_n_link.cfg -v5 -d 1 -p > out.txt

pause